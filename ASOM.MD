# ASOM: Agentic Scrum Operating Model

## What is ASOM?

**ASOM (Agentic Scrum Operating Model)** is a framework for building production-quality data engineering and data science solutions by operating as a specialised Scrum team through distinct agent roles, with Test-Driven Development (TDD) as a fundamental practice.

## Core Principles

### 1. Agentic Role Separation
Rather than one generalist approach, work is divided among five specialised agent roles:
- **Business Analyst** - Requirements and stories
- **Developer** - Implementation with TDD
- **QA** - Validation and quality assurance
- **Governance** - Compliance and documentation
- **Scrum Master** - Process and coordination

Each agent has:
- Clear responsibilities and boundaries
- Specific decision-making frameworks
- Defined handoff protocols
- Quality standards and metrics

### 2. Test-Driven Development (Fundamental)
TDD is not optional in ASOM - it's the foundation of how we build:

**Red → Green → Refactor** cycle is mandatory for all code:
1. **Red**: Write failing test first (defines requirements)
2. **Green**: Write minimum code to pass (implements requirements)
3. **Refactor**: Improve code quality (maintains standards)

**Why TDD is Fundamental to ASOM:**
- **Requirements clarity**: Tests force precise acceptance criteria
- **Quality by design**: Can't mark story "done" without passing tests
- **Regression prevention**: Refactoring is safe with test coverage
- **Documentation**: Tests document expected behavior
- **Confidence**: Enables autonomous agent work with safety net
- **Governance**: Tests prove compliance controls work

### 3. Scrum Methodology
ASOM follows standard Scrum practices:
- 2-week sprints with clear goals
- Daily coordination (async via Beads)
- Sprint planning, review, retrospective
- Definition of Ready and Definition of Done
- Product Delivery Log (PDL) for governance

### 4. Governance by Default
Every story includes:
- PII protection requirements
- Audit trail implementation
- Access control specifications
- Data retention policies
- Compliance validation

Governance is not an afterthought - it's built into acceptance criteria from the start.

### 5. Structured Coordination
All work tracked in Beads (git-backed issue tracker):
- Transparent progress visibility
- Clear agent handoffs
- Audit trail of decisions
- Impediment tracking

## The ASOM TDD Workflow

### Story Creation (BA Agent)
```markdown
User Story: Extract customer data from API

Acceptance Criteria:
1. API returns valid JSON for all customers
2. Email and phone are PII-masked in curated layer
3. Data quality: >95% completeness
4. Access: Raw layer restricted to DATA_ENGINEER role

**Test Requirements** (TDD):
- Unit test: API extraction handles pagination
- Unit test: PII masking produces deterministic tokens
- Integration test: End-to-end pipeline loads to Snowflake
- Data quality test: Completeness threshold validated
- Governance test: No PII in curated layer
```

### Implementation (Dev Agent - TDD Cycle)

**Phase 1: Write Tests First (RED)**
```python
# tests/unit/test_customer_extractor.py
def test_extract_handles_pagination():
    """API extraction should handle paginated responses."""
    extractor = CustomerExtractor()
    # This test will fail - we haven't implemented yet
    records = extractor.extract_all()
    assert len(records) > 100  # More than one page
    
def test_pii_masking_deterministic():
    """Email masking should be deterministic."""
    masker = PIIMasker()
    email = "test@example.com"
    # This test will fail - we haven't implemented yet
    assert masker.mask_email(email) == masker.mask_email(email)

# Run tests: pytest tests/unit/
# Result: FAILED (as expected - RED phase)
```

**Phase 2: Implement Minimum Code (GREEN)**
```python
# src/extract/customer_extractor.py
class CustomerExtractor:
    def extract_all(self):
        """Extract all customers with pagination."""
        records = []
        page = 1
        while True:
            response = self.api_client.get(f"/customers?page={page}")
            data = response.json()
            if not data:
                break
            records.extend(data)
            page += 1
        return records

# src/transform/pii_masker.py
import hashlib

class PIIMasker:
    def __init__(self, salt="default-salt"):
        self.salt = salt
    
    def mask_email(self, email):
        """Mask email with deterministic hash."""
        data = f"{email.lower()}{self.salt}"
        return hashlib.sha256(data.encode()).hexdigest()

# Run tests: pytest tests/unit/
# Result: PASSED (GREEN phase achieved)
```

**Phase 3: Refactor (REFACTOR)**
```python
# Improve code quality while keeping tests green
class CustomerExtractor:
    def __init__(self, api_client, batch_size=100):
        self.api_client = api_client
        self.batch_size = batch_size
    
    def extract_all(self) -> List[Dict]:
        """
        Extract all customers with pagination.
        
        Returns:
            List of customer records
        """
        return list(self._extract_pages())
    
    def _extract_pages(self) -> Iterator[Dict]:
        """Yield customers page by page."""
        page = 1
        while True:
            records = self._fetch_page(page)
            if not records:
                break
            yield from records
            page += 1
    
    def _fetch_page(self, page: int) -> List[Dict]:
        """Fetch single page of results."""
        response = self.api_client.get(
            "/customers",
            params={"page": page, "limit": self.batch_size}
        )
        return response.json().get("data", [])

# Run tests: pytest tests/unit/
# Result: Still PASSED (refactoring successful)
```

