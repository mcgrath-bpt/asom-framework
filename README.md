# ASOM: Agentic Scrum Operating Model

An operating model for building production-quality data engineering and data science solutions using specialized agent roles, Scrum methodology, and Test-Driven Development (TDD) as fundamental practice.

## Overview

**ASOM (Agentic Scrum Operating Model)** enables you to work as a complete Scrum team by embodying specialized agent roles, with TDD as the foundation for quality and governance.

The framework implements a complete Scrum team with specialized agent roles:
- **Business Analyst** - Requirements gathering and story refinement with test requirements
- **Developer** - Implementation using strict TDD methodology (RED → GREEN → REFACTOR)
- **QA** - Testing validation and quality assurance (including TDD process verification)
- **Governance** - Compliance, security, and documentation (tests prove controls work)
- **Scrum Master** - Process facilitation and coordination

All agents coordinate through Beads, a git-backed issue tracker designed specifically for AI agent collaboration.

## Core Principles

### 1. Test-Driven Development (Fundamental)
TDD is not optional in ASOM - it's the foundation:
- **RED**: Write failing test first (defines requirements)
- **GREEN**: Write minimum code to pass (implements requirements)
- **REFACTOR**: Improve code quality (maintains standards)

Every story includes test requirements. Every implementation starts with tests. Every validation proves tests work.

### 2. Agentic Role Separation
Work divided among specialized roles with clear responsibilities, decision frameworks, and handoff protocols.

### 3. Governance by Default
Compliance built into acceptance criteria, not bolted on after. Tests prove governance controls work.

### 4. Scrum Methodology
Standard Scrum practices: sprints, ceremonies, Definition of Done, Product Delivery Log (PDL).

## Quick Start

### 1. Set Up Beads
```bash
# Install Beads (git-backed issue tracker for agent coordination)
# Follow Beads installation instructions for your environment
bd init
```

### 2. Load Agent Definitions
Each agent operates according to its AGENT.md file:
- `agents/BA-AGENT.md` - Business Analyst
- `agents/DEV-AGENT.md` - Developer
- `agents/QA-AGENT.md` - QA Specialist
- `agents/GOVERNANCE-AGENT.md` - Governance & Compliance
- `agents/SCRUM-MASTER-AGENT.md` - Scrum Master

### 3. Load Shared Skills
All agents reference these shared capabilities:
- `skills/beads-coordination.md` - Work tracking and handoffs
- `skills/python-data-engineering.md` - Python best practices
- `skills/snowflake-development.md` - Snowflake DDL, DML, optimization
- `skills/governance-requirements.md` - Compliance and security

### 4. Start Your First Sprint

As Product Owner (you), create the initial epic:
```bash
bd epic create "Customer Data Pipeline with Full Governance"
```

The agents will then follow ASOM with TDD:
1. **Governance Agent** - Creates PDL template and defines compliance requirements
2. **BA Agent** - Breaks down epic into stories WITH TEST REQUIREMENTS in acceptance criteria
3. **Scrum Master** - Facilitates sprint planning and tracks progress
4. **Dev Agent** - Implements stories using TDD (RED → GREEN → REFACTOR)
5. **QA Agent** - Validates TDD process was followed and runs additional tests
6. **Governance Agent** - Certifies compliance (tests prove controls work) and completes PDL

## Framework Structure

```
sdd-agent-framework/
├── agents/                          # Agent role definitions
│   ├── BA-AGENT.md                 # Business Analyst agent
│   ├── DEV-AGENT.md                # Developer agent
│   ├── QA-AGENT.md                 # QA agent
│   ├── GOVERNANCE-AGENT.md         # Governance agent
│   └── SCRUM-MASTER-AGENT.md       # Scrum Master agent
│
├── skills/                          # Shared capabilities
│   ├── beads-coordination.md       # Work tracking
│   ├── python-data-engineering.md  # Python patterns
│   ├── snowflake-development.md    # Snowflake best practices
│   └── governance-requirements.md  # Compliance requirements
│
└── README.md                        # This file
```

## Agent Roles & Responsibilities

### Business Analyst
**Purpose**: Translate business needs into clear technical requirements

