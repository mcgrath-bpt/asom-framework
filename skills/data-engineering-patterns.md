---
name: data-engineering-patterns
description: Foundational data engineering patterns and best practices for building scalable, maintainable pipelines. Covers medallion architecture, data modeling, pipeline orchestration, error handling, and performance optimization. Essential for establishing baseline standards across all data engineering work.
---

# Data Engineering Patterns

## Overview

This skill defines foundational patterns and best practices for data engineering. These patterns establish baseline standards that ensure consistency, quality, and scalability across all data pipelines.

**Purpose:**
- Establish common vocabulary and approaches
- Prevent anti-patterns and technical debt
- Enable team scaling with consistent practices
- Ensure maintainability and reliability

---

## Medallion Architecture

### Overview

The **Medallion Architecture** (Bronze → Silver → Gold) is the foundational pattern for organizing data pipelines.

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   BRONZE    │───▶│   SILVER    │───▶│    GOLD     │
│   (RAW)     │    │ (CURATED)   │    │ (REFINED)   │
└─────────────┘    └─────────────┘    └─────────────┘
    │                   │                   │
    ├─ Exact copy      ├─ Cleaned          ├─ Business logic
    ├─ All data        ├─ Validated        ├─ Aggregated
    ├─ No transforms   ├─ PII masked       ├─ Denormalized
    └─ Immutable       ├─ Typed            └─ Analytics-ready
                       └─ Standardized
```

### Bronze Layer (Raw)

**Purpose:** Exact copy of source data with minimal transformation

**Characteristics:**
- Append-only (immutable)
- Stores all data received
- No business logic or transformations
- Audit columns added (_audit_user, _audit_timestamp)
- Data types: String (VARCHAR) for everything
- Retention: 30-90 days (replay capability)

**Pattern:**
```sql
-- Bronze table structure
CREATE TABLE BRONZE.CUSTOMER_RAW (
    -- Source data (as received, all VARCHAR)
    customer_id VARCHAR,
    email VARCHAR,
    phone VARCHAR,
    created_at VARCHAR,
    updated_at VARCHAR,
    
    -- Technical metadata
    _source_file VARCHAR,
    _source_timestamp TIMESTAMP_NTZ,
    
    -- Audit trail (required)
    _audit_user VARCHAR NOT NULL DEFAULT CURRENT_USER(),
    _audit_timestamp TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    _audit_operation VARCHAR NOT NULL
);
```

**When to Use:**
- All source data ingestion
- API responses
- File uploads
- Change data capture (CDC)

**Benefits:**
- Enables replay (reprocess if logic changes)
- Audit trail of raw data
- Isolates source system issues
- Debugging capability

---

### Silver Layer (Curated)

**Purpose:** Cleaned, validated, standardized data ready for consumption

**Characteristics:**
- PII masked/redacted
- Data types enforced
- Business rules applied
- Data quality validated
- Duplicates removed
- Standardized formats

**Pattern:**
```sql
-- Silver table structure
CREATE TABLE SILVER.CUSTOMER_CURATED (
    -- Business keys (typed)
    customer_id NUMBER PRIMARY KEY,
    email_token VARCHAR(64),  -- SHA256 masked
    phone_redacted VARCHAR(12),  -- XXX-XXX-4567
    
    -- Attributes (typed and validated)
    first_name VARCHAR,
    last_name VARCHAR,
    segment VARCHAR,
    lifetime_value NUMBER(10,2),
    
    -- Temporal fields (typed as dates)
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ,
    
    -- Audit trail (required)
    _audit_user VARCHAR NOT NULL,
    _audit_timestamp TIMESTAMP_NTZ NOT NULL,
    _audit_operation VARCHAR NOT NULL,
    _source_system VARCHAR
);
```

**Transformations Applied:**
```python
def bronze_to_silver(df_bronze: pd.DataFrame) -> pd.DataFrame:
    """Transform bronze to silver with quality and governance."""
    
    # 1. Parse and type
    df = df_bronze.copy()
    df['customer_id'] = pd.to_numeric(df['customer_id'])
    df['created_at'] = pd.to_datetime(df['created_at'])
    
    # 2. PII masking
    df['email_token'] = df['email'].apply(mask_email_sha256)
    df['phone_redacted'] = df['phone'].apply(redact_phone)
    
    # 3. Data quality
    df = df[df['email'].notna()]  # Required field
    df = df.drop_duplicates(subset=['customer_id'])
    
    # 4. Business rules
    df['segment'] = df['lifetime_value'].apply(calculate_segment)
    
    # 5. Standardization
    df['first_name'] = df['first_name'].str.title()
    df['last_name'] = df['last_name'].str.title()
    
    return df
