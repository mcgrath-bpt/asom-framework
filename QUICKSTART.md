# ASOM Quick Start Guide

Get your first sprint running with complete PDL (Project Documentation List) governance.

## Prerequisites

Before starting Sprint 1:

1. **Issue tracker** set up (Beads, Jira, or similar)
2. **Development environment** configured (Python, Snowflake access)
3. **ASOM framework files** available (agents/, skills/)
4. **PDL requirements** understood (see PDL-REFERENCE.md)

## Sprint 1 Goal

**Build a customer data pipeline with complete PII governance and PDL compliance.**

Target:
- Extract customer data from REST API
- Mask PII (email, phone)
- Load to Snowflake with proper access controls
- **Complete all PDL artefacts**

## Day-by-Day Workflow

### Pre-Sprint: Epic Creation (Product Owner)

**You (as PO) create the epic:**

```bash
# In your issue tracker
Create Epic: E001
Title: "Customer Data Pipeline with PII Governance"
Description:
  Extract customer data from API, mask PII, load to Snowflake.
  Marketing team needs access to analyze customer segments.
  Must comply with GDPR (PII protection, audit trail, access controls).
```

---

### Day 1: Governance PDL Impact Assessment

**Load Governance Agent:**
```
Load agents/GOVERNANCE-AGENT.md and skills/pdl-governance.md

Perform PDL Impact Assessment for Epic E001
```

**Governance Agent creates PDL tasks:**

```markdown
PDL Impact Assessment for E001:

INITIATION & GOVERNANCE:
├─ Risk Registry → UPDATE REQUIRED
│  └─ Create T001: Document PII processing risk (assign to BA)
└─ Roadmap → PRODUCED (issue tracker roadmap)

ARCHITECTURE & SECURITY:
├─ Architecture Handbook → UPDATE REQUIRED
│  └─ Create T002: Document API integration pattern (assign to Dev)
└─ Privacy Impact → REQUIRED
   └─ Create T003: Complete DPIA for PII fields (assign to Governance)

REQUIREMENTS:
├─ Functional Spec → PRODUCED (via acceptance criteria)
└─ User Requirements → PRODUCED (via user stories)

TESTING:
├─ IQ Evidence → PRODUCED (via TDD)
└─ OQ Evidence → REQUIRED
   └─ Create T004: Create OQ test plan for business rules (assign to QA)

OPERATIONS:
└─ ITOH → UPDATE REQUIRED
   └─ Create T005: Document API monitoring procedures (assign to Dev)

PDL Tasks Created: T001-T005
PDL Status: 0% (5 tasks to complete)
```

**Result:** 5 PDL tracking tasks created and assigned.

---

### Day 2: BA Creates Stories

**Load BA Agent:**
```
Load agents/BA-AGENT.md and skills/pdl-governance.md

Create user stories for Epic E001
```

**BA Agent creates stories:**

```markdown
Story: S001
Title: Extract customer data from REST API
Priority: High

As a: Marketing Analyst
I need: Customer data loaded daily from the CRM API
So that: I can analyze customer segments and behavior

Acceptance Criteria:
1. Extract all customers from https://api.example.com/v1/customers
2. Handle pagination (100 records per page)
3. Store raw data in Snowflake CUSTOMER_RAW table
4. Email and phone fields present (will be masked in S002)
5. Process completes in <30 minutes

Test Requirements (TDD):
- Unit test: Pagination handles >100 records
- Unit test: API authentication works
- Integration test: Data loaded to Snowflake
- Data quality test: >95% email completeness

Technical Context:
- API: REST, JSON responses, API key auth
- Rate limit: 100 requests/minute
- Expected volume: ~50,000 customers

Dependencies: None

Governance Requirements:
- Raw layer contains PII (restricted access)
- Audit logging: _audit_user, _audit_timestamp
- Data retention: Raw data 30 days

Status: refined
```

```markdown
Story: S002
Title: Implement PII masking for curated layer
Priority: High

[Similar format...]
[Includes: Deterministic SHA256 for email, phone redaction]

Status: refined
```

**BA also handles PDL task:**

