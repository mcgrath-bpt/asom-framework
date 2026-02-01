---
name: audit-logging
description: Audit trail requirements and implementation patterns for compliance. Covers what to log, retention policies, immutability, and query patterns. Essential for Governance Agent to validate audit completeness and for Dev Agent to implement logging.
---

# Audit Logging

## Overview

Audit logging creates an immutable record of who did what, when, where, and why. This is critical for compliance (GDPR, SOX, HIPAA), security investigations, and operational troubleshooting.

## Audit Trail Requirements

### The Five W's of Audit Logging

Every audit record must capture:

1. **WHO** - User or system that performed the action
2. **WHAT** - Action that was performed
3. **WHEN** - Timestamp of the action
4. **WHERE** - System/table/resource affected
5. **WHY** - Business context (optional but valuable)

### Minimum Audit Columns

**Every table with regulated data must have:**

```sql
CREATE TABLE customer (
    -- Business columns
    customer_id NUMBER PRIMARY KEY,
    email VARCHAR,
    -- ...
    
    -- REQUIRED AUDIT COLUMNS
    _audit_user VARCHAR NOT NULL,           -- WHO
    _audit_timestamp TIMESTAMP_NTZ NOT NULL, -- WHEN
    _audit_operation VARCHAR NOT NULL,       -- WHAT (INSERT/UPDATE/DELETE)
    
    -- OPTIONAL BUT RECOMMENDED
    _audit_session_id VARCHAR,               -- Session context
    _audit_source_system VARCHAR,            -- WHERE (which system)
    _audit_reason VARCHAR                    -- WHY (business reason)
);
```

---

## What to Log

### Always Log (Mandatory)

**Data Modifications:**
- INSERT operations (new records)
- UPDATE operations (changes to existing records)
- DELETE operations (record removal)
- MERGE operations (upserts)

**Access to Sensitive Data:**
- Queries accessing PII tables
- Data exports/downloads
- Report generation with personal data

**Security Events:**
- Login/logout
- Failed authentication attempts
- Permission changes
- Role assignments

**Configuration Changes:**
- Schema changes (DDL)
- Access control modifications
- Data retention policy changes

### Consider Logging (Situational)

**Business Operations:**
- Order placements
- Payment transactions
- Account status changes

**Data Quality Events:**
- Validation failures
- Data quality check results
- Pipeline failures

---

## Implementation Patterns

### Pattern 1: Audit Columns (Snowflake)

**Create table with audit columns:**

```sql
CREATE OR REPLACE TABLE customer_curated (
    customer_id NUMBER PRIMARY KEY,
    email_token VARCHAR,
    segment VARCHAR,
    lifetime_value NUMBER,
    
    -- Audit trail
    _audit_user VARCHAR NOT NULL DEFAULT CURRENT_USER(),
    _audit_timestamp TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    _audit_operation VARCHAR NOT NULL,
    _audit_source VARCHAR
);
```

**Insert with audit trail:**

```sql
INSERT INTO customer_curated (
    customer_id,
    email_token,
    segment,
    _audit_operation,
    _audit_source
)
SELECT
    customer_id,
    MASK_EMAIL(email) AS email_token,
    segment,
    'INSERT' AS _audit_operation,
    'customer_pipeline_v1' AS _audit_source
FROM customer_raw;

-- Audit columns auto-populated:
-- _audit_user: CURRENT_USER()
-- _audit_timestamp: CURRENT_TIMESTAMP()
```

**Update with audit trail:**

```sql
UPDATE customer_curated
SET
    segment = 'PREMIUM',
    _audit_user = CURRENT_USER(),
    _audit_timestamp = CURRENT_TIMESTAMP(),
    _audit_operation = 'UPDATE'
WHERE customer_id = 12345;
```

---

### Pattern 2: Separate Audit Table

**For high-volume changes or detailed history:**

```sql
-- Main table
CREATE TABLE customer (
    customer_id NUMBER PRIMARY KEY,
    email VARCHAR,
    segment VARCHAR,
    updated_at TIMESTAMP_NTZ
);

-- Audit/history table
CREATE TABLE customer_audit (
    audit_id NUMBER AUTOINCREMENT PRIMARY KEY,
    customer_id NUMBER,
    
    -- Changed values
    old_segment VARCHAR,
    new_segment VARCHAR,
    
    -- Audit columns
    audit_user VARCHAR NOT NULL,
    audit_timestamp TIMESTAMP_NTZ NOT NULL,
    audit_operation VARCHAR NOT NULL,
    audit_reason VARCHAR
);
```