```

**When to Use:**
- All data consumed by analytics
- Data science model features
- Reporting and dashboards
- Cross-system integration

**Benefits:**
- GDPR/privacy compliant
- Data quality guaranteed
- Consistent formats
- Ready for business use

---

### Gold Layer (Refined)

**Purpose:** Business-specific aggregations and denormalized views

**Characteristics:**
- Denormalized (optimized for queries)
- Pre-aggregated metrics
- Business-friendly naming
- Role-based views
- Department-specific models

**Pattern:**
```sql
-- Gold view/table structure
CREATE VIEW GOLD.CUSTOMER_360 AS
SELECT
    c.customer_id,
    c.segment,
    c.lifetime_value,
    
    -- Aggregated order metrics
    o.total_orders,
    o.total_revenue,
    o.avg_order_value,
    o.last_order_date,
    
    -- Aggregated engagement metrics
    e.email_open_rate,
    e.last_interaction_date,
    
    -- Calculated fields
    DATEDIFF('day', o.last_order_date, CURRENT_DATE()) AS days_since_last_order,
    CASE
        WHEN days_since_last_order > 180 THEN 'AT_RISK'
        WHEN days_since_last_order > 90 THEN 'DORMANT'
        ELSE 'ACTIVE'
    END AS customer_status

FROM SILVER.CUSTOMER_CURATED c
LEFT JOIN SILVER.ORDER_SUMMARY o ON c.customer_id = o.customer_id
LEFT JOIN SILVER.ENGAGEMENT_SUMMARY e ON c.customer_id = e.customer_id;
```

**When to Use:**
- Department-specific views (Marketing, Sales, Finance)
- Pre-calculated KPIs
- Reporting dashboards
- BI tool consumption
- ML feature stores

**Benefits:**
- Query performance (pre-aggregated)
- Business-friendly (denormalized)
- Access control (role-specific views)
- Simplified consumption

---

## Data Modeling Patterns

### Slowly Changing Dimensions (SCD)

**Type 1: Overwrite (Current State Only)**

Use when: You only need current values, no history required

```sql
-- SCD Type 1: Simple UPDATE
UPDATE CUSTOMER_DIM
SET
    segment = 'PREMIUM',
    updated_at = CURRENT_TIMESTAMP()
WHERE customer_id = 12345;
```

**Type 2: Historical Tracking (Full History)**

Use when: You need complete history of all changes

```sql
-- SCD Type 2: New row for each change
CREATE TABLE CUSTOMER_DIM (
    customer_key NUMBER IDENTITY PRIMARY KEY,  -- Surrogate key
    customer_id NUMBER,  -- Natural key
    segment VARCHAR,
    
    -- SCD Type 2 metadata
    valid_from TIMESTAMP_NTZ NOT NULL,
    valid_to TIMESTAMP_NTZ,
    is_current BOOLEAN DEFAULT TRUE,
    
    UNIQUE (customer_id, valid_from)
);

-- Insert new version, expire old version
INSERT INTO CUSTOMER_DIM (customer_id, segment, valid_from)
VALUES (12345, 'PREMIUM', CURRENT_TIMESTAMP());

UPDATE CUSTOMER_DIM
SET
    valid_to = CURRENT_TIMESTAMP(),
    is_current = FALSE
WHERE customer_id = 12345
    AND is_current = TRUE;