### Validation (QA Agent - TDD Validation)

QA Agent validates the TDD process was followed:

```markdown
## QA Validation for S001

### TDD Process Verification:
✅ Tests written before implementation (commit history confirms)
✅ RED phase: Initial test run shows failures
✅ GREEN phase: Implementation makes tests pass
✅ REFACTOR phase: Code improved while maintaining green tests

### Test Coverage:
- Unit tests: 15 tests, all passing
- Integration tests: 4 tests, all passing
- Coverage: 87% (exceeds 80% requirement)

### Test Quality:
✅ Tests are independent (can run in any order)
✅ Tests are repeatable (deterministic results)
✅ Tests are fast (<1s per test)
✅ Tests document expected behavior

### Code Quality:
✅ Clean code (refactored for readability)
✅ Well-documented (docstrings present)
✅ Type hints used throughout
✅ No code smells detected

Result: APPROVED for governance review
```

## ASOM Workflow with TDD

```
Epic Created (PO)
  ↓
[Governance] Define compliance requirements
  ↓
[BA] Create stories with TEST REQUIREMENTS in acceptance criteria
  ↓
[Dev] TDD Cycle for each story:
  │
  ├─ RED: Write failing tests first
  ├─ GREEN: Implement minimum code to pass
  ├─ REFACTOR: Improve code quality
  └─ Verify: All tests still green
  ↓
[QA] Validate TDD process was followed + Run additional tests
  ↓
[Governance] Validate compliance (tests prove controls work)
  ↓
[Scrum Master] Update metrics, mark done
  ↓
Story Complete (All tests green, governance certified)
```

## Why TDD Enables ASOM

### 1. Clear Requirements
Tests force BA Agent to write precise acceptance criteria:
```
❌ Vague: "Extract customer data"
✅ Testable: "Extract all customers with >100 records via pagination"
```

### 2. Safe Refactoring
With comprehensive tests, Dev Agent can refactor confidently:
- Improve performance without breaking functionality
- Change implementation approaches safely
- Clean up code without fear

### 3. Regression Prevention
As the codebase grows, tests prevent breaking existing features:
- New features don't break old features
- Refactoring doesn't introduce bugs
- Dependencies are validated

### 4. Living Documentation
Tests document how the system should behave:
```python
def test_pii_masking_prevents_reverse_lookup():
    """
    PII masking must be one-way to prevent reverse lookup.
    This is a GDPR requirement for pseudonymisation.
    """
    masker = PIIMasker()
    hash1 = masker.mask_email("test@example.com")
    # Should not be able to reverse the hash
    with pytest.raises(ReverseLookupError):
        masker.unmask_email(hash1)
```

### 5. Governance Confidence
Tests prove compliance controls work:
```python
def test_no_pii_in_curated_layer():
    """
    Governance requirement: No PII in curated layer.
    This test validates the requirement is met.
    """
    df = load_curated_customers()
    
    # Check for email addresses (should be tokens)
    assert not any('@' in str(val) for val in df['email_token'])
    
    # Check for phone numbers (should be redacted)
    assert all(
        str(val).startswith('XXX-XXX-') 
        for val in df['phone_redacted']
    )
```

## ASOM Definition of Done

A story is only "Done" when:

### Code Requirements:
- [ ] All tests written BEFORE implementation (TDD RED phase)
- [ ] All tests passing (TDD GREEN phase)
- [ ] Code refactored for quality (TDD REFACTOR phase)
- [ ] Test coverage >80% (>95% for critical paths)
- [ ] Integration tests validate end-to-end flow
- [ ] No test warnings or errors

### Governance Requirements:
- [ ] PII protection implemented and TESTED
- [ ] Audit logging implemented and TESTED
- [ ] Access controls implemented and TESTED
- [ ] Data quality thresholds validated via TESTS
- [ ] Compliance evidence collected (test results)

### Documentation Requirements:
- [ ] Code documented (docstrings, comments)
- [ ] Tests document expected behavior
- [ ] Data lineage diagram created
- [ ] PDL section completed
- [ ] Runbook updated

### Process Requirements:
- [ ] Beads updated with progress
- [ ] Code reviewed by QA Agent
- [ ] Governance validated by Governance Agent
- [ ] All handoffs completed
- [ ] Story marked "done" in Beads

## ASOM Anti-Patterns

### ❌ Writing Code Before Tests
```
Dev Agent: "I'll write the extraction logic first, then add tests"
```
**Why Bad**: Defeats the purpose of TDD, harder to test after the fact

**✅ Correct**: Write test first, then implement

