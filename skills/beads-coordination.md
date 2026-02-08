---
name: beads-coordination
description: Git-backed issue tracking for agent-assisted coordination. Use for creating epics/stories, tracking work, managing handoffs, and maintaining visibility across the agent-assisted Scrum team.
---

# Beads Coordination (bd v0.49.0)

Beads is a git-backed issue tracker designed for AI agent coordination. This skill covers how to use Beads (`bd` commands) for work tracking, agent handoffs, and maintaining transparency.

> **Note:** Beads auto-generates issue IDs with the repo prefix (e.g., `asom-data-template-4lg`). You don't control issue IDs -- the tool assigns them. Use `--silent` to capture just the ID in scripts.

## Core Concepts

### Work Hierarchy

Beads uses `--type` and `--parent` to create hierarchy:

```
Epic (--type epic)
  |-- Story (--type feature, --parent <epic-id>)
  |   |-- Task (--type task, --parent <story-id>)
  |   +-- Comments (bd comments add <id> "...")
  +-- Story (--type feature, --parent <epic-id>)
```

### Issue Types

| Type | Use For | ASOM Mapping |
|------|---------|-------------|
| `epic` | Large body of work | Sprint epic, pipeline |
| `feature` | User story / deliverable | Story (S001, S002, ...) |
| `task` | Sub-work item | Task, PDL task (T001, T002, ...) |
| `bug` | Defect | Bug, impediment |
| `chore` | Maintenance, non-functional | Housekeeping, refactoring |
| `gate` | Async wait condition | G1-G4 promotion gates |

### Workflow States (via --status)

Beads uses these built-in statuses:
- **open**: Created, not yet started (maps to backlog/refined/ready)
- **in_progress**: Active work
- **blocked**: Waiting on dependency
- **deferred**: Deferred for later
- **closed**: Completed

For ASOM-specific workflow granularity, use labels alongside status:
- `workflow:refined` -- Story refined, ready for sprint
- `workflow:in-review` -- PR created, code review
- `workflow:testing` -- QA validation
- `workflow:governance-review` -- Compliance validation

## Basic Commands

### Creating Issues

```bash
# Create an epic
bd create "Customer Data Platform" --type epic

# Create a story (feature) under an epic
bd create "Ingest customer data from API" --type feature --parent <epic-id>

# Create a task under a story
bd create "Design Snowflake schema" --type task --parent <story-id>

# Create with assignment, labels, priority
bd create "Extract CUR data" --type feature \
  --parent <epic-id> \
  --assignee dev-agent \
  --labels "sprint:1,pii-handling" \
  --priority 1

# Create with acceptance criteria
bd create "PII masking for email" --type feature \
  --parent <epic-id> \
  --acceptance "Email addresses masked with SHA-256. Phone numbers redacted."

# Quick capture (returns just the ID)
bd q "Quick bug: null handling in phone masker"
```

### Viewing Issues

```bash
# Show issue details
bd show <issue-id>

# List all open issues
bd list

# List all issues including closed
bd list --all

# List by type
bd list --type epic
bd list --type feature
bd list --type task

# List by status
bd list --status in_progress
bd list --status blocked

# List by assignee
bd list --assignee dev-agent

# List by label
bd list --label "sprint:1"
bd list --label-any "workflow:testing,workflow:governance-review"

# List children of an epic/story
bd children <epic-id>
bd children <epic-id> --pretty

# Tree view
bd list --pretty
bd list --tree

# Show epic completion status
bd epic status <epic-id>
```

### Updating Issues

```bash
# Update status
bd update <issue-id> --status in_progress
bd update <issue-id> --status closed

# Claim an issue (assigns to you + sets in_progress atomically)
bd update <issue-id> --claim

# Update assignee
bd update <issue-id> --assignee qa-agent

# Add labels
bd update <issue-id> --add-label "workflow:in-review"

# Remove labels
bd update <issue-id> --remove-label "workflow:in-review"

# Replace all labels
bd update <issue-id> --set-labels "sprint:1,workflow:testing"

# Update priority
bd update <issue-id> --priority 0

# Update title
bd update <issue-id> --title "Revised: Extract CUR data with pagination"

# Update description
bd update <issue-id> --description "Load AWS CUR Parquet files from S3"
```

### Comments

```bash
# Add a comment
bd comments add <issue-id> "Started implementation of extraction logic"

# Add a structured agent comment
bd comments add <issue-id> "[Dev Agent] PR created: #123
- Implemented pagination for API
- Added retry logic for failures
- Test coverage: 85%"

# View comments on an issue
bd comments <issue-id>

# Add from file
bd comments add <issue-id> -f notes.txt
```

### Closing Issues

```bash
# Close an issue
bd close <issue-id>

# Close with reason
bd close <issue-id> --reason "All acceptance criteria met"

# Close and see what's unblocked
bd close <issue-id> --suggest-next
```

## Dependencies

