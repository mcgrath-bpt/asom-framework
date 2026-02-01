---
name: python-data-engineering
description: Python best practices for data engineering work including pipeline patterns, data quality, testing, and integration with Snowflake. Use when developing data pipelines, ETL/ELT workflows, or data transformation logic in Python.
---

# Python Data Engineering

Best practices and patterns for building production-quality data pipelines in Python.

## Tech Stack

### Core Libraries
- **polars**: High-performance DataFrames (10-100x faster than pandas)
- **pandas**: Legacy compatibility and ecosystem
- **pydantic**: Data validation and type safety
- **sqlalchemy**: Database interaction
- **snowflake-connector-python**: Snowflake integration
- **pytest**: Testing framework
- **great_expectations**: Data quality validation

### Installation
```bash
pip install polars pandas pydantic sqlalchemy snowflake-connector-python pytest great-expectations --break-system-packages
```

## Project Structure

```
project/
├── src/
│   ├── __init__.py
│   ├── extract/
│   │   ├── __init__.py
│   │   ├── api_client.py       # API extraction logic
│   │   ├── file_reader.py      # File-based extraction
│   │   └── database_reader.py  # Database extraction
│   ├── transform/
│   │   ├── __init__.py
│   │   ├── cleaners.py         # Data cleaning
│   │   ├── validators.py       # Data validation
│   │   ├── maskers.py          # PII protection
│   │   └── transformers.py     # Business logic
│   ├── load/
│   │   ├── __init__.py
│   │   ├── snowflake_loader.py # Snowflake loading
│   │   └── file_writer.py      # File output
│   ├── quality/
│   │   ├── __init__.py
│   │   └── expectations.py     # Data quality checks
│   └── utils/
│       ├── __init__.py
│       ├── config.py           # Configuration management
│       ├── logging.py          # Logging setup
│       └── secrets.py          # Secrets management
├── tests/
│   ├── __init__.py
│   ├── unit/                   # Unit tests
│   ├── integration/            # Integration tests
│   └── fixtures/               # Test data
├── config/
│   ├── dev.yaml
│   ├── test.yaml
│   └── prod.yaml
├── requirements.txt
└── pyproject.toml
```

## Data Extraction Patterns

### API Extraction with Pagination
```python
"""API extraction with pagination, rate limiting, and retry logic."""
import logging
import time
from typing import Iterator, Dict, List
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

logger = logging.getLogger(__name__)


class APIExtractor:
    """Extract data from REST API with pagination and error handling."""
    
    def __init__(self, base_url: str, api_key: str, batch_size: int = 100):
        self.base_url = base_url
        self.api_key = api_key
        self.batch_size = batch_size
        self.session = self._create_session()
    
    def _create_session(self) -> requests.Session:
        """Create requests session with retry logic."""
        session = requests.Session()
        retry = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
        )
        adapter = HTTPAdapter(max_retries=retry)
        session.mount("http://", adapter)
        session.mount("https://", adapter)
        return session
    
    def extract_paginated(self, endpoint: str) -> Iterator[Dict]:
        """
        Extract all records from paginated API endpoint.
        
        Args:
            endpoint: API endpoint path (e.g., '/customers')
            
        Yields:
            Individual records from API
        """
        page = 1
        total_records = 0
        
        while True:
            url = f"{self.base_url}{endpoint}"
            params = {
                "page": page,
                "limit": self.batch_size,
            }
            headers = {
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
            }
            
            try:
                response = self.session.get(url, params=params, headers=headers, timeout=30)
                response.raise_for_status()
                
                data = response.json()
                records = data.get("data", [])
                
                if not records:
                    break
                
                for record in records:
                    yield record
                    total_records += 1
                
                logger.info(f"Extracted page {page} ({len(records)} records)")
                
                # Check if there are more pages
                if not data.get("has_more", False):
                    break
                
                page += 1
                time.sleep(0.1)  # Rate limiting
                
            except requests.exceptions.RequestException as e:
                logger.error(f"API request failed on page {page}: {e}")
                raise
        
        logger.info(f"Total records extracted: {total_records}")
```

