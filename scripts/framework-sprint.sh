#!/bin/bash
# ============================================================================
# framework-sprint.sh — Orchestrate framework hardening tasks via Claude CLI
# ============================================================================
#
# Usage:
#   bash scripts/framework-sprint.sh           # Run all sessions sequentially
#   bash scripts/framework-sprint.sh FW-009    # Run a single session
#   bash scripts/framework-sprint.sh --dry-run # Show prompts without running
#
# Each session:
#   - Starts a fresh Claude context (no baggage)
#   - Reads CLAUDE.md automatically (project instructions)
#   - Works autonomously with file edit permissions
#   - Commits its changes to git
#   - Updates the bead when done
#   - Logs output to logs/<task-id>.log
#
# Prerequisites:
#   - claude CLI installed and authenticated
#   - bd CLI installed (beads issue tracker)
#   - Working directory: agentic-SCRUM repo root
# ============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="${REPO_ROOT}/logs"
BUDGET_PER_SESSION=5  # USD cap per session

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# ---- Session Definitions ---------------------------------------------------

fw009_prompt() {
cat <<'PROMPT'
You are the Dev agent working on the agentic-SCRUM framework repo.

TASK: FW-009 — Slim CLAUDE.md to under 12K chars.

Read bead agentic-SCRUM-aab for full context.

Instructions:
1. Read the current CLAUDE.md (currently ~22K chars).
2. Identify content that can move to a new file skills/orchestration.md:
   - The detailed "Multi-Agent Workflows" section (workflow patterns)
   - The detailed "Role Selection Logic" tables (context-based detection, continuous workflows)
   - The "Workflow Orchestration" section
   - The "Agent Coordination Protocol" handoff patterns
3. Create skills/orchestration.md with the extracted content, adding a header explaining this is loaded on demand for workflow orchestration.
4. Replace the moved sections in CLAUDE.md with brief summaries (2-3 lines each) that reference skills/orchestration.md.
5. Update the skill catalogue table in CLAUDE.md to include orchestration.md.
6. Verify CLAUDE.md is under 12K chars: run "wc -c CLAUDE.md".
7. Also apply AI-006: add a line to the BA role selection or self-awareness rules clarifying the BA must NOT include technical implementation details (file paths, column names, SQL patterns) in stories — describe WHAT not HOW.

IMPORTANT:
- Do NOT change any control references, gate definitions, or authority boundary rules.
- Do NOT remove the Summary section, Quality Checks, Error Handling, or Decision Framework.
- Keep the skill catalogue table and context management loading strategy intact (just add the new entry).
- Preserve all existing semantics — this is a refactor, not a rewrite.

When done:
- Run "wc -c CLAUDE.md" and "wc -c skills/orchestration.md" to confirm sizes.
- Commit with message: "FW-009: Slim CLAUDE.md, extract workflows to skills/orchestration.md"
- Run: bd comments add agentic-SCRUM-aab "Done. CLAUDE.md now <X> chars (was 22,664). Extracted to skills/orchestration.md (<Y> chars)."
- Run: bd close agentic-SCRUM-aab --reason "CLAUDE.md slimmed to <X> chars. Orchestration skill created."
PROMPT
}

fw010_prompt() {
cat <<'PROMPT'
You are the Dev agent working on the agentic-SCRUM framework repo.

TASK: FW-010 — Split GOVERNANCE-AGENT.md into core + reference appendix.

Read bead agentic-SCRUM-a43 for full context.

Instructions:
1. Read agents/GOVERNANCE-AGENT.md (currently ~34K chars).
2. Identify the core role definition vs reference material:
   - CORE (keep in GOVERNANCE-AGENT.md): role purpose, authority boundaries, primary responsibilities, key workflows, handoff patterns, skill loading triggers.
   - APPENDIX (move to skills/governance-reference.md): detailed control mapping tables, evidence templates, detailed verification checklists, example reports, extended PDL patterns.
3. Create skills/governance-reference.md with the extracted reference content. Add a header: "Loaded on demand when Governance Agent needs detailed control mappings, evidence templates, or verification checklists."
4. In GOVERNANCE-AGENT.md, replace moved sections with brief pointers: "For detailed [X], load skills/governance-reference.md."
5. Target: GOVERNANCE-AGENT.md under 18K chars. governance-reference.md gets the rest.
6. Update the skill catalogue in CLAUDE.md to include governance-reference.md with trigger "Deep governance verification, evidence templates".

When done:
- Run "wc -c agents/GOVERNANCE-AGENT.md" and "wc -c skills/governance-reference.md" to confirm sizes.
- Commit with message: "FW-010: Split GOVERNANCE-AGENT.md into core + governance-reference.md"
- Run: bd comments add agentic-SCRUM-a43 "Done. GOVERNANCE-AGENT.md now <X> chars (was 34,352). Reference appendix: <Y> chars."
- Run: bd close agentic-SCRUM-a43 --reason "Agent file split. Core <X> chars, reference <Y> chars."
PROMPT
}

