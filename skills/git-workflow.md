---
name: git-workflow
description: Git version control workflow and best practices for data engineering projects. Covers branching strategy, commit conventions, PR process, and collaboration patterns. Essential for Dev Agent to maintain code quality and audit trail.
---

# Git Workflow

## Overview

Git workflow provides version control discipline for data engineering projects, enabling collaboration, code review, and audit trail of changes. This skill covers branching strategy, commit conventions, and pull request processes.

## Branching Strategy

### Branch Types

```
main (production)
├── develop (integration)
│   ├── feature/customer-pipeline
│   ├── feature/pii-masking
│   └── feature/data-quality-checks
└── hotfix/urgent-bug-fix
```

**Branch purposes:**

**`main`** - Production-ready code
- Always deployable
- Protected (no direct commits)
- Requires PR approval
- Tagged with release versions

**`develop`** - Integration branch
- Latest development changes
- Feature branches merge here first
- Tested before merging to main

**`feature/*`** - New features or stories
- One branch per story/feature
- Branched from develop
- Merged back to develop via PR
- Naming: `feature/story-id-brief-description`

**`hotfix/*`** - Emergency production fixes
- Branched from main
- Merged to both main and develop
- Naming: `hotfix/issue-description`

### Branch Lifecycle

**Creating feature branch:**
```bash
# Start from latest develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/S001-customer-api-extraction

# Push to remote
git push -u origin feature/S001-customer-api-extraction
```

**Keeping branch up to date:**
```bash
# Rebase on latest develop (preferred)
git checkout feature/S001-customer-api-extraction
git fetch origin
git rebase origin/develop

# Or merge (if rebase conflicts are complex)
git merge origin/develop
```

**Completing feature:**
```bash
# Ensure all changes committed
git status

# Push final changes
git push origin feature/S001-customer-api-extraction

# Create Pull Request on GitHub/GitLab
# (via web interface)
```

## Commit Conventions

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Example:**
```
feat(extraction): add customer API pagination support

Implement pagination to handle datasets >100 records.
Uses cursor-based pagination with 100 records per page.

Closes #S001
```

### Commit Types

**`feat`** - New feature
```
feat(masking): implement SHA256 email masking
feat(quality): add completeness validation
```

**`fix`** - Bug fix
```
fix(extraction): handle API timeout errors
fix(masking): ensure deterministic hashing
```

**`test`** - Adding or updating tests
```
test(extraction): add pagination test cases
test(masking): verify PII protection
```

**`refactor`** - Code restructuring (no behavior change)
```
refactor(extraction): extract pagination logic to helper
refactor(masking): simplify hash generation
```

**`docs`** - Documentation changes
```
docs(readme): update setup instructions
docs(api): add extraction module docstrings
```

**`chore`** - Maintenance tasks
```
chore(deps): update pandas to 2.0.0
chore(config): add pytest configuration
```

**`perf`** - Performance improvements
```
perf(extraction): batch API requests for efficiency
```

### Commit Message Guidelines

**Good commit messages:**
- ✅ Clear and descriptive subject line
- ✅ Explain WHY, not just WHAT
- ✅ Reference story/issue IDs
- ✅ Imperative mood ("add feature" not "added feature")

**Examples:**

✅ **Good:**
```
feat(extraction): add retry logic for API failures

Customer API occasionally returns 500 errors during peak hours.
Added exponential backoff retry (3 attempts) to handle transient failures.
This improves pipeline reliability from 95% to 99.9%.

Closes #S001
```

✅ **Good:**
```
test(masking): verify email masking is deterministic

Same email must always produce same hash to enable joins across datasets.
Added test with multiple identical inputs to verify determinism.

Part of #S002
```

❌ **Bad:**
```
fix stuff
```

❌ **Bad:**
```
updated code
```

❌ **Bad:**
```
WIP
```

### Atomic Commits

**Each commit should:**
- Represent one logical change
- Pass all tests
- Build successfully
- Be reviewable independently

**Bad (multiple changes in one commit):**
```bash
git add .
git commit -m "Add extraction and masking and tests"
```

**Good (separate commits):**
```bash
# First commit: extraction
git add src/extract/
git commit -m "feat(extraction): implement customer API extractor"

# Second commit: tests
git add tests/unit/test_extractor.py
git commit -m "test(extraction): add pagination test cases"

# Third commit: masking
git add src/transform/masking.py
git commit -m "feat(masking): implement SHA256 email masking"
```

