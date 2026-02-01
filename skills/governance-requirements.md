---
name: governance-requirements
description: Compliance and governance requirements for data pipelines including PII protection, audit logging, access controls, and documentation standards. Use when implementing data governance controls or validating compliance.
---

# Governance Requirements

Essential governance and compliance requirements for all data engineering work.

## Data Classification

### Classification Levels

**Public**: No restrictions
- Aggregated statistics
- Public reference data
- Non-sensitive metadata
- Example: Total customer count by country

**Internal**: Company confidential
- Business metrics
- Internal reports
- Aggregated customer data
- Example: Monthly revenue by product line

**Sensitive**: Requires access controls
- Customer names
- Transaction details
- Business-sensitive data
- Example: Individual customer purchase history

**Restricted**: Strict PII/PHI protection
- Email addresses
- Phone numbers
- Financial account numbers
- Health records
- Example: Customer email, credit card numbers

### Classification Marking
```sql
-- Add classification to table comments
COMMENT ON TABLE curated.customers IS 
'Customer data with PII masked. Classification: SENSITIVE. 
Owner: Data Engineering. 
Retention: 2 years.';
```

## PII Protection Requirements

### Required PII Masking
All PII must be masked/redacted in curated and analytics layers:

| PII Type | Protection Method | Example |
|----------|-------------------|---------|
| Email | SHA256 hash with salt | test@example.com → a3f2c1... |
| Phone | Redact to last 4 digits | 123-456-7890 → XXX-XXX-7890 |
| SSN/NI | Remove entirely or hash | 123-45-6789 → *** or hashed |
| Address | Remove or anonymize | 123 Main St → City level only |
| Credit Card | Last 4 digits only | 1234-5678-9012-3456 → ****-3456 |
| IP Address | Anonymize last octet | 192.168.1.100 → 192.168.1.0 |

### Masking Validation
```sql
-- Verify no email addresses in curated layer
SELECT COUNT(*) as email_violations
FROM curated.customers
WHERE email_token LIKE '%@%';
-- Expected: 0

-- Verify phone redaction format
SELECT COUNT(*) as phone_violations  
FROM curated.customers
WHERE phone_redacted NOT RLIKE '^XXX-XXX-[0-9]{4}$'
  AND phone_redacted IS NOT NULL;
-- Expected: 0
```

## Audit Trail Requirements

### Mandatory Audit Columns
Every curated table must include:
```sql
_audit_user STRING DEFAULT CURRENT_USER()
_audit_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
```

### Audit Logging
All data access must be logged:
```sql
CREATE TABLE audit.access_log (
    access_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    user_name STRING DEFAULT CURRENT_USER(),
    role_name STRING DEFAULT CURRENT_ROLE(),
    schema_name STRING,
    table_name STRING,
    query_id STRING,
    rows_accessed NUMBER
);
```

### Audit Retention
- Access logs: 7 years minimum
- Modification logs: 7 years minimum  
- Deletion logs: Indefinite retention
- Security events: Indefinite retention

## Access Control Requirements

### Role-Based Access Control (RBAC)
```
SYSADMIN
  └── DATA_ENGINEER
        ├── MARKETING_ANALYST
        │     └── BUSINESS_USER
        └── FINANCE_ANALYST
              └── BUSINESS_USER
```

### Access Levels by Layer
- **Raw layer**: DATA_ENGINEER only (contains PII)
- **Curated layer**: ANALYST roles (PII masked)
- **Analytics layer**: BUSINESS_USER and above (aggregated)

### Service Accounts
- Use dedicated service accounts for ETL processes
- Rotate credentials quarterly
- Store credentials in AWS Secrets Manager / Azure Key Vault
- Never hardcode credentials in code

## Data Retention Requirements

### Retention Policies
| Data Layer | Retention Period | Deletion Method |
|------------|------------------|-----------------|
| Raw (PII) | 30 days | Automated Snowflake task |
| Curated | 2 years | Automated Snowflake task |
| Analytics | 5 years | Manual review + task |
| Audit logs | 7 years | Automated task |

### Implementation
```sql
-- Automated deletion task
CREATE TASK curated.delete_expired_raw_data
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 2 * * * UTC'
AS
DELETE FROM raw.customer_data
WHERE loaded_at < DATEADD(day, -30, CURRENT_TIMESTAMP());

ALTER TASK curated.delete_expired_raw_data RESUME;
```

## Encryption Requirements

### Encryption at Rest
- Snowflake default encryption (AES-256)
- Verify: All data encrypted automatically

### Encryption in Transit
- SSL/TLS for all connections
- Minimum TLS 1.2
- Verify: Connection string includes `ssl=true`

### Key Management
- Snowflake manages encryption keys by default
- For customer-managed keys: Use Tri-Secret Secure
- Key rotation: Automatic

## Privacy Compliance

### GDPR Requirements
- **Lawful basis**: Document processing justification
- **Data minimisation**: Collect only necessary data
- **Purpose limitation**: Use data only for stated purpose
- **Storage limitation**: Implement retention policies
- **Data subject rights**:
  - Right to access
  - Right to rectification  
  - Right to erasure
  - Right to data portability

### GDPR Implementation
```markdown
## GDPR Compliance Checklist

- [ ] Lawful basis documented (e.g., Article 6(1)(f) legitimate interest)
- [ ] Privacy notice updated to include data usage
- [ ] Data minimisation applied (only necessary fields collected)
- [ ] Purpose documented in system
- [ ] Retention policy defined and enforced
- [ ] Deletion process documented for data subject requests
- [ ] Data export capability for portability requests
```