fw011_prompt() {
cat <<'PROMPT'
You are the Dev agent working on the agentic-SCRUM framework repo.

TASK: FW-011 — Cache common bd CLI patterns to reduce beads-coordination.md reloads.

Read bead agentic-SCRUM-jko for full context.

Also address:
- AI-003: Run-log must be created as the literal first action of a sprint.
- AI-005: Enforce bd --claim and comment logging during implementation.

Instructions:
1. Read skills/beads-coordination.md to identify the 5 most common bd operations.
2. Add a "Beads Quick Reference" section to CLAUDE.md (keep it under 500 chars) with the essential commands:
   - bd create --title "..." --type story|task|chore --priority p1|p2|p3 --label x
   - bd close <id> --reason "..."
   - bd comments add <id> "text"
   - bd list
   - bd show <id>
   - bd claim <id>
3. In the quick reference, add a note: "For advanced bead workflows (epics, run-logs, sprint lifecycle), load skills/beads-coordination.md."
4. Verify CLAUDE.md is still under 12K chars after adding this section (if FW-009 has already run). If not, trim further.
5. For AI-003: In CLAUDE.md under the "Start sprint" pattern (or its summary if FW-009 extracted it), add explicit text: "FIRST ACTION: SM creates run-log bead before any other sprint activity."
6. For AI-005: Verify agents/DEV-AGENT.md already has the --claim enforcement (it was updated in Sprint 2). If present, just confirm. If not, add it.

When done:
- Commit with message: "FW-011: Inline bd quick reference, enforce AI-003 run-log, verify AI-005"
- Run: bd comments add agentic-SCRUM-jko "Done. bd quick reference added to CLAUDE.md. AI-003 and AI-005 enforcement verified."
- Run: bd close agentic-SCRUM-jko --reason "Common bd patterns cached in CLAUDE.md."
PROMPT
}

fw012_prompt() {
cat <<'PROMPT'
You are the Dev agent working on the agentic-SCRUM framework repo.

TASK: FW-012 — Add context budget metrics to sprint retrospective template.

Read bead agentic-SCRUM-0vs for full context.

Instructions:
1. Read agents/SCRUM-MASTER-AGENT.md.
2. Find the retrospective template or checklist section.
3. Add a "Context Budget Review" subsection to the retro template with these data points:
   - Skills loaded and frequency (which skills, how many times each)
   - Total framework context consumed (chars or estimated tokens)
   - Comparison to previous sprint (better/worse/same)
   - Top 3 context consumers (identify optimisation targets)
4. Keep the addition concise — under 300 chars of template text.
5. Also address FW-008: In CLAUDE.md (or skills/orchestration.md if it exists), find the sprint workflow patterns and add: "MANDATORY: Governance kickoff (control applicability + PDL Impact Assessment) must complete BEFORE BA discovery begins. Skipping this is a process violation."

When done:
- Commit with message: "FW-012: Add context budget metrics to retro template, codify FW-008 governance-first"
- Run: bd comments add agentic-SCRUM-0vs "Done. Context budget review added to SM retro template."
- Run: bd close agentic-SCRUM-0vs --reason "Retro template updated with context budget metrics."
- Run: bd comments add agentic-SCRUM-kbz "Codified in workflow patterns: Governance kickoff mandatory before BA discovery."
- Run: bd close agentic-SCRUM-kbz --reason "Governance-first ordering codified in workflow patterns."
PROMPT
}

