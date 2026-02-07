# ASOM Controls, Evidence, and Gates

**Canonical reference for enterprise control enforcement in ASOM v2.**

> **Agents assist. Systems enforce. Humans approve.**

---

## 1. Purpose

This document consolidates the four pillars of ASOM v2 enterprise governance:

1. **Control Catalog** -- what must be true (C-01 through C-11)
2. **Evidence Ledger** -- how compliance is proven
3. **Promotion Gates** -- where enforcement happens (G1 through G4)
4. **Separation of Duties** -- who can do what

These are technology-agnostic, align to regulated SDLC expectations (SOX / GxP / ITGC), and are enforced through CI/CD gates and human approvals.

**Non-negotiable rules:**
- Controls define what must be true. Tooling defines how.
- Evidence must be produced by authoritative systems, not agents.
- Agents may assist, but cannot satisfy, approve, or certify controls.
- If separation of duties is not enforced technically, it does not exist.

---

## 2. Control Catalog (v2 Baseline)

### Control Model Principles

1. Every control has a clear objective, an explicit risk, and defined evidence requirements
2. Evidence must be produced by authoritative systems and traceable to a single CRQ per release
3. Verification is deterministic and blocks promotion when incomplete
4. "N/A" is allowed only with explicit justification and approval

---

### C-01 -- Change Authorization

| | |
|---|---|
| **Objective** | Ensure all changes are formally approved before promotion to QA and PROD |
| **Risk** | Unauthorised or unreviewed changes reaching controlled environments |
| **Scope** | All releases promoted beyond DEV |

**Evidence Requirements:**

| Evidence | Produced By | Source |
|----------|-------------|--------|
| Approved CRQ | ServiceNow | SNOW record |
| Linked Jira scope | Jira | Epic / Stories |

**Verification Rule:**
- Exactly one CRQ per release
- CRQ state = Approved
- CRQ references Jira release scope

**Gate:** G3 (QA promotion), G4 (PROD promotion)

---

### C-02 -- Separation of Duties (SoD)

| | |
|---|---|
| **Objective** | Ensure no individual or agent can approve or promote their own changes |
| **Risk** | Self-approval leading to uncontrolled or fraudulent changes |

**Evidence Requirements:**

| Evidence | Produced By |
|----------|-------------|
| Commit history | Git |
| Approval records | Jira / ServiceNow |
| Deployment identity logs | CI/CD |

**Verification Rule:**
- Author != Approver
- Approver != Deployer
- Governance verification != Evidence producer

**Gate:** G3 (QA promotion), G4 (PROD promotion)

---

### C-03 -- Requirements Traceability

| | |
|---|---|
| **Objective** | Ensure all implemented changes trace back to approved business intent |
| **Risk** | Scope creep or unapproved functionality |

**Evidence Requirements:**

| Evidence | Produced By |
|----------|-------------|
| Jira stories | Jira |
| Acceptance criteria | Jira |
| Test references | CI/CD |

**Verification Rule:**
- All code changes reference Jira IDs
- All Jira stories have test coverage

**Gate:** G1 (PR merge), G3 (QA promotion)

---

### C-04 -- Data Classification & Handling

| | |
|---|---|
| **Objective** | Ensure data is handled according to its classification (e.g. PII, PHI) |
| **Risk** | Regulatory breaches and data exposure |

**Evidence Requirements:**

| Evidence | Produced By |
|----------|-------------|
| Data classification metadata | Platform / Catalog |
| Handling rules | Policy config |
| Validation tests | CI/CD |

**Verification Rule:**
- Classification defined
- Handling rules enforced
- Tests validate enforcement

**Gate:** G3 (QA promotion), G4 (PROD promotion)

---

### C-05 -- Access Control & Least Privilege

| | |
|---|---|
| **Objective** | Ensure only authorised users and services can access data |
| **Risk** | Unauthorised access or privilege escalation |

**Evidence Requirements:**

| Evidence | Produced By |
|----------|-------------|
| RBAC policies | Platform export |
| Masking / row policies | Platform export |
| Access tests | CI/CD |

**Verification Rule:**
- Policies exist for target environment
- Tests confirm enforcement

**Gate:** G3 (QA promotion), G4 (PROD promotion)

---

### C-06 -- Data Quality Controls

| | |
|---|---|
| **Objective** | Ensure critical data quality rules are enforced |
| **Risk** | Incorrect or misleading analytics and decisions |