```markdown
Task: T001 - Update Risk Registry

Risks identified for E001:
1. PII Breach Risk
   - Description: Email/phone exposed if masking fails
   - Impact: High (GDPR violation, fines)
   - Probability: Low (with proper controls)
   - Mitigation: PII masking in curated layer, access controls, tests

2. API Availability Risk
   - Description: CRM API downtime blocks data refresh
   - Impact: Medium (stale data for marketing)
   - Probability: Medium
   - Mitigation: Retry logic, monitoring, SLA with CRM team

3. Data Quality Risk
   - Description: Incomplete/invalid customer data
   - Impact: Medium (poor analytics)
   - Probability: Medium
   - Mitigation: Data quality tests (>95% thresholds)

Status: T001 complete
```

**Result:** 
- 5 stories created (S001-S005)
- PDL task T001 complete (20% PDL done)

---

### Day 3-5: Development (TDD)

**Load Dev Agent:**
```
Load agents/DEV-AGENT.md, skills/testing-strategies.md, skills/python-data-engineering.md

Implement S001 using TDD
```

**Dev Agent implements with TDD:**

**Day 3 Morning - RED Phase:**
```python
# tests/unit/test_customer_extractor.py
def test_extract_handles_pagination():
    """API extraction should handle paginated responses."""
    extractor = CustomerExtractor()
    records = extractor.extract_all()
    assert len(records) > 100  # More than one page

# Run: pytest tests/unit/test_customer_extractor.py
# Result: FAILED (CustomerExtractor doesn't exist)
```

**Day 3 Afternoon - GREEN Phase:**
```python
# src/extract/customer_extractor.py
class CustomerExtractor:
    def extract_all(self):
        # Minimum code to pass
        customers = []
        page = 1
        while True:
            response = self._fetch_page(page)
            if not response.get('data'):
                break
            customers.extend(response['data'])
            page += 1
        return customers

# Run: pytest
# Result: PASSED
```

**Day 4 - REFACTOR Phase:**
```python
# Improve code quality while keeping tests green
class CustomerExtractor:
    """Extract customer data from CRM API with pagination."""
    
    def __init__(self, api_url: str = "https://api.example.com"):
        self.api_url = api_url
        self.session = requests.Session()
    
    def extract_all(self) -> List[Dict]:
        """
        Extract all customers with automatic pagination.
        
        Returns:
            List of customer dictionaries
        """
        return list(self._extract_pages())
    
    def _extract_pages(self) -> Iterator[Dict]:
        """Yield customers page by page."""
        # Refactored for clarity and performance
        # Tests still pass!
```

**Day 5 - Dev handles PDL tasks:**

```markdown
Task: T002 - Update Architecture Handbook

## Customer API Integration

**Purpose**: Daily customer data extraction from CRM

**Integration Pattern**: REST API → S3 landing → Snowflake RAW

**Data Flow**:
CRM API (JSON) → Python extractor → S3 (parquet) → Snowflake COPY

**Authentication**: API key (rotated quarterly, stored in Secrets Manager)

**Key Design Decisions**:
- S3 landing zone: Enables replay capability, decouples API from Snowflake
- Pagination: Handles large datasets (50K+ records)
- Deterministic PII masking: Allows joins across masked data

**Configuration**:
- Location: config/api_credentials.yaml
- Parameters: api_url, api_key, batch_size

**Monitoring**:
- Metrics: API response time, error rate, records processed
- Alerts: API 4xx/5xx >5%, no data >6 hours

**Related Artefacts**:
- Code: src/extract/customer_extractor.py
- Tests: tests/unit/test_customer_extractor.py
- Diagram: docs/architecture/customer-pipeline.png

Status: T002 complete
```

```markdown
Task: T005 - Update ITOH

## Customer API Operations

**Deployment**:
Prerequisites: API credentials in Secrets Manager, S3 bucket permissions
Steps: Deploy container, update env vars, run smoke test
Rollback: Revert to previous container version

**Monitoring**:
Metrics: API response time (<2s p95), error rate (<1%), records/run
Alerts: API errors >5% → page on-call, no data >6h → email team
Dashboard: Grafana - Customer Pipeline Health

**Troubleshooting**:
Problem: API 429 (rate limited)
Fix: Reduce batch size in config/api_credentials.yaml

Problem: No data in Snowflake
Check: S3 landing zone files, Snowflake COPY errors, API credentials

Status: T005 complete
```

