---
name: data-quality-validation
description: Data quality validation techniques and patterns for data engineering pipelines. Covers completeness, accuracy, consistency, timeliness, and uniqueness checks. Essential for QA Agent to validate data quality thresholds and create OQ test evidence.
---

# Data Quality Validation

## Overview

Data quality validation ensures data pipelines produce reliable, accurate, and complete data. This skill covers the five dimensions of data quality and how to validate them in data engineering contexts.

## Five Dimensions of Data Quality

```
┌─────────────────────────────────────────┐
│  Data Quality Dimensions                │
├─────────────────────────────────────────┤
│  1. Completeness  - No missing values   │
│  2. Accuracy      - Correct values      │
│  3. Consistency   - No contradictions   │
│  4. Timeliness    - Fresh, not stale    │
│  5. Uniqueness    - No duplicates       │
└─────────────────────────────────────────┘
```

## 1. Completeness Validation

### Definition
Completeness measures the percentage of non-null values in required fields.

### When to Use
- Required fields must be present
- Optional fields should meet minimum thresholds
- Record counts should match expectations

### Validation Patterns

**Record Count Validation:**
```python
def validate_record_count(df: pd.DataFrame, min_records: int) -> Dict:
    """Validate minimum record count."""
    actual_count = len(df)
    
    return {
        'dimension': 'completeness',
        'check': 'record_count',
        'passed': actual_count >= min_records,
        'expected': f'>= {min_records}',
        'actual': actual_count,
        'severity': 'critical'
    }

# Usage
result = validate_record_count(customers_df, min_records=1000)
assert result['passed'], f"Record count validation failed: {result}"
```

**Field Completeness:**
```python
def validate_field_completeness(
    df: pd.DataFrame,
    field: str,
    threshold: float = 1.0
) -> Dict:
    """Validate field has minimum completeness percentage."""
    total_rows = len(df)
    non_null_rows = df[field].notna().sum()
    completeness = non_null_rows / total_rows if total_rows > 0 else 0
    
    return {
        'dimension': 'completeness',
        'check': f'{field}_completeness',
        'passed': completeness >= threshold,
        'expected': f'>= {threshold:.1%}',
        'actual': f'{completeness:.1%}',
        'severity': 'critical' if threshold == 1.0 else 'warning'
    }

# Usage
assert validate_field_completeness(df, 'customer_id', 1.0)['passed']
assert validate_field_completeness(df, 'email', 0.95)['passed']
assert validate_field_completeness(df, 'phone', 0.70)['passed']
```

**Multi-Field Completeness:**
```python
def validate_completeness_profile(
    df: pd.DataFrame,
    required_fields: Dict[str, float]
) -> List[Dict]:
    """Validate completeness for multiple fields."""
    results = []
    
    for field, threshold in required_fields.items():
        result = validate_field_completeness(df, field, threshold)
        results.append(result)
    
    return results

# Usage
completeness_requirements = {
    'customer_id': 1.0,      # Required
    'email': 0.95,           # 95% minimum
    'phone': 0.70,           # 70% minimum
    'address': 0.60,         # 60% minimum
    'purchase_date': 1.0     # Required
}

results = validate_completeness_profile(df, completeness_requirements)
failures = [r for r in results if not r['passed']]
assert len(failures) == 0, f"Completeness failures: {failures}"
```

## 2. Accuracy Validation

### Definition
Accuracy measures whether values fall within expected ranges, formats, or business rules.

### When to Use
- Numeric values must be within range
- Dates must be valid and reasonable
- Categorical values must be from allowed set
- Business rules must be satisfied

### Validation Patterns

**Range Validation:**
```python
def validate_numeric_range(
    df: pd.DataFrame,
    field: str,
    min_value: float = None,
    max_value: float = None
) -> Dict:
    """Validate numeric field falls within range."""
    values = df[field].dropna()
    
    if min_value is not None:
        below_min = (values < min_value).sum()
    else:
        below_min = 0
    
    if max_value is not None:
        above_max = (values > max_value).sum()
    else:
        above_max = 0
    
    violations = below_min + above_max
    
    return {
        'dimension': 'accuracy',
        'check': f'{field}_range',
        'passed': violations == 0,
        'expected': f'{min_value} to {max_value}',
        'actual': f'{violations} violations',
        'severity': 'critical' if violations > 0 else 'pass'
    }

# Usage
assert validate_numeric_range(df, 'age', min_value=0, max_value=120)['passed']
assert validate_numeric_range(df, 'price', min_value=0)['passed']
assert validate_numeric_range(df, 'discount', min_value=0, max_value=1)['passed']
```