### File Extraction with Validation
```python
"""File extraction with schema validation."""
import polars as pl
from pathlib import Path
from pydantic import BaseModel, ValidationError
from typing import List


class CustomerRecord(BaseModel):
    """Customer record schema."""
    customer_id: int
    email: str
    created_at: str
    
    class Config:
        extra = "allow"  # Allow additional fields


def extract_csv_with_validation(filepath: Path) -> pl.DataFrame:
    """
    Extract CSV with schema validation.
    
    Args:
        filepath: Path to CSV file
        
    Returns:
        Polars DataFrame with validated records
        
    Raises:
        ValidationError: If records don't match schema
    """
    # Read CSV
    df = pl.read_csv(filepath)
    
    # Validate records
    errors = []
    for idx, row in enumerate(df.iter_rows(named=True)):
        try:
            CustomerRecord(**row)
        except ValidationError as e:
            errors.append(f"Row {idx}: {e}")
    
    if errors:
        raise ValidationError(f"Validation failed:\n" + "\n".join(errors[:10]))
    
    return df
```

## Data Transformation Patterns

### PII Masking (Deterministic)
```python
"""PII masking with deterministic hashing."""
import hashlib
import os
from typing import Optional


class PIIMasker:
    """Mask PII fields using deterministic hashing."""
    
    def __init__(self, salt: Optional[str] = None):
        """
        Initialize masker with salt.
        
        Args:
            salt: Optional salt for hashing (defaults to env var)
        """
        self.salt = salt or os.getenv("PII_MASK_SALT", "default-salt-change-me")
    
    def mask_email(self, email: str) -> str:
        """
        Mask email address with SHA256 hash.
        
        Args:
            email: Email address to mask
            
        Returns:
            64-character hex hash
        """
        if not email:
            return ""
        
        data = f"{email.lower()}{self.salt}"
        return hashlib.sha256(data.encode()).hexdigest()
    
    def redact_phone(self, phone: str) -> str:
        """
        Redact phone number to last 4 digits.
        
        Args:
            phone: Phone number
            
        Returns:
            Redacted format: XXX-XXX-1234
        """
        if not phone:
            return ""
        
        # Extract digits only
        digits = "".join(c for c in phone if c.isdigit())
        
        if len(digits) < 4:
            return "XXX-XXX-XXXX"
        
        last_four = digits[-4:]
        return f"XXX-XXX-{last_four}"
    
    def mask_dataframe(self, df: pl.DataFrame, pii_columns: dict) -> pl.DataFrame:
        """
        Mask PII columns in dataframe.
        
        Args:
            df: Input dataframe
            pii_columns: Dict of {column: masking_method}
                         e.g., {"email": "mask", "phone": "redact"}
        
        Returns:
            Dataframe with PII masked
        """
        result = df.clone()
        
        for col, method in pii_columns.items():
            if col not in df.columns:
                continue
            
            if method == "mask":
                result = result.with_columns(
                    pl.col(col).map_elements(self.mask_email, return_dtype=pl.Utf8).alias(f"{col}_token")
                ).drop(col)
            elif method == "redact":
                result = result.with_columns(
                    pl.col(col).map_elements(self.redact_phone, return_dtype=pl.Utf8).alias(f"{col}_redacted")
                ).drop(col)
        
        return result
```

