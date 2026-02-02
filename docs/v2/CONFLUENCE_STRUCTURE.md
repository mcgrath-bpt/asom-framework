
CONFLUENCE_STRUCTURE.md

ASOM v2 – Confluence Information Architecture & Templates

⸻

1. Purpose

This document defines how ASOM v2 lives in Confluence so that:
	•	auditors find what they expect
	•	engineers are not overwhelmed
	•	governance is visible but not obstructive
	•	documentation stays aligned with reality
	•	duplication is avoided (PDL = mapping, not rewriting)

⸻

2. Top-Level Confluence Space Structure

ASOM v2 – Delivery & Governance Hub

(single space or top-level page)

ASOM v2 – Delivery & Governance Hub
├── 1. What is ASOM v2 (Read First)
├── 2. Operating Model
├── 3. Controls & Governance
├── 4. Delivery Playbooks
├── 5. Release & Audit Evidence
├── 6. Exceptions & Decisions
└── 7. Reference & Templates

This mirrors how Audit + Engineering mentally navigate.

⸻

3. Page-by-Page Breakdown

⸻

1. What is ASOM v2 (Read First)

Audience: Everyone
Purpose: Set tone, scope, and non-goals

Content
	•	What ASOM v2 is
	•	What ASOM v2 is not
	•	“Agents assist. Systems enforce. Humans approve.”
	•	Link to Audit Walkthrough

This page prevents 80% of misunderstandings.

⸻

2. Operating Model

Sub-pages:
	•	ASOM v2 Overview
	•	Roles & Responsibilities
	•	Separation of Duties
	•	Promotion Flow (DEV → QA → PROD)

Each page:
	•	links to the canonical spec in Git
	•	summarises intent, not mechanics

⸻

3. Controls & Governance

Sub-pages:
	•	Control Catalog
	•	Evidence Ledger
	•	Gate Rules
	•	How ASOM Fails

This section is audit-facing.

Each control page should include:
	•	control objective
	•	risk
	•	evidence expectations
	•	links to live examples

⸻

4. Delivery Playbooks

Sub-pages:
	•	How to Start a New Feature
	•	How to Prepare a Release
	•	How to Fix a Failed Gate
	•	How to Handle Emergency Changes

Audience: engineers & delivery leads
Tone: practical, step-by-step

⸻

5. Release & Audit Evidence

This is where PDL mapping happens.

Structure:

Release YYYY-MM-DD (CRQ-XXXX)
├── Release Overview
├── Scope (Jira links)
├── Control Coverage
├── Evidence Ledger Snapshot
└── Approval Summary

No screenshots.
Everything links back to systems of record.

⸻

6. Exceptions & Decisions

Sub-pages:
	•	Exceptions Register
	•	Architecture Decision Records (ADRs)

This is where:
	•	risk acceptance lives
	•	deviations are documented
	•	auditors look when something went “off script”

⸻

7. Reference & Templates

Sub-pages:
	•	Jira templates
	•	Confluence templates
	•	Glossary
	•	v1 → v2 delta

⸻

4. Core Confluence Page Templates

4.1 Release Overview Template

# Release: <Release Name>

## CRQ
- ServiceNow CRQ: <CRQ-ID>

## Scope
- Jira Epic(s): <links>
- Stories included: <links>

## Environments
- QA: <date>
- PROD: <date>

## Summary
<Short human-readable summary>

## Status
- QA Approval: Pending / Approved
- PROD Approval: Pending / Approved


⸻

4.2 Control Coverage Template

# Control Coverage

| Control ID | Applicable | Evidence | Status |
|---|---|---|---|
| C-01 | Yes | EL-2026-001 | Pass |
| C-05 | Yes | EL-2026-015 | Pass |
| C-10 | No | N/A (Justified) | Approved |

## Notes
<N/A justifications or exceptions>


⸻

4.3 Evidence Reference Template

# Evidence References

All evidence is stored in authoritative systems.
This page provides references only.

| Evidence ID | Control | Source |
|---|---|---|
| EL-2026-015 | C-05 | CI Artifact build-789 |
| EL-2026-016 | C-06 | CI Artifact build-789 |


⸻

4.4 Exception Template

# Exception Record

## Exception ID
EX-2026-003

## Related CRQ
SNOW-CRQ-900001

## Description
<What was deviated from>

## Risk
<What risk was accepted>

## Mitigation
<Compensating controls>

## Approval
- Approved by: <role>
- Date: <date>

## Expiry
<date or condition>


⸻

5. Confluence Guardrails (Very Important)

To keep this sustainable:
	•	❌ No screenshots as evidence
	•	❌ No copy/paste of CI logs
	•	❌ No duplicated approval statements
	•	✅ Always link to systems of record
	•	✅ Treat Confluence as narrative + index, not storage

⸻

6. Why This Structure Works
	•	Engineers see playbooks
	•	Governance sees controls
	•	Audit sees evidence traceability
	•	Leadership sees consistency
	•	ASOM remains lightweight but defensible

⸻

✅ CONFLUENCE_STRUCTURE.md — COMPLETE

⸻