**Date Validation:**
```python
def validate_date_reasonableness(
    df: pd.DataFrame,
    date_field: str,
    min_date: str = None,
    max_date: str = 'today'
) -> Dict:
    """Validate dates are reasonable (not in far past/future)."""
    import pandas as pd
    from datetime import datetime
    
    dates = pd.to_datetime(df[date_field], errors='coerce').dropna()
    
    if min_date:
        min_dt = pd.to_datetime(min_date)
        before_min = (dates < min_dt).sum()
    else:
        before_min = 0
    
    if max_date == 'today':
        max_dt = datetime.now()
    else:
        max_dt = pd.to_datetime(max_date)
    
    after_max = (dates > max_dt).sum()
    violations = before_min + after_max
    
    return {
        'dimension': 'accuracy',
        'check': f'{date_field}_reasonableness',
        'passed': violations == 0,
        'expected': f'{min_date} to {max_date}',
        'actual': f'{violations} violations',
        'severity': 'warning' if violations < 10 else 'critical'
    }

# Usage
assert validate_date_reasonableness(
    df, 
    'birth_date', 
    min_date='1900-01-01', 
    max_date='today'
)['passed']

assert validate_date_reasonableness(
    df,
    'purchase_date',
    min_date='2020-01-01',
    max_date='today'
)['passed']
```

**Categorical Validation:**
```python
def validate_categorical_values(
    df: pd.DataFrame,
    field: str,
    allowed_values: List[str]
) -> Dict:
    """Validate categorical field contains only allowed values."""
    actual_values = set(df[field].dropna().unique())
    invalid_values = actual_values - set(allowed_values)
    
    return {
        'dimension': 'accuracy',
        'check': f'{field}_valid_categories',
        'passed': len(invalid_values) == 0,
        'expected': str(allowed_values),
        'actual': f'Found invalid: {invalid_values}' if invalid_values else 'Valid',
        'severity': 'critical' if invalid_values else 'pass'
    }

# Usage
assert validate_categorical_values(
    df,
    'status',
    allowed_values=['ACTIVE', 'INACTIVE', 'PENDING']
)['passed']

assert validate_categorical_values(
    df,
    'segment',
    allowed_values=['PREMIUM', 'STANDARD', 'BASIC']
)['passed']
```

**Business Rule Validation:**
```python
def validate_business_rule(
    df: pd.DataFrame,
    rule_name: str,
    rule_function: callable
) -> Dict:
    """Validate custom business rule."""
    violations = ~df.apply(rule_function, axis=1)
    violation_count = violations.sum()
    
    return {
        'dimension': 'accuracy',
        'check': rule_name,
        'passed': violation_count == 0,
        'expected': 'All rows satisfy rule',
        'actual': f'{violation_count} violations',
        'severity': 'critical' if violation_count > 0 else 'pass'
    }

# Usage: Lifetime value should match sum of purchases
def lifetime_value_matches_purchases(row):
    return row['lifetime_value'] == row['total_purchases']

assert validate_business_rule(
    df,
    'lifetime_value_accuracy',
    lifetime_value_matches_purchases
)['passed']

# Usage: Discount cannot exceed original price
def discount_not_greater_than_price(row):
    return row['discount'] <= row['price']

assert validate_business_rule(
    df,
    'discount_validation',
    discount_not_greater_than_price
)['passed']
```

## 3. Consistency Validation

### Definition
Consistency measures whether data contradicts itself across fields or related records.

### When to Use
- Cross-field relationships must be maintained
- Referential integrity must be preserved
- Aggregate values must match detail records

### Validation Patterns

**Cross-Field Consistency:**
```python
def validate_cross_field_consistency(
    df: pd.DataFrame,
    checks: Dict[str, callable]
) -> List[Dict]:
    """Validate relationships between fields."""
    results = []
    
    for check_name, check_func in checks.items():
        violations = ~df.apply(check_func, axis=1)
        violation_count = violations.sum()
        
        results.append({
            'dimension': 'consistency',
            'check': check_name,
            'passed': violation_count == 0,
            'expected': 'All rows consistent',
            'actual': f'{violation_count} violations',
            'severity': 'critical' if violation_count > 0 else 'pass'
        })
    
    return results

# Usage
consistency_checks = {
    'end_after_start': lambda row: row['end_date'] >= row['start_date'],
    'discount_price_valid': lambda row: row['discount_price'] <= row['original_price'],
    'age_matches_birthdate': lambda row: calculate_age(row['birth_date']) == row['age']
}

results = validate_cross_field_consistency(df, consistency_checks)
assert all(r['passed'] for r in results)
```