**Evidence Requirements:**

| Evidence | Produced By |
|----------|-------------|
| DQ rule definitions | Code |
| DQ execution results | CI/CD |
| Threshold justification | Jira / Confluence |

**Verification Rule:**
- Critical rules defined
- Rules executed
- Failures block promotion

**Gate:** G3 (QA promotion)

---

### C-07 -- Reproducibility

| | |
|---|---|
| **Objective** | Ensure builds and data transformations are reproducible |
| **Risk** | Inability to reproduce results during incidents or audits |

**Evidence Requirements:**

| Evidence | Produced By |
|----------|-------------|
| Commit SHA | Git |
| Build config | CI/CD |
| Parameter records | CI/CD |

**Verification Rule:**
- Build references immutable artifacts
- Parameters versioned

**Gate:** G3 (QA promotion), G4 (PROD promotion)

---

### C-08 -- Incremental Correctness

| | |
|---|---|
| **Objective** | Ensure incremental and reprocessing logic behaves correctly |
| **Risk** | Silent data corruption or duplication |

**Evidence Requirements:**

| Evidence | Produced By |
|----------|-------------|
| Incremental tests | CI/CD |
| Re-run validation | CI/CD |

**Verification Rule:**
- Idempotency verified
- Incremental logic tested

**Gate:** G3 (QA promotion)

---

### C-09 -- Observability & Alerting

| | |
|---|---|
| **Objective** | Ensure failures are detectable and actionable |
| **Risk** | Undetected data pipeline failures |

**Evidence Requirements:**

| Evidence | Produced By |
|----------|-------------|
| Alert configuration | Platform |
| Test alert triggers | CI/CD |

**Verification Rule:**
- Alerts configured
- Alert tests executed

**Gate:** G4 (PROD promotion)

---

### C-10 -- Cost & Performance Guardrails

| | |
|---|---|
| **Objective** | Ensure changes do not introduce unacceptable cost or performance regressions |
| **Risk** | Runaway platform costs or degraded SLAs |

**Evidence Requirements:**

| Evidence | Produced By |
|----------|-------------|
| Baseline metrics | CI/CD |
| Regression checks | CI/CD |

**Verification Rule:**
- Guardrails defined
- Regressions flagged

**Gate:** G3 (QA promotion), G4 (PROD promotion, if material)

---

### C-11 -- Emergency Override Protocol

| | |
|---|---|
| **Objective** | Ensure that time-critical changes can proceed without weakening the audit trail or normalising deviance |
| **Risk** | Undocumented bypasses, normalisation of deviance, erosion of gate enforcement |
| **Scope** | Any promotion where standard gate evidence is incomplete at time of business-critical need |

**Design Philosophy:**

A framework that claims overrides are impossible is lying. A framework that makes overrides auditable is governing. ASOM chooses auditable.

Every regulated framework has an emergency path: ITIL has Emergency Changes, GxP has Deviation Reports, SOX has Management Override with compensating controls. C-11 is ASOM's equivalent.

**Key Principle:** An override does not disable controls -- it defers them. Evidence is still required, just after the fact within a time-bound window.

**Override Model:**

```
Normal:     Code → Tests → Evidence → Gate → Human Approval → Promote
Emergency:  Code → Emergency Approval → Promote → [Evidence within N days]
```

Both paths end with the same evidence requirements. The difference is sequencing, not substance.

**Evidence Requirements:**

| Evidence | Produced By | Timing |
|----------|-------------|--------|
| Override request with justification | Requestor (human) | Before override |
| Emergency Approver sign-off | Emergency Approver (human, senior to Release Approver) | Before override |
| CRQ with override flag | ServiceNow | Before override |
| Deferred evidence (all applicable controls) | CI/CD / platform | Within remediation window |
| Remediation confirmation | Governance Agent (verification only) | At window close |
| Override incident record | ServiceNow | Automatic |

**Override Rules:**

