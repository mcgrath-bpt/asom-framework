---
name: workflow-examples
description: Worked examples of ASOM multi-agent workflows. Load when orchestrating sprints, onboarding new teams, or when the model needs to see what "good" looks like. Not needed for routine single-agent work.
---

# ASOM Workflow Examples

Reference examples showing how the agent team operates across different
scenarios. These illustrate the patterns defined in `CLAUDE.md` and the
coordination patterns in `skills/beads-coordination.md`.

> **When to load this skill:** Sprint initiation, multi-agent orchestration,
> onboarding, or when unsure how a workflow should play out. Not needed for
> single-agent tasks like "implement this story" or "run tests."

---

## Backlog Refinement (Continuous)

Discovery and refinement happen outside the sprint cadence. The BA and PO
work the backlog continuously so that refined stories are ready when sprint
planning arrives.

```
User: "I've dumped some ideas in the backlog — customer pipeline stuff.
       Can the BA take a look?"

Claude Response:
[BA Agent] Reviewing backlog...

Backlog items found: 3 items from PO
- "Ingest customer data from CRM API"
- "Mask PII fields before loading to warehouse"
- "Daily customer segment report"

Before drafting stories, I have questions:

Scope:
1. CRM API -- is this Salesforce, HubSpot, or custom? Pagination style
   matters for extraction design.
2. "Daily report" -- is this a Snowflake view, an email, or a BI
   dashboard? This affects whether it's a transform or analytics story.

Data:
3. Which fields are PII? Just email/phone, or also name/address?
4. Expected data volume? Thousands or millions of records per day?

Boundaries:
5. Is backfill in scope, or just incremental going forward?
6. Any SLA on data freshness (e.g., must be loaded by 6am)?

Assumptions I'm making (please confirm or correct):
- Target is Snowflake DEV environment
- No real-time requirements (batch is acceptable)
- We're building the pipeline, not the reporting layer

[Waiting for PO input before drafting stories]
```

```
User: "Salesforce, mask email and phone with SHA-256, daily Snowflake
       view is fine, ~50k records/day, incremental only, no SLA yet"

Claude Response:
[BA Agent] Thank you. Capturing PO decisions on the epic and drafting
stories based on your input...

[Creates draft stories: S001-S003 with acceptance criteria]
[Captures PO decisions as bead comments]

Draft stories ready. These can go through team grooming whenever you
want, or I can involve Dev/QA/Governance now for a quick review.
```

## Grooming Session

```
User: "Let's groom them"

Claude Response:
[BA Agent] Presenting S001-S003 for team refinement.

[Switching to Dev Agent for feasibility review]

[Dev Agent] Reviewing S001-S003:
- S001: Salesforce pagination uses cursor-based API. AC looks right.
  Suggest: add AC for rate-limit handling (SF enforces 100 req/15min).
- S003 depends on S002 output schema -- make dependency explicit.

[Switching to QA Agent for testability review]

[QA Agent] Reviewing S001-S003:
- S001 AC2 ("handles pagination correctly") is not testable. Suggest:
  "retrieves all records across pages when result > page size."
- S003 AC1: how do we test freshness? Suggest: "view references
  load_date = current_date."

[Switching to Governance Agent for control review]

[Governance Agent] Reviewing S001-S003:
- S002 (PII masking): C-04 covered. Add C-05 (access control) --
  who can see unmasked data in raw layer?

[Switching to BA Agent]

[BA Agent] Incorporating team feedback:
- S001: Added rate-limit AC (Dev), revised pagination AC (QA)
- S002: Added RBAC AC for raw layer (Governance, C-05)
- S003: Explicit dependency on S002, revised freshness AC (QA)
- All decisions captured as comments on story beads

Stories S001-S003 now marked workflow:refined. Ready for sprint planning.
```

## Sprint Initiation

Sprint planning consumes already-refined stories. If stories aren't refined yet,
the SM flags it and the BA refinement workflow runs first.

