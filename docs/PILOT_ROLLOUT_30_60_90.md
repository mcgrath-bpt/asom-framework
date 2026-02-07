# ASOM v2 -- Controlled Pilot Rollout Plan

**Introducing agent-assisted delivery without increasing risk.**

---

## 1. Purpose

This plan defines a low-risk, reversible pilot for ASOM v2.

The goals are to:
- validate the operating model in real delivery
- build trust with Audit, Risk, and ITSM
- surface practical friction early
- avoid disruption to ongoing delivery
- create evidence for scale-out decisions

**Key principle:** ASOM v2 must earn the right to scale.

---

## 2. Pilot Scope (Strictly Limited)

**In Scope:**
- One delivery team
- One data pipeline / data product
- One release
- DEV → QA → PROD lifecycle
- Existing Jira, CI/CD, ServiceNow processes

**Out of Scope:**
- Org-wide rollout
- Tool replacement
- Process re-engineering
- SLA or resourcing changes

---

## 3. Success Criteria (Defined Up Front)

The pilot is successful if:
- Gates block non-compliant promotion correctly
- Evidence is produced without manual rework
- Audit walkthrough can be completed from system records
- Delivery lead confirms friction is acceptable
- No increase in production incidents

If these are not met, the pilot stops.

---

## 4. 0--30 Days -- Foundation & Shadow Mode

### Objective

Introduce ASOM v2 without enforcement.

### Activities

- Socialise ASOM v2 Playbook with:
  - pilot team
  - governance partner
  - ITSM contact
- Identify:
  - applicable controls
  - required test categories
  - evidence expectations
- Configure CI/CD to:
  - generate evidence artifacts
  - populate Evidence Ledger (shadow mode)
- Gates run in observe-only mode
- No release is blocked during this phase

### Deliverables

- Control applicability matrix
- Draft Evidence Ledger entries
- First audit walkthrough (dry run)

### Exit Criteria

- Evidence can be generated deterministically
- Gate outcomes are understandable
- No unexpected tooling blockers

---

## 5. 31--60 Days -- Controlled Enforcement (QA Only)

### Objective

Prove ASOM v2 can block safely without business impact.

### Activities

- Enforce:
  - PR merge gate (G1)
  - QA promotion gate (G3)
- Human QA approval required via ServiceNow
- Evidence Ledger used as source of truth
- Governance checks evidence completeness
- One real QA promotion under ASOM v2

### Deliverables

- QA promotion decision backed by evidence
- Documented gate failure (if any) and remediation
- Updated playbooks based on feedback

### Exit Criteria

- QA promotion blocked when controls are missing
- Remediation path is clear and repeatable
- No emergency overrides required

---

## 6. 61--90 Days -- Full Lifecycle (QA + PROD)

### Objective

Demonstrate end-to-end compliance in production.

### Activities

- Enforce:
  - QA gate (G3)
  - PROD gate (G4)
- Human approvals recorded in ServiceNow
- Governance verification report generated
- Complete audit walkthrough from PROD release

### Deliverables

- PROD release under ASOM v2
- Full evidence ledger for the release
- Audit walkthrough sign-off
- Pilot retrospective

### Exit Criteria

- Audit confirms traceability
- Delivery confirms acceptable friction
- No control bypasses
- Leadership comfortable to decide on scale-out

---

## 7. Metrics to Track (Minimal but Meaningful)

### Delivery Metrics

- Gate failure count (by control)
- Time to remediate failed gates
- Cycle time impact (QA / PROD)

### Governance Metrics

- Manual review effort reduced
- Evidence completeness rate
- Number of exceptions raised

### Risk Metrics

- Production incidents
- Emergency changes
- Post-release defects

---

## 8. Decision Points

### Day 30 -- Continue or Stop

- Evidence generation viable?
- Gates understandable?
- Team engagement acceptable?

### Day 60 -- Expand or Contain

- QA enforcement stable?
- No governance escalations?
- No delivery paralysis?

### Day 90 -- Scale or Sunset

- Audit confidence achieved?
- Platform leadership support?
- Clear value demonstrated?

---

## 9. Scale-Out Guidance (If Approved)

**If the pilot succeeds:**
- onboard 1--2 additional teams
- reuse templates and gates
- do not customise per team
- keep governance centralised initially

**If the pilot fails:**
- revert gates to observe-only
- retain evidence practices
- document lessons learned

Failure is an acceptable outcome.

---

## 10. Risk Posture Statement

This pilot introduces new enforcement gradually, preserves existing approval authority, and can be stopped at any time without system impact.