## TDD Commit Pattern

### RED → GREEN → REFACTOR in Commits

**Phase 1: RED commit (test first)**
```bash
# Write failing test
git add tests/unit/test_customer_extractor.py
git commit -m "test(extraction): add test for pagination (RED phase)"
```

**Phase 2: GREEN commit (make it pass)**
```bash
# Implement minimum code to pass
git add src/extract/customer_extractor.py
git commit -m "feat(extraction): implement pagination (GREEN phase)

Closes #S001"
```

**Phase 3: REFACTOR commit (improve quality)**
```bash
# Refactor for better code quality
git add src/extract/customer_extractor.py
git commit -m "refactor(extraction): extract pagination logic to helper (REFACTOR phase)"
```

This creates clear audit trail of TDD process for QA validation.

## Pull Request (PR) Process

### Creating a PR

**Before creating PR:**
- [ ] All tests passing locally
- [ ] Code follows style guide (black, flake8)
- [ ] Docstrings added/updated
- [ ] No debug code or commented-out code
- [ ] All files added and committed
- [ ] Branch rebased on latest develop

**PR Template:**
```markdown
## Description
Brief description of changes

## Story
Closes #S001

## Type of Change
- [ ] feat: New feature
- [ ] fix: Bug fix
- [ ] test: Test additions/changes
- [ ] refactor: Code restructuring
- [ ] docs: Documentation

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests passing
- [ ] Manual testing completed

## TDD Process
- [ ] RED: Tests written first
- [ ] GREEN: Implementation passes tests
- [ ] REFACTOR: Code quality improved

## Checklist
- [ ] Code follows style guide
- [ ] Docstrings complete
- [ ] No PII in logs or debug output
- [ ] Governance controls tested
- [ ] Documentation updated
```

### PR Review Checklist

**For reviewer:**
- [ ] Code is clear and maintainable
- [ ] Tests cover edge cases
- [ ] No security vulnerabilities
- [ ] No PII leakage
- [ ] Follows coding standards
- [ ] Performance is acceptable
- [ ] Documentation is clear
- [ ] Commit history is clean

**Review comments should:**
- Be constructive and specific
- Explain WHY, not just WHAT
- Suggest alternatives
- Link to style guide/docs when applicable

### Merging Strategy

**Squash and merge (recommended for features):**
```bash
# Combines all commits into one on main
# Keeps main history clean
# Good for feature branches with many small commits
```

**Merge commit (for important branches):**
```bash
# Preserves all commits
# Shows branch history
# Good for release branches
```

**Rebase and merge (for clean linear history):**
```bash
# Replays commits on top of main
# Linear history (no merge commits)
# Good for single-commit features
```

**ASOM Default: Squash and merge**
- Keeps main history clean
- Each feature = one commit on main
- Detailed history preserved in feature branch

## Protecting Branches

### Main Branch Protection

**Rules for `main` branch:**
```
✅ Require pull request reviews (minimum 1 approval)
✅ Require status checks to pass (CI/CD tests)
✅ Require branches to be up to date
✅ Require linear history (optional)
✅ Include administrators (no bypass)
❌ Allow force pushes
❌ Allow deletions
```

### Develop Branch Protection

**Rules for `develop` branch:**
```
✅ Require pull request reviews
✅ Require status checks to pass
❌ Administrators can bypass (for hotfixes)
❌ Allow force pushes
❌ Allow deletions
```

## Tagging and Releases

### Semantic Versioning

**Format:** `vMAJOR.MINOR.PATCH`

Examples:
- `v1.0.0` - Initial release
- `v1.1.0` - New features (backward compatible)
- `v1.1.1` - Bug fixes
- `v2.0.0` - Breaking changes

**Creating tags:**
```bash
# Lightweight tag
git tag v1.0.0

# Annotated tag (recommended)
git tag -a v1.0.0 -m "Release v1.0.0: Customer pipeline with PII governance"

# Push tag to remote
git push origin v1.0.0

# Push all tags
git push origin --tags
```

### Release Notes

