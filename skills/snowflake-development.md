---
name: snowflake-development
description: Snowflake best practices for DDL, DML, optimization, and security. Use when designing schemas, writing SQL, implementing access controls, or optimizing Snowflake performance.
---

# Snowflake Development

Best practices for building production-quality data solutions in Snowflake.

## Medallion Architecture

Implement Bronze → Silver → Gold pattern:

```sql
-- Bronze (Raw) Layer
CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE IF NOT EXISTS raw.customer_data (
    raw_json VARIANT,
    source_file STRING,
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _metadata OBJECT COMMENT 'Audit metadata'
);

-- Silver (Curated) Layer
CREATE SCHEMA IF NOT EXISTS curated;

CREATE TABLE IF NOT EXISTS curated.customers (
    customer_id NUMBER PRIMARY KEY,
    email_token STRING COMMENT 'SHA256 hash of email for PII protection',
    phone_redacted STRING COMMENT 'Redacted phone number (XXX-XXX-1234)',
    first_name STRING,
    last_name STRING,
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ,
    _audit_user STRING DEFAULT CURRENT_USER(),
    _audit_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Gold (Analytics) Layer
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE VIEW analytics.customer_segments AS
SELECT 
    segment,
    COUNT(*) as customer_count,
    AVG(lifetime_value) as avg_ltv,
    MIN(created_at) as earliest_customer,
    MAX(created_at) as latest_customer
FROM curated.customers
GROUP BY segment;
```

## PII Protection

### Masking Functions
```sql
-- Create masking function for emails
CREATE OR REPLACE FUNCTION curated.mask_email(email STRING, salt STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    if (!EMAIL) return null;
    var crypto = require('crypto');
    var hash = crypto.createHash('sha256');
    hash.update(EMAIL.toLowerCase() + SALT);
    return hash.digest('hex');
$$;

-- Create redaction function for phones
CREATE OR REPLACE FUNCTION curated.redact_phone(phone STRING)
RETURNS STRING
AS $$
    CASE 
        WHEN phone IS NULL THEN NULL
        WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) < 4 THEN 'XXX-XXX-XXXX'
        ELSE 'XXX-XXX-' || RIGHT(REGEXP_REPLACE(phone, '[^0-9]', ''), 4)
    END
$$;

-- Use in transformation
INSERT INTO curated.customers (customer_id, email_token, phone_redacted, first_name, last_name, created_at)
SELECT 
    raw_json:customer_id::NUMBER,
    curated.mask_email(raw_json:email::STRING, 'your-salt-here'),
    curated.redact_phone(raw_json:phone::STRING),
    raw_json:first_name::STRING,
    raw_json:last_name::STRING,
    raw_json:created_at::TIMESTAMP_NTZ
FROM raw.customer_data;
```

### Row-Level Security
```sql
-- Create row access policy for sensitive data
CREATE OR REPLACE ROW ACCESS POLICY curated.customer_row_policy
AS (customer_segment STRING) RETURNS BOOLEAN ->
    CASE 
        WHEN CURRENT_ROLE() IN ('SYSADMIN', 'DATA_ENGINEER') THEN TRUE
        WHEN CURRENT_ROLE() = 'MARKETING_ANALYST' AND customer_segment = 'MARKETING_APPROVED' THEN TRUE
        ELSE FALSE
    END;

-- Apply policy to table
ALTER TABLE curated.customers 
ADD ROW ACCESS POLICY curated.customer_row_policy ON (segment);
```

## Access Control (RBAC)

```sql
-- Create roles hierarchy
CREATE ROLE IF NOT EXISTS DATA_ENGINEER;
CREATE ROLE IF NOT EXISTS MARKETING_ANALYST;
CREATE ROLE IF NOT EXISTS BUSINESS_USER;

-- Grant role hierarchy
GRANT ROLE MARKETING_ANALYST TO ROLE DATA_ENGINEER;
GRANT ROLE BUSINESS_USER TO ROLE MARKETING_ANALYST;

-- Raw layer: DATA_ENGINEER only
GRANT USAGE ON SCHEMA raw TO ROLE DATA_ENGINEER;
GRANT SELECT ON ALL TABLES IN SCHEMA raw TO ROLE DATA_ENGINEER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA raw TO ROLE DATA_ENGINEER;

-- Curated layer: MARKETING_ANALYST and above
GRANT USAGE ON SCHEMA curated TO ROLE MARKETING_ANALYST;
GRANT SELECT ON ALL TABLES IN SCHEMA curated TO ROLE MARKETING_ANALYST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA curated TO ROLE MARKETING_ANALYST;

-- Analytics layer: BUSINESS_USER and above
GRANT USAGE ON SCHEMA analytics TO ROLE BUSINESS_USER;
GRANT SELECT ON ALL VIEWS IN SCHEMA analytics TO ROLE BUSINESS_USER;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA analytics TO ROLE BUSINESS_USER;

-- Warehouse access
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE DATA_ENGINEER;
GRANT USAGE ON WAREHOUSE ANALYTICS_WH TO ROLE MARKETING_ANALYST;
```

