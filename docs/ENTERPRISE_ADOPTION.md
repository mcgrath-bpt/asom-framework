# ASOM Enterprise Adoption Guide

## 1. Executive Positioning

### 1.1 Decision Context

**Title:** ASOM v2: Agent-Assisted Delivery Under Enterprise Controls

**Subtitle:** Enabling AI-accelerated delivery without weakening governance

**Decision Requested:** Approval to run a controlled ASOM v2 pilot (30-60-90 days)

### 1.2 The Problem

Delivery velocity and governance are in tension. AI assistance is increasing, but controls lag behind. Manual compliance creates friction and audit risk. Existing SDLCs do not scale to data-platform change velocity.

The risk is binary: either governance erodes, or delivery slows to a crawl.

### 1.3 Why Naive Agentic AI Is Not Acceptable

Observed risks with uncontrolled agent-assisted delivery:

- Self-approval loops
- Fabricated or narrative "evidence"
- Weak separation of duties
- Audit exposure
- Tool-centric rather than control-centric designs

Autonomous AI delivery is incompatible with regulated enterprise environments.

### 1.4 ASOM v2 Positioning

**What ASOM v2 Is:**
- An agent-assisted delivery operating model
- Designed for regulated cloud data platforms
- Built around controls, evidence, and gates

**What ASOM v2 Is Not:**
- Autonomous deployment
- A replacement for Jira, ServiceNow, or CI/CD
- A governance shortcut

**Core Principle:** Agents assist. Systems enforce. Humans approve.

### 1.5 Operating Model Summary

**Roles:**
- Humans: approve, deploy, own accountability
- Agents: draft, analyse, surface gaps
- Systems: enforce gates and produce evidence

**Flow:**
```
DEV --> QA --> PROD
        ^       ^
   Human approval (ServiceNow)
```

**Key Constraint:** Exactly one CRQ per release.

### 1.6 Governance Spine

ASOM v2 enforces:
- Explicit control objectives
- Machine-generated evidence
- Immutable evidence ledger
- Deterministic promotion gates
- Technical separation of duties

No reliance on screenshots, emails, narrative compliance, or trust in individuals or agents.

### 1.7 How a Change Is Governed (Lifecycle View)

1. Scope defined in Jira
2. Code + tests executed in CI/CD
3. Evidence generated automatically
4. Gates evaluate controls
5. Human approvals recorded in ServiceNow
6. Promotion allowed or blocked deterministically

Failures surface early. Remediation is explicit. Audit trail is complete by default.

### 1.8 Evidence and Auditability

Evidence characteristics:
- Machine-generated
- Traceable to commit, build, CRQ
- Stored in authoritative systems
- Indexed via Evidence Ledger

Any production release can be audited end-to-end from system records alone.

### 1.9 Risk Management and Failure Containment

Known failure modes explicitly addressed:
- Hallucinated compliance
- Agent overreach
- Approval bypass
- Evidence reuse
- Silent data drift
- Cost regressions

ASOM v2 fails safe -- by blocking promotion.

### 1.10 Pilot Proposal (30-60-90 Days)

**30 Days:**
- Shadow mode
- No enforcement
- Evidence generation only

**60 Days:**
- QA gate enforced
- Human approvals required
- One real release

**90 Days:**
- PROD gate enforced
- Full audit walkthrough
- Scale / stop decision

The pilot is reversible at any point.

### 1.11 Decision Framework

**Approval Does NOT:**
- Replace existing SDLC
- Automate approvals
- Change ITSM ownership
- Introduce vendor lock-in

**Approval DOES:**
- Allow a controlled pilot
- Reduce audit friction
- Improve delivery predictability
- Establish safe AI usage patterns

**Decision Requested:**
- Approve ASOM v2 pilot
- Nominate one pilot team
- Nominate one governance partner
- Review outcomes at Day 90

**Success Criteria:**
- No increase in risk
- Clear audit traceability
- Acceptable delivery friction
- Leadership confidence to scale (or stop)

---

## 2. Audit Walkthrough

### 2.1 Purpose

This section provides a linear, evidence-first walkthrough of how ASOM v2 governs a change from inception to production. It is designed for Internal Audit, Risk and Compliance, Quality / GxP reviewers, and Architecture Review Boards.