```

**Type 3: Limited History (Previous Value)**

Use when: You only need to track one previous value

```sql
CREATE TABLE CUSTOMER_DIM (
    customer_id NUMBER PRIMARY KEY,
    current_segment VARCHAR,
    previous_segment VARCHAR,
    segment_changed_at TIMESTAMP_NTZ
);
```

**Pattern Selection:**

| Need | Pattern | Storage | Query Complexity |
|------|---------|---------|------------------|
| Current state only | Type 1 | Low | Simple |
| Full history | Type 2 | High | Medium |
| One previous value | Type 3 | Low | Simple |

---

### Fact Tables

**Transaction Fact (Immutable)**

```sql
CREATE TABLE FACT_ORDER (
    order_id NUMBER PRIMARY KEY,
    customer_key NUMBER,  -- FK to dimension
    order_date DATE,
    
    -- Measures (additive)
    order_amount NUMBER(10,2),
    discount_amount NUMBER(10,2),
    tax_amount NUMBER(10,2),
    
    -- Degenerate dimensions (attributes without dimension table)
    order_status VARCHAR,
    payment_method VARCHAR
);
```

**Periodic Snapshot Fact (Daily/Monthly State)**

```sql
CREATE TABLE FACT_INVENTORY_DAILY (
    inventory_date DATE,
    product_key NUMBER,
    warehouse_key NUMBER,
    
    -- Point-in-time measures
    units_on_hand NUMBER,
    units_on_order NUMBER,
    units_reserved NUMBER,
    
    PRIMARY KEY (inventory_date, product_key, warehouse_key)
);
```

**Accumulating Snapshot Fact (Milestone Tracking)**

```sql
CREATE TABLE FACT_ORDER_FULFILLMENT (
    order_id NUMBER PRIMARY KEY,
    
    -- Milestone dates
    order_placed_date DATE,
    payment_confirmed_date DATE,
    shipped_date DATE,
    delivered_date DATE,
    
    -- Duration metrics (calculated)
    days_to_ship NUMBER,
    days_to_deliver NUMBER
);
```

---

## Pipeline Orchestration Patterns

### Incremental Loading (Delta)

**Pattern: Process only new/changed records**

```python
def incremental_load(source_table: str, target_table: str, watermark_column: str):
    """Load only records newer than last watermark."""
    
    # 1. Get last watermark
    last_watermark = get_max_value(target_table, watermark_column)
    
    # 2. Extract incremental data
    query = f"""
        SELECT *
        FROM {source_table}
        WHERE {watermark_column} > '{last_watermark}'
    """
    df_new = pd.read_sql(query, source_conn)
    
    # 3. Load to target
    df_new.to_sql(target_table, target_conn, if_exists='append')
    
    return len(df_new)
```

**When to Use:**
- Large datasets (millions of rows)
- Frequent updates (hourly, daily)
- Source system supports watermark (timestamp, ID)

**Watermark Strategies:**
1. **Timestamp**: `updated_at > last_watermark`
2. **Integer ID**: `id > last_max_id`
3. **Change Data Capture (CDC)**: `_cdc_timestamp > last_watermark`

---

### Full Refresh (Replace)

**Pattern: Replace entire table**

```python
def full_refresh(source_table: str, target_table: str):
    """Replace entire target table."""
    
    # 1. Extract all data
    df = pd.read_sql(f"SELECT * FROM {source_table}", source_conn)
    
    # 2. Replace target
    df.to_sql(target_table, target_conn, if_exists='replace')
    
    return len(df)
```

**When to Use:**
- Small datasets (<1M rows)
- No reliable watermark
- Source is already aggregated/filtered
- Simplicity preferred over performance

---

### Upsert (Merge)

**Pattern: Insert new, update existing**

```sql
-- Snowflake MERGE pattern
MERGE INTO CUSTOMER_CURATED AS target
USING CUSTOMER_STAGING AS source
ON target.customer_id = source.customer_id
WHEN MATCHED THEN
    UPDATE SET
        target.segment = source.segment,
        target.lifetime_value = source.lifetime_value,
        target.updated_at = source.updated_at
WHEN NOT MATCHED THEN
    INSERT (customer_id, segment, lifetime_value, created_at)
    VALUES (source.customer_id, source.segment, source.lifetime_value, source.created_at);