1. **Higher authority, not less authority.** Emergency override requires approval from a named Emergency Approver -- more senior than the standard Release Approver, not less.
2. **Immutable record.** The override itself is an evidence entry in the ledger. It cannot be hidden, deleted, or reclassified after the fact.
3. **Time-bound remediation.** All deferred evidence must be produced within a defined window (default: 5 business days). The window is recorded at override time and cannot be extended without a second Emergency Approver sign-off.
4. **Compensating controls are mandatory.** The override entry must specify which controls are deferred and what compensating measures are in place during the remediation window.
5. **Automatic escalation on missed remediation.** If deferred evidence is not produced within the window, the system escalates to governance leadership -- not the team, not the original approver. This is non-negotiable.
6. **Frequency monitoring.** Override frequency is tracked per team per quarter. Exceeding the threshold (default: >2 per quarter per team) triggers a mandatory process review. This prevents the emergency path from becoming the default path.
7. **Post-incident review is mandatory.** Every override requires a post-incident review within 10 business days documenting: root cause, what was deferred, remediation status, and process improvement actions.

**Override Evidence Ledger Entry (Additional Fields):**

```yaml
evidence_id: EL-2026-000200
control_id: C-11
produced_by: servicenow
source_type: override_record
override_type: emergency
justification: "Critical data feed failure affecting customer SLA"
emergency_approver: jane.smith@company.com
standard_controls_deferred:
  - C-06  # DQ tests not yet executed
  - C-09  # Observability not yet configured
compensating_controls: "Manual monitoring in place, rollback plan documented"
remediation_deadline: 2026-02-14T17:00:00Z
remediation_status: pending  # pending | completed | escalated
crq_ref: SNOW-CRQ-EMG-001
created_at: 2026-02-07T14:30:00Z
```

**Verification Rule:**
- Override record exists in ledger with all required fields
- Emergency Approver is senior to standard Release Approver
- Remediation deadline is set and within policy limits
- Compensating controls are documented
- Post-incident review is scheduled
- At remediation deadline: all deferred evidence must be present and passing

**Gate Interaction:**
- Overrides apply to G3 (QA promotion) and G4 (PROD promotion) only
- G1 (PR merge) and G2 (Release Candidate) cannot be overridden -- they are prerequisite hygiene
- An overridden gate records `gate_result: OVERRIDE` (not READY, not BLOCKED)
- The gate result includes the override evidence ID for traceability

**Anti-Gaming Rules:**
- Override requests cannot be pre-approved or batched
- Each override is for a single, specific release
- "Standing overrides" are explicitly non-compliant
- Override frequency exceeding threshold triggers automatic process review
- Teams with repeated overrides may have override privilege suspended pending review

**What C-11 Is NOT:**
- A shortcut for poor planning
- A way to avoid writing tests
- A permanent state (all overrides are time-bound)
- Available to agents (only humans can request and approve overrides)

---

### Control-to-PDL Relationship

Each PDL item must map to one or more controls above, with corresponding evidence entries in the Evidence Ledger.

| PDL Status | Meaning |
|------------|---------|
| **Produced** | Evidence exists in ledger |
| **Referenced** | Evidence linked from external system |
| **N/A** | Justification approved and recorded |

---

## 3. Evidence Ledger Specification

### 3.1 Purpose

The Evidence Ledger is a formal, machine-verifiable index of control evidence produced during a release.

**Key rule:** Agents may reference evidence. Agents may never generate, modify, or certify evidence.

### 3.2 Core Principles

1. **Authoritative Production** -- Evidence is generated only by deterministic systems: CI/CD pipelines, platform APIs, policy scanners, test frameworks
2. **Immutability** -- Once recorded, evidence must not be altered
3. **Traceability** -- Every evidence item traces to a single commit SHA, a single build execution, and a single CRQ per release
4. **Minimalism** -- The ledger indexes evidence; it does not duplicate artifacts
5. **Verifiability** -- Governance decisions must be reproducible from ledger data alone

### 3.3 Evidence Item Model (Logical Schema)

```yaml
evidence_id: EL-2026-000123
control_id: C-05
produced_by: ci_pipeline
source_type: build_artifact
source_ref: artifact://ci/build-456/access_tests.json
checksum: sha256:ab349c9...
commit_sha: 9f3c2a1...
build_id: ci-456
jira_refs:
  - JIRA-1234
crq_ref: SNOW-CRQ-987654
environment: QA
status: pass
created_at: 2026-02-01T11:42:18Z
notes: Optional explanatory text
```

### 3.4 Required Fields

| Field | Requirement |
|-------|-------------|
| `evidence_id` | Unique, immutable |
| `control_id` | Must map to Control Catalog |
| `produced_by` | Authoritative system only |
| `source_ref` | Verifiable artifact location |
| `checksum` | Required for integrity |
| `commit_sha` | Exact source version |
| `build_id` | Execution traceability |
| `crq_ref` | One CRQ per release |
| `environment` | DEV / QA / PROD |
| `status` | pass / fail / info |
| `created_at` | UTC timestamp |

