# Governance Reference Appendix

> **Loaded on demand** when Governance Agent needs detailed control mappings, evidence templates, or verification checklists.

This file contains reference material extracted from `agents/GOVERNANCE-AGENT.md`. The core role definition, authority boundaries, and key workflows remain in the agent file. This appendix provides detailed examples, templates, and checklists for deep governance work.

---

## Control Verification Checklist

| Control | Objective | Typical Evidence |
|---------|-----------|------------------|
| **C-01** | Change authorisation | Approved CRQ, linked Jira scope |
| **C-02** | Separation of duties | Commit history, approval records, deployment logs |
| **C-03** | Requirements traceability | Jira stories, acceptance criteria, test references |
| **C-04** | Data classification & handling | Classification metadata, handling rules, validation tests |
| **C-05** | Access control & least privilege | RBAC policies, masking policies, access tests |
| **C-06** | Data quality controls | DQ rule definitions, DQ execution results |
| **C-07** | Reproducibility | Commit SHA, build config, parameter records |
| **C-08** | Incremental correctness | Incremental tests, re-run validation |
| **C-09** | Observability & alerting | Alert configuration, test alert triggers |
| **C-10** | Cost & performance guardrails | Baseline metrics, regression checks |
| **C-11** | Emergency override protocol | Override records, remediation evidence, post-incident reviews |

---

## PDL Impact Assessment Workflow — Detailed Examples

### When Epic is Created

**Governance Agent reviews epic and identifies PDL scope:**

```markdown
Epic: Customer Data Pipeline with PII Governance

PDL Impact Assessment:

INITIATION & GOVERNANCE:
├─ Project Charter → REFERENCED (ServiceNow Demand D-12345)
├─ Roadmap → PRODUCED (Issue tracker roadmap view)
└─ Risk Registry → UPDATE REQUIRED (new PII processing risk)
   └─ Action: Create task T001 for BA to update risk register

ARCHITECTURE & SECURITY:
├─ Architecture Handbook → UPDATE REQUIRED (new API integration)
│  └─ Action: Create task T002 for Dev to update architecture doc
├─ Security Assessment → REVIEW REQUIRED (PII processing)
│  └─ Action: Create task T003 for Governance to perform assessment
└─ Privacy Impact → REQUIRED (new PII fields)
   └─ Action: Create task T004 for Governance to complete DPIA

REQUIREMENTS:
├─ Functional Spec → PRODUCED (via story acceptance criteria)
└─ User Requirements → PRODUCED (via user stories)

TESTING:
├─ Test Strategy → REFERENCED (Master Test Strategy v2.1)
├─ IQ Evidence → PRODUCED (via automated tests in issue tracker)
├─ OQ Evidence → REQUIRED (business rule validation)
│  └─ Action: Create task T005 for QA to create OQ test plan
└─ Traceability Matrix → AUTO-GENERATED (from issue tracker)

RELEASE:
├─ Release Notes → REQUIRED (new pipeline)
│  └─ Action: Create task T007 for Dev to draft release notes
└─ Change Request → PRODUCED (when ready for PROD)

OPERATIONS:
├─ Operational Handbook → UPDATE REQUIRED (new monitoring)
│  └─ Action: Create task T006 for Dev to update ITOH
└─ Service Transition → EXEMPTION (approved for Data Mesh)

PDL Tasks Created: T001-T007
PDL Status: 36% complete (7 tasks to track)
```

**Result:** Governance creates 6 tracking tasks, assigns to appropriate agents

### When Story is Created

**Governance Agent reviews each story for PDL impacts:**

```markdown
Story: S001 - Extract customer data from REST API

PDL Impact Check:

Architecture Handbook: IMPACTED
├─ New API integration must be documented
├─ Check: T002 exists and assigned to Dev
└─ Status: Tracked

Functional Spec: COVERED
├─ Story acceptance criteria serve as functional spec
└─ Status: Complete (built into story)

IQ Tests: IMPACTED
├─ New code requires unit and integration tests
├─ Dev will create tests (TDD), QA will validate
└─ Status: Tracked (covered by TDD workflow)

OQ Tests: IMPACTED
├─ Business rule validation needed
├─ Check: T005 exists and assigned to QA
└─ Status: Tracked

ITOH: IMPACTED
├─ Operational procedures for API monitoring
├─ Check: T006 exists and assigned to Dev
└─ Status: Tracked

PDL Impact: All impacts tracked via tasks
Governance verification: No blocking gaps identified. Story can proceed.
```

**Result:** Governance confirms PDL impacts are tracked; story proceeds with tracked obligations

### During Development

**Governance Agent tracks PDL task completion and surfaces gaps:**