## Data Retention & Cleanup

```sql
-- Create task for data retention
CREATE OR REPLACE TASK curated.cleanup_old_raw_data
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 2 * * * UTC'  -- Daily at 2 AM UTC
AS
DELETE FROM raw.customer_data
WHERE loaded_at < DATEADD(day, -30, CURRENT_TIMESTAMP());

-- Enable task
ALTER TASK curated.cleanup_old_raw_data RESUME;

-- Create task for archived data retention
CREATE OR REPLACE TASK curated.cleanup_archived_customers
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 3 * * SUN UTC'  -- Weekly on Sunday at 3 AM
AS
DELETE FROM curated.customers_archive
WHERE archived_at < DATEADD(year, -2, CURRENT_TIMESTAMP());

ALTER TASK curated.cleanup_archived_customers RESUME;

-- Verify tasks
SHOW TASKS IN SCHEMA curated;
```

## Audit Logging

```sql
-- Create audit table
CREATE TABLE IF NOT EXISTS audit.access_log (
    access_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    user_name STRING DEFAULT CURRENT_USER(),
    role_name STRING DEFAULT CURRENT_ROLE(),
    query_id STRING DEFAULT CURRENT_TRANSACTION(),
    query_text STRING,
    schema_name STRING,
    table_name STRING,
    rows_accessed NUMBER
);

-- Create logging procedure
CREATE OR REPLACE PROCEDURE audit.log_access(
    schema_name STRING,
    table_name STRING,
    query_text STRING,
    rows_accessed NUMBER
)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    var sql = `
        INSERT INTO audit.access_log (schema_name, table_name, query_text, rows_accessed)
        VALUES (?, ?, ?, ?)
    `;
    snowflake.execute({
        sqlText: sql,
        binds: [SCHEMA_NAME, TABLE_NAME, QUERY_TEXT, ROWS_ACCESSED]
    });
    return 'Logged';
$$;

-- Query audit logs
SELECT 
    access_timestamp,
    user_name,
    role_name,
    schema_name || '.' || table_name as full_table_name,
    rows_accessed
FROM audit.access_log
WHERE access_timestamp > DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY access_timestamp DESC;
```

## Performance Optimization

### Clustering
```sql
-- Add clustering for query performance
ALTER TABLE curated.customers 
CLUSTER BY (created_at, customer_id);

-- Check clustering depth
SELECT SYSTEM$CLUSTERING_INFORMATION('curated.customers');

-- Monitor clustering efficiency
SELECT 
    table_name,
    clustering_key,
    AVERAGE_DEPTH,
    AVERAGE_OVERLAPS
FROM TABLE(INFORMATION_SCHEMA.CLUSTERING_INFORMATION(
    TABLE_NAME => 'CURATED.CUSTOMERS'
));
```

### Materialized Views
```sql
-- Create materialized view for expensive aggregations
CREATE MATERIALIZED VIEW analytics.daily_customer_metrics AS
SELECT 
    DATE_TRUNC('day', created_at) as date,
    segment,
    COUNT(*) as new_customers,
    AVG(lifetime_value) as avg_ltv
FROM curated.customers
GROUP BY DATE_TRUNC('day', created_at), segment;

-- Refresh materialized view
ALTER MATERIALIZED VIEW analytics.daily_customer_metrics REFRESH;
```

### Query Optimization
```sql
-- Use result caching
ALTER SESSION SET USE_CACHED_RESULT = TRUE;

-- Partition large operations
-- Bad: Full table scan
SELECT * FROM large_table WHERE created_at > '2024-01-01';

-- Good: Partition pruning
SELECT * FROM large_table 
WHERE created_at BETWEEN '2024-01-01' AND '2024-01-31';

-- Use LIMIT for exploration
SELECT * FROM large_table LIMIT 1000;

-- Check query profile
SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE QUERY_ID = 'your-query-id'
ORDER BY START_TIME DESC;
```

## Data Quality Constraints