```

**Python equivalent:**
```python
def upsert(df_new: pd.DataFrame, target_table: str, key_column: str):
    """Upsert data frame to target table."""
    
    # 1. Load to staging
    df_new.to_sql(f"{target_table}_staging", conn, if_exists='replace')
    
    # 2. Execute MERGE
    conn.execute(f"""
        MERGE INTO {target_table} AS target
        USING {target_table}_staging AS source
        ON target.{key_column} = source.{key_column}
        WHEN MATCHED THEN UPDATE SET ...
        WHEN NOT MATCHED THEN INSERT ...
    """)
```

**When to Use:**
- Updates are common
- Need to maintain history (SCD Type 2)
- Source doesn't distinguish new vs changed

---

### Idempotency Pattern

**Principle: Running pipeline multiple times produces same result**

```python
def idempotent_load(
    source_query: str,
    target_table: str,
    business_date: str
):
    """Load data idempotently - can run multiple times safely."""
    
    # 1. Delete existing data for this business date
    conn.execute(f"""
        DELETE FROM {target_table}
        WHERE business_date = '{business_date}'
    """)
    
    # 2. Load new data for this business date
    df = pd.read_sql(source_query, conn)
    df['business_date'] = business_date
    df.to_sql(target_table, conn, if_exists='append')
```

**Why Important:**
- Pipeline failures can be retried safely
- No duplicate data from reruns
- Simplifies error recovery

**Implementation Strategies:**
1. **Delete + Insert**: Remove partition, insert new
2. **MERGE with full match**: Upsert all records
3. **Staging table swap**: Load to staging, atomic swap

---

## Error Handling Patterns

### Retry with Exponential Backoff

```python
import time
from typing import Callable, Any

def retry_with_backoff(
    func: Callable,
    max_retries: int = 3,
    base_delay: int = 1
) -> Any:
    """Retry function with exponential backoff."""
    
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise  # Final attempt, propagate error
            
            delay = base_delay * (2 ** attempt)  # 1, 2, 4, 8...
            print(f"Attempt {attempt + 1} failed: {e}")
            print(f"Retrying in {delay} seconds...")
            time.sleep(delay)

# Usage
result = retry_with_backoff(lambda: api_client.get("/customers"))
```

**When to Use:**
- External API calls (transient network issues)
- Database connections (temporary unavailability)
- File operations (locked files)

---

### Dead Letter Queue

**Pattern: Capture failed records for later processing**

```python
def process_with_dlq(
    df: pd.DataFrame,
    process_func: Callable,
    dlq_table: str
):
    """Process records, send failures to dead letter queue."""
    
    success_records = []
    failed_records = []
    
    for idx, row in df.iterrows():
        try:
            processed = process_func(row)
            success_records.append(processed)
        except Exception as e:
            failed_records.append({
                **row.to_dict(),
                '_error_message': str(e),
                '_error_timestamp': datetime.utcnow(),
                '_retry_count': 0
            })
    
    # Load successful records
    if success_records:
        pd.DataFrame(success_records).to_sql('target_table', conn, if_exists='append')
    
    # Load failed records to DLQ
    if failed_records:
        pd.DataFrame(failed_records).to_sql(dlq_table, conn, if_exists='append')
    
    return len(success_records), len(failed_records)
```

**When to Use:**
- Individual record failures shouldn't fail entire batch
- Need to investigate/retry failed records later
- Compliance requires audit of all failures

---

### Circuit Breaker

**Pattern: Fail fast when downstream system is unavailable**

```python
class CircuitBreaker:
    """Prevent repeated calls to failing system."""
    
    def __init__(self, failure_threshold: int = 5, timeout: int = 60):
        self.failure_count = 0
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.last_failure_time = None
        self.state = 'CLOSED'  # CLOSED, OPEN, HALF_OPEN
    
    def call(self, func: Callable) -> Any:
        """Execute function with circuit breaker protection."""
        
        # Check if circuit is open
        if self.state == 'OPEN':
            if time.time() - self.last_failure_time > self.timeout:
                self.state = 'HALF_OPEN'
            else:
                raise Exception("Circuit breaker is OPEN")
        
        try:
            result = func()
            
            # Success - reset circuit
            if self.state == 'HALF_OPEN':
                self.state = 'CLOSED'
                self.failure_count = 0
            
            return result
            
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = time.time()
            
            if self.failure_count >= self.failure_threshold:
                self.state = 'OPEN'
            
            raise