fw007_prompt() {
cat <<'PROMPT'
You are the Dev agent working on the agentic-SCRUM framework repo.

TASK: FW-007 — Define UAT as distinct activity from QA test coordination.

Read bead agentic-SCRUM-2ru for full context.

Instructions:
1. Read agents/QA-AGENT.md.
2. The QA Agent currently conflates two activities:
   - TEST COORDINATION: verify test coverage, run suite, produce execution report, map tests to ACs.
   - UAT (User Acceptance Testing): independent test cases from ACs alone, edge cases Dev missed, business-perspective validation.
3. Refactor QA-AGENT.md to clearly separate these two activities:
   a. Rename/restructure the role to make TEST COORDINATION the primary agent responsibility.
   b. Add a new section "UAT Boundary" that explains:
      - UAT is a DISTINCT activity requiring independence from the implementation context.
      - In a single-LLM-context setup, QA Agent cannot provide genuine UAT (has seen the code).
      - UAT options: (a) human UAT, (b) separate agent session scoped to stories only, (c) QA writes tests from ACs before reviewing Dev tests, (d) hybrid.
      - Until UAT is implemented, the QA Execution Report explicitly states it covers test coordination only, NOT independent acceptance testing.
   c. Update any references to "QA approval" or "QA pass" to say "QA coordination complete — recommendation only, not approval."
4. Update CLAUDE.md role selection logic if needed — ensure QA references align with the updated role.
5. Reference C-02 (Separation of Duties) in the UAT Boundary section.

IMPORTANT: Do NOT remove any existing QA capabilities. This is additive — clarify what QA does and does not provide.

When done:
- Commit with message: "FW-007: Define UAT as distinct from QA test coordination, update QA-AGENT.md"
- Run: bd comments add agentic-SCRUM-2ru "Done. QA-AGENT.md updated: test coordination vs UAT clearly separated. UAT boundary documented with C-02 reference."
- Run: bd close agentic-SCRUM-2ru --reason "UAT defined as distinct activity. QA role clarified as test coordination."
PROMPT
}

# ---- Runner ----------------------------------------------------------------

run_session() {
  local task_id="$1"
  local prompt="$2"
  local logfile="${LOG_DIR}/${task_id}.log"

  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  Starting: ${task_id}                                       "
  echo "║  Log: ${logfile}                                            "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""

  cd "$REPO_ROOT"

  if [[ "${DRY_RUN:-}" == "true" ]]; then
    echo "[DRY RUN] Would execute:"
    echo "$prompt"
    echo ""
    return 0
  fi

  claude -p \
    --permission-mode acceptEdits \
    --allowedTools "Read,Edit,Write,Bash,Glob,Grep" \
    --max-budget-usd "$BUDGET_PER_SESSION" \
    "$prompt" 2>&1 | tee "$logfile"

  echo ""
  echo "✓ Completed: ${task_id} — log at ${logfile}"
  echo ""
}

# ---- Main ------------------------------------------------------------------

main() {
  local target="${1:-all}"

  cd "$REPO_ROOT"
  echo "Working directory: $(pwd)"
  echo "Budget per session: \$${BUDGET_PER_SESSION} USD"
  echo ""

  if [[ "$target" == "--dry-run" ]]; then
    export DRY_RUN=true
    target="all"
  fi

  case "$target" in
    FW-009) run_session "FW-009" "$(fw009_prompt)" ;;
    FW-010) run_session "FW-010" "$(fw010_prompt)" ;;
    FW-011) run_session "FW-011" "$(fw011_prompt)" ;;
    FW-012) run_session "FW-012" "$(fw012_prompt)" ;;
    FW-007) run_session "FW-007" "$(fw007_prompt)" ;;
    all)
      echo "Running all sessions in dependency order..."
      echo "  1. FW-009 (slim CLAUDE.md) — must go first, others reference it"
      echo "  2. FW-010 (split GOVERNANCE-AGENT.md)"
      echo "  3. FW-011 (cache bd patterns + AI-003/AI-005)"
      echo "  4. FW-012 (retro template + FW-008 governance-first)"
      echo "  5. FW-007 (UAT vs QA)"
      echo ""
      run_session "FW-009" "$(fw009_prompt)"
      run_session "FW-010" "$(fw010_prompt)"
      run_session "FW-011" "$(fw011_prompt)"
      run_session "FW-012" "$(fw012_prompt)"
      run_session "FW-007" "$(fw007_prompt)"
      echo ""
      echo "════════════════════════════════════════════════════════════════"
      echo "  All sessions complete. Review commits with: git log --oneline -5"
      echo "  Review beads with: bd list"
      echo "════════════════════════════════════════════════════════════════"
      ;;
    *)
      echo "Usage: $0 [FW-009|FW-010|FW-011|FW-012|FW-007|all|--dry-run]"
      exit 1
      ;;
  esac
}

main "$@"
