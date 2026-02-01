---
name: beads-coordination
description: Git-backed issue tracking for autonomous agent coordination. Use for creating epics/stories, tracking work, managing handoffs, and maintaining visibility across the autonomous Scrum team.
---

# Beads Coordination

Beads is a git-backed issue tracker designed for AI agent coordination. This skill covers how to use Beads (`bd` commands) for work tracking, agent handoffs, and maintaining transparency.

## Core Concepts

### Work Hierarchy
```
Epic (E001, E002, ...)
  ├── Story (S001, S002, ...)
  │   ├── Task (T001, T002, ...)
  │   └── Comments (timestamped notes)
  └── Story (S003, ...)
```

### Workflow States
- **backlog**: Not yet refined
- **refined**: Ready for sprint planning
- **ready**: Meets Definition of Ready, can be developed
- **in-progress**: Active development
- **in-review**: Code review / PR created
- **testing**: QA validation
- **governance-review**: Compliance validation
- **done**: Completed and approved

## Basic Commands

### Epics
```bash
# Create epic
bd epic create "Customer Data Platform"

# List epics
bd epic list

# View epic details
bd epic show E001

# Update epic
bd epic update E001 --status in-progress
```

### Stories
```bash
# Create story
bd story create --epic E001 "Ingest customer data from API"

# Assign to agent
bd story assign S001 --agent dev-agent

# Update status
bd story update S001 --status in-progress

# Add labels
bd story label S001 --add pii-handling,data-ingestion

# List stories
bd story list --status ready
bd story list --agent dev-agent
bd story list --epic E001
```

### Comments (Communication)
```bash
# Add comment
bd comment S001 "Started implementation of extraction logic"

# Add structured update
bd comment S001 "[Dev Agent] PR created: #123
- Implemented pagination for API
- Added retry logic for failures
- Test coverage: 85%"

# View comment history
bd story show S001
```

### Tasks (Decomposition)
```bash
# Create sub-task
bd task create --story S001 "Design Snowflake schema"
bd task create --story S001 "Implement extraction script"
bd task create --story S001 "Create unit tests"

# Update task
bd task update T001 --status done
```

## Agent Coordination Patterns

### BA → Dev Handoff
```bash
# BA Agent marks story ready
bd story update S001 --status ready
bd comment S001 "[BA Agent] Story refined and ready for development
- Acceptance criteria defined
- Data sources documented: Customer API
- Business rules: Filter for active customers only
- Governance requirements: Email PII masking required"

# Dev Agent picks up story
bd story assign S001 --agent dev-agent
bd story update S001 --status in-progress
bd comment S001 "[Dev Agent] Starting implementation"
```

### Dev → QA Handoff
```bash
# Dev Agent completes implementation
bd story update S001 --status in-review
bd comment S001 "[Dev Agent] PR created: #123
Implementation complete:
- Python extraction script with pagination
- Snowflake DDL with PII masking
- Unit tests (87% coverage)
- Documentation updated

Ready for QA review."

# QA Agent begins testing
bd story assign S001 --agent qa-agent --add
bd story update S001 --status testing
bd comment S001 "[QA Agent] Test execution started
Test plan: TP-S001
Test environment: DEV"
```

### QA → Governance Handoff
```bash
# QA Agent completes testing
bd comment S001 "[QA Agent] Testing complete
- All acceptance criteria met ✅
- Data quality tests passing ✅
- Functional tests passing ✅
- Test coverage: 87%
- Defects: None

Ready for governance validation."
bd story update S001 --status governance-review

# Governance Agent validates
bd story assign S001 --agent governance-agent --add
bd comment S001 "[Governance Agent] Governance validation in progress"
```

### Story Completion
```bash
# Governance Agent approves
bd comment S001 "[Governance Agent] Governance validation complete
- PII masking verified ✅
- Audit logging verified ✅
- Access controls verified ✅
- Compliance evidence collected
- PDL updated

APPROVED for deployment."
bd story update S001 --status done
```

## Impediment Tracking

```bash
# Create impediment
bd issue create --type impediment "Test environment unavailable"

# Assign owner
bd issue assign I001 --agent scrum-master

# Update progress
bd comment I001 "[Scrum Master] Escalated to infrastructure team
Expected resolution: EOD today"

# Resolve
bd issue update I001 --status resolved
bd comment I001 "[Scrum Master] Test environment restored
Root cause: Network configuration issue
Prevention: Monitoring added"
```

## Sprint Management