### 3.5 Evidence Lifecycle

**Creation** -- Evidence is created when a test executes, a policy is evaluated, a platform configuration is exported, or a validation script runs. Creation must occur inside CI/CD or via platform automation invoked by CI/CD.

**Recording** -- For each evidence item: (1) artifact is generated and stored, (2) checksum is calculated, (3) ledger entry is appended. Ledger storage options: append-only JSONL file, CI artifact metadata store, or lightweight evidence index service.

**Verification** -- Governance verification consists of: existence check, provenance check, checksum validation, and control coverage validation. Governance does not inspect artifact contents unless required.

### 3.6 Governance Usage Model

**What Governance Verifies:**
- All applicable controls have evidence
- Evidence sources are authoritative
- Evidence belongs to the correct release (CRQ)
- Evidence status satisfies gate rules

**What Governance Does NOT Do:**
- Create evidence
- Rerun tests
- Modify artifacts
- Approve promotion
- Override failures

Governance produces **verification reports**, not approvals.

### 3.7 Anti-Patterns (Explicitly Forbidden)

The following invalidate evidence:
- Evidence authored manually
- Screenshots as primary evidence
- Narrative descriptions without artifacts
- Evidence generated by agents
- Evidence reused across releases without re-execution
- Shared CRQs across unrelated releases

---

## 4. Promotion Gates (G1 through G4)

### 4.1 Gate Model

A gate does not "recommend." A gate allows or blocks.

Gates are deterministic, machine-enforced, auditable, and independent of agent behaviour. Each gate has explicit entry conditions, pass/fail rules, and produces evidence entries in the Evidence Ledger.

| Gate | Trigger | Purpose |
|------|---------|---------|
| **G1** | PR Merge | Prevent untracked / untested changes |
| **G2** | Release Candidate | Ensure release readiness |
| **G3** | Promote to QA | Enforce controls + human approval |
| **G4** | Promote to PROD | Enforce final approval + PROD-specific controls |

---

### G1 -- Pull Request (PR) Merge Gate

**Objective:** Prevent uncontrolled or untraceable code changes from entering the mainline.

| Requirement | Verification Source |
|-------------|-------------------|
| Linked Jira story | Git / Jira |
| Acceptance criteria present | Jira |
| Unit tests executed | CI |
| Contract/schema tests executed | CI |
| No failing tests | CI |
| Evidence entries created | Evidence Ledger |

**Fail** = PR cannot be merged. **Pass** = PR merge allowed.

---

### G2 -- Release Candidate Gate

**Objective:** Establish a controlled release scope prior to environment promotion.

| Requirement | Verification Source |
|-------------|-------------------|
| Defined release scope | Jira (Epic / Release) |
| Single CRQ created | ServiceNow |
| CRQ references Jira scope | ServiceNow |
| Controls applicability determined | Governance Agent |
| Evidence plan established | Governance Agent |

At this stage, evidence may be incomplete, but expectations must be explicit.

**Fail** = Release cannot proceed. **Pass** = QA promotion eligible (pending approval).

---

### G3 -- Promote to QA

**Objective:** Ensure the release is safe to enter a controlled test environment.

| Requirement | Verification Source |
|-------------|-------------------|
| Human approval recorded | ServiceNow |
| CRQ state = Approved for QA | ServiceNow |
| Evidence completeness | Evidence Ledger |
| SoD compliance | CI / Ledger |
| QA execution report | CI |

**Required evidence (typical):** DQ test results, access control validation, incremental correctness tests, reproducibility metadata.

**Fail** = Promotion blocked. **Pass** = QA deployment allowed.

---

### G4 -- Promote to PROD

**Objective:** Ensure the release is authorised, verified, and safe for production.

| Requirement | Verification Source |
|-------------|-------------------|
| Human PROD approval | ServiceNow |
| CRQ state = Approved for PROD | ServiceNow |
| Governance verification report | Evidence Ledger |
| PROD-specific controls satisfied | Evidence Ledger |
| No unresolved QA failures | CI |

**PROD-specific controls (examples):** Observability & alerting enabled, PROD access policies validated, cost/performance guardrails checked.

**Fail** = PROD deployment blocked. **Pass** = PROD deployment allowed.

---

### 4.2 Agent Interaction with Gates

