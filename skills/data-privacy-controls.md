---
name: data-privacy-controls
description: PII protection techniques and data privacy controls for compliance with GDPR and other privacy regulations. Covers masking, encryption, anonymization, and detection methods. Essential for Governance Agent to validate privacy protection and for Dev Agent to implement controls.
---

# Data Privacy Controls

## Overview

This skill covers techniques for protecting Personally Identifiable Information (PII) and implementing data privacy controls to comply with GDPR, CCPA, and other privacy regulations.

## PII Classification

### What is PII?

**Direct Identifiers** (can identify individual directly):
- Name (first, last, full)
- Email address
- Phone number
- Social Security Number (SSN)
- Passport number
- Driver's license number
- Physical address
- IP address
- Biometric data (fingerprints, facial recognition)

**Quasi-Identifiers** (can identify when combined):
- Date of birth
- Gender
- Postal code
- Occupation
- Employer
- Education level

**Sensitive PII** (special category data under GDPR):
- Health records (PHI - Protected Health Information)
- Financial account numbers
- Racial or ethnic origin
- Political opinions
- Religious beliefs
- Sexual orientation
- Genetic data
- Criminal convictions

## PII Protection Methods

### 1. Masking (Pseudonymization)

**Purpose:** Replace PII with tokens that preserve some utility while preventing identification

**When to use:**
- Need to join data across systems
- Analytics require consistent identifiers
- Reversibility not needed

#### SHA256 Hashing (Deterministic)

**Best for:** Email addresses, usernames, account IDs

**Pattern:**
```python
import hashlib

def mask_email_deterministic(email: str, salt: str = "") -> str:
    """
    Mask email with deterministic SHA256 hash.
    
    Same email always produces same hash (enables joins).
    Adding salt makes it harder to reverse via rainbow tables.
    """
    data = f"{email.lower()}{salt}"
    return hashlib.sha256(data.encode()).hexdigest()

# Usage
masked = mask_email_deterministic("alice@example.com", salt="project-salt")
# Result: "3f7b9c8d..." (always same for alice@example.com with this salt)
```

**Snowflake implementation:**
```sql
-- Create masking function
CREATE OR REPLACE FUNCTION MASK_EMAIL(email VARCHAR, salt VARCHAR)
RETURNS VARCHAR
AS
$$
    SHA2(LOWER(email) || salt, 256)
$$;

-- Use in view
CREATE OR REPLACE VIEW CUSTOMER_CURATED AS
SELECT
    customer_id,
    MASK_EMAIL(email, 'project-salt') AS email_token,
    -- other fields
FROM CUSTOMER_RAW;
```

**Pros:**
- Deterministic (same input = same output)
- Enables joins across masked datasets
- Fast to compute

