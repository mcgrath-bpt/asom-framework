
CONTROL_CATALOG.md

ASOM v2 – Enterprise Control Catalog
Authoritative baseline for regulated data platforms

⸻

1. Purpose

This document defines the minimum enterprise control set enforced by ASOM v2.

These controls:
	•	are technology-agnostic
	•	align to regulated SDLC expectations (SOX / GxP / ITGC)
	•	map directly to PDL items
	•	are verified through machine-produced evidence
	•	are enforced through CI/CD gates and human approvals

Important:
Controls define what must be true.
Tooling defines how it is implemented.
Agents may assist, but cannot satisfy or approve controls.

⸻

2. Control Model Principles
	1.	Every control has:
	•	a clear control objective
	•	an explicit risk
	•	defined evidence requirements
	2.	Evidence:
	•	must be produced by authoritative systems
	•	must be traceable to a single CRQ per release
	3.	Verification:
	•	is deterministic
	•	blocks promotion when incomplete
	4.	“N/A” is allowed only with explicit justification and approval

⸻

3. Control Catalog (v2 Baseline)

⸻

C-01 — Change Authorization

Control Objective
Ensure that all changes are formally approved before promotion to QA and PROD.

Risk Addressed
Unauthorised or unreviewed changes reaching controlled environments.

Scope
	•	In scope: all releases promoted beyond DEV
	•	Out of scope: local development activities

Evidence Requirements

Evidence	Produced By	Source
Approved CRQ	ServiceNow	SNOW record
Linked Jira scope	Jira	Epic / Stories

Verification Rule
	•	Exactly one CRQ per release
	•	CRQ state = Approved
	•	CRQ references Jira release scope

Gate
	•	QA promotion
	•	PROD promotion

⸻

C-02 — Separation of Duties (SoD)

Control Objective
Ensure no individual or agent can approve or promote their own changes.

Risk Addressed
Self-approval leading to uncontrolled or fraudulent changes.

Evidence Requirements

Evidence	Produced By
Commit history	Git
Approval records	Jira / ServiceNow
Deployment identity logs	CI/CD

Verification Rule
	•	Author ≠ Approver
	•	Approver ≠ Deployer
	•	Governance verification ≠ Evidence producer

Gate
	•	QA promotion
	•	PROD promotion

⸻

C-03 — Requirements Traceability

Control Objective
Ensure all implemented changes trace back to approved business intent.

Risk Addressed
Scope creep or unapproved functionality.

Evidence Requirements

Evidence	Produced By
Jira stories	Jira
Acceptance criteria	Jira
Test references	CI/CD

Verification Rule
	•	All code changes reference Jira IDs
	•	All Jira stories have test coverage

Gate
	•	PR merge
	•	QA promotion

⸻

C-04 — Data Classification & Handling

Control Objective
Ensure data is handled according to its classification (e.g. PII, PHI).

Risk Addressed
Regulatory breaches and data exposure.

Evidence Requirements

Evidence	Produced By
Data classification metadata	Platform / Catalog
Handling rules	Policy config
Validation tests	CI/CD

Verification Rule
	•	Classification defined
	•	Handling rules enforced
	•	Tests validate enforcement

Gate
	•	QA promotion
	•	PROD promotion

⸻

C-05 — Access Control & Least Privilege

Control Objective
Ensure only authorised users and services can access data.

Risk Addressed
Unauthorised access or privilege escalation.

Evidence Requirements

Evidence	Produced By
RBAC policies	Platform export
Masking / row policies	Platform export
Access tests	CI/CD

Verification Rule
	•	Policies exist for target environment
	•	Tests confirm enforcement

Gate
	•	QA promotion
	•	PROD promotion

⸻

C-06 — Data Quality Controls

Control Objective
Ensure critical data quality rules are enforced.

Risk Addressed
Incorrect or misleading analytics and decisions.

Evidence Requirements

Evidence	Produced By
DQ rule definitions	Code
DQ execution results	CI/CD
Threshold justification	Jira / Confluence

Verification Rule
	•	Critical rules defined
	•	Rules executed
	•	Failures block promotion

Gate
	•	QA promotion

⸻

C-07 — Reproducibility

Control Objective
Ensure builds and data transformations are reproducible.

Risk Addressed
Inability to reproduce results during incidents or audits.

Evidence Requirements

Evidence	Produced By
Commit SHA	Git
Build config	CI/CD
Parameter records	CI/CD

Verification Rule
	•	Build references immutable artifacts
	•	Parameters versioned

Gate
	•	QA promotion
	•	PROD promotion

⸻

C-08 — Incremental Correctness

Control Objective
Ensure incremental and reprocessing logic behaves correctly.

Risk Addressed
Silent data corruption or duplication.

Evidence Requirements

Evidence	Produced By
Incremental tests	CI/CD
Re-run validation	CI/CD

Verification Rule
	•	Idempotency verified
	•	Incremental logic tested

Gate
	•	QA promotion

⸻

C-09 — Observability & Alerting

Control Objective
Ensure failures are detectable and actionable.

Risk Addressed
Undetected data pipeline failures.

Evidence Requirements

Evidence	Produced By
Alert configuration	Platform
Test alert triggers	CI/CD

Verification Rule
	•	Alerts configured
	•	Alert tests executed

Gate
	•	PROD promotion

⸻

C-10 — Cost & Performance Guardrails

Control Objective
Ensure changes do not introduce unacceptable cost or performance regressions.

Risk Addressed
Runaway platform costs or degraded SLAs.

Evidence Requirements

Evidence	Produced By
Baseline metrics	CI/CD
Regression checks	CI/CD

Verification Rule
	•	Guardrails defined
	•	Regressions flagged

Gate
	•	QA promotion
	•	PROD promotion (if material)

⸻

4. Relationship to PDL

Each PDL item must map to:
	•	one or more controls above
	•	corresponding evidence entries in the Evidence Ledger

PDL status:
	•	Produced → evidence exists
	•	Referenced → evidence linked
	•	N/A → justification approved

⸻

5. Governance Responsibility
	•	Controls are verified, not “owned”, by Governance
	•	Evidence is validated for completeness and provenance
	•	Failure to satisfy any applicable control blocks promotion

⸻

6. Versioning
	•	Control Catalog is versioned
	•	Changes require architectural approval
	•	Controls are additive by default

⸻

✅ CONTROL_CATALOG.md — COMPLETE

⸻