Agents **may**: prepare artifacts, surface missing requirements, summarise gate failures, suggest remediation.

Agents **may not**: approve gates, override failures, manipulate evidence.

### 4.3 Gate Anti-Patterns (Explicitly Forbidden)

The following invalidate a release:
- Undocumented gate overrides (documented overrides via C-11 are permitted)
- "Temporary" bypasses without CRQ and override record
- Approvals outside ServiceNow
- Promotion without ledger verification
- Agent-triggered promotions
- Standing or pre-approved overrides

### 4.4 Evidence Produced by Gates

Each gate produces evidence entries including: gate execution result, timestamp, decision (pass/fail), and blocking reason (if any). This allows auditors to verify what blocked a release, why it was blocked, and how it was resolved.

---

## 5. Separation of Duties (SoD)

### 5.1 Human Roles (Authoritative)

| Role | Responsibility |
|------|---------------|
| **Developer** (human) | Authors code and tests |
| **QA Engineer** (human) | Reviews test outcomes |
| **Release Approver** (human) | Approves QA and PROD promotion |
| **Governance / Quality** (human) | Verifies evidence completeness |
| **Change Manager** (human) | Owns CRQ approval in ServiceNow |

### 5.2 Agent Roles (Non-Authoritative)

| Agent | Responsibility |
|-------|---------------|
| **BA Agent** | Acceptance criteria & scope refinement |
| **Dev Agent** | Code & test generation assistance |
| **QA Agent** | Test execution coordination |
| **Governance Agent** | Evidence completeness verification |
| **Scrum Agent** | Coordination, reporting, hygiene |

**Agents do not hold authority. Agents cannot approve, promote, or certify compliance.**

### 5.3 Authority Matrix

| Actor | May Do | Must Not Do |
|-------|--------|------------|
| Human Developer | Commit code | Approve own promotion |
| Human QA | Review results | Modify code under test |
| Release Approver | Approve QA/PROD | Change artifacts post-approval |
| Governance | Verify evidence | Generate or modify evidence |
| Any Agent | Draft artifacts | Approve or promote |
| CI/CD | Execute gates | Override approvals |

### 5.4 Technical Enforcement Points

**Source Control:**
- Branch protection rules
- Required reviewers
- Disallowed self-approval
- Mandatory Jira linkage

**CI/CD:**
- Distinct identities for build and deploy
- Gate logic verifying: author != approver, evidence producer != verifier
- Promotion blocked on violation

**ServiceNow (Change):**
- CRQ approver != commit author
- CRQ approval required for QA and PROD
- CRQ state validated by CI gate

**Environment Access:**
- DEV, QA, PROD have distinct access roles
- No shared credentials
- Promotion identities are non-human service identities

### 5.5 SoD Evidence

SoD compliance itself is a verifiable control (C-02). Evidence sources: Git commit history, CI execution metadata, Jira approval records, SNOW CRQ approval records, deployment logs. These are indexed in the Evidence Ledger.

### 5.6 SoD Anti-Patterns (Explicitly Non-Compliant)

The following are not allowed:
- One individual committing, approving, and promoting
- Agents approving or promoting
- Governance agents generating evidence
- Shared "release accounts"
- Undocumented override of failed gates (documented C-11 overrides are permitted)
- Retroactive approvals (except deferred evidence under C-11 with time-bound remediation)

Any of the above invalidate the release.

### 5.7 Handling Exceptions

Exceptions must be: rare, documented, approved outside the delivery team, linked to the CRQ, and time-bound. Exceptions are evidence items themselves.

---

## 6. Audit Walkthrough

An auditor should be able to:

1. Select a PROD release
2. Identify the CRQ
3. Retrieve all ledger entries for that CRQ
4. Validate control coverage (C-01 through C-11)
5. Trace each evidence item to its artifact and source
6. Confirm approvals and SoD (author != approver != deployer)
7. Verify gate execution (G1 through G4)
8. Check for overrides: if none, confirm clean passage; if C-11 override used, verify override record completeness, remediation evidence, and post-incident review

**Using system records only.** No screenshots, email chains, or tribal knowledge required.

---

## 7. Versioning

- Control Catalog, Evidence Ledger schema, Gate Rules, and SoD Rules are all versioned
- Changes require architecture and governance approval
- Controls and gates are additive by default
- Gate tightening is allowed without exception; gate loosening requires explicit risk acceptance
- Backward compatibility must be maintained for ledger schema