# Usage
breaker = CircuitBreaker()
result = breaker.call(lambda: api_client.get("/customers"))
```

**When to Use:**
- Dependent services frequently fail
- Cascading failures need prevention
- Fast failure preferred over waiting

---

## Performance Optimization Patterns

### Partitioning

**Pattern: Divide large tables by date/category for performance**

```sql
-- Snowflake automatic clustering by date
CREATE TABLE FACT_ORDER (
    order_id NUMBER,
    order_date DATE,
    customer_id NUMBER,
    amount NUMBER
)
CLUSTER BY (order_date);

-- Queries on date partition efficiently
SELECT *
FROM FACT_ORDER
WHERE order_date = '2024-01-15';  -- Uses clustering
```

**Partition Strategies:**
1. **Date**: Most common (order_date, created_at)
2. **Category**: Region, product_category, status
3. **Hash**: customer_id MOD 10 (for even distribution)

**Benefits:**
- Query performance (scan less data)
- Easier maintenance (drop old partitions)
- Cost optimization (less data scanned)

---

### Incremental Aggregations

**Pattern: Update aggregations incrementally instead of full recalculation**

```sql
-- Instead of: Recalculate everything daily
CREATE TABLE CUSTOMER_METRICS AS
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(amount) AS lifetime_value
FROM ORDERS
GROUP BY customer_id;

-- Better: Update only for changed customers
MERGE INTO CUSTOMER_METRICS AS target
USING (
    SELECT
        customer_id,
        COUNT(*) AS new_orders,
        SUM(amount) AS new_revenue
    FROM ORDERS
    WHERE order_date = CURRENT_DATE()  -- Only today's orders
    GROUP BY customer_id
) AS source
ON target.customer_id = source.customer_id
WHEN MATCHED THEN
    UPDATE SET
        target.total_orders = target.total_orders + source.new_orders,
        target.lifetime_value = target.lifetime_value + source.new_revenue
WHEN NOT MATCHED THEN
    INSERT (customer_id, total_orders, lifetime_value)
    VALUES (source.customer_id, source.new_orders, source.new_revenue);
```

---

### Caching Pattern

**Pattern: Cache expensive computations**

```python
from functools import lru_cache

@lru_cache(maxsize=1000)
def get_customer_segment(lifetime_value: float) -> str:
    """Cache segment calculation (expensive ML model)."""
    # Expensive ML model inference
    return model.predict(lifetime_value)

# Usage - repeated calls use cache
segment1 = get_customer_segment(15000.0)  # Computes
segment2 = get_customer_segment(15000.0)  # Uses cache
```

---

## Data Quality Patterns

### Schema Evolution

**Pattern: Handle schema changes gracefully**

```python
def safe_column_access(df: pd.DataFrame, column: str, default: Any = None) -> pd.Series:
    """Safely access column that may not exist."""
    if column in df.columns:
        return df[column]
    else:
        return pd.Series([default] * len(df))

# Usage
df['new_field'] = safe_column_access(df_source, 'new_field', default='UNKNOWN')
```

**Snowflake ALTER TABLE pattern:**
```sql
-- Add column if not exists
ALTER TABLE CUSTOMER_CURATED
ADD COLUMN IF NOT EXISTS loyalty_tier VARCHAR;

-- Handle nullable new columns
SELECT
    customer_id,
    COALESCE(loyalty_tier, 'STANDARD') AS loyalty_tier