```sql
-- Add NOT NULL constraints
ALTER TABLE curated.customers 
MODIFY COLUMN customer_id SET NOT NULL;

ALTER TABLE curated.customers
MODIFY COLUMN email_token SET NOT NULL;

-- Add check constraints
ALTER TABLE curated.customers
ADD CONSTRAINT valid_email_token 
CHECK (LENGTH(email_token) = 64);  -- SHA256 hash length

ALTER TABLE curated.customers
ADD CONSTRAINT valid_phone_format
CHECK (phone_redacted RLIKE '^XXX-XXX-[0-9]{4}$' OR phone_redacted IS NULL);

-- Add unique constraints
ALTER TABLE curated.customers
ADD CONSTRAINT unique_customer_id UNIQUE (customer_id);

-- Verify constraints
SHOW CONSTRAINTS IN TABLE curated.customers;
```

## Streams for CDC

```sql
-- Create stream on source table
CREATE OR REPLACE STREAM curated.customers_stream 
ON TABLE curated.customers;

-- Process changes
CREATE OR REPLACE TASK curated.process_customer_changes
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '5 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA('curated.customers_stream')
AS
INSERT INTO analytics.customer_changes (
    customer_id,
    change_type,
    change_timestamp,
    old_value,
    new_value
)
SELECT 
    customer_id,
    METADATA$ACTION as change_type,
    CURRENT_TIMESTAMP() as change_timestamp,
    METADATA$ROW_ID as old_value,
    customer_id as new_value
FROM curated.customers_stream;

ALTER TASK curated.process_customer_changes RESUME;
```

## Data Sharing (Secure)

```sql
-- Create share for external consumption
CREATE SHARE analytics_share;

-- Grant access to specific objects
GRANT USAGE ON DATABASE analytics_db TO SHARE analytics_share;
GRANT USAGE ON SCHEMA analytics TO SHARE analytics_share;
GRANT SELECT ON VIEW analytics.customer_segments TO SHARE analytics_share;

-- Add account to share
ALTER SHARE analytics_share ADD ACCOUNTS = partner_account;

-- Revoke if needed
REVOKE SELECT ON VIEW analytics.customer_segments FROM SHARE analytics_share;
```

## Cost Management

```sql
-- Monitor warehouse usage
SELECT 
    warehouse_name,
    SUM(credits_used) as total_credits,
    SUM(credits_used_cloud_services) as cloud_service_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY warehouse_name
ORDER BY total_credits DESC;

-- Set resource monitors
CREATE OR REPLACE RESOURCE MONITOR monthly_limit
WITH CREDIT_QUOTA = 1000
    TRIGGERS 
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO SUSPEND
        ON 100 PERCENT DO SUSPEND_IMMEDIATE;

-- Assign to warehouse
ALTER WAREHOUSE COMPUTE_WH SET RESOURCE_MONITOR = monthly_limit;

-- Auto-suspend warehouse
ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 300;  -- 5 minutes
ALTER WAREHOUSE COMPUTE_WH SET AUTO_RESUME = TRUE;
```

## Testing in Snowflake

```sql
-- Create test data
CREATE OR REPLACE TEMPORARY TABLE test_customers AS
SELECT 
    1 as customer_id,
    'test@example.com' as email,
    '123-456-7890' as phone
UNION ALL
SELECT 2, 'another@test.com', '234-567-8901';

-- Test PII masking
SELECT 
    customer_id,
    curated.mask_email(email, 'test-salt') as masked_email,
    curated.redact_phone(phone) as redacted_phone
FROM test_customers;

-- Verify no PII in curated layer
SELECT COUNT(*) as pii_violations
FROM curated.customers
WHERE email_token LIKE '%@%'  -- Should be 0
   OR phone_redacted NOT RLIKE '^XXX-XXX-[0-9]{4}$';

-- Test data quality
SELECT 
    'Completeness: customer_id' as check_name,
    COUNT(*) as total_records,
    COUNT(customer_id) as complete_records,
    COUNT(customer_id)::FLOAT / COUNT(*) as completeness_rate,
    CASE WHEN COUNT(customer_id)::FLOAT / COUNT(*) >= 0.99 THEN 'PASS' ELSE 'FAIL' END as status
FROM curated.customers;
```

## Best Practices

1. **Always use schemas** to organize objects (raw, curated, analytics)
2. **Implement audit columns** (_audit_user, _audit_timestamp) on all curated tables
3. **Use appropriate data types** (TIMESTAMP_NTZ for timestamps, NUMBER for IDs)
4. **Cluster large tables** on query predicates for performance
5. **Set auto-suspend** on warehouses to control costs
6. **Use resource monitors** to prevent runaway costs
7. **Grant least privilege** access via roles
8. **Document table comments** for data governance
9. **Use streams and tasks** for near-real-time processing
10. **Test with production-scale data** in non-prod environments