
JIRA_TEMPLATES.md

ASOM v2 – Jira Issue Templates & Required Fields

⸻

1. Purpose

These Jira templates ensure that:
	•	requirements are testable
	•	scope is explicit
	•	controls are traceable
	•	evidence linkage is automatic
	•	governance friction is minimised

Principle:
If it isn’t captured in Jira, it doesn’t exist.

⸻

2. Required Jira Issue Types

ASOM v2 assumes the following Jira issue types:
	•	Epic
	•	Story
	•	Bug
	•	Release (or Release Epic)

Each has mandatory fields aligned to controls and gates.

⸻

3. Epic Template (Control-Scoped)

Issue Type: Epic
Purpose: Define business scope and control applicability

Epic Description Template

## Business Objective
<What problem is being solved?>

## In Scope
<Data products / pipelines / features>

## Out of Scope
<Explicit exclusions>

## Impacted Data Classification
- [ ] Non-sensitive
- [ ] Internal
- [ ] PII / PHI / Regulated

## Control Applicability (Initial)
- C-01 Change Authorisation
- C-02 Separation of Duties
- C-03 Requirements Traceability
- C-04 Data Classification & Handling
- C-05 Access Control
- C-06 Data Quality
- C-07 Reproducibility
- C-08 Incremental Correctness
- C-09 Observability
- C-10 Cost & Performance

## Release Target
- Planned release window:
- Target environments: QA / PROD

Mandatory Fields
	•	Business owner
	•	Data owner (if applicable)
	•	Planned release

⸻

4. Story Template (Test-First)

Issue Type: Story
Purpose: Deliver testable, traceable change

Story Description Template

## User Story
As a <role>
I want <capability>
So that <business value>

## Acceptance Criteria (Testable)
1. <Given/When/Then>
2. <Given/When/Then>

## Test Categories Required
- [ ] T1 Unit
- [ ] T2 Contract / Schema
- [ ] T3 Data Quality
- [ ] T4 Access Control
- [ ] T5 Idempotency
- [ ] T6 Incremental Correctness
- [ ] T7 Performance / Cost
- [ ] T8 Observability

## Control Mapping
- Related controls: C-xx, C-yy

## Definition of Done
- Tests implemented
- Tests executed in CI
- Evidence generated

Mandatory Fields
	•	Linked Epic
	•	Acceptance Criteria
	•	Test Categories (at least one)
	•	Control Mapping

⸻

5. Bug Template (Governed)

Issue Type: Bug
Purpose: Correct defects without bypassing controls

Bug Description Template

## Defect Description
<What is wrong?>

## Impact
<Data / users / reports impacted>

## Severity
- [ ] Low
- [ ] Medium
- [ ] High
- [ ] Critical

## Root Cause (if known)
<Optional>

## Fix Scope
<What will change?>

## Controls Impacted
- C-xx
- C-yy

## Tests Required
<List test categories>

Rules
	•	Bugs promoted beyond DEV still require:
	•	tests
	•	evidence
	•	CRQ inclusion

⸻

6. Release Issue Template (CRQ-Centric)

Issue Type: Release
Purpose: Aggregate scope and approvals

Release Description Template

## Release Summary
<High-level summary>

## Jira Scope
- Epics:
- Stories:
- Bugs:

## ServiceNow CRQ
- CRQ ID: SNOW-CRQ-XXXXX
- Approval status: Pending / Approved

## Control Coverage Summary
<Linked Confluence page>

## Environments
- QA target date:
- PROD target date:

Mandatory Fields
	•	CRQ ID
	•	Linked Epics
	•	Target environments

⸻

7. Workflow Expectations (High-Level)

Story Workflow

Backlog → Ready → In Progress → Code Review → Done

Rules:
	•	Cannot move to Done without:
	•	tests passing
	•	evidence generated

⸻

Release Workflow

Draft → QA Approval Pending → QA Approved → PROD Approval Pending → Released

Rules:
	•	Transitions to approval states require:
	•	CRQ state validation
	•	evidence completeness

⸻

8. Automation Rules (Conceptual)

Recommended Jira automation (conceptual):
	•	Block transition to Done if:
	•	Acceptance Criteria empty
	•	Test Categories not selected
	•	Warn if:
	•	Control mapping missing
	•	Sync Release status with CRQ state (read-only)

⸻

9. Anti-Patterns (Explicit)

The following are non-compliant:
	•	stories without acceptance criteria
	•	“test later” stories
	•	release issues without CRQ
	•	bugs bypassing test requirements
	•	manual status changes to bypass gates

⸻

10. Why This Works
	•	Engineers know what’s expected
	•	Governance gets structured data
	•	CI/CD can enforce rules
	•	Audit traceability is automatic
	•	ASOM overhead stays minimal

⸻

✅ JIRA_TEMPLATES.md — COMPLETE

⸻
