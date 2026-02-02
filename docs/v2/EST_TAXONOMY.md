
TEST_TAXONOMY.md

ASOM v2 – Test Taxonomy & Definition of Done
Preventing test theatre in regulated data platforms

⸻

1. Purpose

This document defines the minimum mandatory testing expectations under ASOM v2.

Its goals are to:
	•	ensure tests cover real enterprise risks
	•	prevent “checkbox TDD”
	•	align delivery quality with governance controls
	•	make automated tests valid audit evidence

Key principle:
A test that cannot meaningfully fail does not exist.

⸻

2. Scope

Applies to:
	•	all changes promoted beyond DEV
	•	all data pipelines, transformations, and access policies
	•	all releases governed by a CRQ

Out of scope:
	•	exploratory analysis
	•	throwaway experiments

⸻

3. Test Categories (Authoritative)

ASOM v2 defines eight test categories.
At least one test is required in each applicable category.

⸻

T1 — Unit Tests (Logic Correctness)

Purpose
Validate transformation logic and business rules.

Typical Examples
	•	SQL/Python transformation logic
	•	Calculation rules
	•	Conditional branching

Anti-Patterns
	•	Tests that mock away core logic
	•	Tests that only assert “no error”

Evidence
	•	CI test execution report

⸻

T2 — Contract / Schema Tests

Purpose
Ensure interfaces and schemas remain compatible.

Typical Examples
	•	Table schemas
	•	Column types and nullability
	•	API payload structures

Anti-Patterns
	•	Schemas inferred implicitly
	•	Backward-breaking changes without detection

Evidence
	•	Schema diff outputs
	•	Compatibility checks

⸻

T3 — Data Quality Tests

Purpose
Detect incorrect, incomplete, or inconsistent data.

Typical Rules
	•	Not-null
	•	Uniqueness
	•	Referential integrity
	•	Domain/range constraints

Enterprise Rule
Critical DQ failures must block promotion.

Evidence
	•	DQ rule definitions
	•	Execution results

⸻

T4 — Access Control & Security Tests

Purpose
Ensure data access restrictions are enforced.

Typical Examples
	•	RBAC validation
	•	Masking enforcement
	•	Row/column-level security

Anti-Patterns
	•	Relying on configuration review only
	•	Manual access testing

Evidence
	•	Automated access validation output

⸻

T5 — Idempotency & Reprocessing Tests

Purpose
Ensure pipelines can be safely re-run.

Typical Examples
	•	Re-run produces same result
	•	Backfill does not duplicate data

Why This Matters
Most enterprise incidents originate here.

Evidence
	•	Re-run comparison results

⸻

T6 — Incremental Correctness Tests

Purpose
Validate incremental logic (MERGE, CDC, windowing).

Typical Examples
	•	Inserts vs updates handled correctly
	•	Late-arriving data processed correctly

Anti-Patterns
	•	Full reloads used to avoid testing

Evidence
	•	Incremental scenario test results

⸻

T7 — Performance & Cost Guardrails

Purpose
Prevent regressions in runtime or platform cost.

Typical Examples
	•	Query cost thresholds
	•	Runtime SLAs
	•	Partition pruning checks

Enterprise Rule
Material regressions require explicit approval.

Evidence
	•	Baseline vs current metrics

⸻

T8 — Observability & Alerting Tests

Purpose
Ensure failures are detectable.

Typical Examples
	•	Alert fires on failure
	•	SLO breach detection

Anti-Patterns
	•	Alerts defined but never tested

Evidence
	•	Alert trigger test output

⸻

4. Definition of Done (DoD)

A story is Done only if:
	1.	All applicable test categories are covered
	2.	All tests pass in CI
	3.	Test results are recorded in the Evidence Ledger
	4.	Failures block promotion
	5.	Test scope is traceable to acceptance criteria

⸻

5. Minimum Required by Change Type

Change Type	Required Categories
New pipeline	T1–T6 + T8 (+T7 if material)
Incremental change	T1, T2, T3, T5, T6
Access policy change	T2, T4
Performance optimisation	T1, T7
DQ rule change	T3 (+ affected tests)
PROD-only config	T4, T8


⸻

6. Anti-Gaming Rules (Explicit)

The following do not count as tests:
	•	assertions that only check job completion
	•	mocked data that cannot violate rules
	•	disabled tests marked as “known issue”
	•	full reloads used to avoid incremental testing
	•	tests skipped without justification

Violations block promotion.

⸻

7. Governance Use of Tests

Governance:
	•	verifies required categories are present
	•	verifies results are recorded
	•	does not assess test logic quality

Quality of tests remains an engineering responsibility.

⸻

8. Audit Walkthrough (Testing)

An auditor should be able to:
	1.	Identify a change
	2.	Identify required test categories
	3.	Retrieve execution results
	4.	Confirm failures blocked promotion
	5.	Trace results to CRQ

⸻

9. Versioning & Evolution
	•	Test taxonomy is versioned
	•	New categories may be added
	•	Removal requires risk acceptance

⸻

✅ TEST_TAXONOMY.md — COMPLETE

⸻