**Result:**
- S001 implemented with TDD (87% coverage)
- PDL tasks T002, T005 complete (60% PDL done)

---

### Day 6-7: QA Validation

**Load QA Agent:**
```
Load agents/QA-AGENT.md, skills/testing-strategies.md, skills/data-quality-validation.md

Validate S001 implementation
```

**QA Agent validates:**

```markdown
## QA Validation Report: S001

**TDD Process Verification:**
✅ Tests written before implementation (commit history confirms)
✅ RED phase: Initial test failures documented
✅ GREEN phase: Implementation makes tests pass
✅ REFACTOR phase: Code quality improved, tests remain green

**Test Execution:**
✅ Unit tests: 8/8 passing
✅ Integration tests: 3/3 passing
✅ Coverage: 87% (exceeds 80% requirement)

**Code Quality:**
✅ Type hints present
✅ Docstrings complete
✅ Clean code (no duplication, good naming)
✅ Error handling appropriate

**Acceptance Criteria:**
✅ Extracts all customers from API
✅ Handles pagination (tested with 150 records)
✅ Stores in Snowflake CUSTOMER_RAW
✅ Completes in <30 minutes (actual: 8 minutes)

Result: APPROVED for governance review
```

**QA handles PDL task:**

```markdown
Task: T004 - Create OQ Test Plan

## OQ Test Plan: Customer Data Extraction

**Purpose**: Validate business rules operate correctly in QA environment

**Test Cases**:

OQ-001: Email Completeness
- Input: Extract 1000 customers from QA API
- Expected: >95% have email addresses
- Validation: Business rule enforced

OQ-002: Data Freshness
- Input: Check latest extraction timestamp
- Expected: Data <24 hours old
- Validation: Timeliness requirement met

OQ-003: Record Count Accuracy
- Input: Compare API count vs Snowflake count
- Expected: Counts match within 1%
- Validation: No data loss in pipeline

**Execution Date**: [Date]
**Environment**: QA
**Results**: All tests PASSED
**Evidence**: docs/qa-evidence/oq-customer-extraction/

Status: T004 complete
```

**Result:**
- S001 validated and approved
- PDL task T004 complete (80% PDL done)

---

### Day 8: Governance Certification

**Load Governance Agent:**
```
Load agents/GOVERNANCE-AGENT.md, skills/pdl-governance.md

Complete T003 and perform QA gate review for Sprint 1
```

**Governance completes own task:**

```markdown
Task: T003 - Privacy Impact Assessment

## DPIA: Customer Data Processing

**Data Collected**: customer_id, name, email, phone, address, purchase_history
**PII Fields**: email, phone
**Lawful Basis**: Legitimate interest (customer relationship management)
**Retention**: Raw 30 days, Curated (masked) 2 years
**Access Controls**: Raw layer DATA_ENGINEER only, Curated MARKETING_ANALYST

**Risks**:
- PII exposure: Mitigated by masking in curated layer
- Unauthorized access: Mitigated by RBAC
- Data breach: Mitigated by encryption, audit logging

**Compliance**: GDPR Article 6(1)(f), Data minimization principle applied

Status: T003 complete
```

**Governance performs QA Gate Review:**

```markdown
## QA Deployment Gate Review: Sprint 1

**REQUIREMENTS:**
✅ User stories have acceptance criteria (S001-S005)
✅ Stories approved via workflow

**TESTING:**
✅ IQ evidence exists (pytest results, 87% coverage)
✅ OQ test plan executed (T004 complete)
✅ Traceability: All stories have tests

**ARCHITECTURE:**
✅ Architecture Handbook updated (T002 complete)
✅ API integration documented

**SECURITY & PRIVACY:**
✅ Privacy impact assessment complete (T003)
✅ PII masking implemented (S002)
✅ Access controls configured

**OPERATIONS:**
✅ ITOH updated (T005 complete)
✅ Monitoring procedures documented

**PDL STATUS:**
✅ T001: Risk Registry - COMPLETE
✅ T002: Architecture Handbook - COMPLETE
✅ T003: Privacy Impact - COMPLETE
✅ T004: OQ Test Plan - COMPLETE
✅ T005: ITOH - COMPLETE

PDL Completeness: 100% ✅

**DECISION: APPROVE QA deployment**
All governance requirements met.
Evidence collected and archived.
```