**Referential Integrity:**
```python
def validate_referential_integrity(
    child_df: pd.DataFrame,
    parent_df: pd.DataFrame,
    child_fk: str,
    parent_pk: str
) -> Dict:
    """Validate foreign key references exist in parent."""
    parent_keys = set(parent_df[parent_pk].dropna())
    child_keys = set(child_df[child_fk].dropna())
    
    orphaned = child_keys - parent_keys
    orphaned_count = len(orphaned)
    
    return {
        'dimension': 'consistency',
        'check': f'{child_fk}_referential_integrity',
        'passed': orphaned_count == 0,
        'expected': 'All FKs exist in parent',
        'actual': f'{orphaned_count} orphaned references',
        'severity': 'critical' if orphaned_count > 0 else 'pass',
        'details': f'Orphaned values: {list(orphaned)[:10]}' if orphaned else None
    }

# Usage
assert validate_referential_integrity(
    child_df=orders_df,
    parent_df=customers_df,
    child_fk='customer_id',
    parent_pk='customer_id'
)['passed']
```

**Aggregate Consistency:**
```python
def validate_aggregate_matches_detail(
    detail_df: pd.DataFrame,
    aggregate_df: pd.DataFrame,
    group_key: str,
    detail_value: str,
    aggregate_value: str,
    tolerance: float = 0.01
) -> Dict:
    """Validate aggregate values match sum of details."""
    # Calculate aggregates from detail
    actual_agg = detail_df.groupby(group_key)[detail_value].sum()
    
    # Compare with reported aggregates
    reported_agg = aggregate_df.set_index(group_key)[aggregate_value]
    
    # Allow small tolerance for floating point
    diff = (actual_agg - reported_agg).abs()
    violations = (diff > tolerance).sum()
    
    return {
        'dimension': 'consistency',
        'check': f'{aggregate_value}_matches_detail',
        'passed': violations == 0,
        'expected': 'Aggregates match detail sums',
        'actual': f'{violations} mismatches',
        'severity': 'critical' if violations > 0 else 'pass'
    }

# Usage
assert validate_aggregate_matches_detail(
    detail_df=order_items_df,
    aggregate_df=orders_df,
    group_key='order_id',
    detail_value='item_price',
    aggregate_value='order_total'
)['passed']
```

## 4. Timeliness Validation

### Definition
Timeliness measures whether data is fresh and up-to-date.

### When to Use
- Data must be loaded within SLA windows
- Records must not be stale beyond threshold
- Pipeline latency must be monitored

### Validation Patterns

**Data Freshness:**
```python
def validate_data_freshness(
    df: pd.DataFrame,
    timestamp_field: str,
    max_age_hours: int
) -> Dict:
    """Validate data is not stale beyond threshold."""
    from datetime import datetime, timedelta
    
    latest_timestamp = pd.to_datetime(df[timestamp_field]).max()
    age_hours = (datetime.now() - latest_timestamp).total_seconds() / 3600
    
    return {
        'dimension': 'timeliness',
        'check': 'data_freshness',
        'passed': age_hours <= max_age_hours,
        'expected': f'<= {max_age_hours} hours old',
        'actual': f'{age_hours:.1f} hours old',
        'severity': 'critical' if age_hours > max_age_hours * 1.5 else 'warning'
    }

# Usage
assert validate_data_freshness(
    df,
    timestamp_field='created_at',
    max_age_hours=24
)['passed']
```

**Load SLA Validation:**
```python
def validate_load_sla(
    load_start: datetime,
    load_end: datetime,
    sla_minutes: int
) -> Dict:
    """Validate data load completed within SLA."""
    duration_minutes = (load_end - load_start).total_seconds() / 60
    
    return {
        'dimension': 'timeliness',
        'check': 'load_sla',
        'passed': duration_minutes <= sla_minutes,
        'expected': f'<= {sla_minutes} minutes',
        'actual': f'{duration_minutes:.1f} minutes',
        'severity': 'critical' if duration_minutes > sla_minutes * 1.5 else 'warning'
    }

# Usage
assert validate_load_sla(
    load_start=pipeline_start_time,
    load_end=pipeline_end_time,
    sla_minutes=30
)['passed']
```

## 5. Uniqueness Validation

### Definition
Uniqueness measures whether records that should be unique actually are.

### When to Use
- Primary keys must be unique
- Natural keys must be unique
- Deduplication must be effective

### Validation Patterns

**Primary Key Uniqueness:**
```python
def validate_primary_key_unique(
    df: pd.DataFrame,
    key_fields: List[str]
) -> Dict:
    """Validate primary key is unique."""
    total_rows = len(df)
    unique_keys = df[key_fields].drop_duplicates().shape[0]
    duplicates = total_rows - unique_keys
    
    return {
        'dimension': 'uniqueness',
        'check': f'{"+".join(key_fields)}_uniqueness',
        'passed': duplicates == 0,
        'expected': 'No duplicates',
        'actual': f'{duplicates} duplicate rows',
        'severity': 'critical' if duplicates > 0 else 'pass'
    }

# Usage
assert validate_primary_key_unique(df, ['customer_id'])['passed']
assert validate_primary_key_unique(df, ['order_id', 'line_number'])['passed']
```