```markdown
Sprint Progress Check (Day 7/14):

PDL Task Status:
├─ T001: Risk register update → COMPLETE ✓
├─ T002: Architecture doc update → IN PROGRESS (Dev working)
├─ T003: Security assessment → COMPLETE ✓
├─ T004: Privacy impact assessment → COMPLETE ✓
├─ T005: OQ test plan → READY (QA to execute)
└─ T006: ITOH update → NOT STARTED ⚠️

PDL Completeness: 60%
Risk: T006 not started (could block PROD)
Action: Flag as impediment, Dev to prioritize
```

**Result:** Governance identifies PDL risks early, prevents last-minute blockers

### Before QA Deployment

**Governance Agent performs PDL Gate Review:**

```markdown
QA Deployment Gate Review for Sprint 1

REQUIREMENTS:
✓ All user stories have acceptance criteria (Functional Spec)
✓ Stories approved via workflow

TESTING:
✓ IQ evidence exists (pytest results, 87% coverage)
✓ OQ test plan executed (T005 complete)
✓ Traceability matrix generated from issue tracker

ARCHITECTURE:
✓ Architecture Handbook updated (T002 complete)
✓ Confluence page current and reviewed

RELEASE:
✓ Release notes drafted (T007 complete)

OPERATIONS:
⚠️ ITOH not yet updated (T006 incomplete)

COMPLIANCE:
✓ PII masking validated
✓ Audit logging verified
✓ Access controls tested

PDL Status: 85% complete
BLOCKING ITEM: T006 (ITOH update)

VERIFICATION STATUS: Incomplete
REASON: Operational procedures required for QA testing (T006 outstanding)
RECOMMENDATION: Do not proceed with QA promotion until T006 complete
Human approval required for promotion via ServiceNow CRQ
```

**Result:** Governance surfaces incomplete items; human decides whether to proceed or wait

### After PDL Items Complete

**Governance Agent re-checks completeness and publishes verification report:**

```markdown
QA Deployment Verification Report - RETRY

OPERATIONS:
✓ ITOH updated with API monitoring procedures (T006 complete)
✓ Runbook includes troubleshooting steps

PDL Status: 100% complete
All governance requirements verified

VERIFICATION STATUS: Complete
All applicable controls have evidence in the Evidence Ledger
Human approval required for promotion via ServiceNow CRQ
```

**Result:** Governance verification complete; human reviews report and approves promotion via ServiceNow

### Before PROD Deployment

**Governance Agent performs final verification (G4 gate awareness):**

```markdown
PROD Deployment Verification Report

RE-VALIDATION (changes since QA):
✓ No architecture changes in QA
✓ No new functionality added
✓ PDL items still current

PROD-SPECIFIC CHECKS (G4 gate requirements):
✓ IQ evidence for PROD environment (tests executed in PROD-like)
✓ Change Request created (CRQ state checked)
✓ Release notes finalised and published
✓ Rollback procedures documented
✓ PROD access controls configured (C-05)
✓ Observability and alerting configured (C-09)
✓ Cost/performance guardrails checked (C-10)

CONTROL COVERAGE:
✓ All PII controls verified in QA (C-04)
✓ Audit trail complete (C-07)
✓ Data retention policies configured
✓ Separation of duties validated (C-02)
✓ No compliance violations detected

PDL Status: 100% complete and verified
All artefacts audit-ready

VERIFICATION STATUS: Complete
Human approval required for PROD promotion via ServiceNow CRQ
```

**Result:** Governance verification complete; human Release Approver reviews and authorises PROD promotion

---

## Governance Standards — Templates

### Product Delivery Log (PDL) Template
```markdown
# Product Delivery Log: [Sprint ID] - [Sprint Goal]

**Sprint Duration**: [Start Date] - [End Date]
**Product Owner**: [Name]
**Governance Owner**: [Governance Agent]

## Sprint Scope
[Brief description of sprint goal and key deliverables]

## Governance Requirements
### Data Privacy
- [ ] PII handling requirements identified for all stories
- [ ] Data classification applied to all datasets
- [ ] Privacy impact assessment completed (if applicable)
- [ ] Consent and lawful basis documented (if applicable)

### Security Controls
- [ ] Access controls defined and implemented
- [ ] Encryption requirements identified and met
- [ ] Service account security validated
- [ ] Network security controls applied

### Audit & Compliance
- [ ] Audit logging implemented for all data access
- [ ] Data retention policies defined and coded
- [ ] Data lineage documented
- [ ] Regulatory requirements mapped to controls

### Documentation
- [ ] Architecture decisions documented
- [ ] Data dictionaries created/updated
- [ ] Runbooks created for operations
- [ ] Compliance evidence collected

## Stories & Governance Status
| Story ID | Title | Data Classification | Governance Status |
|----------|-------|---------------------|-------------------|
| S001 | Customer data ingestion | Restricted (PII) | ✅ Verified Complete |
| S002 | Sales analytics dashboard | Internal | ✅ Verified Complete |

## Risks & Issues
| ID | Description | Severity | Status | Mitigation |
|----|-------------|----------|--------|------------|
| R001 | PII retention period unclear | Medium | Open | Escalated to PO |

## Compliance Evidence
- Data flow diagrams: [Link to documentation]
- PII protection test results: [Link to test reports]
- Access control validation: [Link to test evidence]
- Audit log samples: [Link to log exports]

## Verification Status
- [ ] All governance requirements verified
- [ ] All stories include compliance controls
- [ ] Documentation complete and audit-ready
- [ ] No open critical or major governance issues
- [ ] Evidence Ledger entries exist for all applicable controls

**Governance Agent Verification**: [Timestamp] -- VERIFICATION STATUS: Complete / Incomplete
**Human Approval Required**: Release Approver sign-off via ServiceNow CRQ
```

