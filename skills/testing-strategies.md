---
name: testing-strategies
description: Testing strategies and patterns for data engineering, with emphasis on Test-Driven Development (TDD). Covers unit testing, integration testing, data quality testing, and test organization. Essential for Dev Agent (TDD implementation) and QA Agent (test validation).
---

# Testing Strategies

## Overview

This skill covers testing approaches for data engineering pipelines, with Test-Driven Development (TDD) as the foundation. All code development follows the RED → GREEN → REFACTOR cycle.

## Core Principle: Test-Driven Development (TDD)

### The TDD Cycle

**RED → GREEN → REFACTOR** is mandatory for all code:

1. **RED Phase: Write Failing Test**
   - Write test that defines what "done" means
   - Test should fail (no implementation yet)
   - Verify test actually fails (not broken test)

2. **GREEN Phase: Minimum Code to Pass**
   - Write simplest code to make test pass
   - Don't write extra features
   - Get to green as quickly as possible

3. **REFACTOR Phase: Improve Quality**
   - Improve code structure and readability
   - Add type hints, docstrings
   - Optimize performance if needed
   - All tests must remain green

### Why TDD for Data Engineering

**Benefits:**
- Requirements clarity (tests define behavior)
- Regression prevention (refactoring is safe)
- Documentation (tests show usage)
- Confidence (change code without fear)
- Design improvement (testable code is better code)

**For ASOM:**
- Tests serve as IQ evidence (PDL requirement)
- Proves governance controls work
- Enables autonomous agent work (safety net)

## Testing Pyramid for Data Engineering

```
        ┌─────────────┐
        │   E2E/      │  10% - Full pipeline validation
        │ Integration │
        ├─────────────┤
        │    Data     │  30% - Business logic, DQ checks
        │   Quality   │
        ├─────────────┤
        │    Unit     │  60% - Functions, transformations
        │    Tests    │
        └─────────────┘
```

### Unit Tests (60% of tests)
**Purpose:** Test individual functions and methods in isolation

**What to test:**
- Data transformations
- PII masking functions
- Validation logic
- Utility functions
- SQL query generation

**Example:**
```python
def test_mask_email_deterministic():
    """Email masking should be deterministic for joins."""
    masker = PIIMasker(salt="test-salt")
    email = "user@example.com"
    
    # Same input = same output
    result1 = masker.mask_email(email)
    result2 = masker.mask_email(email)
    
    assert result1 == result2
    assert result1 != email  # Actually masked
    assert len(result1) == 64  # SHA256 output
```

### Data Quality Tests (30% of tests)
**Purpose:** Validate data meets business rules and quality thresholds

**What to test:**
- Completeness (null rate, record count)
- Accuracy (value ranges, business rules)
- Consistency (referential integrity, cross-field)
- Timeliness (freshness, staleness)
- Uniqueness (duplicate detection)

**Example:**
```python
def test_customer_data_completeness():
    """Customer data should meet completeness thresholds."""
    df = extract_customers()
    
    # Email required for all customers
    email_completeness = 1 - (df['email'].isna().sum() / len(df))
    assert email_completeness >= 0.95, f"Email completeness: {email_completeness:.2%}"
    
    # Phone optional but should be >70%
    phone_completeness = 1 - (df['phone'].isna().sum() / len(df))
    assert phone_completeness >= 0.70, f"Phone completeness: {phone_completeness:.2%}"
```

### Integration Tests (10% of tests)
**Purpose:** Test components working together

**What to test:**
- API → S3 → Snowflake flow
- Multi-step transformations
- External dependencies (databases, APIs)
- Error handling and retries

**Example:**
```python
@pytest.mark.integration
def test_customer_pipeline_e2e():
    """Full pipeline: API extraction to Snowflake load."""
    # Extract from API
    extractor = CustomerExtractor()
    raw_data = extractor.extract_all()
    assert len(raw_data) > 0
    
    # Transform and mask PII
    transformer = CustomerTransformer()
    transformed = transformer.transform(raw_data)
    
    # Verify PII masked
    assert '@' not in str(transformed['email_token'])
    
    # Load to Snowflake
    loader = SnowflakeLoader()
    rows_loaded = loader.load(transformed, 'CUSTOMER_CURATED')
    assert rows_loaded == len(transformed)
```

