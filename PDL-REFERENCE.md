# PDL Quick Reference for ASOM

**For Humans:** This document provides a quick overview of how Project Documentation List (PDL) items are handled in ASOM.

**For Agents:** Reference `skills/pdl-governance.md` for detailed procedures.

## Overview

The Project Documentation List (PDL) represents regulatory and audit artefacts that must exist for compliance. In ASOM, we follow the principle of **"Mapping Not Duplication"** - demonstrating that controls exist via code, tests, and tools rather than creating redundant documentation.

## Key Principle

**Governance Agent = PDL Gatekeeper (NOT PDL Author)**

The Governance Agent:
- ✅ Identifies which PDL items are impacted by work
- ✅ Creates tracking tasks for PDL updates
- ✅ Validates PDL completeness before QA/PROD
- ✅ Blocks deployment if PDL incomplete
- ❌ Does NOT create all PDL artefacts itself

## PDL Categories & ASOM Mapping

### Initiation & Governance
| PDL Item | ASOM Mapping | Responsible Agent | Control Mapping |
|----------|--------------|-------------------|-----------------|
| Project Charter | Epic/Demand in issue tracker | BA (with PO) | C-01, C-03 |
| Roadmap | Issue tracker roadmap view | BA + Scrum Master | C-01, C-03 |
| Risk Registry | Risks tracked in issue tracker | BA (assigned by Governance) | C-04, C-05 |

### Architecture & Security
| PDL Item | ASOM Mapping | Responsible Agent | Control Mapping |
|----------|--------------|-------------------|-----------------|
| Architecture Handbook | Confluence/docs architecture page | Dev (assigned by Governance) | C-07 |
| Security Assessment | Security review outcome | Governance | C-04, C-05 |
| Privacy Impact | DPIA for PII processing | Governance | C-04, C-05 |

### Requirements
| PDL Item | ASOM Mapping | Responsible Agent | Control Mapping |
|----------|--------------|-------------------|-----------------|
| User Requirements (URS) | User Stories in issue tracker | BA | C-03 |
| Functional Spec (FS) | Acceptance Criteria in stories | BA | C-03 |
| Design Specs | Design documentation in docs/ | Dev | C-07 |

### Testing (IQ/OQ/PQ)
| PDL Item | ASOM Mapping | Responsible Agent | Control Mapping |
|----------|--------------|-------------------|-----------------|
| Test Strategy | Master test strategy (referenced) | QA | C-06, C-08 |
| IQ Evidence | pytest results, unit/integration tests | Dev (TDD) + QA (validation) | C-06, C-07, C-08 |
| OQ Evidence | Business rule validation tests | QA (assigned by Governance) | C-06, C-08 |
| PQ Evidence | Performance/UAT tests (if applicable) | QA | C-10 |
| Traceability Matrix | Auto-generated from issue tracker | QA (assigned by Governance) | C-03 |

### Release & Operations
| PDL Item | ASOM Mapping | Responsible Agent | Control Mapping |
|----------|--------------|-------------------|-----------------|
| Change Request | CRQ record in change management | Scrum Master | C-01, C-02 |
| Operational Handbook (ITOH) | Runbook, monitoring, troubleshooting | Dev (assigned by Governance) | C-09 |
| Service Transition | Deployment procedures | Dev + Scrum Master | C-01, C-07 |

## Complete PDL Workflow

### 1. Epic Created (PO + BA)

```
[PO] Creates Epic E001: Customer Data Pipeline

[BA Agent] Refines epic with business context

[Governance Agent] Performs PDL Impact Assessment
↓
Identifies 6 PDL items impacted:
- T001: Update Risk Registry (→ BA)
- T002: Update Architecture Handbook (→ Dev)
- T003: Security Assessment (→ Governance)
- T004: Privacy Impact Assessment (→ Governance)
- T005: Create OQ Test Plan (→ QA)
- T006: Update ITOH (→ Dev)

[Governance Agent] Creates 6 tracking tasks in issue tracker
```

**PDL Status: 0% complete (6 tasks created)**

### 2. Stories Created (BA)

```
[BA Agent] Creates stories S001-S005

[Governance Agent] Reviews each story
- Checks if PDL tasks cover the impacts
- Confirms functional specs in acceptance criteria
- Validates test requirements included

[BA Agent] Handles T001 (Risk Registry)
- Documents PII processing risks
- Links to epic E001
- Marks complete

[Governance Agent] Verifies T001
```

**PDL Status: 17% complete (1/6 tasks done)**

### 3. Development (Dev Agent - TDD)