```bash
# Add dependency: story-B depends on story-A (A blocks B)
bd dep <story-a-id> --blocks <story-b-id>

# Or equivalently
bd dep add <story-b-id> <story-a-id>

# Create a relates-to link (bidirectional, non-blocking)
bd dep relate <issue-a> <issue-b>

# View dependencies of an issue
bd dep list <issue-id>

# Show dependency tree
bd dep tree <issue-id>

# Check for cycles
bd dep cycles

# Show blocked issues
bd blocked
```

## Gates (ASOM G1-G4)

Beads has native gate support for async coordination:

```bash
# Create a gate (e.g., G1 PR merge gate)
bd create "G1: PR merge gate for S001" --type gate

# List open gates
bd gate list

# Resolve a gate (human approval step)
bd gate resolve <gate-id>

# Show gate details
bd gate show <gate-id>
```

**ASOM gate mapping:**
- **G1 (PR merge)**: Create gate bead, resolve when PR merges with passing CI
- **G3 (QA promotion)**: Create gate bead, resolve when human Release Approver signs off
- **G4 (PROD promotion)**: Create gate bead, resolve when human Release Approver signs off

## Labels for ASOM Workflow

Use labels to track ASOM-specific dimensions beyond basic status:

```bash
# Workflow stage
bd label add <id> "workflow:refined"
bd label add <id> "workflow:in-review"
bd label add <id> "workflow:testing"
bd label add <id> "workflow:governance-review"

# Sprint assignment
bd label add <id> "sprint:1"

# Governance controls
bd label add <id> "control:C-04"
bd label add <id> "control:C-06"

# Test taxonomy
bd label add <id> "test:T1"
bd label add <id> "test:T4"

# Agent assignment tracking
bd label add <id> "agent:dev"
bd label add <id> "agent:qa"
bd label add <id> "agent:governance"

# PDL tracking
bd label add <id> "pdl:architecture"
bd label add <id> "pdl:itoh"

# View all labels in use
bd label list-all

# List labels on a specific issue
bd label list <issue-id>
```

## Operational State (set-state)

For more complex state tracking (e.g., agent or patrol state), use `set-state`:

```bash
# Set operational state (creates event + updates label atomically)
bd set-state <issue-id> workflow=testing --reason "QA validation started"
bd set-state <issue-id> workflow=governance-review --reason "Evidence verification"

# Query current state value
bd state <issue-id> workflow
```

## Agent Coordination Patterns

### BA --> Dev Handoff

```bash
# BA Agent refines story and marks ready
bd update <story-id> --add-label "workflow:refined"
bd comments add <story-id> "[BA Agent] Story refined and ready for development
- Acceptance criteria defined
- Data sources documented: Customer API
- Business rules: Filter for active customers only
- Governance requirements: Email PII masking required"

# Dev Agent claims story
bd update <story-id> --claim
bd update <story-id> --remove-label "workflow:refined"
bd comments add <story-id> "[Dev Agent] Starting implementation"
```

### Dev --> QA Handoff

```bash
# Dev Agent completes implementation
bd update <story-id> --add-label "workflow:in-review"
bd comments add <story-id> "[Dev Agent] PR created: #123
Implementation complete:
- Python extraction script with pagination
- Snowflake DDL with PII masking
- Unit tests (87% coverage)
- Documentation updated

Ready for QA review."

# QA Agent picks up
bd update <story-id> --remove-label "workflow:in-review" --add-label "workflow:testing"
bd comments add <story-id> "[QA Agent] Test execution started
Test plan: TP-S001
Test environment: DEV"
```

### QA --> Governance Handoff

```bash
# QA Agent completes testing
bd comments add <story-id> "[QA Agent] Testing complete
- All acceptance criteria met
- Data quality tests passing
- Functional tests passing
- Test coverage: 87%
- Defects: None

Ready for governance validation."
bd update <story-id> --remove-label "workflow:testing" --add-label "workflow:governance-review"

# Governance Agent validates
bd comments add <story-id> "[Governance Agent] Governance validation in progress"
```

### Story Completion

```bash
# Governance Agent publishes verification report
bd comments add <story-id> "[Governance Agent] Governance verification complete
- PII masking verified (C-04)
- Access controls verified (C-05)
- Data quality evidence verified (C-06)
- Traceability verified (C-03)
- PDL completeness: 100%

VERIFICATION STATUS: Complete
Human approval required for promotion."
bd update <story-id> --remove-label "workflow:governance-review"

# After human approval
bd close <story-id> --reason "All controls verified. Human approval received."
```

## Impediment Tracking

```bash
# Create impediment as a bug
bd create "Test environment unavailable" --type bug --priority 0

# Track progress via comments
bd comments add <issue-id> "[Scrum Master] Escalated to infrastructure team
Expected resolution: EOD today"

# Resolve
bd close <issue-id> --reason "Test environment restored. Root cause: network config."
```

## Sprint Management via Labels

