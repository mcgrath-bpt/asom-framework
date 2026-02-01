# Quick Start: Your First Autonomous Sprint

This guide walks you through Sprint 1 with your autonomous agent team.

## Pre-Sprint Setup (30 minutes)

### 1. Install Beads
```bash
# Install Beads for work tracking
# (Follow Beads-specific installation for your environment)
bd init
```

### 2. Configure Snowflake
```sql
-- Create databases
CREATE DATABASE IF NOT EXISTS DEV_DB;
CREATE DATABASE IF NOT EXISTS TEST_DB;
CREATE DATABASE IF NOT EXISTS AUDIT_DB;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS DEV_DB.RAW;
CREATE SCHEMA IF NOT EXISTS DEV_DB.CURATED;
CREATE SCHEMA IF NOT EXISTS DEV_DB.ANALYTICS;
CREATE SCHEMA IF NOT EXISTS AUDIT_DB.AUDIT;

-- Create roles (see skills/snowflake-development.md for details)
CREATE ROLE IF NOT EXISTS DATA_ENGINEER;
CREATE ROLE IF NOT EXISTS MARKETING_ANALYST;
```

### 3. Set Up Python Environment
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install polars pandas pydantic snowflake-connector-python pytest great-expectations --break-system-packages
```

### 4. Configure Secrets
```bash
# Set environment variables for Snowflake connection
export SNOWFLAKE_ACCOUNT='your-account'
export SNOWFLAKE_USER='your-user'
export SNOWFLAKE_PASSWORD='your-password'
export PII_MASK_SALT='generate-random-salt-here'
```

## Sprint 1 Day-by-Day

### Day 1: Sprint Planning

**You (Product Owner)**:
```bash
# Create epic
bd epic create "Customer Data Pipeline with PII Governance"