```
[Dev Agent] Implements S001 using TDD
- RED: Writes failing tests
- GREEN: Implements code to pass
- REFACTOR: Improves quality

[Dev Agent] Handles T002 (Architecture Handbook)
- Documents API integration
- Creates data flow diagram
- Links to code implementation
- Marks complete

[Governance Agent] Reviews and verifies T002

[Dev Agent] Handles T006 (ITOH)
- Documents deployment procedures
- Adds monitoring and alerting
- Includes troubleshooting guide
- Marks complete

[Governance Agent] Reviews and verifies T006
```

**PDL Status: 50% complete (3/6 tasks done)**

### 4. Governance Reviews (Governance Agent)

```
[Governance Agent] Performs own tasks:

T003: Security Assessment
- Reviews PII handling approach
- Validates encryption in transit/rest
- Verifies security controls
- Marks complete

T004: Privacy Impact Assessment
- Assesses GDPR implications
- Documents lawful basis for processing
- Confirms data minimization
- Marks complete
```

**PDL Status: 83% complete (5/6 tasks done)**

### 5. QA Validation (QA Agent)

```
[QA Agent] Validates S001-S005
- Executes all tests (IQ evidence generated automatically)
- Validates TDD process followed

[QA Agent] Handles T005 (OQ Test Plan)
- Creates business rule test cases
- Executes OQ tests in QA environment
- Generates OQ evidence report
- Creates traceability matrix
- Marks complete

[Governance Agent] Reviews and verifies T005
```

**PDL Status: 100% complete (6/6 tasks done)**

### 6. QA Deployment Gate (Governance Agent -- Verification)

```
[Governance Agent] PDL Verification Report (G3 -- QA Promotion)

Checks:
✓ Risk Registry updated (T001)
✓ Architecture Handbook current (T002)
✓ Security Assessment complete (T003)
✓ Privacy Impact Assessment complete (T004)
✓ OQ Test Plan executed (T005)
✓ ITOH updated (T006)
✓ IQ evidence exists (pytest results) -- produced by CI
✓ Traceability matrix generated
✓ All user stories have acceptance criteria (FS)
✓ PII masking validated
✓ Audit logging verified

PDL Status: 100% complete ✓
Evidence Ledger: All applicable controls have evidence entries ✓

VERIFICATION STATUS: All controls satisfied.
Human approval required for QA promotion via ServiceNow.
```

### 7. PROD Deployment Gate (Governance Agent -- Verification)

```
[Governance Agent] Re-validates for PROD (G4 -- PROD Promotion)

Checks:
✓ No changes since QA (PDL still current)
✓ IQ evidence for PROD environment -- produced by CI
✓ Change Request created
✓ All governance controls verified in QA
✓ Rollback procedures documented

PDL Status: 100% complete and validated ✓
Evidence Ledger: All applicable controls have PROD evidence entries ✓

VERIFICATION STATUS: All controls satisfied.
Human PROD approval required via ServiceNow.
```

## PDL and the Evidence Ledger

Every PDL item must be backed by one or more evidence ledger entries. The evidence ledger is a formal, machine-verifiable index of control evidence produced during a release.

| PDL Status | Evidence Ledger Meaning |
|------------|------------------------|
| **Produced** | Evidence entry exists in ledger, produced by an authoritative system (CI/CD, platform, policy engine) |
| **Referenced** | Evidence entry links to an external authoritative system (e.g., ServiceNow CRQ record) |
| **N/A** | Justification recorded and approved by human; documented as evidence entry |

**Key rules:**
- PDL status is only valid when backed by verifiable evidence ledger entries
- Agents may reference evidence but cannot generate, modify, or certify it
- Evidence must trace to a single commit SHA, build execution, and CRQ per release
- The ledger indexes evidence -- it does not duplicate artifacts

For the full evidence ledger specification, see `docs/ASOM_CONTROLS.md`.

## PDL and Gates

Promotion gates verify PDL completeness at key transitions. Each gate checks that all applicable PDL items have corresponding evidence ledger entries.

| Gate | PDL Verification |
|------|-----------------|
| **G1 (PR Merge)** | Linked Jira story exists, unit tests executed, evidence entries created |
| **G2 (Release Candidate)** | Release scope defined, CRQ created, control applicability determined |
| **G3 (QA Promotion)** | PDL 100% complete, all applicable controls have evidence, human QA approval recorded in ServiceNow |
| **G4 (PROD Promotion)** | PDL re-validated, PROD-specific evidence present, human PROD approval recorded in ServiceNow |

**Gate behavior:**
- Gates are deterministic and machine-enforced -- they allow or block
- Incomplete PDL blocks promotion at G3 and G4
- Governance Agent verifies evidence completeness but does not approve promotion
- Human approval is required at G3 (QA) and G4 (PROD) via ServiceNow

For the full gate rules, see `docs/ASOM_CONTROLS.md`.

## Agent Responsibilities Summary