**Duplicate Detection:**
```python
def find_duplicates(
    df: pd.DataFrame,
    key_fields: List[str]
) -> pd.DataFrame:
    """Find duplicate records for investigation."""
    duplicated_mask = df.duplicated(subset=key_fields, keep=False)
    duplicates = df[duplicated_mask].sort_values(key_fields)
    return duplicates

# Usage
dupes = find_duplicates(df, ['customer_id'])
if len(dupes) > 0:
    print(f"Found {len(dupes)} duplicate records:")
    print(dupes[['customer_id', 'email', 'created_at']])
```

## Comprehensive Data Quality Report

### Quality Report Function

```python
def generate_data_quality_report(
    df: pd.DataFrame,
    config: Dict
) -> Dict:
    """Generate comprehensive data quality report."""
    results = {
        'completeness': [],
        'accuracy': [],
        'consistency': [],
        'timeliness': [],
        'uniqueness': []
    }
    
    # Completeness checks
    for field, threshold in config.get('completeness', {}).items():
        result = validate_field_completeness(df, field, threshold)
        results['completeness'].append(result)
    
    # Accuracy checks
    for field, spec in config.get('accuracy_ranges', {}).items():
        result = validate_numeric_range(df, field, **spec)
        results['accuracy'].append(result)
    
    # Uniqueness checks
    for key in config.get('unique_keys', []):
        result = validate_primary_key_unique(df, key)
        results['uniqueness'].append(result)
    
    # Calculate overall quality score
    all_checks = sum(results.values(), [])
    passed = sum(1 for r in all_checks if r['passed'])
    total = len(all_checks)
    
    return {
        'timestamp': datetime.now().isoformat(),
        'record_count': len(df),
        'checks_passed': passed,
        'checks_total': total,
        'quality_score': passed / total if total > 0 else 0,
        'results': results,
        'summary': {
            dim: f"{sum(1 for r in checks if r['passed'])}/{len(checks)}"
            for dim, checks in results.items()
        }
    }

# Usage
quality_config = {
    'completeness': {
        'customer_id': 1.0,
        'email': 0.95,
        'phone': 0.70
    },
    'accuracy_ranges': {
        'age': {'min_value': 0, 'max_value': 120},
        'lifetime_value': {'min_value': 0}
    },
    'unique_keys': [
        ['customer_id'],
        ['email']
    ]
}

report = generate_data_quality_report(customers_df, quality_config)
print(f"Quality Score: {report['quality_score']:.1%}")
print(f"Passed: {report['checks_passed']}/{report['checks_total']}")
```

## Data Quality Testing for ASOM

### OQ Test Evidence

```python
def test_customer_data_quality_oq():
    """OQ Test: Customer data meets all quality thresholds."""
    df = load_customer_data_from_qa()
    
    # Completeness (OQ requirement)
    assert validate_field_completeness(df, 'customer_id', 1.0)['passed']
    assert validate_field_completeness(df, 'email', 0.95)['passed']
    
    # Accuracy (OQ requirement)
    assert validate_numeric_range(df, 'age', 0, 120)['passed']
    
    # Uniqueness (OQ requirement)
    assert validate_primary_key_unique(df, ['customer_id'])['passed']
    
    # Generate OQ evidence report
    report = generate_data_quality_report(df, quality_config)
    assert report['quality_score'] >= 0.95  # 95% minimum
    
    # Save evidence
    save_oq_evidence(report, 'customer_dq_validation')
```

### Integration with PDL

Data quality tests serve as **OQ (Operational Qualification) evidence**:
- Validates business rules work correctly
- Proves data quality thresholds enforced
- Provides audit trail for compliance
- Demonstrates operational effectiveness

## Summary

**Five dimensions:**
1. Completeness - No missing required data
2. Accuracy - Values within expected ranges
3. Consistency - No contradictions
4. Timeliness - Data is fresh
5. Uniqueness - No unwanted duplicates

**For QA Agent:**
- Use these patterns to validate pipelines
- Create OQ test evidence
- Report quality scores
- Flag data quality issues early

**Quality thresholds:**
- Completeness: Required fields 100%, optional >70%
- Accuracy: 0 violations for critical fields
- Consistency: 0 referential integrity violations
- Timeliness: Data < 24 hours old
- Uniqueness: 0 duplicate PKs

**All validations contribute to OQ evidence for PDL compliance.**
