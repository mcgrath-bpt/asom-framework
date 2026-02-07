# ASOM: Agentic Scrum Operating Model

**Agent-assisted delivery under enforced SDLC controls for regulated data platforms.**

> **Agents assist. Systems enforce. Humans approve.**

[![Framework Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/yourusername/asom-framework)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## What is ASOM?

ASOM (Agentic Scrum Operating Model) is an operating model for agent-assisted delivery under enforced SDLC controls. Agents draft and interpret artifacts, while authoritative systems (CI/CD, SCM, ticketing, policy engines) produce immutable evidence and enforce gates. ASOM is designed for regulated data platforms where separation of duties and auditability are mandatory.

AI agents accelerate -- but never bypass -- SDLC controls. Governance, auditability, and separation of duties are enforced by authoritative enterprise systems (Git, CI/CD, Jira, Confluence, ServiceNow).

ASOM combines:

- **Five specialized agent roles** (BA, Dev, QA, Governance, Scrum Master)
- **Test-Driven Development** as fundamental practice (RED -> GREEN -> REFACTOR)
- **PDL Governance** integrated into workflow ("Mapping Not Duplication")
- **Control Objectives** (C-01 through C-11) defining what must be true, including emergency override protocol
- **Evidence Ledger** with immutable, system-produced compliance evidence
- **Promotion Gates** (G1 through G4) enforcing controls at every transition
- **Scrum methodology** with 2-week sprints
- **Production-ready quality** with complete audit trail

**Use ASOM when you need:**
- Regulatory compliance (GDPR, SOX, HIPAA)
- Audit-ready documentation
- High-quality, tested code
- Clear governance boundaries
- Machine-enforced promotion gates
- Immutable evidence ledger
- Separation of duties enforcement

---

## Quick Start

### 1. Get the Framework

```bash
git clone https://github.com/yourusername/asom-framework.git
cd asom-framework
```

### 2. Your First Sprint

Follow the [QUICKSTART.md](QUICKSTART.md) guide to build your first customer data pipeline with complete PDL governance in 10 days.

**What you'll build:**
- Extract customer data from REST API
- Mask PII (email, phone) for GDPR compliance
- Load to Snowflake with access controls
- Complete all PDL artefacts (100%)
- Deploy to production with governance certification

### 3. Read the Philosophy

See [ASOM.md](ASOM.md) to understand the core principles and why TDD + PDL governance + enforced controls enable agent-assisted delivery.

---

## Core Principles

### 1. Agentic Role Separation

Work is divided among five specialized agent roles, each with clear responsibilities:

| Agent | Primary Responsibility | PDL Artefacts |
|-------|----------------------|---------------|
| **Business Analyst** | Requirements, stories | Risk Registry, Charter, Roadmap |
| **Developer** | Implementation (TDD) | Architecture Handbook, ITOH |
| **QA** | Testing, validation | Test Evidence (IQ/OQ/PQ), Traceability |
| **Governance** | PDL Gatekeeper | Security/Privacy Assessments, Gate Reviews |
| **Scrum Master** | Coordination, tracking | PDL task tracking, Sprint reports |

Each agent has:
- Defined decision-making frameworks
- Clear handoff protocols
- Specific skills to reference
- Quality standards

### 2. Test-Driven Development (Fundamental)

**TDD is mandatory in ASOM** - not optional:

```
RED -> GREEN -> REFACTOR
```

1. **RED**: Write failing test first (defines requirements)
2. **GREEN**: Write minimum code to pass (implements requirements)
3. **REFACTOR**: Improve code quality (maintains standards)

**Why TDD is fundamental:**
- Requirements clarity (tests force precise criteria)
- Quality by design (can't mark "done" without tests)
- Regression prevention (refactoring is safe)
- Governance evidence (tests produce system-verifiable evidence)
- Agent-assisted confidence (safety net with enforced gates)

### 3. Control Objectives, Evidence, and Gates

**Control Objectives (C-01 through C-11):** Define what must be true for every release. Controls are technology-agnostic and align to SOX, GxP, and ITGC. Controls range from change authorization (C-01) through cost/performance guardrails (C-10), plus the emergency override protocol (C-11) for time-critical situations where evidence is deferred but not waived. See `docs/ASOM_CONTROLS.md` for the full catalog.

**Evidence Ledger:** A formal, machine-verifiable index of control evidence. Evidence is produced only by authoritative systems (CI/CD, platform APIs, policy scanners). Agents may reference evidence but cannot generate, modify, or certify it.

**Promotion Gates (G1 through G4):**

| Gate | Trigger | Purpose |
|------|---------|---------|
| **G1** | PR Merge | Prevent untracked / untested changes |
| **G2** | Release Candidate | Ensure release readiness and CRQ linkage |
| **G3** | Promote to QA | Enforce controls + human approval |
| **G4** | Promote to PROD | Enforce final approval + PROD-specific controls |

Gates are deterministic and machine-enforced. A gate allows or blocks -- it does not recommend.

### 4. PDL Governance ("Mapping Not Duplication")

**Project Documentation List (PDL)** = regulatory/audit artefacts required for compliance

**Core Principle:** Demonstrate controls exist via code, tests, and tools - don't create redundant documentation.

Every PDL item must be:
- **Produced** - Generated by SDLC process
- **Referenced** - Exists in corporate system
- **Not Applicable** - Explicitly justified exemption

**PDL Workflow:**
1. Governance performs PDL Impact Assessment at epic creation
2. Creates tracking tasks (T001-T00N) assigned to appropriate agents
3. Agents complete PDL tasks throughout sprint
4. Governance validates 100% PDL completion before QA/PROD deployment
5. Blocks deployment if PDL incomplete

**PDL Categories:**

| Category | ASOM Mapping | Examples |
|----------|--------------|----------|
| Initiation & Governance | Epic, Risk Registry | Charter, Roadmap |
| Architecture & Security | Confluence docs | Architecture Handbook, Security Assessments |
| Requirements | User Stories | Acceptance Criteria (Functional Spec) |
| Testing | Test execution | IQ/OQ/PQ evidence, Traceability Matrix |
| Release | Change Request | CRQ records |
| Operations | Runbooks | ITOH, Monitoring procedures |

See [PDL-REFERENCE.md](PDL-REFERENCE.md) for complete workflow.

### 5. Scrum Methodology

Standard Scrum practices:
- 2-week sprints with clear goals
- Daily coordination (async via issue tracker)
- Sprint planning, review, retrospective
- Definition of Ready and Definition of Done
- PDL tracking integrated into backlog

### 6. Governance by Default

Every story includes:
- PII protection requirements
- Audit trail implementation
- Access control specifications
- Data retention policies
- Test requirements (IQ/OQ evidence)

Governance is not an afterthought - it's built into acceptance criteria from the start.

---

## Framework Structure

```
asom-framework/
│
├── agents/                          # Agent role definitions
│   ├── BA-AGENT.md                 # Business Analyst
│   ├── DEV-AGENT.md                # Developer (TDD mandatory)
│   ├── QA-AGENT.md                 # QA Engineer
│   ├── GOVERNANCE-AGENT.md         # Governance (PDL Gatekeeper)
│   └── SCRUM-MASTER-AGENT.md       # Scrum Master
│
├── skills/                          # Shared capabilities
│   ├── beads-coordination.md       # Work tracking in issue tracker
│   ├── python-data-engineering.md  # Python patterns for data work
│   ├── snowflake-development.md    # Snowflake best practices
│   ├── testing-strategies.md       # TDD, unit, integration, DQ testing
│   ├── data-quality-validation.md  # Completeness, accuracy, consistency
│   ├── pdl-governance.md           # PDL workflow and tracking
│   ├── data-privacy-controls.md    # PII masking, encryption
│   ├── audit-logging.md            # Audit trail requirements
│   ├── git-workflow.md             # Version control best practices
│   └── governance-requirements.md  # Compliance requirements
│
├── docs/                            # Governance and control specifications
│   └── ASOM_CONTROLS.md            # Control catalog, evidence ledger, gates, SoD
│
├── src/                             # Application source code
├── tests/                           # Test suites (unit, integration, DQ, governance)
├── evidence/                        # Evidence ledger storage (append-only)
├── scripts/                         # CI/CD and automation scripts
│
├── ASOM.md                          # Framework philosophy and principles
├── README.md                        # This file
├── QUICKSTART.md                    # Your first sprint guide
├── PDL-REFERENCE.md                 # PDL quick reference for humans
├── ARCHITECTURE.md                  # AGENT vs SKILLS design rationale
└── CLAUDE.md                        # Meta-coordinator for orchestration
```

---

## Technology Stack

ASOM is designed for data engineering with Python and Snowflake, but principles apply to any tech stack.

### Python
- **polars** - High-performance DataFrames
- **pydantic** - Data validation
- **pytest** - Testing (generates IQ evidence)
- **snowflake-connector-python** - Snowflake integration

### Snowflake
- **Medallion Architecture** - Bronze (raw) → Silver → Gold (curated)
- **Streams & Tasks** - Near-real-time processing
- **Row-level security** - Fine-grained access control
- **Masking policies** - PII protection at column level

### Coordination
- **Issue Tracker** - Work and PDL tracking (Beads, Jira, or similar)
- **Documentation** - Architecture and operational docs (Confluence, Markdown)
- **Test Management** - Test evidence (XRay, issue tracker, or similar)
- **Version Control** - Git with conventional commits

---

## Typical Story Lifecycle

```
1. Epic Created (Product Owner)
   └─ Governance Agent: PDL Impact Assessment
      ├─ Identifies 6 PDL items impacted
      └─ Creates PDL tasks T001-T006, assigns to agents

2. BA Agent: Creates Stories
   ├─ Story S001-S005 with acceptance criteria
   ├─ Includes test requirements (TDD)
   └─ Handles T001 (Risk Registry update)

3. Dev Agent: Implements with TDD
   ├─ RED: Writes failing tests
   ├─ GREEN: Implements to pass tests
   ├─ REFACTOR: Improves code quality
   ├─ Handles T002 (Architecture Handbook)
   └─ Handles T006 (ITOH update)

4. QA Agent: Validates
   ├─ Verifies TDD process followed
   ├─ Executes all tests
   ├─ Validates data quality thresholds
   ├─ Handles T005 (OQ test evidence)
   └─ Generates traceability matrix

5. Governance Agent: Completes Own Tasks
   ├─ T003 (Security Assessment)
   └─ T004 (Privacy Impact Assessment)

6. Governance Agent: QA Gate Verification (G3)
   ├─ Verifies PDL 100% complete
   ├─ Verifies all applicable controls have evidence
   ├─ VERIFICATION STATUS: All controls satisfied or Incomplete
   └─ Human QA approval required via ServiceNow

7. QA Deployment
   └─ G3 passed → System deployed to QA environment

8. Governance Agent: PROD Gate Verification (G4)
   ├─ Re-validates PDL completeness
   ├─ Confirms PROD-specific evidence (CRQ, observability, etc.)
   ├─ VERIFICATION STATUS: All controls satisfied or Incomplete
   └─ Human PROD approval required via ServiceNow

9. Story Complete
   └─ Status: Done (100% PDL, all tests passing, evidence ledger complete, gates passed)
```

**Key Insight:** PDL tasks are created at epic start and completed throughout the sprint, NOT as a last-minute scramble.

---

## Agent Handoffs

Clear handoff protocols ensure smooth flow:

```
BA → Governance:    Story refined, needs governance review
Governance → Dev:   Story approved, ready for development
Dev → QA:           PR created, needs testing
QA → Governance:    Tests passing, needs governance verification
Governance → QA:    PDL verified, human approval required for QA (G3)
QA → Governance:    QA validated, needs PROD verification
Governance → Done:  PROD verified, human approval recorded, G4 passed
```

**Workflow States:**
```
backlog → refined → ready → in-progress → in-review → 
testing → governance-review → done
```

---

## Definition of Done

A story is "Done" when:

**Functional:**
- [ ] All acceptance criteria met
- [ ] Code reviewed and approved
- [ ] Deployed to QA and tested

**Quality:**
- [ ] TDD process followed (tests written first)
- [ ] All tests passing (unit, integration, data quality)
- [ ] Test coverage ≥80%
- [ ] Code quality standards met

**Governance:**
- [ ] All PDL tasks complete (100%)
- [ ] PII protection validated
- [ ] Audit logging verified
- [ ] Access controls tested
- [ ] No compliance violations
- [ ] Evidence ledger entries exist for all applicable controls (produced by CI/CD)
- [ ] All applicable gates passed (G1 through G4)

**Documentation:**
- [ ] Architecture Handbook updated (if architecture changed)
- [ ] ITOH updated (if operations changed)
- [ ] Test evidence generated (IQ/OQ)
- [ ] Traceability matrix current

**Deployment:**
- [ ] G3 gate passed (human QA approval via ServiceNow)
- [ ] QA environment validated
- [ ] G4 gate passed (human PROD approval via ServiceNow)
- [ ] Production deployment successful

---

## Success Metrics

### Sprint Health
- **Velocity** - Story points completed per sprint
- **Burndown** - Daily remaining work trending to zero
- **Quality** - Defects found, test coverage percentage
- **Governance** - Compliance violations, PDL completeness
- **PDL Tracking** - % PDL tasks complete at any point

### Agent Performance
- **BA** - Story refinement turnaround, PDL tasks (risk registry) completion
- **Dev** - Code quality, test coverage, TDD adherence, PDL tasks (architecture, ITOH)
- **QA** - Defect detection rate, test evidence creation, PDL tasks (OQ, traceability)
- **Governance** - Time to validate, PDL gate efficiency, assessment completion
- **Scrum Master** - Impediment resolution time, PDL tracking visibility

### Example Dashboard

```
Sprint 3 (Day 10/14):
├─ Committed: 40 points
├─ Completed: 32 points  
├─ Remaining: 8 points
├─ On track: ✅ Yes
├─ Velocity: 32 pts (consistent with Sprint 1: 30, Sprint 2: 34)
├─ Defects: 1 (minor)
├─ Test Coverage: 89%
├─ Governance: 0 violations
├─ PDL Completeness: 90% (9/10 tasks complete)
│  ├─ T001-T008: Complete ✅
│  ├─ T009: In Progress (Dev working)
│  └─ T010: Not Started (blocked on PO decision)
└─ Impediments: 1 (T010 blocked, escalated to PO)
```

---

## Getting Started

### Prerequisites

**Environment:**
- Python 3.9+ with virtual environment
- Snowflake account (DEV, TEST, PROD databases)
- Issue tracker (Beads, Jira, Linear, etc.)
- Git repository

**Knowledge:**
- Basic Python and SQL
- Data engineering concepts
- Scrum methodology
- Willingness to learn TDD

### Sprint 0: Bootstrap

Before your first sprint:

1. **Set up issue tracker**
   ```bash
   # Example with Beads
   bd init
   bd epic create "Establish ASOM Capability"
   ```

2. **Configure environments**
   - Snowflake: Create DEV, TEST, PROD databases
   - Python: Set up virtual environment with dependencies
   - Secrets: Configure secrets manager (AWS Secrets Manager, etc.)

3. **Define governance policies**
   - Data classification standards (Public, Internal, Sensitive, Restricted)
   - PII masking requirements (SHA256 for emails, redaction for phones)
   - Access control roles (DATA_ENGINEER, ANALYST, etc.)
   - Retention policies (Raw 30 days, Curated 2 years, Audit 7 years)

4. **Set up PDL tracking**
   - Define PDL categories for your organization
   - Create PDL task labels/tags in issue tracker
   - Establish PDL completeness gates (QA: 100%, PROD: 100%)
   - Document PDL-to-artefact mappings

5. **Load framework**
   - Clone this repository
   - Review ASOM.md for philosophy
   - Read QUICKSTART.md for first sprint
   - Familiarize with agent and skill files

### Sprint 1: First Pipeline

**Goal:** Build customer data pipeline with PII governance

See [QUICKSTART.md](QUICKSTART.md) for day-by-day walkthrough.

**Success Criteria:**
- ✅ Pipeline works end-to-end (API → Snowflake)
- ✅ PII properly masked (email, phone)
- ✅ All tests passing (≥80% coverage)
- ✅ IQ evidence exists (pytest results)
- ✅ OQ evidence created (business rule validation)
- ✅ All PDL tasks complete (100%)
- ✅ Governance certified for PROD
- ✅ Agent handoffs successful

**Expected Outcome:** Production-ready pipeline with complete audit trail and governance.

---

## Common Use Cases

### 1. Customer Data Pipeline (GDPR Compliance)

**Challenge:** Extract customer data from CRM, mask PII, enable analytics while maintaining GDPR compliance.

**ASOM Solution:**
- BA: Creates stories with PII requirements
- Dev: Implements SHA256 masking (deterministic for joins)
- QA: Validates no PII in curated layer
- Governance: DPIA, security assessment, PDL certification
- Result: Audit-ready, GDPR-compliant pipeline

### 2. Financial Reporting (SOX Compliance)

**Challenge:** Build financial data pipeline with complete audit trail for SOX compliance.

**ASOM Solution:**
- BA: Documents data lineage requirements
- Dev: Implements audit logging (who, what, when)
- QA: Validates audit trail completeness
- Governance: 7-year retention policy, PDL evidence
- Result: SOX-compliant reporting with audit trail

### 3. Healthcare Analytics (HIPAA Compliance)

**Challenge:** Process patient data while maintaining HIPAA privacy and security requirements.

**ASOM Solution:**
- BA: Identifies PHI fields requiring protection
- Dev: Implements encryption, access controls
- QA: Tests unauthorized access prevention
- Governance: Privacy impact assessment, security controls
- Result: HIPAA-compliant analytics platform

---

## Framework Evolution

### Version Management

Each project references a framework version:

```markdown
# In project README.md
ASOM Framework: v2.0.0
```

### Framework Updates

**Update process:**
1. Retrospective identifies improvements
2. Update framework repository (agents/, skills/)
3. Tag new version: `git tag -a v1.1.0 -m "Release v1.1.0"`
4. Projects adopt new version when ready

**Versioning:**
- Major (v2.0.0): Breaking changes to agent/skill contracts
- Minor (v1.1.0): New skills, enhanced agents
- Patch (v1.0.1): Bug fixes, clarifications

---

## Best Practices

### Do's ✅

- **Create PDL tasks at epic start** - Don't wait until end
- **Write tests first** - RED → GREEN → REFACTOR always
- **Distribute PDL work** - BA/Dev/QA handle their artefacts
- **Block deployment if PDL incomplete** - Governance enforces 100%
- **Keep feature branches short-lived** - 1-3 days maximum
- **Commit often with meaningful messages** - Conventional format
- **Review your own code first** - Before creating PR
- **Track PDL completeness daily** - Prevent surprises at gates

### Don'ts ❌

- **Don't write code before tests** - Breaks TDD discipline
- **Don't let Governance do all PDL** - Distribute to appropriate agents
- **Don't skip PDL to "go faster"** - Will block deployment anyway
- **Don't commit secrets** - Use environment variables
- **Don't update audit records** - Append-only, immutable
- **Don't expose PII in curated layer** - Always masked/redacted
- **Don't merge without tests passing** - Quality gate

---

## Troubleshooting

### "PDL tasks blocking sprint completion"

**Cause:** PDL tasks created too late or ignored during sprint

**Solution:**
- Create PDL tasks during epic creation (Day 1)
- Track PDL completeness daily
- Flag PDL tasks >24 hours old
- Governance escalates blockers early

### "Tests written after code"

**Cause:** Dev Agent not following TDD discipline

**Solution:**
- QA Agent checks commit history for TDD pattern
- Reject PR if tests not written first
- Reinforce TDD in retrospective
- Pair programming to learn TDD

### "Too many governance violations"

**Cause:** Governance requirements not in acceptance criteria

**Solution:**
- BA includes governance in every story
- Governance reviews stories before "ready"
- Create governance checklist template
- Automate governance tests

### "Slow agent handoffs"

**Cause:** Unclear handoff criteria or missing context

**Solution:**
- Review handoff protocols in retrospective
- Add handoff checklist to workflow states
- Improve story context and acceptance criteria
- Better agent-to-agent communication

---

## Contributing

Contributions to the ASOM framework are welcome!

**Areas for contribution:**
- New skills (additional tech stacks, patterns)
- Agent enhancements (better decision frameworks)
- Example projects (reference implementations)
- Documentation improvements
- Bug fixes and clarifications

**Process:**
1. Fork repository
2. Create feature branch: `feature/improve-qa-agent`
3. Make changes with tests (if applicable)
4. Submit PR with description
5. Address review feedback

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Resources

### Framework Documentation
- [ASOM.md](ASOM.md) - Core philosophy and principles
- [QUICKSTART.md](QUICKSTART.md) - Your first sprint walkthrough
- [PDL-REFERENCE.md](PDL-REFERENCE.md) - PDL workflow reference
- [ARCHITECTURE.md](ARCHITECTURE.md) - Design decisions

### Agent Definitions
- [BA-AGENT.md](agents/BA-AGENT.md) - Business Analyst role
- [DEV-AGENT.md](agents/DEV-AGENT.md) - Developer role (TDD)
- [QA-AGENT.md](agents/QA-AGENT.md) - QA Engineer role
- [GOVERNANCE-AGENT.md](agents/GOVERNANCE-AGENT.md) - Governance role
- [SCRUM-MASTER-AGENT.md](agents/SCRUM-MASTER-AGENT.md) - Scrum Master role

### Skills
- [testing-strategies.md](skills/testing-strategies.md) - TDD, unit, integration testing
- [data-quality-validation.md](skills/data-quality-validation.md) - DQ validation patterns
- [pdl-governance.md](skills/pdl-governance.md) - PDL workflow and tracking
- [data-privacy-controls.md](skills/data-privacy-controls.md) - PII protection techniques
- [audit-logging.md](skills/audit-logging.md) - Audit trail requirements

---

## Support

**Questions?** Open an issue in this repository.

**Discussions?** See GitHub Discussions for:
- Best practices
- Use case sharing
- Troubleshooting
- Feature requests

---

## Acknowledgments

ASOM was developed to enable agent-assisted, high-quality, compliant software development using AI agents while maintaining enterprise governance standards through enforced SDLC controls.

**Built with:**
- Anthropic Claude (AI agent orchestration)
- Scrum methodology
- Test-Driven Development principles
- Enterprise governance frameworks (GDPR, SOX, HIPAA)

---

**Remember:** Agents assist. Systems enforce. Humans approve.

**ASOM = Agent-Assisted Scrum + TDD + Enforced Controls + Evidence Ledger**

Build production-ready data pipelines with complete governance, audit trails, and confidence.