## pytest Patterns

### Test Organization

```
tests/
├── unit/                           # Fast, isolated tests
│   ├── test_extractors.py
│   ├── test_transformers.py
│   ├── test_pii_masking.py
│   └── test_data_quality.py
├── integration/                    # Slower, external deps
│   ├── test_api_integration.py
│   ├── test_snowflake_integration.py
│   └── test_end_to_end.py
├── fixtures/                       # Test data
│   ├── sample_customers.json
│   └── sample_api_responses.json
└── conftest.py                     # Shared fixtures
```

### Fixtures for Data Engineering

**conftest.py:**
```python
import pytest
import pandas as pd
from pathlib import Path

@pytest.fixture
def sample_customer_data():
    """Sample customer data for testing."""
    return pd.DataFrame({
        'customer_id': [1, 2, 3],
        'email': ['alice@example.com', 'bob@example.com', 'carol@example.com'],
        'phone': ['555-0001', '555-0002', None],
        'created_at': ['2024-01-01', '2024-01-02', '2024-01-03']
    })

@pytest.fixture
def mock_api_client(monkeypatch):
    """Mock API client for testing without real API calls."""
    class MockAPIClient:
        def get(self, endpoint, **kwargs):
            # Return mock data
            return MockResponse({'data': [...]})
    
    return MockAPIClient()

@pytest.fixture
def snowflake_test_connection():
    """Real Snowflake connection for integration tests."""
    conn = snowflake.connector.connect(
        account=os.getenv('SNOWFLAKE_ACCOUNT'),
        user=os.getenv('SNOWFLAKE_USER'),
        password=os.getenv('SNOWFLAKE_PASSWORD'),
        database='TEST_DB',
        schema='TEST_SCHEMA'
    )
    yield conn
    conn.close()
```

### Parametrized Tests

```python
@pytest.mark.parametrize("input_email,expected_masked", [
    ("alice@example.com", True),
    ("bob@test.org", True),
    ("", False),  # Empty string should not be masked
    (None, False),  # None should not be masked
])
def test_email_masking_various_inputs(input_email, expected_masked):
    """Test email masking with various inputs."""
    masker = PIIMasker()
    result = masker.mask_email(input_email)
    
    if expected_masked:
        assert result != input_email
        assert '@' not in result
    else:
        assert result == input_email
```

### Mocking External Dependencies

```python
from unittest.mock import Mock, patch

def test_api_extraction_with_retry():
    """Test API extraction handles retries on failure."""
    mock_client = Mock()
    
    # Fail twice, succeed third time
    mock_client.get.side_effect = [
        Exception("Connection timeout"),
        Exception("Connection timeout"),
        {'data': [{'id': 1, 'name': 'Alice'}]}
    ]
    
    extractor = CustomerExtractor(api_client=mock_client)
    result = extractor.extract_with_retry(max_retries=3)
    
    assert len(result) == 1
    assert mock_client.get.call_count == 3
```

## Test Coverage

### Coverage Targets

**Minimum:**
- Overall: 80%
- Critical paths (PII masking, security): 95%+
- New code: 100% (via TDD)

**Measure coverage:**
```bash
pytest --cov=src --cov-report=html --cov-report=term
```

### Coverage Configuration

**setup.cfg or pyproject.toml:**
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "--cov=src",
    "--cov-report=html",
    "--cov-report=term-missing",
    "--cov-fail-under=80",
]