# Define sprint goal
echo "Sprint Goal: Deliver production-ready customer data ingestion pipeline with complete PII protection and governance documentation"
```

**Governance Agent First**:
Load `agents/GOVERNANCE-AGENT.md` and ask:
> "Create the PDL template for Sprint 1 focused on customer data ingestion with PII handling. The pipeline will extract customer data from a REST API (containing email, phone), mask PII, load to Snowflake, and provide analytics views."

Expected output: PDL template with governance requirements

**Business Analyst Next**:
Load `agents/BA-AGENT.md` and ask:
> "Using the Governance Agent's PDL, create user stories for the customer data ingestion epic. Break down into: extraction, PII masking, Snowflake schema creation, data quality checks, access controls, and documentation."

Expected output: 5-8 user stories in Beads with acceptance criteria

**Scrum Master Facilitates**:
Load `agents/SCRUM-MASTER-AGENT.md` and ask:
> "Review the sprint backlog, validate Definition of Ready for each story, and create the sprint plan."

Expected output: Sprint planning document with committed stories

### Days 2-4: Development Sprint

**For each story**, follow this sequence:

#### 1. Dev Agent Implements
Load `agents/DEV-AGENT.md` with relevant skills:
```
Skills needed:
- skills/python-data-engineering.md
- skills/snowflake-development.md
- skills/governance-requirements.md
```

Example prompt:
> "Implement story S001: Extract customer data from API. Review the acceptance criteria, implement the solution following the Python and governance best practices, write tests achieving >80% coverage, and create a PR with documentation."

Expected output:
- Python extraction script
- Unit tests
- PR description
- Beads comment with progress

#### 2. QA Agent Validates
Load `agents/QA-AGENT.md` with relevant skills:
```
Skills needed:
- skills/testing-strategies.md (you'll create this or use inline guidance)
- skills/python-data-engineering.md
- skills/governance-requirements.md
```

Example prompt:
> "Review the PR for S001. Execute the test plan, validate against acceptance criteria, verify data quality, test PII masking, and report results."

Expected output:
- Test execution report
- Pass/fail determination
- Defect reports (if any)
- Beads comment with results

#### 3. Governance Agent Certifies
Load `agents/GOVERNANCE-AGENT.md`:

Example prompt:
> "Perform governance validation on S001. Verify PII masking works correctly, audit logging is present, access controls are implemented, and all compliance evidence is collected."

Expected output:
- Governance validation report
- Compliance evidence
- PDL update
- Approval or rejection

### Days 5-7: Continue Development

Repeat the Dev → QA → Governance cycle for remaining stories:
- S002: PII masking implementation
- S003: Snowflake schema creation
- S004: Data quality checks
- S005: Access controls

### Days 8-9: Integration & Testing

**QA Agent** performs end-to-end testing:
> "Execute integration tests for the complete customer data pipeline. Verify data flows from API → Raw → Curated → Analytics. Test all governance controls together."

Expected output:
- Integration test results
- End-to-end validation
- Performance metrics

### Day 10: Sprint Review & Retrospective

**Scrum Master** facilitates:
> "Generate the sprint review document showing completed stories, demonstrations, and metrics. Then create the retrospective covering what went well, what didn't, and action items for Sprint 2."

Expected output:
- Sprint review report
- Retrospective notes
- Action items for improvement

**Governance Agent** finalizes:
> "Complete the Product Delivery Log for Sprint 1. Ensure all governance requirements are met, evidence is collected, and compliance is certified."

Expected output:
- Completed PDL
- Compliance certificate
- Audit-ready documentation

## Monitoring Your First Sprint

### Daily Check-in
Each morning, ask **Scrum Master Agent**:
> "Provide daily coordination update. Show status of all stories, any impediments, and agent handoff status."

### Key Metrics to Watch

**Velocity**:
```bash
bd metrics velocity --sprint 1
```
Expected: 20-30 story points (first sprint, learning curve)

**Quality**:
- Test coverage: >80%
- Defects: <5 total
- PII violations: 0

**Governance**:
- PDL completion: >90%
- Compliance violations: 0
- Documentation: Complete

## Common Issues & Solutions

### Issue: Agents Waiting on Each Other
**Solution**: Check Beads comments for explicit handoffs. Make sure status transitions are clear.

### Issue: Quality Problems
**Solution**: Have QA Agent review earlier. Don't wait until end of sprint.

### Issue: Unclear Requirements
**Solution**: BA Agent and Governance Agent should collaborate upfront on acceptance criteria.

### Issue: Tests Failing
**Solution**: Dev Agent should fix immediately. Don't continue to next story with broken tests.

## Success Criteria for Sprint 1

At the end of Sprint 1, you should have:

**Working Software**:
- [ ] Customer data extracted from API
- [ ] PII properly masked (email → hash, phone → redacted)
- [ ] Data loaded to Snowflake (Bronze → Silver → Gold)
- [ ] Data quality checks automated
- [ ] Access controls implemented and tested
- [ ] Pipeline runs end-to-end successfully

**Quality**:
- [ ] Test coverage >80%
- [ ] All tests passing
- [ ] No PII leaks detected
- [ ] Code review completed

**Governance**:
- [ ] PDL 100% complete
- [ ] All compliance requirements met
- [ ] Audit trail verified
- [ ] Documentation complete and audit-ready

**Process**:
- [ ] Agent handoffs worked smoothly
- [ ] Beads tracking provided visibility
- [ ] Retrospective identified improvements
- [ ] Ready to run Sprint 2 with less intervention

## What's Next: Sprint 2

Based on Sprint 1 learnings:

1. **Refine Agent Definitions**: Update AGENT.md files based on what worked/didn't work
2. **Expand Skills**: Add new patterns discovered during Sprint 1
3. **Increase Autonomy**: Move from Phase 1 (supervised) toward Phase 2 (conditional)
4. **Scale Complexity**: Take on more challenging stories or multiple parallel workstreams
5. **Optimize Process**: Implement retrospective action items

## Pro Tips

1. **Start Each Day with Scrum Master**: Get coordination update first
2. **Load Relevant Skills**: Don't load all skills for every agent - just what's needed
3. **Explicit Handoffs**: Always mark status changes with Beads comments
4. **Test Governance Early**: Don't wait until end to validate PII protection
5. **Document Decisions**: Use ADR pattern for significant technical choices
6. **Iterate Fast**: Don't perfect everything in Sprint 1 - learn and improve
7. **Trust the Process**: Let agents make decisions within their expertise
8. **Verify Output**: Especially in Sprint 1, actually run the code and check results
9. **Celebrate Wins**: When agents produce good work, note it in retrospective
10. **Learn from Failures**: When things break, update skills and agent definitions

## Emergency Procedures

### PII Leak Detected
1. Stop all work immediately
2. Document in Beads with CRITICAL priority
3. Governance Agent investigates
4. Fix and re-test before continuing

### Production Incident
1. Scrum Master coordinates response
2. Dev Agent provides immediate fix
3. QA Agent validates fix
4. Governance Agent documents for audit
5. Retrospective analyzes root cause

### Agent Confusion
1. Review agent's AGENT.md for clarity
2. Check if skills are loaded
3. Provide more specific prompt
4. Update agent definition if needed

## Getting Help

If agents aren't performing as expected:

1. **Check Agent Definition**: Is the AGENT.md clear on this scenario?
2. **Load Relevant Skills**: Are the right skills referenced?
3. **Review Examples**: Look at the examples in AGENT.md files
4. **Simplify Prompt**: Break complex requests into smaller pieces
5. **Iterate**: Agents improve with feedback and refinement

## Conclusion

Sprint 1 is about proving the model works. Don't expect perfection - expect learning.

Key goals:
- Agents can coordinate through Beads ✅
- Handoffs work smoothly ✅
- Quality and governance maintained ✅
- Working software delivered ✅
- Process improves through retrospective ✅

After Sprint 1, you'll have confidence in the autonomous team and be ready to scale.

Good luck with your first sprint! 🚀