**Trigger to populate audit table:**

```sql
-- Note: Snowflake doesn't support triggers,
-- Use Streams + Tasks instead

CREATE OR REPLACE STREAM customer_stream
    ON TABLE customer;

CREATE OR REPLACE TASK customer_audit_task
    WAREHOUSE = compute_wh
    SCHEDULE = '1 MINUTE'
WHEN
    SYSTEM$STREAM_HAS_DATA('customer_stream')
AS
    INSERT INTO customer_audit (
        customer_id,
        old_segment,
        new_segment,
        audit_user,
        audit_timestamp,
        audit_operation
    )
    SELECT
        customer_id,
        segment AS old_segment,  -- From stream metadata
        segment AS new_segment,
        CURRENT_USER(),
        CURRENT_TIMESTAMP(),
        METADATA$ACTION  -- INSERT/UPDATE/DELETE
    FROM customer_stream;

ALTER TASK customer_audit_task RESUME;
```

---

### Pattern 3: Python Implementation

**Audit logging in Python ETL:**

```python
import pandas as pd
from datetime import datetime
import getpass

class AuditLogger:
    """Add audit columns to DataFrames."""
    
    def __init__(self, source_system: str = "etl_pipeline"):
        self.user = getpass.getuser()
        self.source_system = source_system
    
    def add_audit_columns(
        self,
        df: pd.DataFrame,
        operation: str,
        reason: str = None
    ) -> pd.DataFrame:
        """
        Add audit columns to DataFrame.
        
        Args:
            df: DataFrame to audit
            operation: INSERT, UPDATE, DELETE, MERGE
            reason: Optional business reason
        
        Returns:
            DataFrame with audit columns
        """
        df = df.copy()
        
        df['_audit_user'] = self.user
        df['_audit_timestamp'] = datetime.utcnow()
        df['_audit_operation'] = operation
        df['_audit_source'] = self.source_system
        
        if reason:
            df['_audit_reason'] = reason
        
        return df

# Usage
auditor = AuditLogger(source_system="customer_pipeline_v1")

# Add audit columns to data
df_with_audit = auditor.add_audit_columns(
    df=customers_df,
    operation='INSERT',
    reason='Daily customer sync'
)

# Load to Snowflake with audit trail
df_with_audit.to_sql(
    'customer_curated',
    engine,
    if_exists='append',
    index=False
)
```

---

## Retention Policies

### Regulatory Requirements

**Minimum retention periods:**
- **GDPR**: 7 years for financial records
- **SOX**: 7 years for financial audit trails
- **HIPAA**: 6 years for health records
- **ISO 27001**: Varies by organization policy

**ASOM Default: 7 years for all audit logs**

### Implementation

**Snowflake retention with time travel:**

```sql
-- Enable time travel for audit table
ALTER TABLE customer_audit
    SET DATA_RETENTION_TIME_IN_DAYS = 90;  -- Max 90 days

-- For longer retention, use separate archive table
CREATE TABLE customer_audit_archive AS
SELECT * FROM customer_audit
WHERE audit_timestamp < DATEADD('year', -1, CURRENT_TIMESTAMP());

-- Then delete from active audit table
DELETE FROM customer_audit
WHERE audit_timestamp < DATEADD('year', -1, CURRENT_TIMESTAMP());
```

**Automated archival with tasks:**

```sql
CREATE OR REPLACE TASK archive_old_audit_logs
    WAREHOUSE = compute_wh
    SCHEDULE = 'USING CRON 0 2 * * SUN UTC'  -- Weekly on Sunday 2am
AS
BEGIN
    -- Archive logs older than 1 year to archive table
    INSERT INTO customer_audit_archive
    SELECT * FROM customer_audit
    WHERE audit_timestamp < DATEADD('year', -1, CURRENT_TIMESTAMP());
    
    -- Delete archived logs from active table
    DELETE FROM customer_audit
    WHERE audit_timestamp < DATEADD('year', -1, CURRENT_TIMESTAMP());
END;

ALTER TASK archive_old_audit_logs RESUME;
```

---

## Immutability

### Why Immutability Matters

Audit logs must be **tamper-proof** to be credible in investigations or compliance audits.