### Data Quality Checks
```python
"""Data quality validation."""
import polars as pl
from dataclasses import dataclass
from typing import List


@dataclass
class QualityCheck:
    """Data quality check result."""
    check_name: str
    passed: bool
    threshold: float
    actual: float
    message: str


def check_completeness(df: pl.DataFrame, column: str, threshold: float = 0.95) -> QualityCheck:
    """
    Check column completeness.
    
    Args:
        df: Input dataframe
        column: Column to check
        threshold: Minimum completeness (0-1)
        
    Returns:
        QualityCheck result
    """
    total = len(df)
    non_null = df.select(pl.col(column).is_not_null().sum()).item()
    completeness = non_null / total if total > 0 else 0
    
    passed = completeness >= threshold
    message = f"{column}: {completeness:.1%} complete (threshold: {threshold:.1%})"
    
    return QualityCheck(
        check_name=f"Completeness: {column}",
        passed=passed,
        threshold=threshold,
        actual=completeness,
        message=message,
    )


def check_uniqueness(df: pl.DataFrame, column: str) -> QualityCheck:
    """
    Check column uniqueness.
    
    Args:
        df: Input dataframe
        column: Column to check
        
    Returns:
        QualityCheck result
    """
    total = len(df)
    unique = df.select(pl.col(column).n_unique()).item()
    uniqueness = unique / total if total > 0 else 0
    
    passed = uniqueness == 1.0
    duplicates = total - unique
    message = f"{column}: {duplicates} duplicates found"
    
    return QualityCheck(
        check_name=f"Uniqueness: {column}",
        passed=passed,
        threshold=1.0,
        actual=uniqueness,
        message=message,
    )


def check_format(df: pl.DataFrame, column: str, pattern: str) -> QualityCheck:
    """
    Check column format matches regex.
    
    Args:
        df: Input dataframe
        column: Column to check
        pattern: Regex pattern
        
    Returns:
        QualityCheck result
    """
    total = len(df)
    matches = df.select(
        pl.col(column).str.contains(pattern).sum()
    ).item()
    match_rate = matches / total if total > 0 else 0
    
    passed = match_rate == 1.0
    message = f"{column}: {match_rate:.1%} match pattern '{pattern}'"
    
    return QualityCheck(
        check_name=f"Format: {column}",
        passed=passed,
        threshold=1.0,
        actual=match_rate,
        message=message,
    )


def run_quality_checks(df: pl.DataFrame) -> List[QualityCheck]:
    """
    Run comprehensive quality checks.
    
    Args:
        df: Input dataframe
        
    Returns:
        List of QualityCheck results
    """
    checks = []
    
    # Example checks
    checks.append(check_completeness(df, "customer_id", threshold=0.99))
    checks.append(check_completeness(df, "email_token", threshold=0.95))
    checks.append(check_uniqueness(df, "customer_id"))
    
    # Log results
    for check in checks:
        status = "✅ PASS" if check.passed else "❌ FAIL"
        print(f"{status}: {check.message}")
    
    return checks
```

## Snowflake Integration

### Snowflake Loader
```python
"""Load data to Snowflake."""
import polars as pl
import snowflake.connector
from contextlib import contextmanager
from typing import Iterator


@contextmanager
def snowflake_connection(
    account: str,
    user: str,
    password: str,
    warehouse: str,
    database: str,
    schema: str,
) -> Iterator[snowflake.connector.SnowflakeConnection]:
    """
    Context manager for Snowflake connection.
    
    Args:
        account: Snowflake account
        user: Username
        password: Password
        warehouse: Warehouse name
        database: Database name
        schema: Schema name
        
    Yields:
        Snowflake connection
    """
    conn = snowflake.connector.connect(
        account=account,
        user=user,
        password=password,
        warehouse=warehouse,
        database=database,
        schema=schema,
    )
    try:
        yield conn
    finally:
        conn.close()


def load_to_snowflake(
    df: pl.DataFrame,
    table_name: str,
    connection_params: dict,
    if_exists: str = "append",
) -> int:
    """
    Load dataframe to Snowflake table.
    
    Args:
        df: Polars DataFrame
        table_name: Target table name
        connection_params: Snowflake connection parameters
        if_exists: 'append', 'replace', or 'fail'
        
    Returns:
        Number of rows loaded
    """
    with snowflake_connection(**connection_params) as conn:
        cursor = conn.cursor()
        
        # Convert to pandas for Snowflake write_pandas
        pdf = df.to_pandas()
        
        # Use Snowflake's write_pandas
        from snowflake.connector.pandas_tools import write_pandas
        
        success, nchunks, nrows, _ = write_pandas(
            conn=conn,
            df=pdf,
            table_name=table_name,
            auto_create_table=False,  # Require explicit DDL
            overwrite=(if_exists == "replace"),
        )
        
        if not success:
            raise RuntimeError(f"Failed to load data to {table_name}")
        
        return nrows
```

## Testing

