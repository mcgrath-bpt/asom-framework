# ASOM v2 -- ServiceNow (SNOW) Change Interaction Model

**CRQ-centric, enterprise-safe, tooling-agnostic.**

---

## 1. Purpose

This document defines how ASOM v2 interacts with ServiceNow (SNOW) as the authoritative system of record for change approval, while preserving:
- enterprise ITSM ownership
- audit integrity
- human accountability
- tool independence

**Key principle:** ASOM reads ServiceNow. ServiceNow authorises change. ASOM never replaces or bypasses SNOW.

---

## 2. Scope

**Applies to:**
- all releases promoted beyond DEV
- all environments requiring human approval (QA, PROD)
- all changes governed by ASOM v2

**Out of scope:**
- internal ServiceNow implementation details
- ITSM process customisation
- emergency change design (except interaction points)

---

## 3. Change Model Assumptions (Locked)

The following assumptions are explicit and non-negotiable:
- Exactly one CRQ per release
- CRQ is created before QA promotion
- CRQ covers both QA and PROD
- CRQ state transitions represent human approval
- ASOM gates validate CRQ state -- they do not infer intent

---

## 4. ServiceNow as System of Record

ServiceNow is authoritative for:

| Concern | Ownership |
|---------|-----------|
| Change approval | ServiceNow |
| Approver identity | ServiceNow |
| Approval timestamps | ServiceNow |
| Emergency classification | ServiceNow |
| Change history | ServiceNow |

ASOM does not:
- approve changes
- store approval evidence
- override CRQ state

---

## 5. CRQ Lifecycle (Conceptual)

### 5.1 Recommended CRQ States

```
Draft
  ↓
QA Approval Pending
  ↓ (Human approval)
QA Approved
  ↓
PROD Approval Pending
  ↓ (Human approval)
Approved / Implemented
```

State names may vary by organisation -- state meaning must not.

---

## 6. CRQ Creation & Scope Definition

### 6.1 When CRQ Is Created

- After PRs are merged
- Before QA promotion (Gate G3)
- Once release scope is stable

### 6.2 What CRQ Must Reference

**Mandatory CRQ fields (conceptual):**
- Jira Release / Epic IDs
- Impacted systems
- Deployment window
- Risk level
- Rollback plan (link)
- ASOM Release ID (optional)

---

## 7. ASOM Gate Integration with SNOW

### 7.1 Gate G3 -- Promote to QA

ASOM gate checks:

| Check | Source |
|-------|--------|
| CRQ exists | ServiceNow |
| CRQ state allows QA | ServiceNow |
| Human approval recorded | ServiceNow |
| CRQ references Jira scope | ServiceNow |
| Evidence complete | Evidence Ledger |

If any check fails → QA promotion blocked.

---

### 7.2 Gate G4 -- Promote to PROD

ASOM gate checks:

| Check | Source |
|-------|--------|
| CRQ exists | ServiceNow |
| CRQ PROD approval recorded | ServiceNow |
| Change window valid | ServiceNow |
| Evidence complete | Evidence Ledger |
| QA gate passed | CI/CD |

If any check fails → PROD promotion blocked.

---

## 8. Evidence & Traceability

ServiceNow approvals are referenced, not duplicated.

Evidence Ledger entries include:

```yaml
crq_ref: SNOW-CRQ-900001
approval_state: QA Approved / PROD Approved
approval_timestamp: <from SNOW>
```

The CRQ remains the single source of truth.

---

## 9. Separation of Duties Enforcement via SNOW

SNOW contributes to SoD enforcement by ensuring:
- approver ≠ code author
- approver ≠ deploy identity
- approval performed by authorised role

ASOM gates validate:
- identity separation
- approval sequence
- state transitions

---

## 10. Emergency Changes

### 10.1 Emergency CRQs

Emergency changes:
- still require a CRQ
- may use expedited approval paths
- must be flagged explicitly

ASOM behaviour:
- validates CRQ emergency flag
- requires post-implementation review
- records exception as evidence

---

## 11. Anti-Patterns (Explicitly Forbidden)

The following invalidate compliance:
- promotion without CRQ
- approvals outside SNOW
- verbal or email approvals
- retroactive CRQ creation
- shared CRQs across releases

---

## 12. Audit Walkthrough (SNOW Focus)

An auditor can:
1. Identify a PROD release
2. Retrieve the CRQ
3. Verify QA and PROD approvals
4. Confirm approver identities
5. Trace release scope via Jira
6. Confirm gates enforced promotion

Without relying on:
- screenshots
- email trails
- verbal explanations

---

## 13. Why This Model Works

- Preserves ITSM ownership
- Avoids tool duplication
- Aligns with regulated SDLC
- Scales across teams
- Keeps ASOM implementation-agnostic
