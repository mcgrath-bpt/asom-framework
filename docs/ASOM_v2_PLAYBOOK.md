
ASOM v2 PLAYBOOK

Agent-Assisted Scrum Operating Model
Enterprise-safe delivery for regulated cloud data platforms

⸻

How to Read This Playbook

This playbook has three reading paths:
```text
	•	Executives / ARB / Audit → Sections 1, 3, 6, 9
	•	Platform & Architecture → Sections 2, 3, 5
	•	Delivery Teams → Sections 4, 7, 8
```
You do not need to read it end-to-end to use it.

⸻

1. Executive Overview

1.1 Why ASOM Exists

Modern data platforms:
	•	change frequently
	•	carry regulatory risk
	•	increasingly use AI-assisted development
	•	must still satisfy enterprise SDLC, audit, and ITSM controls

Most organisations face a false choice:
	•	Move fast and weaken governance
	•	Stay safe and accept delivery friction

ASOM v2 removes that trade-off.

⸻

1.2 What ASOM v2 Is

ASOM v2 is an agent-assisted delivery operating model designed for:
	•	cloud data platforms (e.g. Snowflake-style warehouses)
	•	CI/CD-driven delivery
	•	Jira-based planning
	•	ServiceNow-based change approval
	•	regulated environments (SOX, GxP, ITGC)

It accelerates delivery without bypassing controls.

⸻

1.3 What ASOM v2 Is Not

ASOM v2 is not:
	•	autonomous deployment
	•	self-approving AI
	•	a replacement for Jira, Confluence, or ServiceNow
	•	a governance shortcut
	•	a tooling product

Core principle:
Agents assist. Systems enforce. Humans approve.

⸻

2. Operating Model

2.1 Roles

Human Roles (Authoritative)
	•	Developer
	•	QA Engineer
	•	Release Approver
	•	Governance / Quality
	•	Change Manager (ServiceNow)

Agent Roles (Non-Authoritative)
	•	Business Analyst Agent
	•	Developer Agent
	•	QA Agent
	•	Governance Agent
	•	Scrum Agent

Agents draft, analyse, and surface gaps.
They never approve, promote, or certify.

⸻

2.2 Separation of Duties (Non-Negotiable)

No actor (human or agent) may:
	•	author code and
	•	approve promotion and
	•	deploy to controlled environments

Separation of duties is enforced via:
	•	Git branch rules
	•	CI/CD gates
	•	ServiceNow approval states
	•	Environment access boundaries

If it is not technically enforced, it does not exist.

⸻

2.3 Environment Flow

```text
DEV  →  QA  →  PROD
        ▲        ▲
   Human approval  Human approval
   (ServiceNow)   (ServiceNow)
```

Exactly one CRQ per release governs QA and PROD.

⸻

3. Governance Spine (Why Audit Says Yes)

3.1 Control-Driven Model

ASOM v2 governs delivery through explicit control objectives, not documents.

Controls cover:
	•	change authorisation
	•	separation of duties
	•	data classification
	•	access control
	•	data quality
	•	reproducibility
	•	observability
	•	cost & performance

PDL items map to controls, not the other way around.

⸻

3.2 Evidence Ledger

All compliance evidence is:
	•	machine-generated
	•	traceable to commit + build + CRQ
	•	immutable once recorded

The Evidence Ledger:
	•	indexes evidence
	•	does not duplicate artifacts
	•	enables deterministic verification

Agents may reference evidence.
They may never create or modify it.

⸻

3.3 Gates (Blocking, Not Advisory)

ASOM v2 defines deterministic gates:

Gate	Purpose
PR Merge	Prevent untracked changes
Release Candidate	Lock scope + CRQ
Promote to QA	Enforce controls + approval
Promote to PROD	Final authorisation

If a gate fails, promotion stops.

⸻

4. Delivery Model (Why Engineers Don’t Hate It)

4.1 Test-First, Not Test-Theatre

ASOM v2 defines a test taxonomy aligned to real data-platform risks:
	•	logic correctness
	•	schema compatibility
	•	data quality
	•	access control
	•	idempotency
	•	incremental correctness
	•	performance & cost
	•	observability

A change is not Done unless required categories are covered.

⸻

4.2 Failure Is a Feature

When something is missing:
	•	the gate fails early
	•	the reason is explicit
	•	remediation is deterministic
	•	no late surprises

This reduces rework and audit stress.

⸻

5. Enterprise Integration Model

5.1 Jira

Jira is the system of record for:
	•	scope
	•	acceptance criteria
	•	delivery status

Templates enforce:
	•	testable requirements
	•	control mapping
	•	evidence traceability

⸻

5.2 ServiceNow

ServiceNow is the only system of record for:
	•	QA approval
	•	PROD approval
	•	change authority

ASOM:
	•	reads CRQ state
	•	validates approvals
	•	never replaces SNOW workflows

⸻

5.3 Confluence

Confluence is used for:
	•	narrative
	•	traceability
	•	audit explanation

It is not an evidence store.

⸻

6. Audit Walkthrough (Standalone)

For any PROD release, an auditor can:
	1.	Identify the CRQ
	2.	Retrieve Jira scope
	3.	Retrieve Evidence Ledger entries
	4.	Validate control coverage
	5.	Confirm human approvals
	6.	Confirm separation of duties

No screenshots.
No email chains.
No tribal knowledge.

⸻

7. Worked Reference Example (Summary)

A realistic data pipeline:
	•	fails QA promotion due to missing access-control evidence
	•	is blocked automatically
	•	is remediated
	•	passes QA and PROD with full traceability

This demonstrates:
	•	controls work
	•	gates are real
	•	agents accelerate but do not override

⸻

8. Failure Model (Safety Net)

ASOM v2 explicitly documents:
	•	hallucinated compliance
	•	agent overreach
	•	evidence fabrication
	•	approval bypass
	•	silent data drift
	•	cost explosions

Each has:
	•	a mitigation
	•	an enforcement point

Undocumented failures are uncontrolled risks.

⸻

9. Adoption & Pilot Model (Preview)

ASOM v2 is designed for incremental adoption:
	•	start with one team
	•	one pipeline
	•	one release
	•	observe before enforcing
	•	scale only when trusted

(Full 30–60–90 plan follows as a separate artifact.)

⸻

10. Final Positioning

ASOM v2 does not make delivery faster by weakening governance.
It makes delivery faster by making the compliant path the easiest path.

⸻

✅ ASOM v2 PLAYBOOK — COMPLETE

⸻
