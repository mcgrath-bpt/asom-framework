
CORPORATE_PDL_MAPPING.md

ASOM v2 – Corporate Project Documentation List (PDL) Mapping
PDL → Controls → Evidence → Gates

⸻

1. Purpose

This document explains how ASOM v2 satisfies corporate PDL requirements without duplicating documentation.

It demonstrates that:
	•	ASOM v2 does not replace the corporate PDL
	•	ASOM v2 maps PDL items to controls
	•	Evidence is produced by systems, not documents
	•	Audit expectations are met by design

Key principle:
PDL compliance is achieved through control coverage and evidence,
not by manually authoring documents.

⸻

2. Mapping Strategy

Each corporate PDL item is mapped to:
	1.	ASOM Control ID (what risk is controlled)
	2.	Evidence Type (what proves the control)
	3.	System of Record (where it lives)
	4.	Gate (where enforcement happens)
	5.	PDL Status
	•	Produced
	•	Referenced
	•	N/A (with justification)

⸻

3. Standard Mapping Table (Core)

⚠️ Names below are generic — align labels to your corporate PDL exactly.

Corporate PDL Item	ASOM Control(s)	Evidence	System of Record	Gate	PDL Status
Business Requirements	C-03	Jira Epics & Stories	Jira	G1	Referenced
Functional Specification	C-03	Acceptance Criteria + Tests	Jira / CI	G1	Referenced
Technical Design	C-07	Code + Config in Git	Git	G1	Referenced
Test Plan	C-06, C-08	Test Definitions	Git / CI	G3	Referenced
Test Execution Report	C-06, C-08	Test Results	CI	G3	Produced
Data Classification	C-04	Metadata / Policy Export	Platform	G3	Produced
Access Control Design	C-05	RBAC / Masking Config	Platform	G3	Produced
Security Review	C-05	Access Validation Tests	CI	G3	Produced
Deployment Plan	C-01	CRQ	ServiceNow	G3	Referenced
Change Approval	C-01	Approved CRQ	ServiceNow	G3/G4	Produced
QA Sign-Off	C-01	CRQ Approval (QA)	ServiceNow	G3	Produced
PROD Sign-Off	C-01	CRQ Approval (PROD)	ServiceNow	G4	Produced
Release Notes	C-03	Jira Release Summary	Jira	G4	Produced
Operational Readiness	C-09	Alerts & Observability Tests	CI / Platform	G4	Produced
Rollback Plan	C-01	Linked Runbook	Confluence	G3/G4	Referenced


⸻

4. Produced vs Referenced vs N/A (Clarified)

4.1 Produced
	•	Evidence is generated as part of delivery
	•	Stored in authoritative systems
	•	Indexed in the Evidence Ledger

Examples:
	•	Test execution results
	•	CRQ approvals
	•	Gate outcomes

⸻

4.2 Referenced
	•	Artifact already exists
	•	ASOM links to it
	•	No duplication required

Examples:
	•	Jira requirements
	•	Git-based design
	•	Platform configuration

⸻

4.3 N/A (With Justification)

Allowed only when:
	•	Control does not apply to the release
	•	Justification is explicit
	•	Approval is recorded

N/A entries:
	•	are evidence themselves
	•	are reviewed by Governance
	•	are visible to Audit

⸻

5. Evidence Ledger Alignment

Each PDL item marked Produced or Referenced has:
	•	an Evidence Ledger entry
	•	a Control ID
	•	a CRQ reference
	•	a gate association

This allows auditors to:
	•	start from the PDL
	•	trace to controls
	•	retrieve evidence
	•	confirm enforcement

⸻

6. Example: One PDL Item Walkthrough

PDL Item: Test Execution Report
	•	Risk: Untested changes reaching production
	•	ASOM Control: C-06 (Data Quality), C-08 (Incremental Correctness)
	•	Evidence: CI test results
	•	Ledger Entry: EL-2026-00XYZ
	•	Gate: G3 (QA Promotion)
	•	Status: Produced

No document is authored manually.

⸻

7. Why This Mapping Works for Audit

Audit can verify that:
	•	every PDL item is addressed
	•	evidence exists or is referenced
	•	approvals are human and recorded
	•	controls are enforced by gates
	•	nothing relies on screenshots or emails

This satisfies both:
	•	intent of the PDL
	•	letter of audit requirements

⸻

8. Governance Responsibilities

Governance:
	•	validates mapping correctness
	•	reviews N/A justifications
	•	verifies evidence completeness

Governance does not:
	•	author PDL documents
	•	certify delivery
	•	override gates

⸻

9. Change Management for PDL Mapping
	•	Mapping table is versioned
	•	Changes require governance approval
	•	New PDL items must map to controls
	•	Retiring PDL items requires risk acceptance

⸻

10. How to Adapt This to Your Corporate PDL

To adapt:
	1.	Replace PDL item names with corporate terms
	2.	Keep ASOM Control IDs stable
	3.	Validate evidence locations
	4.	Confirm gate alignment

No structural changes required.

⸻

✅ CORPORATE_PDL_MAPPING.md — COMPLETE

⸻