**Cons:**
- Not reversible (can't get original back)
- Vulnerable to rainbow table attacks without salt
- Not suitable if you need original value later

---

#### bcrypt/scrypt (One-Way Hashing)

**Best for:** Passwords, security credentials

**Pattern:**
```python
import bcrypt

def hash_password(password: str) -> str:
    """
    Hash password with bcrypt (slow, secure).
    
    Includes random salt automatically.
    Computational cost makes brute force attacks infeasible.
    """
    salt = bcrypt.gensalt(rounds=12)  # Higher rounds = slower but more secure
    hashed = bcrypt.hashpw(password.encode(), salt)
    return hashed.decode()

def verify_password(password: str, hashed: str) -> bool:
    """Verify password against hash."""
    return bcrypt.checkpw(password.encode(), hashed.encode())

# Usage
hashed = hash_password("user-password")
# Result: "$2b$12$..." (different each time due to random salt)

is_valid = verify_password("user-password", hashed)  # True
```

**Pros:**
- Very secure (slow computation prevents brute force)
- Random salt included automatically
- Industry standard for passwords

**Cons:**
- Not deterministic (same input = different output)
- Cannot use for joins
- Slow (intentionally)

---

### 2. Redaction (Partial Masking)

**Purpose:** Hide part of PII while keeping some information visible

**When to use:**
- Need to show last 4 digits for verification
- Customer service needs partial visibility
- Compliance allows partial exposure

#### Phone Number Redaction

**Pattern:**
```python
def redact_phone(phone: str) -> str:
    """
    Redact phone number, keeping last 4 digits.
    
    Input: "+1-555-123-4567" or "5551234567"
    Output: "XXX-XXX-4567"
    """
    # Remove non-digits
    digits = ''.join(c for c in phone if c.isdigit())
    
    if len(digits) < 4:
        return "XXX-XXX-XXXX"  # Too short, redact completely
    
    last_4 = digits[-4:]
    return f"XXX-XXX-{last_4}"

# Usage
redacted = redact_phone("555-123-4567")
# Result: "XXX-XXX-4567"
```

**Snowflake implementation:**
```sql
CREATE OR REPLACE FUNCTION REDACT_PHONE(phone VARCHAR)
RETURNS VARCHAR
AS
$$
    'XXX-XXX-' || RIGHT(REGEXP_REPLACE(phone, '[^0-9]', ''), 4)
$$;
```

#### SSN Redaction

**Pattern:**
```python
def redact_ssn(ssn: str) -> str:
    """
    Redact SSN, keeping last 4 digits.
    
    Input: "123-45-6789" or "123456789"
    Output: "XXX-XX-6789"
    """
    digits = ''.join(c for c in ssn if c.isdigit())
    
    if len(digits) != 9:
        return "XXX-XX-XXXX"
    
    last_4 = digits[-4:]
    return f"XXX-XX-{last_4}"
```

**Pros:**
- Preserves utility for verification
- Less privacy risk than full exposure
- User-friendly (recognizable)

**Cons:**
- Still reveals some information
- Not sufficient alone for strong privacy
- Not suitable for analytics

---

### 3. Tokenization (Reversible)

**Purpose:** Replace PII with random tokens, maintain mapping in secure vault

**When to use:**
- Need to retrieve original value later
- Strong security required
- Third-party tokenization service available

**Pattern:**
```python
import secrets
from typing import Dict

class TokenVault:
    """Secure token vault (simplified example)."""
    
    def __init__(self):
        self._vault: Dict[str, str] = {}  # token -> original
        self._reverse: Dict[str, str] = {}  # original -> token
    
    def tokenize(self, pii_value: str) -> str:
        """Replace PII with random token."""
        # Check if already tokenized
        if pii_value in self._reverse:
            return self._reverse[pii_value]
        
        # Generate random token
        token = f"TOK-{secrets.token_hex(16)}"
        
        # Store mapping
        self._vault[token] = pii_value
        self._reverse[pii_value] = token
        
        return token
    
    def detokenize(self, token: str) -> str:
        """Retrieve original PII (requires authorization)."""
        if token not in self._vault:
            raise ValueError("Token not found")
        
        return self._vault[token]

# Usage
vault = TokenVault()

token = vault.tokenize("alice@example.com")
# Result: "TOK-3f7b9c8d2e1a4b5c..."

original = vault.detokenize(token)
# Result: "alice@example.com"
```

**Production implementation:**
- Use dedicated tokenization service (e.g., Protegrity, HashiCorp Vault)
- Encrypt vault storage
- Strict access controls on detokenization
- Audit all detokenization operations

**Pros:**
- Reversible (can get original back)
- Strong security (tokens are random)
- Centralized control

**Cons:**
- Requires secure vault infrastructure
- Single point of failure
- Performance overhead

---

### 4. Encryption

**Purpose:** Protect data in transit and at rest using cryptographic algorithms

#### Encryption in Transit

**TLS/SSL for API calls:**
```python
import requests

# Always use https://
response = requests.get(
    "https://api.example.com/customers",
    verify=True  # Verify SSL certificate
)
```

**Snowflake connections:**
```python
import snowflake.connector

conn = snowflake.connector.connect(
    account='account.region',
    user='user',
    password='password',
    # TLS enabled by default in Snowflake
)
```

#### Encryption at Rest

**Snowflake (automatic):**
```sql
-- Snowflake encrypts all data at rest by default (AES-256)
-- No configuration needed
```

**S3 (server-side encryption):**
```python
import boto3

s3 = boto3.client('s3')

# Upload with encryption
s3.put_object(
    Bucket='data-bucket',
    Key='customers.parquet',
    Body=data,
    ServerSideEncryption='AES256'  # or 'aws:kms'
)
```

**Column-level encryption (when needed):**
```python
from cryptography.fernet import Fernet

# Generate key (store securely!)
key = Fernet.generate_key()
cipher = Fernet(key)

# Encrypt
encrypted = cipher.encrypt(b"sensitive data")

# Decrypt
decrypted = cipher.decrypt(encrypted)
```

---

### 5. Anonymization (Irreversible)

**Purpose:** Remove all identifying information, make re-identification impossible

**When to use:**
- Public datasets
- Research data
- No need for individual-level analysis

**Techniques:**

**Generalization:**
```python
def generalize_age(age: int) -> str:
    """Convert exact age to age range."""
    if age < 18:
        return "0-17"
    elif age < 30:
        return "18-29"
    elif age < 50:
        return "30-49"
    elif age < 65:
        return "50-64"
    else:
        return "65+"

def generalize_zipcode(zipcode: str) -> str:
    """Convert full zipcode to first 3 digits."""
    return zipcode[:3] + "XX"
```

**Aggregation:**
```sql
-- Don't expose individual records
SELECT
    age_range,
    gender,
    COUNT(*) AS customer_count,
    AVG(lifetime_value) AS avg_ltv
FROM customers
GROUP BY age_range, gender
HAVING COUNT(*) >= 5  -- k-anonymity (minimum 5 people per group)
```

**Pros:**
- Strongest privacy protection
- Safe for public release
- GDPR "right to be forgotten" compatible

**Cons:**
- Loses granularity
- Can't trace back to individuals
- Reduced analytical value

---

## PII Detection

### Automated PII Detection

```python
import re

def detect_email(text: str) -> bool:
    """Detect if text contains email address."""
    pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
    return bool(re.search(pattern, text))

def detect_phone(text: str) -> bool:
    """Detect if text contains phone number."""
    # US phone number patterns
    patterns = [
        r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b',  # 555-123-4567
        r'\b\(\d{3}\)\s?\d{3}[-.\s]?\d{4}\b',  # (555) 123-4567
    ]
    return any(re.search(p, text) for p in patterns)

def detect_ssn(text: str) -> bool:
    """Detect if text contains SSN."""
    pattern = r'\b\d{3}-\d{2}-\d{4}\b'
    return bool(re.search(pattern, text))

def scan_dataframe_for_pii(df) -> dict:
    """Scan DataFrame for PII exposure."""
    findings = {}
    
    for column in df.columns:
        sample = str(df[column].dropna().head(100).tolist())
        
        findings[column] = {
            'has_email': detect_email(sample),
            'has_phone': detect_phone(sample),
            'has_ssn': detect_ssn(sample)
        }
    
    return findings

# Usage
pii_findings = scan_dataframe_for_pii(curated_df)
pii_columns = [col for col, checks in pii_findings.items() 
               if any(checks.values())]

if pii_columns:
    raise ValueError(f"PII detected in curated layer: {pii_columns}")
```

---

## Data Privacy Principles

### GDPR Principles

1. **Lawfulness, fairness, transparency**
   - Have legal basis for processing
   - Be transparent about usage
   
2. **Purpose limitation**
   - Use data only for stated purpose
   - Don't repurpose without consent

3. **Data minimization**
   - Collect only what's needed
   - Don't store unnecessary PII

4. **Accuracy**
   - Keep data up to date
   - Allow correction requests

5. **Storage limitation**
   - Don't keep data longer than needed
   - Implement retention policies

6. **Integrity and confidentiality**
   - Protect against unauthorized access
   - Implement security controls

7. **Accountability**
   - Demonstrate compliance
   - Maintain audit trails

### Data Minimization in Practice

```python
# Bad: Collecting everything
SELECT * FROM customer_raw

# Good: Only what's needed
SELECT
    customer_id,
    MASK_EMAIL(email) AS email_token,  # Masked, not raw
    age_range,  # Generalized, not exact age
    -- Do NOT include: SSN, exact DOB, full address
FROM customer_raw
```

---

## Snowflake Privacy Patterns

### Row-Level Security (RLS)

```sql
-- Create row access policy
CREATE OR REPLACE ROW ACCESS POLICY customer_pii_policy
AS (region VARCHAR) RETURNS BOOLEAN ->
    CASE
        -- Data engineers see raw PII for all regions
        WHEN CURRENT_ROLE() = 'DATA_ENGINEER' THEN TRUE
        
        -- Regional analysts see only their region (masked)
        WHEN CURRENT_ROLE() = 'ANALYST_NORTH' AND region = 'NORTH' THEN TRUE
        WHEN CURRENT_ROLE() = 'ANALYST_SOUTH' AND region = 'SOUTH' THEN TRUE
        
        -- Everyone else: no access
        ELSE FALSE
    END;

-- Apply policy to table
ALTER TABLE CUSTOMER_RAW
    ADD ROW ACCESS POLICY customer_pii_policy ON (region);
```

### Column Masking Policies

```sql
-- Create masking policy for email
CREATE OR REPLACE MASKING POLICY email_mask AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
        WHEN CURRENT_ROLE() IN ('DATA_ENGINEER', 'COMPLIANCE_OFFICER')
            THEN val  -- See original
        ELSE SHA2(val, 256)  -- See masked
    END;

-- Apply to column
ALTER TABLE CUSTOMER_RAW
    MODIFY COLUMN email
    SET MASKING POLICY email_mask;
```

---

## Testing Privacy Controls

### Governance Test: No PII in Curated Layer

```python
def test_no_pii_in_curated_layer():
    """Governance requirement: No PII in curated layer."""
    df = load_curated_customers()
    
    # Email should be tokens (no @ symbol)
    assert not df['email_token'].str.contains('@').any(), \
        "Email addresses found in curated layer"
    
    # Phone should be redacted
    assert df['phone_redacted'].str.startswith('XXX-XXX-').all(), \
        "Phone numbers not properly redacted"
    
    # SSN should not exist
    assert 'ssn' not in df.columns, \
        "SSN column should not exist in curated layer"
    
    # Scan for any PII patterns
    pii_found = scan_dataframe_for_pii(df)
    pii_columns = [col for col, checks in pii_found.items() 
                   if any(checks.values())]
    
    assert len(pii_columns) == 0, \
        f"PII patterns detected in columns: {pii_columns}"
```

### Governance Test: Masking is Deterministic

```python
def test_pii_masking_deterministic():
    """PII masking must be deterministic for joins."""
    masker = PIIMasker(salt="test-salt")
    
    email = "test@example.com"
    
    # Same input should produce same output
    hash1 = masker.mask_email(email)
    hash2 = masker.mask_email(email)
    
    assert hash1 == hash2, "Masking is not deterministic"
    assert hash1 != email, "Email not actually masked"
    assert len(hash1) == 64, "SHA256 should produce 64-char hex"
```

---

## Common Privacy Violations to Avoid

### ❌ Don't: Log PII

```python
# Bad
logger.info(f"Processing customer: {email}")

# Good
logger.info(f"Processing customer: {customer_id}")
```

### ❌ Don't: Include PII in Error Messages

```python
# Bad
raise ValueError(f"Invalid email: {email}")

# Good
raise ValueError(f"Invalid email for customer {customer_id}")
```

### ❌ Don't: Store PII in URLs

```python
# Bad
url = f"https://api.example.com/report?email={email}"

# Good
url = f"https://api.example.com/report?customer_id={customer_id}"
```

### ❌ Don't: Expose PII in Analytics Layer

```sql
-- Bad: Raw PII accessible to analysts
CREATE VIEW analytics.customer AS
SELECT customer_id, email, phone  -- PII exposed!
FROM raw.customer;

-- Good: Only masked PII
CREATE VIEW analytics.customer AS
SELECT 
    customer_id,
    MASK_EMAIL(email) AS email_token,
    REDACT_PHONE(phone) AS phone_redacted
FROM raw.customer;
```

---

## Summary

**PII Protection Methods:**
1. **Masking** - SHA256 hashing (deterministic, joins)
2. **Redaction** - Partial hiding (XXX-XXX-4567)
3. **Tokenization** - Random tokens (reversible, needs vault)
4. **Encryption** - Cryptographic protection (transit & rest)
5. **Anonymization** - Complete de-identification (irreversible)

**When to Use:**
- **Analytics/Curated Layer**: Masking (SHA256) or Redaction
- **Passwords**: bcrypt hashing
- **Reversible**: Tokenization with secure vault
- **Public Data**: Anonymization
- **Transit**: Always TLS/SSL
- **Rest**: Encryption (Snowflake automatic)

**Testing:**
- Scan for PII in curated layers
- Verify masking is deterministic
- Test access controls (RBAC)
- Validate retention policies

**For ASOM:**
- All PII masked in curated layer
- Raw layer restricted to DATA_ENGINEER role
- Tests prove masking works (governance evidence)
- Audit trail of all PII access
