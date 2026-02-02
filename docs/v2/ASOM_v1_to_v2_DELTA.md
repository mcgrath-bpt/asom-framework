
ASOM_v1_to_v2_DELTA.md

ASOM v1 → ASOM v2: Enterprise Readiness Delta Pack
What changed, why it changed, and what risks are now controlled

⸻

1. Purpose of This Document

This document explains:
	•	what changed between ASOM v1 and ASOM v2
	•	why those changes were necessary
	•	which enterprise risks were addressed
	•	what remains intentionally out of scope

It is written for:
	•	senior engineering leadership
	•	platform owners
	•	audit / risk partners
	•	early adopter teams

This is not a re-description of ASOM v2.
It is a justification for the evolution.

⸻

2. Executive Summary

ASOM v1 established a strong conceptual foundation for agent-assisted delivery but relied on process intent and role discipline.

ASOM v2 introduces:
	•	explicit control objectives
	•	machine-enforced gates
	•	immutable evidence
	•	enforced separation of duties
	•	formal integration with enterprise systems of record

As a result, ASOM v2 is suitable for regulated environments, while ASOM v1 was suitable primarily for experimentation and early feedback.

⸻

3. High-Level Comparison

Area	ASOM v1	ASOM v2
Agent model	Conceptual role separation	Enforced non-authoritative roles
Governance	Process-driven	Control-objective driven
Evidence	Described	Machine-generated + ledgered
Approvals	Implied	Explicit, human, SNOW-backed
Gates	Conceptual	Deterministic, blocking
SoD	Stated	Technically enforced
Auditability	Narrative	Evidence-first
Enterprise adoption	Risky	Defensible


⸻

4. Key Changes and Rationale

⸻

4.1 From “Autonomous” to “Agent-Assisted”

Change
	•	Removed any implication of autonomous promotion or approval
	•	Reframed ASOM as agent-assisted under enforced controls

Why
	•	Autonomy conflicts with regulated SDLC expectations
	•	Language alone was a blocker for Audit and Risk

Risk Addressed
	•	Self-approval
	•	Uncontrolled change
	•	Regulatory non-compliance

⸻

4.2 Introduction of Explicit Control Objectives

Change
	•	Added a formal Control Catalog
	•	Mapped PDL items to control objectives, not documents

Why
	•	Auditors evaluate controls, not artifacts
	•	PDL completion alone is not evidence of control effectiveness

Risk Addressed
	•	Checkbox compliance
	•	Ambiguous governance interpretation

⸻

4.3 Evidence Ledger (New in v2)

Change
	•	Introduced an Evidence Ledger as a first-class concept

Why
	•	Evidence must be immutable, attributable, and reproducible
	•	Narrative compliance is not defensible at scale

Risk Addressed
	•	Fabricated evidence
	•	Reused evidence
	•	Incomplete audit trails

⸻

4.4 Enforced Separation of Duties

Change
	•	Explicit SoD model with technical enforcement points
	•	Clear prohibition of agent authority

Why
	•	Role discipline does not scale
	•	SoD must be enforced by systems, not trust

Risk Addressed
	•	Self-certification
	•	Fraud risk
	•	Audit failure

⸻

4.5 Human Approval for QA and PROD (Formalised)

Change
	•	Mandatory human approval for:
	•	DEV → QA
	•	QA → PROD
	•	Enforced via ServiceNow CRQ

Why
	•	Required by enterprise ITGCs
	•	Aligns with real operating constraints

Risk Addressed
	•	Unauthorised promotion
	•	Accountability gaps

⸻

4.6 Deterministic Gates (Blocking, Not Advisory)

Change
	•	Defined explicit gates (PR, QA, PROD)
	•	Gates block promotion when controls are not satisfied

Why
	•	Advisory governance fails under pressure
	•	Blocking is the only reliable enforcement mechanism

Risk Addressed
	•	“We’ll fix it later” releases
	•	Emergency bypass normalisation

⸻

4.7 Test Taxonomy and Anti-Gaming Rules

Change
	•	Introduced mandatory test categories
	•	Explicitly banned test theatre

Why
	•	TDD without structure is easily gamed
	•	Data platforms fail in non-obvious ways

Risk Addressed
	•	Silent data corruption
	•	Security regressions
	•	Cost explosions

⸻

4.8 Explicit Failure Model (“How ASOM Fails”)

Change
	•	Documented known failure modes and mitigations

Why
	•	Undocumented failures are uncontrolled risks
	•	Transparency increases trust

Risk Addressed
	•	Hallucinated compliance
	•	Governance rubber-stamping
	•	Agent overreach

⸻

5. What Did NOT Change (By Design)

The following principles were retained intentionally:
	•	PDL as mapping, not duplication
	•	Agent role separation
	•	Test-first mindset
	•	Tooling abstraction
	•	Vendor neutrality
	•	Incremental adoption

ASOM v2 strengthens these — it does not replace them.

⸻

6. What Remains Out of Scope (Explicit)

ASOM v2 does not attempt to:
	•	replace Jira, Confluence, or ServiceNow
	•	define specific CI/CD tooling
	•	automate approvals
	•	remove human accountability
	•	solve organisational change management

These are deliberate boundaries, not gaps.

⸻

7. Adoption Impact Summary

For Engineering Teams
	•	Clearer expectations
	•	Fewer late surprises
	•	Less subjective governance

For Governance / Audit
	•	Deterministic controls
	•	Evidence-first verification
	•	Reduced manual review effort

For Platform Owners
	•	Scalable model
	•	Tool-agnostic design
	•	Reduced compliance friction

⸻

8. Recommended Adoption Path
	1.	Socialise this delta, not the full spec
	2.	Pilot ASOM v2 on:
	•	one team
	•	one pipeline
	•	one release
	3.	Implement gates incrementally
	4.	Expand once trust is established

⸻

9. Final Positioning Statement

ASOM v2 does not make delivery faster by bypassing controls.
It makes delivery faster by making the right path the easiest path,
while ensuring the wrong path is impossible.

⸻

✅ ASOM v1 → v2 Delta Pack — COMPLETE

⸻