```
User: "Let's start Sprint 1 to build the customer data pipeline"

Claude Response:
[Scrum Master] Initiating Sprint 1

Sprint Goal: Build customer data pipeline with PII governance
Run-log created: [bead-id] (--type chore, labels: run-log, sprint:1)

Backlog check: 3 refined stories available (S001-S003, all DoR met).

Step 1: Control applicability + PDL Impact Assessment
[Switching to Governance Agent]

[Governance Agent] Performing unified kickoff assessment for Sprint 1...

Control Applicability:
Applicable controls: C-01 (Change Auth), C-02 (SoD), C-03 (Traceability),
  C-04 (Data Classification), C-05 (Access Control), C-06 (DQ), C-07 (Reproducibility)
Evidence plan: 7 controls require evidence before G3 (QA promotion)

PDL Impact Assessment:
├─ Requirements: PRODUCED (via stories + ACs) | C-03
├─ Architecture Handbook: UPDATE REQUIRED | C-03
│  └─ T001 → Dev Agent
├─ Security Assessment: N/A (no PII in scope) | C-04
├─ Test Strategy: REFERENCED (Master v2.1) | C-06, C-08
├─ IQ Evidence: PRODUCED (via TDD) | C-06
├─ OQ Evidence: REQUIRED | C-06
│  └─ T002 → QA Agent
├─ ITOH: UPDATE REQUIRED | C-09
│  └─ T003 → Dev Agent
├─ Release Notes: REQUIRED | C-01, C-03
│  └─ T004 → Dev Agent
└─ Change Request: PRODUCED (at G3) | C-01

PDL Tasks: T001-T004 created and assigned
PDL Status: 33% complete (4 tasks to track, 5 items auto-produced)

Step 2: Sprint planning
[Switching to Scrum Master]

[Scrum Master] Sprint plan complete.
- Committed: 3 stories (S001-S003), 21 story points
- Duration: 2 weeks
- Gate readiness: G1 per PR (feature branches), G3 at sprint end
- Evidence plan: 7 controls to satisfy
- PDL plan: 4 tasks tracked (T001-T004), 5 items auto-produced
- Stories pre-refined: all 3 passed DoR with grooming decisions captured
- Risks: Salesforce API rate limits (mitigated in S001 design)

Sprint 1 ready to begin. Next: Dev Agent to implement S001 on
feature/S001-salesforce-extraction.
```

## Story Implementation

```
User: "Implement S001: Extract customer data from API"

Claude Response:
[Dev Agent] Implementing S001 using TDD

Phase 1: RED (Write failing tests)
[Creates test_customer_extractor.py with test cases]
[Runs tests: FAILED as expected - no implementation yet]

Phase 2: GREEN (Minimum code to pass)
[Implements CustomerExtractor class]
[Runs tests: PASSED - basic functionality works]

Phase 3: REFACTOR (Improve quality)
[Refactors for readability and maintainability]
[Adds type hints, docstrings, error handling]
[Runs tests: STILL PASSED - quality improved]

Implementation complete:
- Tests: 8 unit tests, all green
- Code: src/extract/customers.py (87% coverage)
- Quality: Refactored, documented, type-hinted
- PR: #123 with linked Jira S001
- Note: Evidence entries will be created by CI on PR merge (G1 gate)

Handoff to: QA Agent for validation coordination
Status: S001 marked "in-review" in Beads
Awaiting: G1 (PR merge gate) pass
```

## Quality Validation

```
User: "Validate S001"

Claude Response:
[QA Agent] Coordinating validation of S001

TDD Process Verification:
- Tests written before implementation (commit history confirms)
- RED phase documented (initial test failures)
- GREEN phase achieved (tests pass with implementation)
- REFACTOR phase completed (code quality improved)

Test Execution Summary:
- Functional tests: All passing (8/8)
- Data quality tests: All passing (5/5) -- C-06 evidence
- PII masking tests: All passing (3/3) -- C-04 evidence
- Code coverage: 87% (exceeds 80% target)

Code Review Observations:
- Code quality: Clean, well-documented
- Tests comprehensive and focused
- Type hints used throughout
- Minor: One function could use better naming

QA Execution Report: Published
Recommendation: Ready for governance verification

Handoff to: Governance Agent for evidence verification
Status: S001 marked "governance-review" in Beads
Note: Human QA Engineer should review QA execution report
```

## Evidence Verification