**Requirements:**
- No updates to audit records (INSERT-only)
- No deletes (except automated retention)
- Cryptographic verification (optional)

### Implementation

**Prevent updates/deletes:**

```sql
-- Revoke update/delete permissions on audit table
REVOKE UPDATE, DELETE ON customer_audit FROM ROLE analyst;
REVOKE UPDATE, DELETE ON customer_audit FROM ROLE developer;

-- Only DBA can delete for retention purposes
GRANT DELETE ON customer_audit TO ROLE dba;
```

**Append-only table:**

```sql
-- Use INSERT-only pattern
-- Never UPDATE or DELETE individual records

-- Bad
UPDATE customer_audit SET audit_reason = 'Updated reason';  -- Don't do this!

-- Good: Insert new record if correction needed
INSERT INTO customer_audit (
    customer_id,
    audit_timestamp,
    audit_operation,
    audit_reason
) VALUES (
    12345,
    CURRENT_TIMESTAMP(),
    'CORRECTION',
    'Correcting previous audit entry'
);
```

**Checksums for verification (advanced):**

```python
import hashlib

def calculate_audit_checksum(record: dict) -> str:
    """Calculate checksum of audit record for verification."""
    # Concatenate all fields in fixed order
    data = f"{record['customer_id']}{record['audit_user']}" \
           f"{record['audit_timestamp']}{record['audit_operation']}"
    
    return hashlib.sha256(data.encode()).hexdigest()

# Add checksum to audit record
record['audit_checksum'] = calculate_audit_checksum(record)

# Later: verify not tampered
assert calculate_audit_checksum(record) == record['audit_checksum']
```

---

## Query Patterns

### Who Changed This Record?

```sql
-- Find all changes to customer 12345
SELECT
    audit_timestamp,
    audit_user,
    audit_operation,
    old_segment,
    new_segment
FROM customer_audit
WHERE customer_id = 12345
ORDER BY audit_timestamp DESC;
```

### What Did This User Do?

```sql
-- Find all actions by user 'alice' in last 30 days
SELECT
    audit_timestamp,
    customer_id,
    audit_operation,
    audit_source
FROM customer_audit
WHERE audit_user = 'alice'
    AND audit_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())
ORDER BY audit_timestamp DESC;
```

### When Was This Table Last Updated?

```sql
-- Find last modification time
SELECT MAX(audit_timestamp) AS last_updated
FROM customer_audit
WHERE audit_operation IN ('INSERT', 'UPDATE');
```

### Audit Trail for Compliance

```sql
-- Generate audit report for compliance officer
SELECT
    DATE_TRUNC('day', audit_timestamp) AS audit_date,
    audit_user,
    audit_operation,
    COUNT(*) AS operation_count
FROM customer_audit
WHERE audit_timestamp BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;
```

### Detect Suspicious Activity

```sql
-- Find users with unusual delete activity
SELECT
    audit_user,
    COUNT(*) AS delete_count
FROM customer_audit
WHERE audit_operation = 'DELETE'
    AND audit_timestamp >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY audit_user
HAVING COUNT(*) > 100  -- Alert if >100 deletes in a week
ORDER BY delete_count DESC;
```

---

## Access Logging

### Query History in Snowflake

```sql
-- Snowflake automatically logs all queries
-- Access via QUERY_HISTORY view

SELECT
    query_text,
    user_name,
    role_name,
    start_time,
    end_time,
    execution_status,
    rows_produced
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE user_name = 'alice'
    AND start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;
```

### Log PII Access

```sql
-- Create view that logs access to PII
CREATE OR REPLACE VIEW customer_pii_logged AS
SELECT
    c.*,
    CURRENT_USER() AS accessed_by,
    CURRENT_TIMESTAMP() AS accessed_at
FROM customer_raw c;

-- Whenever someone queries this view, access is logged automatically
-- (Snowflake query history captures the view access)
```

---

## Testing Audit Completeness

### Governance Test: Audit Columns Present

```python
def test_audit_columns_present():
    """All curated tables must have audit columns."""
    df = load_curated_customers()
    
    required_columns = [
        '_audit_user',
        '_audit_timestamp',
        '_audit_operation'
    ]
    
    for col in required_columns:
        assert col in df.columns, f"Missing required audit column: {col}"
```

### Governance Test: No Null Audit Values