[tool.coverage.run]
source = ["src"]
omit = [
    "*/tests/*",
    "*/conftest.py",
    "*/__init__.py",
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
]
```

## Testing Governance Controls

### PII Masking Tests

```python
def test_no_pii_in_curated_layer():
    """Governance requirement: No PII in curated layer."""
    df = load_curated_customers()
    
    # Check for email addresses (should be tokens)
    assert not df['email_token'].str.contains('@').any()
    
    # Check for phone numbers (should be redacted)
    assert all(df['phone_redacted'].str.startswith('XXX-XXX-'))
    
    # Check for SSN (should be removed)
    assert 'ssn' not in df.columns
```

### Audit Logging Tests

```python
def test_audit_trail_completeness():
    """Governance requirement: Complete audit trail."""
    df = load_curated_customers()
    
    # All rows must have audit columns
    assert '_audit_user' in df.columns
    assert '_audit_timestamp' in df.columns
    assert '_audit_operation' in df.columns
    
    # No null audit values
    assert df['_audit_user'].notna().all()
    assert df['_audit_timestamp'].notna().all()
```

### Access Control Tests

```python
def test_rbac_enforcement():
    """Governance requirement: RBAC enforced."""
    # Test as MARKETING_ANALYST role
    with snowflake_connection(role='MARKETING_ANALYST') as conn:
        # Should have access to curated layer
        df = pd.read_sql("SELECT * FROM CUSTOMER_CURATED LIMIT 10", conn)
        assert len(df) > 0
        
        # Should NOT have access to raw layer
        with pytest.raises(snowflake.connector.errors.ProgrammingError):
            pd.read_sql("SELECT * FROM CUSTOMER_RAW LIMIT 10", conn)
```

## Test Naming Conventions

### Format

```
test_<what>_<condition>_<expected>
```

### Examples

```python
# Good naming
def test_mask_email_with_valid_input_returns_sha256_hash():
    """Clear what, condition, and expectation."""
    pass

def test_extract_customers_when_api_fails_raises_exception():
    """Describes failure scenario."""
    pass

def test_transform_handles_null_phone_gracefully():
    """Describes edge case handling."""
    pass

# Bad naming (too vague)
def test_masking():
    pass

def test_api():
    pass
```

## TDD Workflow Example

### Story: S001 - Extract customer data from API

**Step 1: RED - Write Failing Test**
```python
# tests/unit/test_customer_extractor.py
def test_extract_customers_returns_list_of_dicts():
    """Customer extraction should return list of customer dictionaries."""
    extractor = CustomerExtractor()  # Doesn't exist yet!
    
    customers = extractor.extract_all()
    
    assert isinstance(customers, list)
    assert len(customers) > 0
    assert 'customer_id' in customers[0]
    assert 'email' in customers[0]
```

**Run test:**
```bash
$ pytest tests/unit/test_customer_extractor.py
FAILED - NameError: CustomerExtractor is not defined
```
✅ Test fails as expected (RED phase complete)

**Step 2: GREEN - Minimum Code**
```python
# src/extract/customer_extractor.py
class CustomerExtractor:
    def extract_all(self):
        # Minimum code to pass test
        return [
            {'customer_id': 1, 'email': 'test@example.com'}
        ]
```

**Run test:**
```bash
$ pytest tests/unit/test_customer_extractor.py
PASSED
```
✅ Test passes (GREEN phase complete)

**Step 3: REFACTOR - Add Real Implementation**
```python
# src/extract/customer_extractor.py
import requests
from typing import List, Dict

class CustomerExtractor:
    """Extract customer data from REST API."""
    
    def __init__(self, api_url: str = "https://api.example.com"):
        self.api_url = api_url
        self.session = requests.Session()
    
    def extract_all(self) -> List[Dict]:
        """
        Extract all customers with pagination.
        
        Returns:
            List of customer dictionaries
        """
        customers = []
        page = 1
        
        while True:
            response = self._fetch_page(page)
            data = response.get('data', [])
            
            if not data:
                break
                
            customers.extend(data)
            page += 1
        
        return customers
    
    def _fetch_page(self, page: int) -> Dict:
        """Fetch single page of customers."""
        response = self.session.get(
            f"{self.api_url}/customers",
            params={'page': page, 'limit': 100}
        )
        response.raise_for_status()
        return response.json()