**Result:**
- All PDL tasks complete (100%)
- QA deployment APPROVED

---

### Day 9: Deploy to QA

```bash
# Deploy to QA environment
./deploy.sh qa

# Smoke test
pytest tests/smoke/ --env=qa

# Monitor first execution
# Verify data loaded successfully
```

---

### Day 10: PROD Gate Review

**Governance performs PROD gate review:**

```markdown
## PROD Deployment Gate Review

**RE-VALIDATION:**
✅ No architecture changes since QA
✅ PDL items still current
✅ No new functionality added

**PROD-SPECIFIC:**
✅ IQ evidence for PROD environment
✅ Change Request created (CRQ-12345)
✅ Rollback procedures documented
✅ PROD access controls configured

**FINAL COMPLIANCE:**
✅ All governance controls tested in QA
✅ PII masking working correctly
✅ Audit trail complete
✅ No compliance violations

PDL Status: 100% complete and validated ✅

**DECISION: APPROVE PROD deployment**
Compliance certified ✅
```

**Result:** PROD deployment APPROVED

---

## Sprint 1 Complete!

### What You Built

**Functionality:**
- ✅ Customer data extracted from API
- ✅ PII properly masked
- ✅ Data loaded to Snowflake
- ✅ Access controls working
- ✅ Monitoring in place

**PDL Artefacts (100% complete):**
- ✅ T001: Risk Registry updated
- ✅ T002: Architecture Handbook current
- ✅ T003: Privacy Impact Assessment
- ✅ T004: OQ Test Evidence
- ✅ T005: ITOH up-to-date

**Quality:**
- ✅ 87% test coverage (IQ evidence)
- ✅ All tests passing
- ✅ TDD process followed
- ✅ Code reviewed and approved

**Governance:**
- ✅ PII protected
- ✅ Audit logging complete
- ✅ Compliance certified
- ✅ Audit-ready

## Key Learnings

### What Worked Well

1. **PDL Impact Assessment early** - Creating PDL tasks at epic start prevented last-minute scrambling
2. **TDD discipline** - Tests first made requirements clearer and prevented rework
3. **Agent role clarity** - Each agent knew their PDL responsibilities
4. **Continuous PDL tracking** - Daily progress prevented surprises at gate reviews

### Common Pitfalls Avoided

❌ **Don't**: Wait until end of sprint for PDL  
✅ **Do**: Create PDL tasks at epic start

❌ **Don't**: Write code before tests  
✅ **Do**: Follow RED → GREEN → REFACTOR

❌ **Don't**: Let Governance create all PDL artefacts  
✅ **Do**: Distribute to appropriate agents (BA/Dev/QA)

❌ **Don't**: Skip PDL tasks to "go faster"  
✅ **Do**: Complete PDL tasks - they'll block deployment anyway

## Next Sprint

Now you're ready for Sprint 2!

**Improvements to make:**
- More complex PII masking patterns
- Additional data quality checks
- Performance optimization
- Enhanced monitoring

**Framework refinements:**
- Update skills based on learnings
- Refine PDL task templates
- Improve handoff efficiency

---

## Need Help?

- **PDL workflow unclear?** → See `PDL-REFERENCE.md`
- **PDL task templates?** → See `skills/pdl-governance.md`
- **TDD patterns?** → See `skills/testing-strategies.md`
- **Agent roles?** → See `agents/[AGENT]-AGENT.md`
- **Overall philosophy?** → See `ASOM.md`

**Remember**: ASOM = TDD + PDL + Agentic Roles + Scrum

You're now operating with production-grade quality and complete governance! 🎉