### Governance Checklist for Stories
```markdown
## Governance Checklist: [Story ID] - [Story Title]

**Data Classification**: Public | Internal | Sensitive | Restricted

### If Restricted (PII/PHI):
- [ ] PII fields identified (list: email, phone, SSN, etc.)
- [ ] Masking/tokenisation method defined
- [ ] Redaction approach specified
- [ ] Access controls for raw PII defined
- [ ] Privacy impact assessment completed
- [ ] Lawful basis for processing documented
- [ ] Data subject rights process defined (deletion, portability)

### Audit Trail:
- [ ] _audit_user column in all curated tables
- [ ] _audit_timestamp column in all curated tables
- [ ] Data access logging enabled
- [ ] Data modification logging enabled
- [ ] Audit log retention: 7 years minimum
- [ ] Audit log integrity protection enabled

### Access Controls:
- [ ] Roles defined (who needs access)
- [ ] Least privilege principle applied
- [ ] Raw layer restricted to DATA_ENGINEER
- [ ] Curated layer accessible to defined business roles
- [ ] Analytics layer accessible to broader audience
- [ ] Service account credentials secured (not in code)
- [ ] Access review process defined (quarterly)

### Data Retention:
- [ ] Retention period defined for raw data
- [ ] Retention period defined for curated data
- [ ] Retention period defined for analytics data
- [ ] Automated deletion jobs scheduled
- [ ] Deletion testing completed
- [ ] Legal hold process defined

### Security:
- [ ] Data encrypted at rest (Snowflake default)
- [ ] Data encrypted in transit (SSL/TLS)
- [ ] No hardcoded secrets or credentials
- [ ] API keys stored securely
- [ ] Database credentials rotated regularly
- [ ] Network security controls applied

### Documentation:
- [ ] Data lineage diagram created
- [ ] Data dictionary updated
- [ ] Privacy notice updated (if customer-facing)
- [ ] Compliance evidence documented
- [ ] Runbook created for operations
```

---

## Data Lineage Documentation Example
```markdown
# Data Lineage: Customer Data Pipeline

## Source Systems
**System**: Customer API (REST)
- **Endpoint**: https://api.example.com/v1/customers
- **Authentication**: API key (rotated quarterly)
- **Data Classification**: Restricted (contains PII)
- **Update Frequency**: Daily at 02:00 UTC
- **Data Volume**: ~1M records/day
- **PII Fields**: email, phone, billing_address

## Data Flow
- Source API
  → Python extraction script (src/extract/customers.py)
  → S3 landing zone (s3://data-lake/raw/customers/YYYY-MM-DD/)
  → Snowflake COPY INTO raw.customer_data (VARIANT)
  → dbt transformation with PII masking
  → Snowflake curated.customers (structured, PII masked)
  → dbt analytics models
  → Snowflake analytics.customer_segments (aggregated, no PII)

## Transformations & Controls
**Raw → Curated** (silver layer):
- Schema parsing from VARIANT to typed columns
- PII masking:
  - email → SHA256 hash with salt
  - phone → redacted to last 4 digits
  - address → removed entirely
- Data quality checks:
  - Required fields populated (>99%)
  - Valid email format (100%)
  - No duplicate customer_ids
- Audit columns added (_audit_user, _audit_timestamp)

**Curated → Analytics** (gold layer):
- Aggregation to segment level (no individual records)
- Business logic for segmentation
- Performance optimisation (materialised views)

## Access Controls
- **Raw layer** (raw.customer_data): DATA_ENGINEER role only
- **Curated layer** (curated.customers): MARKETING_ANALYST, DATA_ANALYST
- **Analytics layer** (analytics.*): BUSINESS_USER, EXECUTIVE

## Retention Policies
- **Raw layer**: 30 days (automated deletion via Snowflake task)
- **Curated layer**: 2 years (compliance requirement)
- **Analytics layer**: 5 years (business requirement)

## Compliance Notes
- GDPR Article 6(1)(f): Legitimate interest for customer analytics
- Data subject rights: Deletion process via support ticket → DATA_ENGINEER manual action
- Privacy notice: Updated 2024-01-15 to include analytics use
```

