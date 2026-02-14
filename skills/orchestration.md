# Orchestration — Role Selection, Workflows & Handoffs

> **Load on demand** when orchestrating multi-agent workflows, resolving role selection, or performing agent handoffs. Not needed for single-agent deep work.

---

## Role Selection Logic

### Explicit Role Assignment
When the user explicitly mentions a role, assume that role immediately:

| User Says | Action |
|-----------|--------|
| "As the BA..." | Load `agents/BA-AGENT.md` and relevant skills |
| "Dev agent, implement..." | Load `agents/DEV-AGENT.md` and technical skills |
| "QA, validate this..." | Load `agents/QA-AGENT.md` and testing skills |
| "Governance agent, review..." | Load `agents/GOVERNANCE-AGENT.md` and compliance skills |
| "Scrum master, show status..." | Load `agents/SCRUM-MASTER-AGENT.md` |

### Context-Based Role Detection
When the role is implicit, infer from the task type:

| Request Pattern | Agent Role | Reasoning |
|----------------|------------|-----------|
| "Here are some ideas for the sprint..." | BA | Backlog triage and discovery is BA starting point |
| "Create stories/epics for..." | BA | Story creation is BA responsibility |
| "Refine this requirement..." | BA | Requirements analysis is BA work |
| "Let's groom the backlog..." | BA + Team | BA leads, Dev/QA/Governance challenge |
| "What data sources do we need..." | BA | Data source identification is BA work |
| "Implement this feature/story..." | Dev | Implementation is Dev responsibility |
| "Write the code for..." | Dev | Coding is Dev work |
| "Create Snowflake schema..." | Dev | DDL creation is Dev work |
| "Test this code/feature..." | QA | Testing is QA responsibility |
| "Review this PR..." | QA | Code review is QA work |
| "Validate data quality..." | QA | Quality validation is QA work |
| "Check for PII exposure..." | Governance | PII protection is Governance work |
| "Verify compliance..." | Governance | Compliance verification is Governance work |
| "Create/update the PDL..." | Governance | PDL is Governance responsibility |
| "What's our sprint status..." | Scrum Master | Progress tracking is SM work |
| "Show me the burndown..." | Scrum Master | Metrics reporting is SM work |
| "We're blocked on..." | Scrum Master | Impediment management is SM work |
| "We need an emergency override..." | Governance + SM | Override assessment is Governance, tracking is SM |
| "This is urgent, can we skip..." | Governance | Override eligibility assessment is Governance work |

---

## Continuous Workflows (Between and During Sprints)

These run independently of the sprint cadence. The BA and PO work the backlog continuously.

**Pattern: "Backlog refinement"** (Continuous — BA + PO)
- **PO (human)** → Seeds backlog with ideas, priorities, rough requirements (anytime)
- **BA** → Triages backlog items: asks PO clarifying questions, surfaces assumptions, drafts/refines stories incrementally
- **BA** → Involves Dev/QA/Governance for specific questions as needed (not full team sessions)
- **BA** → Captures all PO decisions and refinement revisions as bead comments
- Stories progress from rough ideas → drafted → refined → ready (DoR met)

**Pattern: "Groom the backlog" / "Let's do grooming"** (Scheduled session)
1. **BA** → Presents refined stories to team for challenge
2. **Dev** → Reviews for feasibility, sizing, technical approach, missing edge cases
3. **QA** → Reviews for testability (vague ACs get rejected), test data needs
4. **Governance** → Reviews for control coverage, missing governance ACs, PDL implications
5. **BA** → Incorporates feedback, captures decisions as bead comments on each story
6. Stories that pass team challenge → marked `workflow:refined`. Others go back to backlog.

---

## Multi-Agent Workflows (Sprint-Bound)

These execute within a sprint. They consume stories that are already refined.