**Key Activities**:
- Analyze epics and create user stories
- Define acceptance criteria including governance requirements
- Document data sources and business rules
- Coordinate with Governance Agent on compliance needs

**Handoff**: BA → Dev (stories marked "ready")

### Developer
**Purpose**: Build production-quality data pipelines and transformations

**Key Activities**:
- Implement Python data extraction/transformation logic
- Create Snowflake schemas and SQL
- Write comprehensive tests (unit & integration)
- Implement governance controls (PII masking, audit logging)

**Handoff**: Dev → QA (PR created with tests)

### QA
**Purpose**: Ensure quality meets acceptance criteria and governance standards

**Key Activities**:
- Execute functional and data quality tests
- Validate governance controls actually work
- Perform code reviews
- Report defects with reproduction steps

**Handoff**: QA → Governance (all tests passing)

### Governance
**Purpose**: Ensure compliance, security, and audit-readiness

**Key Activities**:
- Define compliance requirements for sprint
- Validate PII protection mechanisms
- Verify access controls and audit trails
- Generate compliance documentation (PDL)

**Handoff**: Governance → Done (compliance certified)

### Scrum Master
**Purpose**: Facilitate process and remove impediments

**Key Activities**:
- Coordinate agent handoffs
- Track sprint progress and burndown
- Identify and resolve blockers
- Facilitate retrospectives and improvements

**Handoff**: Coordinates all other handoffs

## Workflow

### Typical Story Lifecycle

```
1. BA Agent: Creates story from epic
   ├─ Defines acceptance criteria
   ├─ Documents data sources
   └─ Status: "refined"

2. Governance Agent: Reviews for compliance
   ├─ Adds governance requirements
   ├─ Updates PDL
   └─ Status: "ready"

3. Dev Agent: Implements solution
   ├─ Writes Python extraction/transformation
   ├─ Creates Snowflake DDL
   ├─ Implements PII masking
   ├─ Writes tests (>80% coverage)
   └─ Status: "in-review" (PR created)

4. QA Agent: Validates implementation
   ├─ Reviews code quality
   ├─ Executes test plan
   ├─ Validates data quality
   ├─ Tests governance controls
   └─ Status: "testing" → "governance-review"

5. Governance Agent: Certifies compliance
   ├─ Validates PII masking works
   ├─ Verifies audit logging
   ├─ Checks access controls
   ├─ Collects evidence
   └─ Status: "done"
```

### Communication Pattern

All agents communicate through Beads comments with structured format:
```
[Agent Name] Action taken

Context/Reasoning:
- Why this approach
- Alternatives considered
- Dependencies

Progress:
- ✅ Completed
- 🚧 In progress
- ⏳ Pending

Next steps:
- Planned actions
- Needed from others
```

## Governance Framework

### PII Protection
- **Email**: SHA256 hash with salt → deterministic tokens
- **Phone**: Redaction → XXX-XXX-1234 format
- **SSN/NI**: Remove entirely or hash
- **Addresses**: City level only or remove

### Access Control (RBAC)
```
Raw Layer (PII)        → DATA_ENGINEER only
Curated Layer (masked) → ANALYST roles
Analytics Layer (agg)  → BUSINESS_USER
```

### Audit Requirements
- All curated tables: `_audit_user`, `_audit_timestamp`
- Access logs: 7 years retention
- Modification logs: 7 years retention

### Data Retention
- Raw (PII): 30 days (automated deletion)
- Curated: 2 years
- Analytics: 5 years
- Audit logs: 7 years minimum

## Technology Stack

### Python
- **polars** - High-performance DataFrames
- **pydantic** - Data validation
- **pytest** - Testing
- **snowflake-connector-python** - Snowflake integration

### Snowflake
- **Medallion Architecture** - Bronze → Silver → Gold
- **Streams & Tasks** - Near-real-time processing
- **Row-level security** - Fine-grained access control
- **Resource monitors** - Cost management

### Coordination
- **Beads** - Git-backed issue tracking for agents

## Sprint 0: Bootstrap

Before Sprint 1, you'll need to:

1. **Set up Beads workspace**
   ```bash
   bd init
   bd epic create "Establish SDD Capability"
   ```

