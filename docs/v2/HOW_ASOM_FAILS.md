
HOW_ASOM_FAILS.md

ASOM v2 – Failure Modes & Mitigations
Explicitly documenting how this operating model can break — and how it is contained

⸻

1. Purpose

This document enumerates known and foreseeable failure modes in an agent-assisted delivery model and defines explicit mitigations enforced by ASOM v2.

Its purpose is to:
	•	demonstrate control awareness
	•	prevent naïve or unsafe adoption
	•	provide auditors and risk partners with transparency
	•	ensure failures degrade safely rather than silently

Key principle:
If a failure mode is not explicitly documented, it is not controlled.

⸻

2. Scope

This applies to:
	•	all ASOM v2 implementations
	•	all agent-assisted delivery activities
	•	all regulated environments (QA, PROD)

Out of scope:
	•	local experimentation
	•	research prototypes

⸻

3. Failure Mode Categories

Failure modes are grouped into five categories:
	1.	Agent-related failures
	2.	Evidence and compliance failures
	3.	SDLC and approval failures
	4.	Data platform–specific failures
	5.	Organisational and behavioural failures

Each failure mode includes:
	•	description
	•	risk
	•	mitigation
	•	enforcement point

⸻

4. Agent-Related Failures

⸻

F-01 — Hallucinated Compliance

Description
An agent claims a control is satisfied without real evidence.

Risk
False assurance leading to audit failure or regulatory breach.

Mitigation
	•	Agents cannot generate evidence
	•	Evidence must exist in the Evidence Ledger
	•	Gates verify ledger completeness only

Enforcement Point
	•	G3 / G4 promotion gates

⸻

F-02 — Prompt Injection via Requirements

Description
Malicious or poorly written requirements influence agent behaviour.

Risk
Unsafe code, bypassed controls, or unintended access.

Mitigation
	•	Acceptance criteria must be reviewed by humans
	•	Tests derived from acceptance criteria must pass
	•	Human approval required for QA/PROD

Enforcement Point
	•	G1 PR merge
	•	G3 QA promotion

⸻

F-03 — Agent Overreach (Authority Creep)

Description
Agents begin approving, promoting, or certifying.

Risk
Collapse of separation of duties.

Mitigation
	•	Agents have no credentials
	•	Promotion requires ServiceNow approval
	•	CI validates approver identity

Enforcement Point
	•	CI/CD
	•	SNOW integration

⸻

5. Evidence & Compliance Failures

⸻

F-04 — Fabricated Evidence

Description
Evidence is manually created or altered to appear compliant.

Risk
Audit failure; regulatory breach.

Mitigation
	•	Evidence must be machine-generated
	•	Checksums required
	•	Provenance verified at gate

Enforcement Point
	•	Evidence Ledger verification

⸻

F-05 — Reused Evidence Across Releases

Description
Old evidence reused to satisfy new release controls.

Risk
Controls not actually revalidated.

Mitigation
	•	Evidence bound to commit SHA and CRQ
	•	Re-execution required per release

Enforcement Point
	•	G2 Release Candidate
	•	G3/G4 gates

⸻

F-06 — Abuse of “N/A”

Description
Controls incorrectly marked N/A to bypass requirements.

Risk
Silent control gaps.

Mitigation
	•	N/A requires explicit justification
	•	Justification reviewed and approved
	•	N/A entries recorded as evidence

Enforcement Point
	•	Governance verification

⸻

6. SDLC & Approval Failures

⸻

F-07 — Self-Approval Loops

Description
Same individual authors, approves, and promotes.

Risk
Fraud or uncontrolled change.

Mitigation
	•	SoD enforced technically
	•	Identity checks at gates

Enforcement Point
	•	CI/CD
	•	SNOW approval checks

⸻

F-08 — Approval Outside System of Record

Description
Approvals given via email/chat instead of SNOW.

Risk
Unverifiable approvals.

Mitigation
	•	Only SNOW approval state accepted
	•	CI validates CRQ status

Enforcement Point
	•	G3/G4 gates

⸻

7. Data Platform–Specific Failures

⸻

F-09 — Silent Semantic Drift

Description
Data meaning changes without schema changes.

Risk
Incorrect analytics and decisions.

Mitigation
	•	Incremental correctness tests
	•	DQ rules aligned to semantics

Enforcement Point
	•	T3 / T6 tests
	•	QA gate

⸻

F-10 — Full Reloads Used to Mask Errors

Description
Teams avoid incremental complexity by full reloads.

Risk
Performance degradation; data loss risk.

Mitigation
	•	Incremental testing mandatory
	•	Full reloads require justification

Enforcement Point
	•	Test taxonomy enforcement

⸻

F-11 — Cost Explosion

Description
Change causes excessive compute or storage usage.

Risk
Budget breach; platform instability.

Mitigation
	•	Cost guardrail tests
	•	Explicit approval for regressions

Enforcement Point
	•	QA / PROD gates

⸻

8. Organisational & Behavioural Failures

⸻

F-12 — “Process Bypass in Emergencies”

Description
Controls bypassed under urgency.

Risk
Normalisation of deviance.

Mitigation
	•	Emergency paths still require CRQ
	•	Exception treated as evidence
	•	Post-incident review mandatory

Enforcement Point
	•	SNOW process
	•	Governance review

⸻

F-13 — Governance as Rubber Stamp

Description
Governance approves without verification.

Risk
False assurance.

Mitigation
	•	Governance verifies evidence only
	•	No discretionary approval powers

Enforcement Point
	•	Governance role definition

⸻

9. Safe Failure Philosophy

When ASOM fails, it must fail by:
	•	blocking promotion
	•	surfacing explicit gaps
	•	requiring human remediation

It must never:
	•	silently pass
	•	auto-approve
	•	degrade controls

⸻

10. Audit Use of This Document

Auditors may use this document to:
	•	understand control intent
	•	assess residual risk
	•	verify mitigations exist
	•	confirm governance maturity

⸻

11. Versioning & Maintenance
	•	Failure modes are reviewed quarterly
	•	New failures are added as discovered
	•	Mitigations must be updated accordingly

⸻

✅ HOW_ASOM_FAILS.md — COMPLETE

⸻
