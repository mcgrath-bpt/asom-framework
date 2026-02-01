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
| PDL Item | ASOM Mapping | Responsible Agent |
|----------|--------------|-------------------|
| Project Charter | Epic/Demand in issue tracker | BA (with PO) |
| Roadmap | Issue tracker roadmap view | BA + Scrum Master |
| Risk Registry | Risks tracked in issue tracker | BA (assigned by Governance) |

### Architecture & Security
| PDL Item | ASOM Mapping | Responsible Agent |
|----------|--------------|-------------------|
| Architecture Handbook | Confluence/docs architecture page | Dev (assigned by Governance) |
| Security Assessment | Security review outcome | Governance |
| Privacy Impact | DPIA for PII processing | Governance |

### Requirements
| PDL Item | ASOM Mapping | Responsible Agent |
|----------|--------------|-------------------|
| User Requirements (URS) | User Stories in issue tracker | BA |
| Functional Spec (FS) | Acceptance Criteria in stories | BA |
| Design Specs | Design documentation in docs/ | Dev |

### Testing (IQ/OQ/PQ)
| PDL Item | ASOM Mapping | Responsible Agent |
|----------|--------------|-------------------|
| Test Strategy | Master test strategy (referenced) | QA |
| IQ Evidence | pytest results, unit/integration tests | Dev (TDD) + QA (validation) |
| OQ Evidence | Business rule validation tests | QA (assigned by Governance) |
| PQ Evidence | Performance/UAT tests (if applicable) | QA |
| Traceability Matrix | Auto-generated from issue tracker | QA (assigned by Governance) |

### Release & Operations
| PDL Item | ASOM Mapping | Responsible Agent |
|----------|--------------|-------------------|
| Change Request | CRQ record in change management | Scrum Master |
| Operational Handbook (ITOH) | Runbook, monitoring, troubleshooting | Dev (assigned by Governance) |
| Service Transition | Deployment procedures | Dev + Scrum Master |

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

[Governance Agent] Approves T001
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

[Governance Agent] Reviews and approves T002

[Dev Agent] Handles T006 (ITOH)
- Documents deployment procedures
- Adds monitoring and alerting
- Includes troubleshooting guide
- Marks complete

[Governance Agent] Reviews and approves T006
```

**PDL Status: 50% complete (3/6 tasks done)**

### 4. Governance Reviews (Governance Agent)

```
[Governance Agent] Performs own tasks:

T003: Security Assessment
- Reviews PII handling approach
- Validates encryption in transit/rest
- Approves security controls
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

[Governance Agent] Reviews and approves T005
```

**PDL Status: 100% complete (6/6 tasks done)**

### 6. QA Deployment Gate (Governance Agent)

```
[Governance Agent] PDL Gate Review

Checks:
✓ Risk Registry updated (T001)
✓ Architecture Handbook current (T002)
✓ Security Assessment complete (T003)
✓ Privacy Impact Assessment complete (T004)
✓ OQ Test Plan executed (T005)
✓ ITOH updated (T006)
✓ IQ evidence exists (pytest results)
✓ Traceability matrix generated
✓ All user stories have acceptance criteria (FS)
✓ PII masking validated
✓ Audit logging verified

PDL Status: 100% complete ✓
All artefacts exist and current ✓

DECISION: APPROVE QA deployment
```

### 7. PROD Deployment Gate (Governance Agent)

```
[Governance Agent] Re-validates for PROD

Checks:
✓ No changes since QA (PDL still current)
✓ IQ evidence for PROD environment
✓ Change Request created
✓ All governance controls tested in QA
✓ Rollback procedures documented

PDL Status: 100% complete and validated ✓

DECISION: APPROVE PROD deployment
Compliance certified ✓
```

## Agent Responsibilities Summary

### Governance Agent (PDL Gatekeeper)
- Performs PDL Impact Assessment (epic/story level)
- Creates PDL tracking tasks
- Assigns tasks to appropriate agents
- Monitors PDL task completion
- Blocks QA/PROD if PDL incomplete
- Performs own governance tasks (security, privacy assessments)

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
  ✅ All PDL items tracked explicitly
  ✅ Clear accountability (assigned agents)
  ✅ Audit trail of completion
  ✅ Evidence generated, not manually authored
  ✅ Mapping to SDLC artefacts documented

### For Delivery
  ✅ No duplicate documentation
  ✅ PDL integrated into workflow (not separate)
  ✅ Early identification of blockers
  ✅ Continuous PDL updates (not last-minute)
  ✅ Reuses existing tools and artefacts

### For Quality
  ✅ Tests serve as IQ/OQ/PQ evidence
  ✅ Architecture always documented
  ✅ Operations always have runbooks
  ✅ Governance built-in, not bolted-on
  ✅ TDD ensures compliance controls work

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

  ✅ PDL tasks created at epic level
  ✅ PDL tasks tracked throughout sprint
  ✅ PDL completeness visible in daily coordination
  ✅ No QA/PROD deployments with incomplete PDL
  ✅ All artefacts exist and are current
  ✅ Audit trail of PDL task completion
  ✅ Governance integrated, not separate

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

**QA Gate:**
- Governance validates PDL: 100% complete ✓
- APPROVED for QA

**PROD Gate:**
- Governance re-validates: Still 100% ✓
- APPROVED for PROD

**Result:** Compliant release with complete audit trail