```
User: "Verify S001"

Claude Response:
[Governance Agent] Verifying evidence + PDL completeness for S001

Evidence Ledger Check (applicable controls):
- C-03 (Traceability): Jira S001 linked to PR #123, AC present
- C-04 (Data Classification): PII masking test results in ledger (CI-generated)
- C-05 (Access Control): RBAC validation test results in ledger (CI-generated)
- C-06 (DQ Controls): DQ test results in ledger (CI-generated)
- C-07 (Reproducibility): Commit SHA and build config recorded

PDL Completeness Check:
- T001 (Architecture Handbook): Complete
- T002 (OQ Evidence): Complete
- T003 (ITOH): INCOMPLETE — monitoring procedures not yet documented
- Auto-produced items: Requirements, IQ, Traceability, CRQ all present

Evidence Status: All applicable controls have passing evidence
PDL Status: Incomplete — T003 (ITOH) outstanding
Evidence Provenance: All entries produced by CI pipeline (authoritative)

VERIFICATION STATUS: Incomplete
REASON: PDL task T003 (ITOH update) required before G3
RECOMMENDATION: Dev Agent to complete T003, then re-verify

Note: This is a verification report, not an approval.
Human Governance/Quality reviewer should confirm.
Human Release Approver action required for G3 (QA promotion).

Status: S001 verification report published
```

## Sprint Status Check

```
User: "What's our sprint status?"

Claude Response:
[Scrum Master] Sprint 1 Status Report (Day 7/14)

Progress:
- Committed: 32 story points
- Completed: 20 story points
- Remaining: 12 story points
- On track: Yes

Story Status:
- S001: Customer extraction - verification complete, awaiting human approval
- S002: PII masking - verification complete, awaiting human approval
- S003: Snowflake schema - In Progress (Dev)
- S004: Data quality checks - Ready
- S005: Access controls - Ready

Gate Readiness (G3 -- QA promotion):
- Evidence: 5/7 controls satisfied
- Remaining: C-09 (Observability), C-10 (Cost guardrails) -- pending S004, S005
- PDL: 2/3 tasks complete (T003 ITOH outstanding -- assigned to Dev)
- CRQ: SNOW-CRQ-001 created, pending approval
- Human approval: Not yet requested

Metrics:
- Velocity: Projected 28 points
- Defects: 2 (both minor, resolved)
- Test coverage: 87%
- Evidence ledger entries: 12

Impediments: None

Next: Dev Agent to complete S003, then QA validation
```

## Emergency Override

```
User: "Critical data feed is down, we need to push this fix NOW.
       DQ tests aren't complete but the fix is validated manually."

Claude Response:
[Scrum Master] Emergency override situation identified

This requires C-11 Emergency Override Protocol.

Step 1: Assess override eligibility
[Switching to Governance Agent]

[Governance Agent] Override assessment for hotfix release

Override Eligibility:
- Business impact: Critical (customer SLA at risk)
- Fix scope: Single config change
- G1/G2 passed: Yes (overrides only apply to G3/G4)
- Standard path timeframe: Estimated 2 days for full DQ suite
- Override justified: Yes -- customer impact exceeds evidence delay risk

Controls to defer:
- C-06 (DQ tests): Not yet executed for PROD data volumes
- C-09 (Observability): Alert thresholds not yet validated

Compensating controls during remediation window:
- Manual monitoring by on-call engineer
- Rollback plan documented and tested
- Fix validated manually against sample data

Override requirements:
1. Emergency Approver sign-off (senior to Release Approver)
2. CRQ created with override flag in ServiceNow
3. Remediation deadline: 5 business days from promotion
4. Post-incident review scheduled within 10 business days

Human action required:
  - Emergency Approver: Approve override via ServiceNow
  - On-call: Confirm manual monitoring in place
  - Governance: Will verify remediation evidence by deadline

[Scrum Master] Override tracked
- Override ID: EL-2026-000200
- Remediation deadline: [Date + 5 business days]
- Post-incident review: [Date + 10 business days]
- Status: Awaiting Emergency Approver sign-off

Note: This is a time-bound deferral, not a bypass.
All deferred evidence must be produced within the remediation window.
Missed remediation triggers automatic escalation to governance leadership.
```

## Sprint Closure + Retrospective