Beads doesn't have native sprint commands. Use labels and list filters:

```bash
# Tag stories for a sprint
bd label add <story-1> "sprint:1"
bd label add <story-2> "sprint:1"
bd label add <story-3> "sprint:1"

# View sprint backlog
bd list --label "sprint:1"

# View sprint in-progress
bd list --label "sprint:1" --status in_progress

# View sprint completed
bd list --label "sprint:1" --status closed

# Sprint summary counts
bd count --label "sprint:1"
bd count --label "sprint:1" --status closed
bd count --label "sprint:1" --status in_progress

# Show ready work (no blockers)
bd ready
```

## Transparency and Reasoning

### Structured Comments

Use consistent format for agent updates:

```
[Agent Name] Action taken

Context/Reasoning:
- Why this approach was chosen
- What alternatives were considered
- What dependencies exist

Progress:
- Completed items
- In-progress items
- Pending items

Next steps:
- What's planned next
- What's needed from others
```

### Example: Dev Agent Update

```bash
bd comments add <story-id> "[Dev Agent] Implementation progress update

Design decisions:
- Using polars instead of pandas for 10x performance on large datasets
- Implementing incremental load pattern to reduce API calls
- Snowflake table clustering on (load_date, customer_id) for query performance

Progress:
- API extraction logic complete
- Snowflake DDL created
- PII masking implementation 80% complete
- Unit tests pending

Blockers:
- Need test API credentials from BA Agent

Next: Complete PII masking, create tests, generate PR"
```

## Query and Reporting

```bash
# Find assigned issues
bd list --assignee dev-agent --status in_progress

# Find blocked issues
bd blocked

# Find issues needing governance review
bd list --label "workflow:governance-review"

# Find issues by label (AND -- must match all)
bd list --label "sprint:1,control:C-04"

# Find issues by label (OR -- match any)
bd list --label-any "workflow:testing,workflow:governance-review"

# Count issues
bd count --label "sprint:1" --status closed

# Show stale issues
bd stale

# Show overdue issues
bd list --overdue

# Show ready work (open, no blockers, not deferred)
bd ready

# Export for external dashboards
bd export --format jsonl

# Show overall database status
bd status
```

## Best Practices

### Clear Ownership
- Always assign stories with `--assignee`
- Use labels (`agent:dev`, `agent:qa`) for additional visibility
- Clear handoffs: "Ready for [next agent]" in comments

### Detailed Reasoning
- Document WHY decisions were made, not just WHAT
- Include alternatives considered
- Explain tradeoffs
- Link to relevant documentation

### Timely Updates
- Update status when state changes
- Comment on progress at each workflow transition
- Flag blockers immediately with `--status blocked`
- Communicate handoffs explicitly

### Structured Information
- Use `sprint:N` labels for sprint assignment
- Use `workflow:*` labels for ASOM state granularity
- Use `control:C-*` labels to trace governance controls
- Use `test:T*` labels to trace test taxonomy
- Reference PRs, docs, evidence in comments

### Audit Trail
- Every significant decision documented in comments
- All handoffs explicitly logged
- Impediments tracked to resolution
- Evidence of governance validation in comments
- Gate beads for promotion checkpoints

## Integration with Git

Beads uses git as storage backend, providing:
- Full version history of all work items via `.beads/` directory
- JSONL export for mergeability across branches
- Audit trail via git log

Install git hooks for auto-sync:
```bash
bd hooks install
```

Link Beads issues to git commits:
```bash
git commit -m "feat(extract): implement customer API pagination

Implemented pagination to handle >10k customer records.
Added retry logic for transient API failures.

Refs: <issue-id>"
```

## Common Workflows

### Starting a Story
```bash
bd update <story-id> --claim
bd comments add <story-id> "[Dev Agent] Starting implementation
Story: Customer data ingestion
Estimated effort: 3 days
Approach: Incremental load via API pagination"
```

### Blocking on Another Agent
```bash
bd comments add <story-id> "[Dev Agent] Blocked waiting for test data
Need sample customer records from QA Agent to complete testing
Estimated impact: 4 hours delay"
bd update <story-id> --status blocked
```

### Requesting Clarification
```bash
bd comments add <story-id> "[Dev Agent] Question for BA Agent
The story says 'filter active customers' but doesn't define 'active'.
Options:
1. Customers with orders in last 90 days
2. Customers with account status = 'ACTIVE'
3. Something else?

Please clarify in next comment."
```

### Closing with Evidence
```bash
bd comments add <story-id> "[Governance Agent] Story verification complete
- Evidence ledger: C-03, C-04, C-05, C-06, C-07 all satisfied
- PDL: 100% complete (Architecture, ITOH, OQ evidence all present)
- Test results: All T1-T8 categories passing

VERIFICATION STATUS: Complete
Human approval required for promotion."

# After human approval
bd close <story-id> --reason "All controls verified. Approved by Release Approver."
```