### Unit Tests
```python
"""Unit tests for PII masking."""
import pytest
from src.transform.maskers import PIIMasker


def test_email_masking_deterministic():
    """Email masking should be deterministic."""
    masker = PIIMasker(salt="test-salt")
    email = "test@example.com"
    
    assert masker.mask_email(email) == masker.mask_email(email)


def test_email_masking_different_inputs():
    """Different emails should produce different hashes."""
    masker = PIIMasker(salt="test-salt")
    
    hash1 = masker.mask_email("a@b.com")
    hash2 = masker.mask_email("c@d.com")
    
    assert hash1 != hash2


def test_phone_redaction():
    """Phone numbers should be redacted correctly."""
    masker = PIIMasker()
    
    assert masker.redact_phone("123-456-7890") == "XXX-XXX-7890"
    assert masker.redact_phone("1234567890") == "XXX-XXX-7890"
    assert masker.redact_phone("123") == "XXX-XXX-XXXX"


@pytest.fixture
def sample_dataframe():
    """Provide sample customer data for testing."""
    import polars as pl
    return pl.DataFrame({
        "customer_id": [1, 2, 3],
        "email": ["a@b.com", "c@d.com", "e@f.com"],
        "phone": ["123-456-7890", "234-567-8901", "345-678-9012"],
    })


def test_dataframe_masking(sample_dataframe):
    """Dataframe masking should work correctly."""
    masker = PIIMasker(salt="test-salt")
    
    result = masker.mask_dataframe(
        sample_dataframe,
        pii_columns={"email": "mask", "phone": "redact"},
    )
    
    # Original columns should be removed
    assert "email" not in result.columns
    assert "phone" not in result.columns
    
    # Masked columns should exist
    assert "email_token" in result.columns
    assert "phone_redacted" in result.columns
    
    # Check format
    assert all(len(token) == 64 for token in result["email_token"])
    assert all("XXX-XXX" in redacted for redacted in result["phone_redacted"])
```

### Integration Tests
```python
"""Integration test for complete pipeline."""
import pytest
import polars as pl
from src.pipelines.customer import CustomerPipeline


@pytest.fixture
def test_snowflake_connection():
    """Set up test Snowflake environment."""
    # Create test schema and tables
    # Load test data
    # Yield connection
    # Cleanup
    pass


def test_customer_pipeline_end_to_end(test_snowflake_connection):
    """Test complete customer data pipeline."""
    pipeline = CustomerPipeline()
    
    # Extract
    raw_data = pipeline.extract()
    assert len(raw_data) > 0
    
    # Transform
    clean_data = pipeline.transform(raw_data)
    assert "email_token" in clean_data.columns
    assert "email" not in clean_data.columns
    
    # Validate quality
    checks = pipeline.validate_quality(clean_data)
    assert all(check.passed for check in checks)
    
    # Load
    rows_loaded = pipeline.load(clean_data)
    assert rows_loaded == len(clean_data)
```

## Configuration Management

```python
"""Configuration management with Pydantic."""
from pydantic import BaseModel, Field
from typing import Optional
import yaml


class SnowflakeConfig(BaseModel):
    """Snowflake connection configuration."""
    account: str
    user: str
    password: str
    warehouse: str
    database: str
    schema: str
    role: Optional[str] = None


class PipelineConfig(BaseModel):
    """Pipeline configuration."""
    api_url: str
    api_key: str
    batch_size: int = Field(default=100, ge=1, le=1000)
    snowflake: SnowflakeConfig
    pii_salt: str


def load_config(env: str = "dev") -> PipelineConfig:
    """Load configuration for environment."""
    with open(f"config/{env}.yaml") as f:
        data = yaml.safe_load(f)
    return PipelineConfig(**data)
```

## Logging

```python
"""Logging setup."""
import logging
import sys


def setup_logging(level: str = "INFO") -> None:
    """Configure logging for the application."""
    logging.basicConfig(
        level=level,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler("pipeline.log"),
        ],
    )
```

## Best Practices

1. **Use Polars over Pandas** for performance on large datasets
2. **Always validate data** with Pydantic schemas
3. **Implement deterministic PII masking** for join consistency
4. **Test with realistic data volumes** in integration tests
5. **Use type hints** throughout for IDE support
6. **Log at appropriate levels** (DEBUG for details, INFO for progress, ERROR for failures)
7. **Handle errors gracefully** with retries and clear messages
8. **Document complex transformations** with docstrings
9. **Keep functions pure** where possible for testability
10. **Use configuration files** rather than hardcoding parameters