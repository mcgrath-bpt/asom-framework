
AUDIT_WALKTHROUGH.md

ASOM v2 – End-to-End Audit Walkthrough Narrative
A deterministic explanation of how a change moves safely to production

⸻

1. Purpose

This document provides a linear, evidence-first walkthrough of how ASOM v2 governs a change from inception to production.

It is designed for:
	•	Internal Audit
	•	Risk & Compliance
	•	Quality / GxP reviewers
	•	Architecture Review Boards

It intentionally avoids:
	•	screenshots
	•	tool-specific instructions
	•	subjective judgement
	•	agent narratives

Principle:
If the control cannot be demonstrated from system records, it does not exist.

⸻

2. Audit Question This Document Answers

“How do you ensure that only approved, tested, and compliant changes reach production?”

ASOM v2 answers this through:
	•	enforced gates
	•	authoritative systems of record
	•	deterministic evidence
	•	explicit human approvals

⸻

3. Systems of Record

Concern	System of Record
Source code	Git
Test execution	CI/CD
Scope & requirements	Jira
Documentation & narrative	Confluence
Change approval	ServiceNow
Evidence index	Evidence Ledger

Agents are not systems of record.

⸻

4. Step-by-Step Walkthrough

⸻

Step 1 — Business Intent Is Defined
	•	Business requirement is captured in Jira
	•	Acceptance criteria are explicitly documented
	•	Scope is visible and reviewable

Control Coverage
	•	C-03 Requirements Traceability

Evidence
	•	Jira issue history
	•	Acceptance criteria text

⸻

Step 2 — Code Is Implemented & Tested
	•	Code is committed to Git
	•	Tests execute automatically in CI/CD
	•	Test failures block progress

Control Coverage
	•	C-03 Traceability
	•	C-06 Data Quality
	•	C-08 Incremental Correctness

Evidence
	•	CI test reports
	•	Commit history

⸻

Step 3 — PR Merge Gate Enforced
	•	PR cannot merge without:
	•	linked Jira
	•	passing tests
	•	evidence generation

Control Coverage
	•	C-01 Change Authorisation
	•	C-02 Separation of Duties

Evidence
	•	PR approval record
	•	CI gate result

⸻

Step 4 — Release Candidate Established
	•	Release scope is defined
	•	Exactly one CRQ is created in ServiceNow
	•	CRQ references Jira scope

Control Coverage
	•	C-01 Change Authorisation

Evidence
	•	ServiceNow CRQ
	•	Jira–CRQ linkage

⸻

Step 5 — Promote to QA (Human-Approved)
	•	Human approval recorded in ServiceNow
	•	CI validates:
	•	CRQ approval state
	•	evidence completeness
	•	SoD compliance

Control Coverage
	•	C-01 Change Authorisation
	•	C-02 Separation of Duties
	•	All applicable technical controls

Evidence
	•	CRQ approval state
	•	Evidence Ledger entries
	•	CI gate result

⸻

Step 6 — QA Validation Performed
	•	QA execution report generated
	•	Results reviewed by humans
	•	Failures block further promotion

Control Coverage
	•	C-06 Data Quality
	•	C-09 Observability

Evidence
	•	QA execution report
	•	Test artifacts

⸻

Step 7 — Promote to PROD (Human-Approved)
	•	Second human approval recorded in ServiceNow
	•	PROD-specific controls verified
	•	Governance verification confirms completeness

Control Coverage
	•	All applicable controls

Evidence
	•	CRQ PROD approval
	•	Governance verification report
	•	PROD gate result

⸻

5. Evidence-First Verification

For any production release, an auditor can:
	1.	Identify the CRQ
	2.	Retrieve linked Jira scope
	3.	Retrieve Evidence Ledger entries
	4.	Validate control coverage
	5.	Trace evidence to artifacts
	6.	Confirm human approvals
	7.	Confirm no overrides occurred

No screenshots.
No emails.
No tribal knowledge.

⸻

6. Separation of Duties Demonstration

From system records, an auditor can confirm:
	•	Author ≠ Approver
	•	Approver ≠ Deployer
	•	Evidence Producer ≠ Verifier
	•	Agents ≠ Approvers

This satisfies enterprise SoD expectations.

⸻

7. Handling Exceptions
	•	Emergency changes still require a CRQ
	•	Exceptions are explicitly recorded
	•	Exception evidence is auditable
	•	Post-incident review is mandatory

No silent bypasses exist.

⸻

8. Why Agents Do Not Break Controls

Agents:
	•	draft artifacts
	•	accelerate analysis
	•	surface gaps

Agents:
	•	have no credentials
	•	cannot approve
	•	cannot promote
	•	cannot fabricate evidence

This preserves accountability.

⸻

9. Audit Conclusion Statement

ASOM v2 ensures that all changes reaching production are:
	•	explicitly approved
	•	fully tested
	•	governed by enforced controls
	•	traceable end to end
	•	auditable from system records alone

⸻

✅ AUDIT_WALKTHROUGH.md — COMPLETE

⸻

Where We Are Now

You now have:
	•	a defensible operating model
	•	a provable control system
	•	a clear audit narrative

At this point, ASOM v2 can survive:
	•	Audit
	•	Risk
	•	Architecture Review
	•	Senior Engineering scrutiny

⸻