## Data Quality Requirements

### Minimum Thresholds
- **Completeness**: >95% for critical fields
- **Accuracy**: >99% for validated fields
- **Uniqueness**: 100% for primary keys
- **Timeliness**: Data <24 hours old for daily refreshes

### Quality Validation
```sql
-- Completeness check
SELECT 
    COUNT(*) as total,
    COUNT(customer_id) as has_customer_id,
    COUNT(customer_id)::FLOAT / COUNT(*) as completeness
FROM curated.customers;
-- Expected: >0.99

-- Uniqueness check
SELECT 
    COUNT(*) as total,
    COUNT(DISTINCT customer_id) as unique_ids,
    COUNT(*) - COUNT(DISTINCT customer_id) as duplicates
FROM curated.customers;
-- Expected: duplicates = 0
```

## Documentation Requirements

### Required Documentation
Every story must include:
1. **Data lineage diagram**: Source → Transformation → Destination
2. **PII handling documentation**: What PII exists and how it's protected
3. **Access control documentation**: Who can access what data
4. **Retention policy**: How long data is kept and deletion process
5. **Data quality thresholds**: Expected quality levels

### Architecture Decision Records (ADR)
Document significant technical decisions:
```markdown
# ADR-001: PII Masking Strategy

**Status**: Approved
**Date**: 2024-01-15

## Context
Customer pipeline contains PII that must be protected per GDPR.

## Decision  
Use SHA256 hashing with salt for deterministic email masking.

## Consequences
+ GDPR compliant pseudonymisation
+ Enables analytics without PII exposure
- Cannot reverse tokens to original emails

## Implementation
Salt stored in AWS Secrets Manager, rotated quarterly.
```

## Compliance Testing

### PII Protection Tests
```python
def test_no_pii_in_curated_layer():
    """Verify no actual PII in curated layer."""
    result = snowflake_query("""
        SELECT COUNT(*) as violations
        FROM curated.customers
        WHERE email_token LIKE '%@%'
           OR phone_redacted NOT RLIKE '^XXX-XXX-[0-9]{4}$'
    """)
    assert result['violations'] == 0, "PII detected in curated layer"
```

### Access Control Tests
```sql
-- Test: Raw layer restricted to DATA_ENGINEER
SHOW GRANTS ON SCHEMA raw;
-- Verify: Only DATA_ENGINEER and SYSADMIN have access

-- Test: Unauthorised access blocked
USE ROLE BUSINESS_USER;
SELECT * FROM raw.customer_data;  
-- Expected: Access denied
```

### Audit Trail Tests
```sql
-- Test: Audit columns populated
SELECT COUNT(*) as missing_audit
FROM curated.customers
WHERE _audit_user IS NULL 
   OR _audit_timestamp IS NULL;
-- Expected: 0

-- Test: Audit logs captured
SELECT COUNT(*) as log_entries
FROM audit.access_log
WHERE access_timestamp > DATEADD(hour, -1, CURRENT_TIMESTAMP());
-- Expected: >0 if any access occurred
```

## Product Delivery Log (PDL)

### PDL Template
```markdown
# Sprint [N] Product Delivery Log

## Data Privacy Compliance
- [ ] PII fields identified and documented
- [ ] PII masking/redaction implemented
- [ ] Privacy impact assessment completed (if high-risk processing)
- [ ] Data subject rights process documented

## Security Controls
- [ ] Access controls implemented (RBAC)
- [ ] Encryption verified (at rest and in transit)
- [ ] Service account credentials secured
- [ ] Network security controls applied

## Audit & Compliance
- [ ] Audit logging implemented for all data access
- [ ] Audit columns added to all curated tables
- [ ] Data retention policies defined and coded
- [ ] Data lineage documented

## Testing Evidence
- [ ] PII masking tests: PASSED
- [ ] Access control tests: PASSED
- [ ] Data quality tests: PASSED
- [ ] Audit trail tests: PASSED

## Documentation
- [ ] Data lineage diagram created
- [ ] Privacy notice updated
- [ ] Runbook created for operations
- [ ] Compliance evidence archived
```

## Governance Metrics

Track compliance:
```markdown
## Governance Dashboard

**PII Violations**: 0 (Target: 0)
**Access Control Violations**: 0 (Target: 0)
**Audit Log Gaps**: 0 (Target: 0)
**Data Quality Failures**: 1 (Target: 0)
**Documentation Completeness**: 95% (Target: 100%)
**Retention Policy Compliance**: 100% (Target: 100%)
```

## Escalation Criteria

Escalate to Product Owner if:
- Potential PII exposure detected
- Access control violations discovered
- Audit trail gaps identified
- Regulatory requirements unclear
- Retention policy conflicts with business needs
- Data breach suspected

## Best Practices

1. **Default deny**: Start with no access, grant as needed
2. **Least privilege**: Grant minimum necessary permissions
3. **Defence in depth**: Multiple layers of security
4. **Audit everything**: Log all access and modifications
5. **Automate compliance**: Use code for retention, testing
6. **Document decisions**: Maintain ADRs for governance choices
7. **Test governance controls**: Verify PII protection actually works
8. **Regular reviews**: Quarterly access reviews, annual policy reviews
9. **Incident response**: Have plan for potential data breaches
10. **Continuous monitoring**: Alert on governance violations