**Format:**
```markdown
# Release v1.0.0

## Features
- Customer API extraction with pagination (#S001)
- PII masking with SHA256 (#S002)
- Data quality validation (#S003)

## Bug Fixes
- Fix API timeout handling (#B001)

## Breaking Changes
None

## Upgrade Instructions
1. Update dependencies: `pip install -r requirements.txt`
2. Run database migrations: `python migrate.py`
3. Update configuration: See CONFIG_CHANGES.md
```

## Common Git Commands

### Daily Workflow

```bash
# Start of day: Update local repository
git checkout develop
git pull origin develop

# Create feature branch for story S005
git checkout -b feature/S005-data-quality-checks

# Make changes, then check status
git status

# Add changes
git add src/quality/
git add tests/unit/test_quality.py

# Commit with descriptive message
git commit -m "feat(quality): add completeness validation

Validates required fields have >95% non-null values.

Part of #S005"

# Push to remote
git push origin feature/S005-data-quality-checks

# When feature complete, create PR via web interface
```

### Reviewing Changes

```bash
# See what changed
git diff

# See staged changes
git diff --cached

# See commit history
git log --oneline --graph

# See who changed a line
git blame src/extract/customer_extractor.py

# See changes in a file over time
git log -p src/extract/customer_extractor.py
```

### Fixing Mistakes

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes) - DANGEROUS
git reset --hard HEAD~1

# Amend last commit message
git commit --amend -m "New commit message"

# Amend last commit (add forgotten file)
git add forgotten_file.py
git commit --amend --no-edit

# Discard local changes to a file
git checkout -- src/extract/customer_extractor.py

# Unstage a file
git reset HEAD src/extract/customer_extractor.py
```

### Working with Remote

```bash
# Add remote
git remote add origin https://github.com/org/repo.git

# See remotes
git remote -v

# Fetch from remote (doesn't merge)
git fetch origin

# Pull from remote (fetch + merge)
git pull origin develop

# Push to remote
git push origin feature/S005-data-quality-checks

# Delete remote branch
git push origin --delete feature/S005-data-quality-checks
```

## .gitignore Patterns

### Data Engineering .gitignore

```.gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv

# Jupyter
.ipynb_checkpoints
*.ipynb

# IDEs
.vscode/
.idea/
*.swp
*.swo

# Data files (never commit data!)
*.csv
*.parquet
*.json
*.xlsx
data/
raw/
processed/

# Credentials (CRITICAL - never commit secrets!)
*.env
.env.local
secrets.yaml
credentials.json
*.pem
*.key
config/credentials/

# OS
.DS_Store
Thumbs.db

# Testing
.coverage
htmlcov/
.pytest_cache/
.tox/

# Build
dist/
build/
*.egg-info/

# Logs
*.log
logs/
```

## Git Configuration

### Initial Setup

```bash
# Set user information
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"

# Set default editor
git config --global core.editor "vim"

# Set default branch name
git config --global init.defaultBranch main

# Enable color output
git config --global color.ui auto

# Set merge strategy
git config --global pull.rebase false
```

### Useful Aliases

```bash
# Short status
git config --global alias.st status

# Short log
git config --global alias.lg "log --oneline --graph --all"

# Amend commit
git config --global alias.amend "commit --amend --no-edit"

# Undo last commit
git config --global alias.undo "reset --soft HEAD~1"