```bash
# Create sprint
bd sprint create "Sprint 1" --start 2024-01-15 --end 2024-01-29

# Add stories to sprint
bd sprint add S001 S002 S003 --sprint 1

# View sprint status
bd sprint show 1

# Generate sprint report
bd sprint report --sprint 1
```

## Transparency & Reasoning

### Structured Comments
Use consistent format for agent updates:
```
[Agent Name] Action taken

Context/Reasoning:
- Why this approach was chosen
- What alternatives were considered
- What dependencies exist

Progress:
- ✅ Completed items
- 🚧 In-progress items
- ⏳ Pending items

Next steps:
- What's planned next
- What's needed from others
```

### Example: Dev Agent Update
```bash
bd comment S001 "[Dev Agent] Implementation progress update

Design decisions:
- Using polars instead of pandas for 10x performance on large datasets
- Implementing incremental load pattern to reduce API calls
- Snowflake table clustering on (load_date, customer_id) for query performance

Progress:
- ✅ API extraction logic complete
- ✅ Snowflake DDL created
- 🚧 PII masking implementation 80% complete
- ⏳ Unit tests pending

Blockers:
- Need test API credentials from BA Agent

Next: Complete PII masking, create tests, generate PR"
```

## Query and Reporting

```bash
# Find all stories assigned to you
bd story list --agent dev-agent --status in-progress

# Find blocked stories
bd story list --label blocked

# Find stories needing governance review
bd story list --status governance-review

# Export data for dashboards
bd export --format json --output sprint-data.json

# Get metrics
bd metrics --sprint 1
```

## Best Practices

### Clear Ownership
- Always assign stories to specific agents
- Use `--add` flag when multiple agents work on same story
- Clear handoffs: "Ready for [next agent]" in comments

### Detailed Reasoning
- Document WHY decisions were made, not just WHAT
- Include alternatives considered
- Explain tradeoffs
- Link to relevant documentation

### Timely Updates
- Update status when state changes
- Comment on progress daily
- Flag blockers immediately
- Communicate handoffs explicitly

### Structured Information
- Use labels for categorisation
- Use consistent comment formats
- Link related work items
- Reference PRs, docs, evidence

### Audit Trail
- Every significant decision documented
- All handoffs explicitly logged
- Impediments tracked to resolution
- Evidence of governance validation

## Common Workflows

### Starting a Story
```bash
bd story assign S001 --agent dev-agent
bd story update S001 --status in-progress
bd comment S001 "[Dev Agent] Starting implementation
Story: Customer data ingestion
Estimated effort: 3 days
Approach: Incremental load via API pagination"
```

### Blocking on Another Agent
```bash
bd comment S001 "[Dev Agent] Blocked waiting for test data
Need sample customer records from QA Agent to complete testing
Estimated impact: 4 hours delay"
bd story label S001 --add blocked
bd story update S001 --status blocked
```

### Requesting Clarification
```bash
bd comment S001 "[Dev Agent] Question for BA Agent
The story says 'filter active customers' but doesn't define 'active'.
Options:
1. Customers with orders in last 90 days
2. Customers with account status = 'ACTIVE'
3. Something else?

Please clarify in next comment."
```

### Closing with Evidence
```bash
bd comment S001 "[Governance Agent] Story complete with evidence
- Test results: /docs/tests/S001-test-results.md
- PII validation: /docs/compliance/S001-pii-validation.md
- Access control verification: /docs/compliance/S001-rbac.md
- PDL updated: Section 3.2

All acceptance criteria met. APPROVED."
bd story update S001 --status done
```

## Integration with Git

Beads uses git as storage backend, providing:
- Full version history of all work items
- Merge capabilities for distributed teams
- Branching for parallel work
- Audit trail via git log

Link Beads stories to git commits:
```bash
git commit -m "feat(extract): implement customer API pagination

Implemented pagination to handle >10k customer records.
Added retry logic for transient API failures.

Closes: S001"
```

## Metrics and Visibility

Track team performance:
```bash
# Sprint velocity
bd metrics velocity --sprint 1

# Cycle time (story creation → done)
bd metrics cycle-time --sprint 1

# Lead time (backlog → done)
bd metrics lead-time --sprint 1

# Defect density
bd metrics defects --sprint 1
```

Generate reports:
```bash
# Sprint summary
bd sprint report --sprint 1 --output sprint-1-report.md

# Burndown chart data
bd burndown --sprint 1 --output burndown.csv
```