```python
def test_no_null_audit_values():
    """Audit columns must not have null values."""
    df = load_curated_customers()
    
    audit_columns = ['_audit_user', '_audit_timestamp', '_audit_operation']
    
    for col in audit_columns:
        null_count = df[col].isna().sum()
        assert null_count == 0, f"Found {null_count} nulls in {col}"
```

### Governance Test: Audit Timestamp Reasonable

```python
from datetime import datetime, timedelta

def test_audit_timestamp_reasonable():
    """Audit timestamps should be recent and not in future."""
    df = load_curated_customers()
    
    now = datetime.utcnow()
    one_year_ago = now - timedelta(days=365)
    
    timestamps = pd.to_datetime(df['_audit_timestamp'])
    
    # No timestamps in future
    future_count = (timestamps > now).sum()
    assert future_count == 0, f"Found {future_count} future timestamps"
    
    # All timestamps within last year (for fresh data)
    old_count = (timestamps < one_year_ago).sum()
    assert old_count == 0, f"Found {old_count} timestamps >1 year old"
```

---

## Snowflake-Specific Features

### Query Tags

```sql
-- Tag queries for audit purposes
ALTER SESSION SET QUERY_TAG = 'customer_pipeline_daily_load';

-- All subsequent queries will be tagged
INSERT INTO customer_curated ...;

-- Query tag appears in query history
SELECT query_tag, query_text
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_tag = 'customer_pipeline_daily_load';
```

### Object Change Tracking

```sql
-- Snowflake tracks all DDL changes automatically
SELECT
    object_name,
    object_type,
    created,
    last_altered,
    deleted
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
WHERE table_schema = 'CURATED'
ORDER BY last_altered DESC;
```

### Access History

```sql
-- See who accessed what tables
SELECT
    user_name,
    query_start_time,
    direct_objects_accessed,
    base_objects_accessed
FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY
WHERE query_start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY query_start_time DESC;
```

---

## Common Audit Logging Mistakes

### ❌ Don't: Use Local Timestamps

```python
# Bad: Local time (ambiguous)
df['audit_timestamp'] = datetime.now()

# Good: UTC time (unambiguous)
df['audit_timestamp'] = datetime.utcnow()
```

### ❌ Don't: Allow Null Audit Columns

```sql
-- Bad: Nullable audit columns
_audit_user VARCHAR,
_audit_timestamp TIMESTAMP_NTZ

-- Good: NOT NULL constraints
_audit_user VARCHAR NOT NULL,
_audit_timestamp TIMESTAMP_NTZ NOT NULL
```

### ❌ Don't: Update Audit Records

```sql
-- Bad: Modifying audit trail
UPDATE customer_audit
SET audit_reason = 'Corrected reason'
WHERE audit_id = 123;

-- Good: Insert correction record
INSERT INTO customer_audit (...)
VALUES (..., 'CORRECTION', 'Correcting previous entry');
```

### ❌ Don't: Delete Audit Logs Manually

```sql
-- Bad: Manual deletion
DELETE FROM customer_audit
WHERE audit_timestamp < '2020-01-01';

-- Good: Automated retention policy
CREATE TASK archive_old_logs ... ;
```

---

## Audit Logging Checklist

**For every table with regulated data:**

- [ ] Audit columns present (_audit_user, _audit_timestamp, _audit_operation)
- [ ] Audit columns NOT NULL
- [ ] Timestamps in UTC
- [ ] Operation values standardized (INSERT/UPDATE/DELETE/MERGE)
- [ ] Permissions prevent UPDATE/DELETE on audit tables
- [ ] Retention policy defined (7 years minimum)
- [ ] Automated archival task configured
- [ ] Access to audit logs restricted to authorized users
- [ ] Tests validate audit completeness

---

## Summary

**Audit Trail Requirements:**
- WHO: _audit_user
- WHAT: _audit_operation
- WHEN: _audit_timestamp (UTC)
- WHERE: _audit_source
- WHY: _audit_reason (optional)

**Implementation:**
- Add audit columns to all curated tables
- Use Snowflake Streams + Tasks for complex scenarios
- Python AuditLogger class for ETL pipelines

**Retention:**
- 7 years minimum (GDPR, SOX compliance)
- Automated archival with Snowflake tasks
- Immutable (INSERT-only, no updates/deletes)

**For ASOM:**
- All curated tables have audit columns
- Tests verify audit completeness
- Audit trail provides governance evidence
- Query history available for investigations

**Audit logs are not optional - they are mandatory for compliance and security.**