### Governance Agent (PDL Gatekeeper -- Verification Only)
- Performs Control Applicability Assessment (epic/story level, referencing C-01 through C-11)
- Creates PDL tracking tasks
- Assigns tasks to appropriate agents
- Monitors PDL task completion
- Verifies evidence completeness before QA/PROD (does not approve promotion)
- Performs own governance tasks (security, privacy assessments)
- Publishes verification reports (not approvals -- humans approve via ServiceNow)

### BA Agent (Requirements & Risk)
- Creates user stories (serves as URS/FS)
- Handles assigned PDL tasks:
  - Risk Registry updates
  - Charter/Roadmap updates
  - Requirements clarifications

### Dev Agent (Implementation & Documentation)
- Implements code with TDD (generates IQ evidence)
- Handles assigned PDL tasks:
  - Architecture Handbook updates
  - ITOH (Operational Handbook) updates
  - Design documentation

### QA Agent (Test Evidence)
- Validates implementation (verifies IQ evidence)
- Handles assigned PDL tasks:
  - OQ Test Plan creation and execution
  - Traceability Matrix generation
  - Test summary reports

### Scrum Master (Coordination)
- Tracks PDL task completion
- Flags PDL blockers early
- Coordinates PDL task handoffs
- Reports PDL status in daily coordination

## PDL Tracking in Issue Tracker

### Labels/Tags
- `pdl-task` - Identifies PDL tracking tasks
- `pdl-blocker` - PDL task blocking QA/PROD
- `pdl-architecture` - Architecture Handbook tasks
- `pdl-testing` - Test evidence tasks
- `pdl-operations` - ITOH tasks
- `pdl-governance` - Governance assessment tasks

### Example Task Structure
```
Task: T002
Title: Update Architecture Handbook - Customer API Integration
Type: PDL Task
Assigned: Dev Agent
Epic: E001
Story: S001
PDL Item: Architecture Handbook
Status: In Progress
Blocker: No
```

### Queries for Visibility
- "Show all PDL tasks for Sprint 1"
- "Show incomplete PDL tasks"
- "Show PDL blockers"
- "PDL completeness percentage"

## Benefits of This Approach

### For Compliance
- ✅ All PDL items tracked explicitly
- ✅ Clear accountability (assigned agents)
- ✅ Audit trail of completion
- ✅ Evidence generated, not manually authored
- ✅ Mapping to SDLC artefacts documented

### For Delivery
- ✅ No duplicate documentation
- ✅ PDL integrated into workflow (not separate)
- ✅ Early identification of blockers
- ✅ Continuous PDL updates (not last-minute)
- ✅ Reuses existing tools and artefacts

### For Quality
- ✅ Tests serve as IQ/OQ/PQ evidence
- ✅ Architecture always documented
- ✅ Operations always have runbooks
- ✅ Governance built-in, not bolted-on
- ✅ TDD ensures compliance controls work

## Anti-Patterns to Avoid

❌ **Creating PDL documents manually**
→ Generate from code/tests/tools instead

❌ **Waiting until end of sprint for PDL**
→ Track PDL tasks from epic creation

❌ **Governance Agent doing all PDL work**
→ Distribute to appropriate agents

❌ **Treating PDL as separate from delivery**
→ Integrate PDL tasks into sprint backlog

❌ **Skipping PDL tasks to "go faster"**
→ Will block deployment later (slower overall)

## Success Criteria

After implementing this PDL workflow:

- ✅ PDL tasks created at epic level
- ✅ PDL tasks tracked throughout sprint
- ✅ PDL completeness visible in daily coordination
- ✅ No QA/PROD deployments with incomplete PDL
- ✅ All artefacts exist and are current
- ✅ Audit trail of PDL task completion
- ✅ Governance integrated, not separate

## Example: Full Sprint PDL Lifecycle

**Sprint Start:**
- Epic created: E001
- Governance creates: T001-T006 (PDL tasks)
- PDL Status: 0%

**Week 1:**
- BA completes T001 (Risk Registry)
- Dev working on T002 (Architecture)
- Governance completes T003, T004 (Assessments)
- PDL Status: 50%

**Week 2:**
- Dev completes T002 (Architecture), T006 (ITOH)
- QA completes T005 (OQ Tests)
- PDL Status: 100%

**QA Gate (G3):**
- Governance verifies PDL: 100% complete ✓
- Evidence ledger: All applicable controls have evidence ✓
- Human QA approval recorded in ServiceNow ✓
- G3 PASSED

**PROD Gate (G4):**
- Governance re-validates: Still 100% ✓
- Evidence ledger: PROD evidence entries present ✓
- Human PROD approval recorded in ServiceNow ✓
- G4 PASSED

**Result:** Compliant release with complete audit trail and evidence ledger
