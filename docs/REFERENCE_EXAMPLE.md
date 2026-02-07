# ASOM v2 -- Worked Reference Example (End-to-End)

**A minimal but realistic data pipeline under regulated SDLC.**

---

## 1. Purpose

This example demonstrates, end to end:
- how ASOM v2 is applied in practice
- how controls translate into gates
- how failures are detected early
- how promotion is blocked deterministically
- how remediation restores compliance
- how evidence is produced and verified

This example is intentionally small, but structurally identical to a real enterprise pipeline.

---

## 2. Scenario Overview

### Use Case

A data pipeline ingests Sales Transactions into a curated analytics table.

### Key Characteristics

- Incremental load (MERGE logic)
- Contains sensitive fields (customer identifier)
- Promoted through DEV → QA → PROD
- Governed by one CRQ per release

---

## 3. Systems Involved (Conceptual)

| Area | System |
|------|--------|
| Source control | Git |
| CI/CD | Enterprise CI |
| Work tracking | Jira |
| Change approval | ServiceNow |
| Data platform | Snowflake (illustrative) |
| Evidence storage | CI artifact store |

---

## 4. Release Setup

### Jira

- Epic: JIRA-EPIC-101
- Stories:
  - JIRA-1234 -- Add incremental merge logic
  - JIRA-1235 -- Add DQ rules for transactions

### ServiceNow

- CRQ: SNOW-CRQ-900001
- Scope: references JIRA-EPIC-101
- Approval required for QA and PROD

---

## 5. Control Applicability

Applicable controls for this release:
- C-01 Change Authorization
- C-02 Separation of Duties
- C-03 Requirements Traceability
- C-04 Data Classification & Handling
- C-05 Access Control
- C-06 Data Quality
- C-07 Reproducibility
- C-08 Incremental Correctness
- C-09 Observability
- C-10 Cost & Performance (non-material → QA only)

---

## 6. Development Phase (DEV)

### Actions

- Dev Agent assists in generating:
  - MERGE logic
  - unit tests (T1)
  - incremental tests (T6)
- Developer commits code:
  - commit SHA: `abc123`

### PR Gate (G1)

- ✔ Jira linked
- ✔ Unit tests pass
- ✔ Schema tests pass
- ✔ Evidence entries created

**Result:** PR merge allowed

---

## 7. Release Candidate Gate (G2)

### Inputs

- Jira scope confirmed
- CRQ created (SNOW-CRQ-900001)
- Governance Agent assesses control applicability
- Evidence plan established

**Result:** Release candidate accepted

---

## 8. First Attempt to Promote to QA (FAILURE)

### Gate Evaluated: G3 -- Promote to QA

**Evidence Present:**
- Unit tests ✔
- Incremental tests ✔
- Schema tests ✔
- Data classification ✔

**Missing Evidence:**
- ❌ Access control validation (C-05)
- ❌ DQ rule execution results (C-06)

### Gate Decision: FAIL

Promotion blocked due to:
- Missing evidence for applicable controls
- No human QA approval recorded yet

---

### Evidence Ledger Snapshot (Failure)

```yaml
evidence_id: EL-2026-00101
control_id: C-05
status: missing

evidence_id: EL-2026-00102
control_id: C-06
status: missing
```

---

## 9. Remediation

### Actions Taken

- Dev Agent assists in adding:
  - automated access control test (T4)
  - DQ rules + execution test (T3)
- Developer commits fixes:
  - commit SHA: `def456`
- CI executes new tests
- Evidence artifacts generated

---

## 10. Second Attempt to Promote to QA (PASS)

### Gate Evaluated: G3 -- Promote to QA

**Conditions:**
- ✔ CRQ approved for QA
- ✔ Human QA approval recorded
- ✔ All required evidence present
- ✔ No SoD violations

**Result:** QA promotion allowed

---

### Evidence Ledger Snapshot (QA Pass)

```yaml
evidence_id: EL-2026-00115
control_id: C-05
status: pass
source_ref: artifact://ci/build-789/access_test.json

evidence_id: EL-2026-00116
control_id: C-06
status: pass
source_ref: artifact://ci/build-789/dq_results.json
```

---

## 11. QA Validation

**QA Agent:**
- Coordinates execution
- Publishes QA execution report

**Human QA:**
- Reviews results
- Confirms no critical failures

---

## 12. Promote to PROD (PASS)

### Gate Evaluated: G4 -- Promote to PROD

**Conditions:**
- ✔ CRQ approved for PROD
- ✔ Human PROD approval recorded
- ✔ Governance verification report generated
- ✔ PROD-specific controls satisfied

**Result:** PROD promotion allowed

---

## 13. Audit Walkthrough (End State)

An auditor can now:
1. Identify PROD deployment
2. Retrieve CRQ (SNOW-CRQ-900001)
3. See all Jira scope
4. Retrieve Evidence Ledger entries
5. Verify all applicable controls satisfied
6. Confirm failures blocked promotion
7. Confirm SoD enforcement

No screenshots. No tribal knowledge. No narrative reconstruction.

---

## 14. What This Example Proves

- ASOM v2 blocks unsafe releases
- Failures surface early
- Remediation is deterministic
- Governance is enforced by gates
- Agents accelerate but do not override
- One CRQ per release scales cleanly
