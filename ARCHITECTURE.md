# Architecture Guide: AGENT.md vs SKILLS.md

> **Agents assist. Systems enforce. Humans approve.**

## TL;DR

- **AGENT.md**: "Who I am, what I do, how I decide, who I work with"
- **SKILLS.md**: "How to accomplish specific technical tasks"

Use **AGENT.md** when defining agent-assisted behaviour and decision-making.
Use **SKILLS.md** when codifying reusable technical knowledge and patterns.

## Authority Model

ASOM v2 operates on a three-tier authority model that governs what agents, systems, and humans are permitted to do:

### Tier 1: Agents (Non-Authoritative)
Agents draft artifacts, interpret requirements, surface gaps, and suggest remediation. Agents **cannot** approve, certify, promote, or generate evidence. All agent output is advisory until verified by a system or approved by a human.

### Tier 2: Systems (Enforcement)
Authoritative systems (CI/CD, Git, ServiceNow, Jira, platform policy engines) produce immutable evidence, enforce promotion gates (G1 through G4), and validate separation of duties. Systems are deterministic -- they allow or block, they do not recommend.

### Tier 3: Humans (Approval)
Humans hold final authority for promotion decisions (QA and PROD), CRQ approval, exception handling, and risk acceptance. Human approval must be recorded in authoritative systems (ServiceNow), not in agent conversations or documentation.

**Architectural rule:** When adding new agents to the framework, every AGENT.md must define explicit authority boundaries -- what the agent may draft, what the agent must not approve, and which systems enforce the boundary.

### Architectural Artifacts

The control enforcement model is defined in `docs/ASOM_CONTROLS.md`, which consolidates:
- Control Catalog (C-01 through C-10)
- Evidence Ledger Specification
- Promotion Gate Rules (G1 through G4)
- Separation of Duties Matrix

## Detailed Comparison

### AGENT.md Files

**Purpose**: Define an agent's identity, responsibilities, decision-making framework, and authority boundaries.

**Contains**:
- Role identity and purpose
- Core responsibilities  
- Decision-making frameworks
- Coordination protocols with other agents
- Success metrics
- Output standards and formats
- What the agent does and doesn't do

**Example from DEV-AGENT.md**:
```markdown
## Decision-Making Framework

### Technology Choices
- Python libraries: Prefer polars over pandas for large datasets
- Testing: pytest for Python, Snowflake stored procedures for SQL
- When to use what pattern...

### When to Seek Input
- Technical uncertainty without clear pattern
- Performance concerns exceeding expectations
- Security questions about sensitive data
```

**When to Use**:
- Defining a new agent role
- Specifying agent-assisted decision-making rules
- Establishing agent coordination protocols
- Setting role boundaries, responsibilities, and authority boundaries

**Characteristics**:
- Role-specific (unique to each agent)
- Behavioural guidance
- Process-oriented
- Defines "who" and "when"

### SKILLS.md Files

**Purpose**: Provide reusable technical knowledge and implementation patterns.

**Contains**:
- Technical procedures and patterns
- Code examples and templates
- Best practices for specific technologies
- Configuration and setup instructions
- Testing approaches
- Common pitfalls and solutions

**Example from python-data-engineering.md**:
```python
class PIIMasker:
    """Mask PII fields using deterministic hashing."""
    
    def mask_email(self, email: str) -> str:
        """Mask email address with SHA256 hash."""
        # Implementation details...
```

**When to Use**:
- Codifying technical best practices
- Sharing knowledge across multiple agents
- Documenting technology-specific patterns
- Providing reusable code templates

**Characteristics**:
- Domain-specific (technology or task)
- Technical how-to
- Implementation-focused
- Defines "how" and "what"

## Relationship Between Agent and Skills

```
AGENT.md (DEV-AGENT)
  ├─ References: python-data-engineering.md
  ├─ References: snowflake-development.md
  ├─ References: governance-requirements.md
  └─ References: beads-coordination.md

AGENT.md (QA-AGENT)
  ├─ References: python-data-engineering.md (to understand code)
  ├─ References: snowflake-development.md (to test SQL)
  ├─ References: governance-requirements.md (to test compliance)
  └─ References: beads-coordination.md

AGENT.md (GOVERNANCE-AGENT)
  ├─ References: governance-requirements.md (to enforce)
  └─ References: beads-coordination.md
```

**Key Insight**: Multiple agents can reference the same skill, but each interprets it through their role's lens.

## Concrete Examples

### Example 1: PII Masking

**In SKILLS (governance-requirements.md)**:
```markdown
### Required PII Masking

| PII Type | Protection Method | Example |
|----------|-------------------|---------|
| Email | SHA256 hash with salt | test@example.com → a3f2c1... |
| Phone | Redact to last 4 digits | 123-456-7890 → XXX-XXX-7890 |
```

**In AGENT (DEV-AGENT.md)**:
```markdown
### Governance Integration
Every implementation must include:
- PII protection: Mask/tokenise sensitive fields per governance-requirements.md
- Reference the skill for approved masking methods
- Implement using patterns from python-data-engineering.md
```

**In AGENT (QA-AGENT.md)**:
```markdown
### Governance Tests
**GOV001**: PII Masking
- Verify email addresses are tokenised (no @ symbols)
- Verify phone numbers are redacted (last 4 digits only)
- Reference governance-requirements.md for validation criteria
```

**In AGENT (GOVERNANCE-AGENT.md)**:
```markdown
### PII Protection Validation
- Define requirements using governance-requirements.md
- Validate Dev Agent implementation meets standards
- Test that QA Agent verified correctly
```

