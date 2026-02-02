
SEPARATION_OF_DUTIES.md

ASOM v2 – Separation of Duties (SoD) Model
Enterprise-enforceable role and authority boundaries

⸻

1. Purpose

This document defines how separation of duties (SoD) is enforced within ASOM v2.

Its purpose is to ensure that:
	•	no individual (human or agent) can approve or promote their own changes
	•	compliance evidence cannot be self-certified
	•	promotion to QA and PROD remains under explicit human control
	•	agent assistance does not weaken enterprise controls

Non-negotiable principle:
If separation of duties is not enforced technically, it does not exist.

⸻

2. Scope

This model applies to:
	•	all changes promoted beyond DEV
	•	all releases governed by a ServiceNow CRQ
	•	all agents operating within ASOM v2

Out of scope:
	•	local experimentation
	•	throwaway prototypes without promotion intent

⸻

3. Roles in ASOM v2

3.1 Human Roles

Role	Responsibility
Developer	Authors code and tests
QA Engineer	Reviews test outcomes
Release Approver	Approves QA and PROD promotion
Governance / Quality	Verifies evidence completeness
Change Manager	Owns CRQ approval in SNOW


⸻

3.2 Agent Roles (Non-Authoritative)

Agent	Responsibility
BA Agent	Acceptance criteria & scope refinement
Dev Agent	Code & test generation assistance
QA Agent	Test execution coordination
Governance Agent	Evidence completeness verification
Scrum Agent	Coordination, reporting, hygiene

Important:
Agents do not hold authority.
Agents cannot approve, promote, or certify compliance.

⸻

4. Authority Matrix (Allowed vs Forbidden)

4.1 Authority Boundaries

Actor	May Do	Must Not Do
Human Developer	Commit code	Approve own promotion
Human QA	Review results	Modify code under test
Release Approver	Approve QA/PROD	Change artifacts post-approval
Governance	Verify evidence	Generate or modify evidence
Any Agent	Draft artifacts	Approve or promote
CI/CD	Execute gates	Override approvals


⸻

5. Enforcement Points (Technical)

Separation of duties must be enforced at multiple independent layers.

5.1 Source Control
	•	Branch protection rules
	•	Required reviewers
	•	Disallowed self-approval
	•	Mandatory Jira linkage

⸻

5.2 CI/CD
	•	Distinct identities for:
	•	build
	•	deploy
	•	Gate logic verifying:
	•	author ≠ approver
	•	evidence producer ≠ verifier
	•	Promotion blocked on violation

⸻

5.3 ServiceNow (Change)
	•	CRQ approver ≠ commit author
	•	CRQ approval required for QA and PROD
	•	CRQ state validated by CI gate

⸻

5.4 Environment Access
	•	DEV, QA, PROD have distinct access roles
	•	No shared credentials
	•	Promotion identities are non-human service identities

⸻

6. Evidence of SoD Compliance

SoD compliance itself is a verifiable control (C-02).

Evidence sources include:
	•	Git commit history
	•	CI execution metadata
	•	Jira approval records
	•	SNOW CRQ approval records
	•	Deployment logs

These are indexed in the Evidence Ledger.

⸻

7. Anti-Patterns (Explicitly Non-Compliant)

The following are not allowed under ASOM v2:
	•	one individual committing, approving, and promoting
	•	agents approving or promoting
	•	governance agents generating evidence
	•	shared “release accounts”
	•	manual override of failed gates
	•	retroactive approvals

Any of the above invalidate the release.

⸻

8. Handling Exceptions

Exceptions:
	•	must be rare
	•	must be documented
	•	must be approved outside the delivery team
	•	must be linked to the CRQ
	•	must be time-bound

Exceptions are evidence items themselves.

⸻

9. Audit Walkthrough (SoD)

An auditor should be able to demonstrate:
	1.	Who authored the change
	2.	Who reviewed and approved it
	3.	Who verified evidence
	4.	Who authorised promotion
	5.	That no single actor fulfilled more than one critical role

Using:
	•	system records only
	•	no screenshots
	•	no verbal explanations

⸻

10. Versioning & Change Control
	•	SoD rules are versioned
	•	Changes require architecture and governance approval
	•	Backward compatibility must be considered

⸻

✅ SEPARATION_OF_DUTIES.md — COMPLETE

⸻
