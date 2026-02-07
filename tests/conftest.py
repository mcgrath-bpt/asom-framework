"""Shared pytest configuration and fixtures for ASOM reference tests."""
import pytest
from src.pii_masker import PIIMasker


@pytest.fixture
def masker():
    """PIIMasker with a deterministic test salt."""
    return PIIMasker(salt="test-salt")