2. **Configure environments**
   - Snowflake: DEV, TEST, PROD databases
   - Python: Virtual environment with dependencies
   - Secrets: AWS Secrets Manager / Azure Key Vault

3. **Define initial governance policies**
   - Data classification standards
   - PII masking requirements
   - Access control roles
   - Retention policies

4. **Create Product Delivery Log template**
   - Sprint governance checklist
   - Compliance evidence requirements

## Sprint 1: Prove the Model

**Goal**: Build a single data pipeline with full governance to prove the agent team works

**Example Epic**: "Customer Data Ingestion Pipeline with PII Governance"

**Expected Stories**:
- Extract customer data from REST API
- Implement PII masking (email, phone)
- Create Snowflake schema (bronze → silver → gold)
- Implement data quality checks
- Set up access controls
- Create audit logging
- Configure retention policies

**Success Criteria**:
- Pipeline works end-to-end ✅
- PII properly protected ✅
- Governance documentation complete ✅
- All agent handoffs successful ✅
- <50% manual intervention required

## Monitoring & Metrics

### Sprint Health
- **Velocity**: Story points completed per sprint
- **Burndown**: Daily remaining work tracking
- **Quality**: Defects found, test coverage
- **Governance**: Violations, compliance gaps

### Agent Performance
- **BA**: Story refinement turnaround
- **Dev**: Code quality, test coverage
- **QA**: Defect detection rate
- **Governance**: Time to validate compliance
- **Scrum Master**: Impediment resolution time

### Example Dashboard
```
Sprint 1 (Day 7/14):
├─ Committed: 40 points
├─ Completed: 24 points
├─ Remaining: 16 points
├─ On track: ✅ Yes
├─ Defects: 2 (minor)
├─ Governance: 0 violations
└─ Impediments: 1 (test data)
```

## Phased Autonomy

### Phase 1: Supervised (Weeks 1-4)
- Agents produce work but don't commit
- You review all artifacts
- Approve/reject with feedback
- Goal: Build trust and tune agents

### Phase 2: Conditional (Weeks 5-8)
- Low-risk: Automated (story updates, tests)
- Medium-risk: Approval needed (merges, schemas)
- High-risk: Supervised (compliance, security)
- Goal: Reduce manual intervention

### Phase 3: Full Autonomy (Week 9+)
- Agents operate independently
- Exception-based oversight
- Automated quality gates
- Goal: Minimal human intervention

## Troubleshooting

### Agents Not Coordinating
- Check Beads status transitions
- Review comment format in stories
- Verify agents following handoff protocol

### Quality Issues
- Review test coverage metrics
- Check if QA validating acceptance criteria
- Verify governance controls actually tested

### Governance Violations
- Escalate to Governance Agent immediately
- Document in issue tracker
- Update controls in skills/governance-requirements.md

### Sprint Goals Not Met
- Review retrospective for root causes
- Check impediment resolution times
- Adjust story sizing or capacity

## Extending the Framework

### Add New Agent Roles
Create `agents/NEW-ROLE-AGENT.md` following the pattern:
- Role Identity
- Core Responsibilities
- Working with Other Agents
- Skills & Capabilities
- Decision-Making Framework

### Add New Skills
Create `skills/new-skill.md` with:
- Frontmatter (name, description)
- Practical guidance and examples
- Best practices
- Common patterns

### Customize for Your Domain
- Update PII protection for your data types
- Add domain-specific data quality rules
- Customize governance for your regulations
- Add organization-specific patterns

## Best Practices

1. **Start Small**: Single pipeline first, scale after proving model
2. **Trust but Verify**: Phase autonomy gradually
3. **Clear Handoffs**: Explicit status transitions in Beads
4. **Document Decisions**: Use ADRs for significant choices
5. **Test Governance**: Verify controls actually work
6. **Iterate**: Retrospectives drive continuous improvement
7. **Measure**: Track velocity, quality, compliance metrics
8. **Automate**: Use Snowflake tasks for retention, testing
9. **Communicate**: Structured comments in Beads
10. **Maintain**: Update agent definitions based on learnings

## Support & Contribution

This framework is designed to evolve through use. Update agent definitions and skills based on retrospective findings and lessons learned.

## License

This framework is provided as-is for use in autonomous agent-based development projects.