# List aliases
git config --global --list | grep alias
```

## Best Practices

### Do's

✅ **Commit early and often**
- Small, focused commits are easier to review
- Easier to revert if needed

✅ **Write descriptive commit messages**
- Future you will thank present you
- Aids code review and debugging

✅ **Keep commits atomic**
- One logical change per commit
- Each commit should pass tests

✅ **Use feature branches**
- Isolate work
- Easier to manage and review

✅ **Review your own PR first**
- Catch mistakes before reviewers see them
- Add helpful comments for reviewers

✅ **Rebase on latest develop before PR**
- Prevents merge conflicts
- Ensures tests pass on current codebase

### Don'ts

❌ **Never commit credentials**
- Use environment variables
- Use secrets managers
- Add to .gitignore

❌ **Never commit PII or sensitive data**
- Add data files to .gitignore
- Scan commits before pushing

❌ **Never force push to shared branches**
- Rewrites history for others
- Can lose work

❌ **Avoid WIP commits on shared branches**
- Complete work before sharing
- Use local branches for experimentation

❌ **Don't commit commented-out code**
- Git history keeps old code
- Remove dead code

❌ **Don't commit large binary files**
- Slows down repository
- Use Git LFS for large files if needed

## ASOM Integration

### Branching Model and Gates

Feature branches enforce the G1 gate. Each story gets its own branch, and the
PR merge is the G1 checkpoint.

```
main (protected -- no direct commits)
├── feature/S001-extract-cur-data      → PR → G1 gate → merge to main
├── feature/S002-transform-cost-summary → PR → G1 gate → merge to main
└── feature/S003-cost-analytics         → PR → G1 gate → merge to main
```

**Branch naming convention:** `feature/<story-id>-brief-description`

**G1 gate requirements (enforced at PR merge):**
- Linked Jira/Beads story ID in PR description
- All tests passing (CI)
- TDD commit history (RED → GREEN → REFACTOR visible in branch)
- No secrets or PII in diff

**CRITICAL — No stacked branch chains (AI-007):**
Stacked branches (e.g. s004→s005→s006 where each PR targets the previous feature branch) cause PRs to merge into feature branches instead of main. This requires a catch-up PR and creates a confusing history.

**Rule:** Use ONE of these patterns per sprint:
1. **Single sprint branch** (recommended): One branch for the sprint, one PR to main at the end.
2. **Independent feature branches**: Each story branches from main and PRs to main independently.
3. **Re-target after merge**: If using sequential branches, re-target each PR's base to main after the previous PR merges.

Never chain PRs where PR #2 targets the branch from PR #1.

**When to use `develop` branch:**
- Optional. Use `main`-only for small teams or early adoption.
- Add `develop` as integration branch when multiple stories merge
  concurrently and need integration testing before release.

**Simplified model (recommended for getting started):**
```
main (protected)
└── feature/* (one per story, PR to main)
```

**Full model (for larger teams):**
```
main (production, tagged releases)
├── develop (integration)
│   └── feature/* (one per story, PR to develop)
└── hotfix/* (emergency, PR to main + develop)
```

### For Dev Agent

**TDD workflow with Git:**
1. Create feature branch from main: `feature/S001-description`
2. RED commit: Write failing test
3. GREEN commit: Implement to pass
4. REFACTOR commit: Improve quality
5. Create PR with linked story, TDD history visible
6. G1 gate: CI passes, PR approved, merge to main

**Governance evidence:**
- Commit history proves TDD followed
- PR reviews show quality validation
- Branch-per-story enforces isolation
- Tags mark audit-ready releases

### For QA Agent

**Validating TDD process:**
```bash
# Check commit history for RED → GREEN → REFACTOR
git log --oneline feature/S005-data-quality-checks

# Should see pattern like:
# abc123 refactor(quality): extract validation logic (REFACTOR)
# def456 feat(quality): implement completeness check (GREEN)
# 789xyz test(quality): add completeness test (RED)
```

**Reviewing PR:**
- Check commit messages follow conventions
- Verify tests added before implementation
- Confirm no PII in diffs
- Validate documentation updated

### For Governance Agent

**Audit trail:**
- Git history = complete change log
- Tags = release markers for compliance
- PR approvals = peer review evidence
- Commit messages = change justification

**Compliance checks:**
```bash
# Who made changes to PII masking logic?
git log --oneline -- src/transform/masking.py

# When was this introduced?
git log -p --follow src/transform/masking.py

# Full blame for current state
git blame src/transform/masking.py
```

## Summary

**Branching:**
- `main` for production (protected, no direct commits)
- `feature/*` for stories (one branch per story, PR = G1 gate)
- `develop` for integration (optional, add when needed)
- `hotfix/*` for urgent fixes (from main, PR to main)

**Commits:**
- Type prefix (feat, fix, test, refactor, docs, chore)
- Clear, descriptive messages
- Atomic changes
- Reference story IDs

**PRs:**
- Template with checklist
- Minimum 1 approval required
- All tests must pass
- Squash and merge to main

**TDD Integration:**
- RED commit: failing test
- GREEN commit: implementation
- REFACTOR commit: code quality
- Complete audit trail

**For ASOM:**
- Git history provides governance evidence
- Commit messages explain changes
- PR process ensures quality
- Tags mark compliant releases
