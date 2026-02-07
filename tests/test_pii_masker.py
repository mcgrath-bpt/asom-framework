"""
Tests for PII Masker -- demonstrates ASOM TDD and governance testing.

Test Categories Covered (per ASOM test taxonomy):
- T1 (Unit Tests): Logic correctness
- T3 (Data Quality): Validation rules
- T4 (Access Control / Security): PII masking enforcement
- T5 (Idempotency): Deterministic behaviour

Reference: docs/ASOM_CONTROLS.md (C-04, C-05)
"""
import pytest
from src.pii_masker import PIIMasker


# ---------------------------------------------------------------------------
# T1: Unit Tests (Logic Correctness)
# ---------------------------------------------------------------------------

class TestEmailMasking:
    """T1 -- core email masking logic."""

    def test_mask_email_returns_sha256_hex(self, masker):
        result = masker.mask_email("user@example.com")
        assert len(result) == 64  # SHA-256 hex digest length

    def test_mask_email_normalises_case(self, masker):
        assert masker.mask_email("User@Example.COM") == masker.mask_email("user@example.com")

    def test_mask_email_strips_whitespace(self, masker):
        assert masker.mask_email("  user@example.com  ") == masker.mask_email("user@example.com")

    def test_mask_email_rejects_invalid(self, masker):
        with pytest.raises(ValueError):
            masker.mask_email("not-an-email")

    def test_mask_email_rejects_empty(self, masker):
        with pytest.raises(ValueError):
            masker.mask_email("")


class TestPhoneRedaction:
    """T1 -- core phone redaction logic."""

    def test_redact_phone_standard_format(self, masker):
        assert masker.redact_phone("123-456-7890") == "XXX-XXX-7890"

    def test_redact_phone_digits_only(self, masker):
        assert masker.redact_phone("1234567890") == "XXX-XXX-7890"

    def test_redact_phone_with_country_code(self, masker):
        assert masker.redact_phone("+1-555-123-4567") == "XXX-XXX-4567"

    def test_redact_phone_too_short(self, masker):
        with pytest.raises(ValueError):
            masker.redact_phone("123")


# ---------------------------------------------------------------------------
# T4: Access Control / Security Tests (PII masking enforcement)
# ---------------------------------------------------------------------------

class TestPIIMaskingEnforcement:
    """T4 -- validates C-04 and C-05 controls."""

    def test_masked_email_contains_no_at_sign(self, masker):
        """Governance: no PII leakage through masked values."""
        result = masker.mask_email("user@example.com")
        assert "@" not in result

    def test_masked_phone_hides_full_number(self, masker):
        """Governance: phone prefix must not be recoverable."""
        result = masker.redact_phone("555-123-4567")
        assert "555" not in result[:7]
        assert result.startswith("XXX-XXX-")

    def test_different_emails_produce_different_masks(self, masker):
        """Security: collision resistance."""
        assert masker.mask_email("a@b.com") != masker.mask_email("c@d.com")

    def test_different_salts_produce_different_masks(self):
        """Security: salt isolation between environments."""
        m1 = PIIMasker(salt="salt-one")
        m2 = PIIMasker(salt="salt-two")
        assert m1.mask_email("user@example.com") != m2.mask_email("user@example.com")


# ---------------------------------------------------------------------------
# T5: Idempotency Tests (Deterministic behaviour)
# ---------------------------------------------------------------------------

class TestDeterminism:
    """T5 -- validates C-08 (incremental correctness)."""

    def test_email_masking_is_deterministic(self, masker):
        assert masker.mask_email("user@example.com") == masker.mask_email("user@example.com")

    def test_phone_redaction_is_deterministic(self, masker):
        assert masker.redact_phone("555-123-4567") == masker.redact_phone("555-123-4567")


# ---------------------------------------------------------------------------
# T3: Data Quality / Validation
# ---------------------------------------------------------------------------

class TestIsMasked:
    """T3 -- masked-state detection for DQ validation."""

    def test_detects_masked_email(self, masker):
        masked = masker.mask_email("user@example.com")
        assert masker.is_masked(masked, "email") is True

    def test_detects_unmasked_email(self, masker):
        assert masker.is_masked("user@example.com", "email") is False

    def test_detects_masked_phone(self, masker):
        assert masker.is_masked("XXX-XXX-7890", "phone") is True

    def test_detects_unmasked_phone(self, masker):
        assert masker.is_masked("555-123-4567", "phone") is False


class TestConstructor:
    """T1 -- constructor validation."""

    def test_rejects_empty_salt(self):
        with pytest.raises(ValueError):
            PIIMasker(salt="")
