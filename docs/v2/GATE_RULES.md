
GATE_RULES.md

ASOM v2 – Promotion & Enforcement Gates
How “blocking deployment” actually works

⸻

1. Purpose

This document defines the mandatory enforcement gates used by ASOM v2 to control promotion of changes through the SDLC lifecycle.

Gates are:
	•	deterministic
	•	machine-enforced
	•	auditable
	•	independent of agent behaviour

Key principle:
A gate does not “recommend”.
A gate allows or blocks.

⸻

2. Gate Model Overview

ASOM v2 defines four primary gates:

Gate	Trigger	Purpose
G1	PR Merge	Prevent untracked / untested changes
G2	Release Candidate	Ensure release readiness
G3	Promote to QA	Enforce controls + human approval
G4	Promote to PROD	Enforce final approval + prod-specific controls

Each gate:
	•	has explicit entry conditions
	•	has explicit pass/fail rules
	•	produces evidence entries in the Evidence Ledger

⸻

3. Gate G1 — Pull Request (PR) Merge Gate

Objective

Prevent uncontrolled or untraceable code changes from entering the mainline.

Mandatory Conditions

Requirement	Verification Source
Linked Jira story	Git / Jira
Acceptance criteria present	Jira
Unit tests executed	CI
Contract/schema tests executed	CI
No failing tests	CI
Evidence entries created	Evidence Ledger

Failure Conditions
	•	Missing Jira reference
	•	Failing tests
	•	Missing evidence entries

Result
	•	Fail → PR cannot be merged
	•	Pass → PR merge allowed

⸻

4. Gate G2 — Release Candidate Gate

Objective

Establish a controlled release scope prior to environment promotion.

Mandatory Conditions

Requirement	Verification Source
Defined release scope	Jira (Epic / Release)
Single CRQ created	ServiceNow
CRQ references Jira scope	ServiceNow
Controls applicability determined	Governance Agent
Evidence plan established	Governance Agent

At this stage, evidence may be incomplete, but expectations must be explicit.

Failure Conditions
	•	Missing CRQ
	•	Ambiguous scope
	•	Controls not assessed

Result
	•	Fail → Release cannot proceed
	•	Pass → QA promotion eligible (pending approval)

⸻

5. Gate G3 — Promote to QA

Objective

Ensure the release is safe to enter a controlled test environment.

Mandatory Conditions

Requirement	Verification Source
Human approval recorded	ServiceNow
CRQ state = Approved for QA	ServiceNow
Evidence completeness	Evidence Ledger
SoD compliance	CI / Ledger
QA execution report	CI

Required Evidence (Typical)
	•	DQ test results
	•	Access control validation
	•	Incremental correctness tests
	•	Reproducibility metadata

Failure Conditions
	•	Missing or failed evidence
	•	SoD violation
	•	Missing approval

Result
	•	Fail → Promotion blocked
	•	Pass → QA deployment allowed

⸻

6. Gate G4 — Promote to PROD

Objective

Ensure the release is authorised, verified, and safe for production.

Mandatory Conditions

Requirement	Verification Source
Human PROD approval	ServiceNow
CRQ state = Approved for PROD	ServiceNow
Governance verification report	Evidence Ledger
PROD-specific controls satisfied	Evidence Ledger
No unresolved QA failures	CI

PROD-Specific Controls (Examples)
	•	Observability & alerting enabled
	•	PROD access policies validated
	•	Cost/performance guardrails checked

Failure Conditions
	•	Any missing approval
	•	Any failed control
	•	Any unresolved QA issues

Result
	•	Fail → PROD deployment blocked
	•	Pass → PROD deployment allowed

⸻

7. Governance Role in Gates

Governance:
	•	verifies evidence completeness
	•	validates provenance
	•	publishes verification status

Governance:
	•	does not approve promotion
	•	does not override failures
	•	does not bypass gates

⸻

8. Agent Interaction with Gates

Agents may:
	•	prepare artifacts
	•	surface missing requirements
	•	summarise gate failures
	•	suggest remediation

Agents may not:
	•	approve gates
	•	override failures
	•	manipulate evidence

⸻

9. Anti-Patterns (Explicitly Forbidden)

The following invalidate a release:
	•	manual gate overrides
	•	“temporary” bypasses without CRQ exception
	•	approvals outside ServiceNow
	•	promotion without ledger verification
	•	agent-triggered promotions

⸻

10. Evidence Produced by Gates

Each gate produces evidence entries, including:
	•	gate execution result
	•	timestamp
	•	decision (pass/fail)
	•	blocking reason (if any)

This allows auditors to verify:
	•	what blocked a release
	•	why it was blocked
	•	how it was resolved

⸻

11. Audit Walkthrough (Gates)

An auditor should be able to:
	1.	Identify a PROD release
	2.	Trace PR merge approval
	3.	Confirm CRQ approval
	4.	Validate QA promotion gate
	5.	Validate PROD promotion gate
	6.	Confirm no overrides occurred

Using system records only.

⸻

12. Versioning & Governance
	•	Gate rules are versioned
	•	Changes require architecture + governance approval
	•	Gate tightening is allowed without exception
	•	Gate loosening requires explicit risk acceptance

⸻

✅ GATE_RULES.md — COMPLETE

⸻