### Example 2: Story Creation

**In SKILLS (beads-coordination.md)**:
```bash
# Create story
bd story create --epic E001 "Ingest customer data from API"

# Add comment with structured format
bd comment S001 "[Agent Name] Action taken
Context: ...
Progress: ...
Next: ..."
```

**In AGENT (BA-AGENT.md)**:
```markdown
## Output Standards

### User Story Format
```
As a [role]
I need [capability]
So that [business value]

Acceptance Criteria:
- [Functional criterion]
- [Data quality criterion]
- [Governance criterion]
```

Use beads-coordination.md for creating stories in Beads.
```

**In AGENT (SCRUM-MASTER-AGENT.md)**:
```markdown
## Sprint Management

Use beads-coordination.md for:
- Creating epics and stories
- Tracking workflow states
- Managing handoffs
- Generating reports
```

## Decision Tree: AGENT.md or SKILLS.md?

```
Is this about...

└─ "Who does what and when to do it"
   → AGENT.md
   
└─ "How to accomplish a specific technical task"
   → SKILLS.md

└─ "Decision-making rules for a role"
   → AGENT.md
   
└─ "Code patterns and best practices"
   → SKILLS.md
   
└─ "Coordination between agents"
   → AGENT.md (references beads-coordination.md skill)
   
└─ "Technology-specific knowledge"
   → SKILLS.md
```

## Anti-Patterns to Avoid

### ❌ Don't Put Technical Details in AGENT.md
```markdown
## BAD - In DEV-AGENT.md

### How to Mask Emails
```python
def mask_email(email: str) -> str:
    import hashlib
    return hashlib.sha256(email.encode()).hexdigest()
```
```

**Why Bad**: Technical implementation belongs in skills. Agent should reference the skill instead.

**✅ Better**:
```markdown
## GOOD - In DEV-AGENT.md

### PII Protection
Implement PII masking using approved methods from:
- skills/governance-requirements.md (requirements)
- skills/python-data-engineering.md (implementation patterns)
```

### ❌ Don't Put Role Decisions in SKILLS.md
```markdown
## BAD - In python-data-engineering.md

### When Dev Agent Should Implement
The Dev Agent should implement PII masking when the BA Agent 
has marked the story ready and the Governance Agent has approved...
```

**Why Bad**: Role coordination belongs in agent definitions. Skills should be role-agnostic.

**✅ Better**:
```markdown
## GOOD - In python-data-engineering.md

### PII Masking Implementation
Use deterministic SHA256 hashing for email addresses:
[code example]
```

## Maintenance Guidelines

### When to Update AGENT.md
- Agent role responsibilities change
- Decision-making rules evolve
- New coordination patterns emerge
- Success metrics need adjustment
- Retrospectives identify process improvements

### When to Update SKILLS.md
- New technical patterns discovered
- Better implementation approaches found
- Technology versions update
- Common mistakes need documentation
- Best practices evolve

### When to Create New SKILLS.md
- Multiple agents need the same technical knowledge
- Technology-specific guidance is complex
- Patterns are reused across stories
- Technical domain needs codification

### When to Create New AGENT.md
- New role needed in the team
- Responsibilities need to be separated
- Specialisation improves efficiency
- Clear decision boundaries needed

## Your Framework's Design

### Agent Architecture
```
5 Agents (AGENT.md files):
├─ BA: Requirements and stories
├─ Dev: Implementation
├─ QA: Quality assurance
├─ Governance: Compliance
└─ Scrum Master: Coordination
```

### Shared Skills Architecture
```
4 Core Skills (SKILLS.md files):
├─ beads-coordination: Work tracking (used by ALL agents)
├─ python-data-engineering: Python patterns (Dev, QA)
├─ snowflake-development: Snowflake patterns (Dev, QA, Governance)
└─ governance-requirements: Compliance (ALL agents)
```

This design is **modular and scalable**:
- Add new agents without changing skills
- Add new skills without changing agents
- Agents compose skills as needed
- Skills remain technology-focused
- Agents remain role-focused

## Scaling Considerations

### Adding Agents
When adding a new agent role:
1. Create new AGENT.md defining the role
2. **Define explicit authority boundaries** -- what the agent may draft, what it must not approve, and which systems enforce the boundary
3. Reference existing relevant SKILLS.md files
4. Update other AGENT.md files for coordination
5. Don't duplicate technical content - reference skills

### Adding Skills
When adding a new skill:
1. Create new SKILLS.md with technical patterns
2. Update relevant AGENT.md files to reference it
3. Keep it role-agnostic
4. Focus on "how", not "who" or "when"

### Evolving the Framework
- **Agent evolution**: Update AGENT.md based on retrospectives
- **Skills evolution**: Update SKILLS.md based on technical learnings
- **New patterns**: Capture in appropriate skill file
- **New responsibilities**: Update or create agent definitions

## Summary

| Aspect | AGENT.md | SKILLS.md |
|--------|----------|-----------|
| **Purpose** | Define agent-assisted behaviour | Codify technical knowledge |
| **Scope** | Role-specific | Domain-specific |
| **Content** | Who, when, why | How, what |
| **Reuse** | One per role | Many agents reference |
| **Updates** | Process improvements | Technical improvements |
| **Examples** | Decision frameworks, coordination | Code patterns, best practices |

**Golden Rule**: If it's about the agent's identity and decision-making, it's AGENT.md. If it's technical knowledge that could help multiple agents, it's SKILLS.md.

Your framework follows this pattern perfectly, enabling both clear role boundaries and efficient knowledge sharing. This is why it will scale effectively as you add more agents and skills over time.