---

## Compliance Testing Examples

### PII Protection Validation
```sql
-- Test 1: Verify no email addresses in curated layer
SELECT
    'No email addresses in curated layer' as test_name,
    COUNT(*) as violations
FROM curated.customers
WHERE email_token LIKE '%@%';
-- Expected: 0 violations

-- Test 2: Verify phone number redaction
SELECT
    'Phone numbers properly redacted' as test_name,
    COUNT(*) as violations
FROM curated.customers
WHERE phone_redacted NOT RLIKE '^XXX-XXX-[0-9]{4}$'
  AND phone_redacted IS NOT NULL;
-- Expected: 0 violations

-- Test 3: Verify no PII in analytics layer
SELECT
    'No PII fields in analytics views' as test_name,
    COUNT(*) as violations
FROM information_schema.columns
WHERE table_schema = 'ANALYTICS'
  AND column_name IN ('EMAIL', 'PHONE', 'SSN', 'ADDRESS', 'EMAIL_TOKEN');
-- Expected: 0 violations
```

### Audit Trail Validation
```sql
-- Test 1: Audit columns populated
SELECT
    'Audit columns populated' as test_name,
    COUNT(*) as total_records,
    COUNT(_audit_user) as has_user,
    COUNT(_audit_timestamp) as has_timestamp,
    CASE
        WHEN COUNT(_audit_user) = COUNT(*)
         AND COUNT(_audit_timestamp) = COUNT(*)
        THEN 'PASS'
        ELSE 'FAIL'
    END as status
FROM curated.customers;

-- Test 2: Audit log retention
SELECT
    'Audit logs retained 7 years' as test_name,
    MIN(audit_timestamp) as oldest_log,
    DATEDIFF('day', MIN(audit_timestamp), CURRENT_TIMESTAMP()) as retention_days,
    CASE WHEN DATEDIFF('day', MIN(audit_timestamp), CURRENT_TIMESTAMP()) >= 2555
         THEN 'PASS' ELSE 'CHECK'
    END as status
FROM audit.access_log;
```

### Access Control Validation
```sql
-- Test 1: Raw layer access restricted
SHOW GRANTS ON SCHEMA raw;
-- Manually verify: Only DATA_ENGINEER and SYSADMIN have access

-- Test 2: Curated layer access appropriate
SHOW GRANTS ON SCHEMA curated;
-- Verify: MARKETING_ANALYST has SELECT only, not INSERT/UPDATE/DELETE

-- Test 3: Service account least privilege
SHOW GRANTS TO ROLE ETL_SERVICE_ACCOUNT;
-- Verify: Only necessary permissions granted
```

---

## Architecture Decision Record (ADR) Template
```markdown
# ADR-001: PII Masking Strategy for Customer Data

**Status**: Verified
**Date**: 2024-01-15
**Proposed By**: Governance Agent
**Decision Maker**: Human Governance/Quality Lead
**Stakeholders**: Dev Agent, QA Agent, Product Owner

## Context
Customer data pipeline contains PII (email, phone) that must be protected per GDPR while maintaining analytical utility.

## Decision
Use deterministic SHA256 hashing with salt for email addresses to enable:
- Consistent tokenisation (same email → same token)
- Ability to join across tables
- Prevention of reverse lookup
- Compliance with GDPR pseudonymisation requirements

Use redaction for phone numbers (XXX-XXX-1234) as phone analytics not required.

## Alternatives Considered
1. **Random tokenisation**: Rejected - breaks joins across tables
2. **Format-preserving encryption**: Rejected - adds complexity and key management burden
3. **Removal entirely**: Rejected - prevents customer analytics use cases

## Consequences
**Positive**:
- GDPR compliant pseudonymisation
- Enables analytics without PII exposure
- Simple to implement and test

**Negative**:
- Cannot reverse tokens to original emails (by design)
- Requires secure salt management
- Small risk of hash collisions (mitigated by SHA256 strength)

## Compliance Notes
- GDPR Article 32: Security of processing (pseudonymisation)
- Salt stored in AWS Secrets Manager, rotated quarterly
- Hash algorithm documented for audit purposes

## Implementation
- Library: hashlib (Python standard library)
- Salt: 32-byte random, stored securely
- Verified by: Test suite in tests/integration/test_pii_masking.py
```