```

**Run test:**
```bash
$ pytest tests/unit/test_customer_extractor.py
PASSED
```
✅ Test still passes after refactoring (REFACTOR phase complete)

**Step 4: Add More Tests (Continue TDD)**
```python
def test_extract_customers_handles_pagination():
    """Should fetch all pages automatically."""
    # Write test first (RED)
    # Implement feature (GREEN)
    # Refactor if needed
    pass

def test_extract_customers_handles_api_errors():
    """Should handle API failures gracefully."""
    # RED → GREEN → REFACTOR
    pass
```

## Testing Anti-Patterns

### ❌ Don't: Write Tests After Code
```python
# Bad: Code already written, tests added later
def process_data(df):
    # Complex logic already implemented
    return result

# Now adding tests (not TDD)
def test_process_data():
    pass
```

### ✅ Do: Write Tests First
```python
# Good: Test defines behavior
def test_process_data_removes_duplicates():
    # Test written first
    pass

# Then implement to pass the test
```

### ❌ Don't: Test Implementation Details
```python
# Bad: Testing internal structure
def test_uses_specific_algorithm():
    assert extractor._internal_method() == "specific_value"
```

### ✅ Do: Test Behavior
```python
# Good: Testing public interface
def test_extract_returns_valid_customers():
    customers = extractor.extract_all()
    assert all('customer_id' in c for c in customers)
```

### ❌ Don't: Multiple Assertions Per Concept
```python
# Bad: Testing multiple things
def test_everything():
    # Tests extraction
    # Tests transformation
    # Tests loading
    # Tests validation
    assert True
```

### ✅ Do: One Concept Per Test
```python
# Good: Focused tests
def test_extraction():
    pass

def test_transformation():
    pass

def test_loading():
    pass
```

## Running Tests

### Development Workflow
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=term-missing

# Run specific test file
pytest tests/unit/test_customer_extractor.py

# Run specific test
pytest tests/unit/test_customer_extractor.py::test_extract_handles_pagination

# Run tests matching pattern
pytest -k "pii_masking"

# Run only unit tests (fast)
pytest tests/unit/

# Run integration tests (slower)
pytest tests/integration/ -v

# Watch mode (re-run on file changes)
pytest-watch

# Parallel execution (faster)
pytest -n auto
```

### CI/CD Integration
```bash
# In CI pipeline
pytest --cov=src --cov-report=xml --junitxml=test-results.xml
```

## Test Quality Metrics

### What to Track
- Test coverage: >80% overall
- Test speed: Unit tests <1s each
- Test reliability: No flaky tests
- Test maintenance: Tests updated with code

### Red Flags
- 🚩 Coverage dropping over sprints
- 🚩 Integration tests taking >5 minutes
- 🚩 Tests failing intermittently
- 🚩 Tests not updated when code changes

## Integration with ASOM

### For Dev Agent
- Follow TDD: RED → GREEN → REFACTOR
- All code starts with test
- Test coverage >80% required
- Tests are part of Definition of Done

### For QA Agent
- Validate TDD process followed (check commits)
- Run all tests in test suite
- Verify coverage meets thresholds
- Create additional OQ tests for business rules
- Generate test evidence for PDL (IQ/OQ)

### For Governance Agent
- Tests serve as IQ evidence (Installation Qualification)
- Test execution proves controls work
- Coverage reports show governance compliance
- Test results archived for audit

## Summary

**TDD is fundamental to ASOM:**
- Write test first (RED)
- Implement to pass (GREEN)
- Improve quality (REFACTOR)

**Test types:**
- Unit (60%): Fast, isolated
- Data Quality (30%): Business rules
- Integration (10%): End-to-end

**Coverage targets:**
- Overall: 80%
- Critical: 95%+
- New code: 100% (via TDD)

**Tests serve governance:**
- IQ/OQ evidence
- Prove controls work
- Enable confident refactoring