**Pattern: "Build/Create [feature/pipeline]"** (Complete workflow)
1. **Governance** → Control applicability assessment (C-01 through C-11) + PDL Impact Assessment → evidence plan + PDL tracking tasks (T001-T00N)
2. **Scrum Master** → Confirm refined stories available, validate DoR, confirm sprint commitment
3. **Dev** → Implement each story on feature branch (TDD). Evidence entries created by CI. Complete assigned PDL tasks (architecture, ITOH). Push branch, prepare PR.
4. **→ Gate G1:** Human merges PR (linked story, passing tests, TDD history visible)
5. **QA** → Coordinate validation, publish QA execution report. Complete assigned PDL tasks (OQ evidence, traceability).
6. **Governance** → Verify evidence completeness + PDL completeness, surface gaps for human review
7. **Scrum Master** → Track progress and update metrics (including PDL completion %)
8. **→ Gate G3:** Human approval required for QA promotion (or C-11 emergency override with deferred evidence). PDL must be 100% complete.
9. **→ Gate G4:** Human approval required for PROD promotion (or C-11 emergency override with deferred evidence). PDL re-validated.

Note: If stories are not yet refined when this pattern is invoked, the BA discovery and grooming patterns run first. See "Backlog refinement" and "Groom the backlog" above.

**MANDATORY:** Governance kickoff (control applicability + PDL Impact Assessment) must complete BEFORE BA discovery begins. Skipping this is a process violation.

**Pattern: "Implement [story]"** (Development workflow — story must have passed DoR)
1. **Dev** → Create feature branch (`feature/<story-id>-description`). Implement with TDD. Push branch. Prepare PR. Complete any assigned PDL tasks (architecture, ITOH).
2. **→ Gate G1:** Human merges PR (linked story, passing tests, TDD history visible)
3. **QA** → Coordinate validation against acceptance criteria. Complete any assigned PDL tasks (OQ evidence, traceability).
4. **Governance** → Verify evidence + PDL completeness, publish verification report
5. **Scrum Master** → Update story status (including PDL task status)
6. **→ Human action:** Release Approver reviews for promotion

**Pattern: "Start sprint"** (Sprint planning — stories should already be refined)
1. **Scrum Master** → Acknowledge sprint goal, create run-log bead (`--type chore`, `run-log,sprint:N` labels)
2. **Governance** → Unified kickoff: control applicability + PDL Impact Assessment → evidence plan + PDL tasks
3. **Scrum Master** → Select from refined stories, validate DoR (including PDL task coverage), confirm sprint commitment, create sprint plan

Note: If the backlog is empty or stories are unrefined, the BA discovery and grooming patterns run before planning can complete. The SM should flag this as a readiness gap.

**Pattern: "Close sprint"** (Sprint closure workflow)
1. **Scrum Master** → Confirm all stories complete, all PDL tasks closed
2. **Governance** → Final evidence verification + PDL completeness check
3. **→ Gate G3:** Human Release Approver approves via CRQ → gate task closed
4. **Scrum Master** → Close stories (with reason), close epic (with reason)
5. **Scrum Master** → Close run-log with final summary
6. **Scrum Master** → Create retrospective bead, facilitate retrospective
7. **All agents** → Contribute retro observations (what went well, what to improve)
8. **Scrum Master** → Raise action items: sprint-level (for Sprint N+1) and framework-level (for framework backlog)

---

## Agent Coordination Protocol

### Handoff Pattern
When completing work as one agent and handing to another:

```
[Current Agent] Work complete

Summary: [What was accomplished]
Evidence: [What evidence was produced / what CI will produce]
Gate: [Which gate is being approached, if applicable]

Handoff to: [Next Agent Role]
Status: [Story status in Beads]
Next steps: [What the next agent should do]
```

Handoff chain: BA → Dev → QA → Governance → Human. See `skills/workflow-examples.md` for full handoff examples.

### Operating Modes

**Mode 1: Single Agent Deep Work** — User explicitly requests one agent. Load that agent's file + skills. Maintain role until user switches.

**Mode 2: Multi-Agent Workflow** — Complex task requiring multiple agents. Orchestrate automatically with gate checkpoints. Follow the workflow patterns above.

**Mode 3: Meta-Coordination** — Status, planning, or cross-cutting concerns. Default to Scrum Master.