FROM CUSTOMER_CURATED;
```

---

### Data Validation Pattern

**Pattern: Validate before loading to target**

```python
def validate_and_load(
    df: pd.DataFrame,
    validation_rules: dict,
    target_table: str
) -> dict:
    """Validate data against rules before loading."""
    
    results = {
        'total_records': len(df),
        'valid_records': 0,
        'invalid_records': 0,
        'validation_errors': []
    }
    
    # Apply validation rules
    for rule_name, rule_func in validation_rules.items():
        valid_mask = df.apply(rule_func, axis=1)
        invalid_count = (~valid_mask).sum()
        
        if invalid_count > 0:
            results['validation_errors'].append({
                'rule': rule_name,
                'failed_count': invalid_count
            })
    
    # Load only valid records
    all_valid = all(len(e['failed_count']) == 0 for e in results['validation_errors'])
    
    if all_valid:
        df.to_sql(target_table, conn, if_exists='append')
        results['valid_records'] = len(df)
    else:
        # Send to DLQ or raise error
        raise ValueError(f"Validation failed: {results['validation_errors']}")
    
    return results
```

---

## Best Practices Summary

### DO ✅

1. **Use Medallion Architecture** - Bronze → Silver → Gold always
2. **Implement Idempotency** - Pipelines can be retried safely
3. **Add Audit Columns** - _audit_user, _audit_timestamp on all tables
4. **Mask PII in Silver** - Never expose PII in curated/gold layers
5. **Use Incremental Loading** - For large datasets (>1M rows)
6. **Partition by Date** - Improves performance and cost
7. **Validate Before Load** - Catch quality issues early
8. **Handle Errors Gracefully** - Retry, DLQ, circuit breaker patterns
9. **Version Schema Changes** - ALTER TABLE IF NOT EXISTS
10. **Monitor Pipeline Health** - Execution time, record counts, error rates

### DON'T ❌

1. **Don't Transform in Bronze** - Bronze is exact source copy
2. **Don't Expose PII in Gold** - Always mask in Silver first
3. **Don't Skip Validation** - Quality issues compound downstream
4. **Don't Use Full Refresh for Large Tables** - Use incremental
5. **Don't Ignore Failed Records** - Implement DLQ pattern
6. **Don't Hardcode Dates** - Use parameters for backfills
7. **Don't Mix Concerns** - One pipeline = one purpose
8. **Don't Skip Testing** - TDD applies to data pipelines
9. **Don't Create Orphaned Data** - Validate referential integrity
10. **Don't Forget Audit Trail** - Required for governance

---

## Pattern Selection Guide

### Choose Your Pattern

**For Data Loading:**
- Small table (<1M rows) → Full Refresh
- Large table with timestamp → Incremental Load
- Updates common → Upsert (MERGE)
- Need history → SCD Type 2
- Need idempotency → Delete + Insert by partition

**For Error Handling:**
- External API → Retry with Backoff
- Individual failures → Dead Letter Queue
- System frequently down → Circuit Breaker
- All records must succeed → Fail entire batch

**For Performance:**
- Large table → Partition by date
- Repeated queries → Materialized view or table
- Expensive computation → Cache results
- Complex aggregation → Incremental aggregation

**For Data Quality:**
- Schema may change → Safe column access
- Critical quality → Validate before load
- Variable source quality → Separate validation layer
- Need audit of failures → Validation results table

---

## Integration with ASOM

### For BA Agent

**Use patterns to:**
- Understand technical feasibility
- Estimate story complexity
- Identify non-functional requirements
- Communicate with Dev Agent

### For Dev Agent

**Use patterns to:**
- Select appropriate architecture (Bronze/Silver/Gold)
- Implement standard error handling
- Optimize performance
- Ensure maintainability

### For QA Agent

**Use patterns to:**
- Validate pattern implementation
- Test error handling (retry, DLQ)
- Verify performance expectations
- Check data quality validations

### For Governance Agent

**Use patterns to:**
- Ensure PII masked in Silver layer
- Validate audit columns present
- Verify idempotency (no duplicates from reruns)
- Check data retention policies (Bronze 30d, Silver/Gold longer)

---

## Summary

**Core Patterns:**
1. **Medallion Architecture** - Bronze → Silver → Gold
2. **Incremental Loading** - Process only new/changed data
3. **Idempotency** - Safe to retry
4. **Error Handling** - Retry, DLQ, Circuit Breaker
5. **Data Quality** - Validate before load
6. **Performance** - Partition, cache, incremental aggregation

**These patterns are baselines** - use them consistently across all pipelines to ensure quality, maintainability, and scalability.

When in doubt, follow the pattern. Deviation requires justification and documentation.