### ❌ Testing Only Happy Path
```python
def test_extract_customers():
    """Only tests successful extraction"""
    assert len(extractor.extract()) > 0
```
**Why Bad**: Doesn't test edge cases, errors, or governance

**✅ Correct**: Test happy path, edge cases, errors, and governance

### ❌ Skipping Refactor Phase
```
Dev Agent: "Tests pass, I'm done"
```
**Why Bad**: Code quality degrades over time without refactoring

**✅ Correct**: Always refactor for quality while keeping tests green

### ❌ Low-Quality Tests
```python
def test_everything():
    """Tests extraction, masking, loading, and quality"""
    # 200 lines of test code
    assert True  # Everything worked!
```
**Why Bad**: Tests should be focused, one concept per test

**✅ Correct**: Small, focused tests with clear purpose

### ❌ Skipping Governance Tests
```
Dev Agent: "I implemented PII masking, no need to test it"
```
**Why Bad**: Can't prove compliance without tests

**✅ Correct**: Governance controls must have tests proving they work

## ASOM Metrics

Track these metrics to validate ASOM effectiveness:

### TDD Metrics:
- **Test-First Compliance**: % of code with tests written first
- **Test Coverage**: % of code covered by tests (target: >80%)
- **Test Quality**: Tests per function, assertions per test
- **Test Speed**: Average test execution time
- **Red-Green Cycle Time**: Time from RED to GREEN phase

### Quality Metrics:
- **Defect Density**: Defects per 1000 lines of code
- **Defect Escape Rate**: % defects reaching production
- **Code Quality**: Complexity, duplication, code smells
- **Refactoring Frequency**: % of stories including refactoring
- **Technical Debt**: Accumulated issues requiring cleanup

### Governance Metrics:
- **Compliance Coverage**: % of governance requirements with tests
- **PII Violations**: Count of PII exposures (target: 0)
- **Audit Trail Completeness**: % of actions logged
- **Policy Compliance**: % of stories meeting all policies
- **Evidence Collection**: % of stories with complete evidence

### Process Metrics:
- **Velocity**: Story points completed per sprint
- **Cycle Time**: Days from story creation to done
- **Lead Time**: Days from backlog to done
- **Handoff Efficiency**: Time between agent handoffs
- **Retrospective Actions**: % of action items completed

## ASOM Success Criteria

After implementing ASOM, you should see:

```markdown
### Technical Outcomes:
✅ Test coverage consistently >80%
✅ Defect rate decreasing sprint over sprint
✅ Code quality high and maintainable
✅ Refactoring frequent and safe
✅ Technical debt controlled

### Governance Outcomes:
✅ Zero PII violations in production
✅ 100% audit trail completeness
✅ All compliance requirements testable
✅ Evidence readily available for audits
✅ Governance validation automated via tests

### Process Outcomes:
✅ Predictable velocity (±10% variance)
✅ Clear agent handoffs with no confusion
✅ Sprint goals consistently met (>85%)
✅ Retrospectives drive continuous improvement
✅ Impediments resolved quickly (<48 hours)

### Team Outcomes:
✅ Confidence in making changes (tests provide safety net)
✅ Fast feedback loops (tests run in seconds)
✅ Clear ownership (agent roles are distinct)
✅ Quality built-in (not bolted-on after)
✅ Governance as enabler (not blocker)
```

## Getting Started with ASOM

### 1. Adopt TDD Mindset
Before writing any code:
- Write the test that defines what "done" means
- See it fail (RED)
- Write minimum code to pass (GREEN)
- Improve the code (REFACTOR)
- Repeat

### 2. Embrace Agent Roles
Separate concerns:
- BA defines WHAT and WHY
- Dev implements HOW with TDD
- QA validates TESTS and QUALITY
- Governance ensures COMPLIANCE
- Scrum Master coordinates PROCESS

### 3. Use the Framework
- Load CLAUDE.md for coordination
- Reference agent definitions for role clarity
- Follow skills for technical patterns
- Track everything in Beads

### 4. Start Small
Sprint 1: Single pipeline, full TDD, complete governance
- Prove the model works
- Learn the patterns
- Refine the process

### 5. Iterate and Improve
Every retrospective:
- What TDD practices worked well?
- Where did agent handoffs stumble?
- How can we improve test quality?
- What governance patterns emerged?

## ASOM Philosophy

**Test-Driven Development** isn't just a practice - it's the foundation that makes the Agentic Scrum Operating Model work:

- Tests define clear requirements (enables BA Agent)
- Tests guide implementation (enables Dev Agent)
- Tests validate quality (enables QA Agent)
- Tests prove compliance (enables Governance Agent)
- Tests provide metrics (enables Scrum Master Agent)

**Without TDD, ASOM is just role-playing.**
**With TDD, ASOM is a rigorous, quality-first operating model.**

---

**ASOM = Agentic Scrum + TDD + Governance**

This is how you build production-quality data engineering solutions with confidence, quality, and compliance.