It intentionally avoids screenshots, tool-specific instructions, subjective judgement, and agent narratives.

**Principle:** If the control cannot be demonstrated from system records, it does not exist.

### 2.2 Audit Question

"How do you ensure that only approved, tested, and compliant changes reach production?"

ASOM v2 answers this through enforced gates, authoritative systems of record, deterministic evidence, and explicit human approvals.

### 2.3 Systems of Record

| Concern | System of Record |
|---------|------------------|
| Source code | Git |
| Test execution | CI/CD |
| Scope and requirements | Jira |
| Documentation and narrative | Confluence |
| Change approval | ServiceNow |
| Evidence index | Evidence Ledger |

Agents are not systems of record.

### 2.4 Step-by-Step Narrative

**Step 1 -- Business Intent Is Defined**
- Business requirement captured in Jira
- Acceptance criteria explicitly documented
- Scope is visible and reviewable
- Control coverage: C-03 (Requirements Traceability)
- Evidence: Jira issue history, acceptance criteria text

**Step 2 -- Code Is Implemented and Tested**
- Code committed to Git
- Tests execute automatically in CI/CD
- Test failures block progress
- Control coverage: C-03, C-06 (Data Quality), C-08 (Incremental Correctness)
- Evidence: CI test reports, commit history

**Step 3 -- PR Merge Gate Enforced**
- PR cannot merge without linked Jira, passing tests, and evidence generation
- Control coverage: C-01 (Change Authorisation), C-02 (Separation of Duties)
- Evidence: PR approval record, CI gate result

**Step 4 -- Release Candidate Established**
- Release scope defined
- Exactly one CRQ created in ServiceNow
- CRQ references Jira scope
- Control coverage: C-01
- Evidence: ServiceNow CRQ, Jira-CRQ linkage

**Step 5 -- Promote to QA (Human-Approved)**
- Human approval recorded in ServiceNow
- CI validates CRQ approval state, evidence completeness, and SoD compliance
- Control coverage: C-01, C-02, all applicable technical controls
- Evidence: CRQ approval state, Evidence Ledger entries, CI gate result

**Step 6 -- QA Validation Performed**
- QA execution report generated
- Results reviewed by humans
- Failures block further promotion
- Control coverage: C-06, C-09 (Observability)
- Evidence: QA execution report, test artifacts

**Step 7 -- Promote to PROD (Human-Approved)**
- Second human approval recorded in ServiceNow
- PROD-specific controls verified
- Governance verification confirms completeness
- Control coverage: all applicable controls
- Evidence: CRQ PROD approval, governance verification report, PROD gate result

### 2.5 Evidence-First Verification

For any production release, an auditor can:

1. Identify the CRQ
2. Retrieve linked Jira scope
3. Retrieve Evidence Ledger entries
4. Validate control coverage
5. Trace evidence to artifacts
6. Confirm human approvals
7. Confirm no overrides occurred

No screenshots. No emails. No tribal knowledge.

### 2.6 Separation of Duties Demonstration

From system records, an auditor can confirm:
- Author is not Approver
- Approver is not Deployer
- Evidence Producer is not Verifier
- Agents are not Approvers

This satisfies enterprise SoD expectations.

### 2.7 Exception Handling

- Emergency changes still require a CRQ
- Exceptions are explicitly recorded
- Exception evidence is auditable
- Post-incident review is mandatory

No silent bypasses exist.

### 2.8 Why Agents Do Not Break Controls

Agents draft artifacts, accelerate analysis, and surface gaps.

Agents have no credentials, cannot approve, cannot promote, and cannot fabricate evidence.

This preserves accountability.

### 2.9 Audit Conclusion

ASOM v2 ensures that all changes reaching production are:
- Explicitly approved
- Fully tested
- Governed by enforced controls
- Traceable end to end
- Auditable from system records alone

---

## References

- `docs/ASOM_CONTROLS.md` -- Controls, evidence ledger, gates, and separation of duties
- `docs/HOW_ASOM_FAILS.md` -- Failure modes and mitigations
- `docs/PILOT_ROLLOUT_30_60_90.md` -- Detailed pilot plan