```
User: "Let's close Sprint 1"

Claude Response:
[Scrum Master] Initiating Sprint 1 closure

Step 1: Confirm completeness
All stories complete (S001-S003). All PDL tasks closed (T001-T003).
Governance verification: COMPLETE.
Run-log (chr.9): All step transitions recorded.

Step 2: G3 gate resolution
[Gate G3 requires human Release Approver sign-off]
Human action: Release Approver approves via CRQ → G3 gate closed.

Step 3: Close stories and epic
S001: Closed (reason: All ACs met. G3 approved.)
S002: Closed (reason: All ACs met. G3 approved.)
S003: Closed (reason: All ACs met. G3 approved.)
Epic: Closed (reason: Sprint 1 complete.)
Run-log: Closed with final summary.

Step 4: Retrospective
[Creates retrospective bead]

What went well:
- [Observations from all agents]

What to improve:
- [Observations from all agents]

Action items:
- Sprint-level: AI-001, AI-002, ... (for Sprint 2 backlog)
- Framework-level: FW-001, FW-002, ... (for framework backlog)

[Framework items raised as beads in framework repo]
[Sprint items carried into Sprint 2 planning]

Sprint 1 closed. Ready for Sprint 2 planning.
```

## Example Handoffs

### BA → Dev
```
[BA Agent] Story S001 refined and ready

Summary:
- Acceptance criteria with PII masking requirements (C-04)
- Test requirements mapped to T1 (unit), T3 (DQ), T4 (security)
- Documented API endpoint and data sources
- Governance requirements included per control assessment

Handoff to: Dev Agent
Status: S001 marked "ready" in Beads
Next steps: Implement with TDD. PR must satisfy G1 gate (linked Jira, passing tests).
```

### Dev → QA
```
[Dev Agent] Implementation complete for S001

Summary:
- Python extraction script with pagination (src/extract/customers.py)
- Snowflake DDL with PII masking (sql/ddl/customers.sql)
- Unit tests: 87% coverage
- PR created: #123 (linked to S001)

Evidence: CI will produce test result entries for C-04, C-05, C-06 on PR merge (G1)

Handoff to: QA Agent
Status: S001 marked "in-review" in Beads
Next steps: Coordinate test execution, publish QA execution report
```

### QA → Governance
```
[QA Agent] Validation coordinated for S001

Summary:
- All functional tests passing (8/8)
- Data quality validated (5/5 checks) -- C-06 evidence
- PII masking verified -- C-04, C-05 evidence
- Code review observations documented
- QA execution report published

Handoff to: Governance Agent
Status: S001 marked "governance-review" in Beads
Next steps: Verify evidence completeness in ledger, publish verification report
Note: Human QA should review execution report
```

### Governance → Human Action Required
```
[Governance Agent] Evidence verification complete for S001

Summary:
- All applicable controls verified: C-03, C-04, C-05, C-06, C-07
- Evidence provenance validated (all CI-generated)
- No gaps identified
- Verification report published

Status: S001 evidence complete
Human action required:
  - Human Governance/Quality: Review verification report
  - Human Release Approver: Approve G3 (QA promotion) via ServiceNow CRQ
```

## Operating Mode Examples

### Single Agent Deep Work
```
User: "Act as Dev Agent for the rest of this conversation"

Claude: [Assumes Dev Agent role]
[Loads DEV-AGENT.md and docs/ASOM_CONTROLS.md]
[Loads python-data-engineering.md, snowflake-development.md, governance-requirements.md]

[Dev Agent] Ready to implement.

I'll maintain the Developer perspective for this conversation, focusing on:
- Implementation quality with TDD
- Test coverage across T1-T8 categories
- Governance control implementation (C-04, C-05, etc.)
- Code documentation

Reminder: I draft code and tests. CI produces evidence. Human approval required for promotion.

What would you like me to build?
```

### Multi-Agent Workflow
```
User: "Take S001 from requirements through to deployment readiness"

Claude: [Orchestrates full workflow]

Phase 1: [BA Agent] Requirements → acceptance criteria with control traceability
Phase 2: [Dev Agent] Implementation (TDD) → G1 gate (PR merge)
Phase 3: [QA Agent] Validation → QA execution report
Phase 4: [Governance Agent] Evidence verification → verification report
Phase 5: [Scrum Master] Status update → gate readiness summary

S001 evidence complete.
Human action required: Release Approver to approve G3 via ServiceNow.
```
