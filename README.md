# ai-bu-status-report

Claude Code slash commands that generate status reports a VP would forward to their boss. Scans your git activity, GitHub PRs, and issues to produce structured, evidence-backed reports with zero manual reconstruction.

Every report uses chain-of-thought reasoning, self-critique guards, and the "So What?" test to ensure every claim has a number, every status has evidence, and every risk has a mitigation.

## Commands

### Core Reports

| Command | What It Produces |
|---------|-----------------|
| `/status-report` | Weekly status with impact metrics, risk detection, and the "So What?" test on every bullet |
| `/executive-summary` | VP-ready single paragraph with traffic light status and SCQA narrative structure |
| `/team-report` | Team rollup with bottleneck analysis, review load distribution, and manager action items |
| `/quarterly-review` | Quarter summary with initiative narratives, velocity trends, and performance-review-ready prose |

### Analysis Tools

| Command | What It Produces |
|---------|-----------------|
| `/okr-update` | Maps work to OKRs with alignment scoring, gap analysis, and time allocation vs. priority |
| `/status-trends` | Multi-week trends dashboard with Unicode sparkline charts and "what this means" analysis |
| `/risk-register` | Formal risk register with likelihood/impact scoring, ASCII risk matrix, and priority actions |
| `/stakeholder-view` | Same data tailored to audience: exec (business impact), pm (features), eng (technical), external (polished) |

## Installation

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-status-report.git
cd ai-bu-status-report
chmod +x install.sh
./install.sh
```

This copies all 8 command files into `~/.claude/commands/` where Claude Code picks them up automatically.

## Configuration

Create `~/.status-config` to set defaults. All commands check for this file and apply its settings unless overridden by explicit arguments.

### Config File Format

```yaml
# Default repos to scan (comma-separated)
repos: my-org/repo-one, my-org/repo-two, my-org/repo-three

# Default org for team reports
org: my-org

# Default team members for team reports (GitHub usernames, comma-separated)
team: alice, bob, carol, dave

# Default timeframe for status reports
timeframe: 7 days

# Default timeframe for quarterly reviews
quarterly_timeframe: 90 days

# OKR file path for /okr-update
okr_file: ~/okrs.txt

# Output format: markdown or plain
format: markdown
```

### Example Config

```yaml
repos: openshift/llm-d, openshift/llm-d-inference-sim
org: openshift
team: mrobinson, jsmith, akumar
timeframe: 7 days
okr_file: ~/q3-okrs.txt
format: markdown
```

## Usage

### `/status-report`

```
/status-report
/status-report last 2 weeks
/status-report repo:my-org/my-repo
/status-report last 2 weeks repo:my-org/my-repo focus:engineering
```

### `/executive-summary`

```
/executive-summary org:my-org
/executive-summary org:my-org for:vp
/executive-summary users:alice,bob,carol for:all-hands
/executive-summary repo:my-org/my-repo for:stakeholders
```

### `/team-report`

```
/team-report org:my-org
/team-report users:alice,bob,carol
/team-report org:my-org focus:bottlenecks
```

### `/quarterly-review`

```
/quarterly-review Q2 2025
/quarterly-review 2025-01-01 to 2025-03-31
/quarterly-review Q1 2025 org:my-org
/quarterly-review Q2 2025 focus:performance-review
```

### `/okr-update`

```
/okr-update O1: Improve inference performance KR1: Reduce p99 latency by 30% KR2: Ship model router v2
/okr-update okrs:~/q3-okrs.txt
/okr-update okrs:~/q3-okrs.txt last 2 weeks
```

### `/status-trends`

```
/status-trends
/status-trends 8 weeks
/status-trends 12 weeks repo:my-org/my-repo
/status-trends 6 weeks org:my-org focus:velocity
```

### `/risk-register`

```
/risk-register
/risk-register repo:my-org/my-repo
/risk-register org:my-org last 4 weeks
/risk-register focus:delivery threshold:medium
```

### `/stakeholder-view`

```
/stakeholder-view exec
/stakeholder-view pm last 2 weeks
/stakeholder-view eng repo:my-org/my-repo
/stakeholder-view external project:inference-gateway
```

## Example Outputs

### Weekly Status Report

```markdown
## Weekly Status Report

**Period**: 2025-06-16 to 2025-06-23
**Author**: Markell Robinson
**Repos**: openshift/llm-d, openshift/llm-d-inference-sim, MarkellR-RedHat/ai-bu-status-report

### Summary

This week shipped streaming support for the inference gateway (PR #42, +312/-45
lines), which unblocks real-time model serving for the enterprise tier. The team
also fixed a token counting bug that was causing 15% overcharging on batch requests
and completed 6 code reviews across the model router refactor. PR #50 (quota
management API) has been open 3 days with no reviewer assigned and needs attention
to stay on track for the Q3 milestone.

### Impact Metrics

| Metric | This Week | Trend |
|--------|-----------|-------|
| Commits | 14 | up from 11 last week |
| PRs Merged | 3 | flat |
| PRs Reviewed | 6 | up from 4 |
| Issues Closed | 2 | flat |
| Lines Changed | +847 / -213 | |

### What Shipped

- **Streaming inference support for enterprise tier** (PR #42) - +312/-45 lines
  - Why it matters: Enables real-time model serving, required for 3 enterprise
    customer deployments scheduled for Q3

- **Token counting accuracy fix** (PR #38) - +28/-12 lines
  - Why it matters: Resolved 15% overcharging on batch inference, affecting all
    customers using the batch API

- **Multi-model routing in Helm chart** (PR #51) - +67/-23 lines
  - Why it matters: Unblocks the Q3 inference gateway milestone by enabling
    per-model routing configuration

### In Progress

- **Quota management API** (PR #50) - opened 2025-06-20, 3 days old, no reviewer assigned
- **Load testing framework** (PR #53) - opened 2025-06-22, 1 day old, @jsmith reviewing

### Planned Next Week

- **Finalize quota management API** (Issue #44) - openshift/llm-d, Q3 Milestone
- **Write load testing runbook** (Issue #18) - openshift/llm-d-docs
- **Investigate memory leak in long-running sessions** (Issue #55) - openshift/llm-d

### Risks and Blockers

| Risk | Severity | Days Open | Recommended Action |
|------|----------|-----------|-------------------|
| PR #50 has no reviewer assigned | Medium | 3 days | Assign @akumar as reviewer by EOD Monday |
```

### Executive Summary

```markdown
## Executive Summary

The AI platform team shipped streaming inference support and fixed batch pricing
accuracy across 4 repos this week, completing 3 of 4 Q3 milestone deliverables
on schedule. The streaming capability (PR #42) enables real-time model serving
for the 3 enterprise deployments scheduled in July, while the token counting fix
(PR #38) resolved 15% overcharging affecting all batch API customers. The quota
management API (PR #50) needs a reviewer assigned this week to hit the July 15
feature-complete deadline.

**Status**: GREEN - 3 of 4 Q3 deliverables complete, 2 weeks of buffer remaining

### Key Deliverables

1. **Streaming inference for enterprise tier** - Enables real-time model serving
   for July enterprise deployments (PR #42)
2. **Batch pricing accuracy fix** - Resolved 15% overcharging on batch API (PR #38)
3. **Multi-model routing support** - Unblocks per-model configuration for Q3 GA (PR #51)

### Metrics

| Metric | Count |
|--------|-------|
| PRs Merged | 11 |
| Issues Closed | 5 |
| Active Contributors | 4 |
| Repos Touched | 4 |

### What Is Next

- Quota management API feature-complete by July 15
- Load testing validation for enterprise deployment readiness
```

### Status Trends Dashboard

```markdown
## Activity Trends Dashboard

**Analysis Window**: 2025-05-12 to 2025-06-23 (6 weeks)
**Scope**: Markell Robinson
**Repos**: openshift/llm-d, openshift/llm-d-inference-sim

### Trend Summary

Shipping velocity increased 35% over the past 6 weeks, driven by smaller PRs with
faster review cycles. PR merge time improved from 3.2 days to 1.8 days, suggesting
the review process is maturing. One concern: review load remains concentrated on
2 of 5 team members, with @alice handling 55% of all reviews.

### Velocity Dashboard

Metric              Trend      Sparkline          Avg    Direction
Commits/week        ▂▃▅▅▇█    8>10>14>15>18>20   14.2   ↑ Increasing
PRs Merged/week     ▃▃▅▅▇█    3>3>5>5>7>8        5.2    ↑ Increasing
PRs Reviewed/week   ▇▅▃▃▃▁    8>5>3>3>3>1        3.8    ↓ Decreasing
Issues Closed/week  ▃▃▃▅▃▃    2>2>2>4>2>2        2.3    → Stable

### PR Cycle Time Trend

Week 1 (May 12):   4.2 days   ████████░░
Week 2 (May 19):   3.8 days   ████████░░
Week 3 (May 26):   3.1 days   ██████░░░░
Week 4 (Jun 02):   2.5 days   █████░░░░░
Week 5 (Jun 09):   1.9 days   ████░░░░░░
Week 6 (Jun 16):   1.8 days   ████░░░░░░

Trend: ↓ Getting faster
What this means: PR cycle time dropped 57% over 6 weeks. Smaller PR sizes
(avg 126 lines, down from 340) and consistent review turnaround drove the
improvement.

### Notable Patterns

1. Review bottleneck: @alice reviewed 55% of all PRs. Weeks where @alice
   reviewed fewer than 3 PRs saw average cycle times 2x higher.
2. Friday shipping: 40% of PR merges happened on Fridays, suggesting a
   batch-review pattern. Spreading reviews across the week would reduce
   end-of-week merge congestion.

### Recommendations

1. Distribute review load: Assign @bob and @carol as default reviewers
   on llm-d and llm-d-inference-sim respectively to reduce dependency
   on @alice.
2. Target PR size under 200 lines: The data shows PRs under 200 lines
   merge in 1.2 days vs 3.8 days for larger PRs.
```

### Risk Register

```markdown
## Risk Register

**Generated**: 2025-06-23
**Analysis Window**: 2025-05-26 to 2025-06-23
**Scope**: openshift/llm-d
**Total Risks Identified**: 3

### Risk Summary

3 risks identified: 1 high and 2 medium. The high risk is an unreviewed PR
blocking the Q3 milestone, open for 12 days with no reviewer assigned. The
2 medium risks relate to declining review coverage and an external API
dependency with a 1-week delay.

### Risk Matrix

                          IMPACT
              1-Min  2-Low  3-Mod  4-High  5-Crit
            +------+------+------+-------+-------+
5-Certain   |      |      |      |       |       |
            +------+------+------+-------+-------+
4-V.Likely  |      |      |      | [R1]  |       |
            +------+------+------+-------+-------+
3-Likely    |      |      | [R3] |       |       |
            +------+------+------+-------+-------+
2-Possible  |      |      |      | [R2]  |       |
            +------+------+------+-------+-------+
1-Unlikely  |      |      |      |       |       |
            +------+------+------+-------+-------+

### Risk Register Detail

R1: Quota Management API Unreviewed

| Field | Detail |
|-------|--------|
| Category | Delivery |
| Description | PR #50 has been open 12 days with no reviewer assigned |
| Likelihood | 4/5 - PR cannot merge without review, blocking milestone |
| Impact | 4/5 - Quota API is a Q3 milestone dependency |
| Risk Score | 16/25 - High |
| Evidence | PR #50: https://github.com/openshift/llm-d/pull/50 |
| Current Mitigations | None |
| Recommended Action | Assign @akumar as reviewer by EOD Monday |
| Owner | @mrobinson |
| Due Date | 2025-06-25 |

R2: External API Dependency Delayed

| Field | Detail |
|-------|--------|
| Category | External |
| Description | Platform team API v2 delayed 1 week, affects quota integration |
| Likelihood | 2/5 - Delay confirmed but workaround exists |
| Impact | 4/5 - Would delay quota API integration testing |
| Risk Score | 8/25 - Medium |
| Evidence | Platform team standup 2025-06-20 |
| Current Mitigations | Mock API available for development |
| Recommended Action | Confirm revised API delivery date with platform team lead |
| Owner | @jsmith |
| Due Date | 2025-06-27 |

### Recommended Priority Actions

1. Assign reviewer to PR #50 - Reduces R1 from 16 to 4. Owner: @mrobinson. Target: 2025-06-25.
2. Confirm platform API v2 timeline - Reduces R2 from 8 to 4. Owner: @jsmith. Target: 2025-06-27.
```

### Stakeholder View (Executive)

```markdown
## Executive Status Update

**Period**: 2025-06-16 to 2025-06-23
**Status**: GREEN - 3 of 4 Q3 deliverables shipped, 2 weeks of buffer

### Bottom Line

The platform team completed 3 of 4 Q3 deliverables this week, shipping the
streaming inference capability that enables real-time AI responses for the 3
enterprise deployments scheduled in July. Batch processing costs dropped 15%
with a pricing accuracy fix, directly improving margins on the managed service
tier. The remaining deliverable (quota management) needs a reviewer assigned
this week to hit the July 15 deadline.

### Key Outcomes This Period

1. **Enterprise deployment readiness** - Streaming inference enables real-time
   model serving, required for July enterprise rollouts
2. **Managed service margin improvement** - 15% cost reduction on batch
   processing through pricing accuracy fix
3. **Infrastructure flexibility** - Multi-model routing support enables
   per-customer model configuration

### Timeline Status

| Milestone | Target Date | Status | Notes |
|-----------|------------|--------|-------|
| Q3 Feature Complete | Jul 15 | On Track | 3 of 4 items shipped |
| Enterprise Deployment 1 | Jul 22 | On Track | Streaming support landed |
| GA Release | Aug 30 | On Track | No blockers identified |
```

### Stakeholder View (Engineering)

```markdown
## Engineering Status Update

**Period**: 2025-06-16 to 2025-06-23
**Repos**: openshift/llm-d, openshift/llm-d-inference-sim

### Technical Summary

Shipped the vLLM scheduling loop optimization that cuts p99 latency from 500ms to
300ms under concurrent load, enabling streaming responses through the inference
gateway. Fixed a floating-point rounding issue in the token counter that was
accumulating billing errors on batch requests. Moved to event-driven model routing
in the Helm chart to support per-deployment model selection.

### Metrics

| Metric | Count |
|--------|-------|
| Commits | 14 |
| PRs Merged | 3 |
| PRs Reviewed | 6 |
| Issues Closed | 2 |
| Lines Added | +847 |
| Lines Removed | -213 |
| Avg PR Size | 126 lines |
| Avg PR Cycle Time | 1.8 days |

### What Shipped (Technical Detail)

**openshift/llm-d**
- **Streaming inference via vLLM scheduling optimization** (PR #42) - +312/-45
  - Redesigned the scheduling loop to support streaming token generation.
    Replaced the batch-and-flush pattern with an async generator that yields
    tokens as they are produced. p99 dropped from 500ms to 300ms at 200
    concurrent requests.
  - Tests: Added 12 integration tests covering streaming under load, connection
    drops, and backpressure handling.
  - Performance: 40% p99 reduction validated with k6 load test suite.

- **Token counting precision fix** (PR #38) - +28/-12
  - Root cause: float32 accumulation in the token counter was losing precision
    after ~10K tokens per batch. Switched to int64 counting with explicit
    rounding at the billing boundary.
  - Tests: Added property-based test that validates billing accuracy over
    100K-token batches.

### Architecture Decisions

- **Event-driven model routing**: Moved from static config to event-driven model
  selection in the Helm chart (PR #51). Enables hot-reloading model assignments
  without pod restarts. Chose event-driven over polling to avoid the 30s
  latency window in the previous approach.

### Blockers and Risks (Technical)

| Issue | Type | Impact | Recommended Fix |
|-------|------|--------|-----------------|
| PR #50 needs review | Review | Blocks quota API | Assign @akumar |
```

### OKR Update

```markdown
## OKR Progress Update

**Period**: 2025-06-09 to 2025-06-23
**Author**: Markell Robinson
**Alignment Score**: 78% of work items mapped to OKRs

### Alignment Overview

| Metric | Count |
|--------|-------|
| Total Work Items | 9 |
| Mapped to OKRs | 7 |
| Unmapped | 2 |
| KRs On Track | 2 of 4 |
| KRs At Risk | 1 of 4 |
| KRs Off Track | 1 of 4 |

### Time Allocation vs. OKR Priority

| Objective | Work Items | % of Total Effort | Expected Priority |
|-----------|------------|-------------------|-------------------|
| O1: Inference Performance | 4 | 44% | High |
| O2: Platform Reliability | 2 | 22% | Medium |
| Unmapped Work | 2 | 22% | - |
| O3: Developer Adoption | 1 | 11% | High |

Misalignment flag: O3 (Developer Adoption) is rated High priority but received
only 11% of effort. Consider allocating more time next sprint.

### Objective 1: Improve Inference Performance

#### KR 1.1: Reduce p99 latency by 30%
**Status**: On Track
**Evidence**:

- Shipped vLLM scheduling optimization, p99 dropped from 500ms to 300ms (40%
  reduction, exceeding 30% target) (PR #42) - 2025-06-18
- Load testing confirmed improvement holds at 200 concurrent requests (PR #53)

Impact: 2 PRs merged, +340/-57 lines directly advancing this KR

#### KR 1.2: Ship quota management API
**Status**: At Risk
**Evidence**:

- PR #50 open for 3 days, no reviewer assigned
- API design complete, implementation at approximately 70% based on commit history

Impact: 1 PR open, +280/-0 lines. At risk because review has not started.

### Gap Analysis

| Key Result | Status | Days Since Last Activity | What Is Needed |
|-----------|--------|-------------------------|---------------|
| KR 1.2: Quota API | At Risk | 3 days (PR open, unreviewed) | Assign reviewer to PR #50 by Monday |
| KR 3.1: Onboarding guide | Off Track | 14 days | Allocate 2 days next sprint to draft quick-start guide |

### Unmapped Activity

| Item | Type | Impact |
|------|------|--------|
| Helm chart refactor (PR #51) | PR | +67/-23 lines |
| 2 community issue responses | Issues | Triage only |

Assessment: 22% of effort went to unmapped work. The Helm chart refactor arguably
supports O1 but the connection is indirect. Consider adding an infrastructure
KR to O1 if this work continues.
```

## Report Frameworks

The commands use three frameworks to ensure quality. See `reference/report-frameworks.md` for the full reference.

### SCQA (Situation, Complication, Question, Answer)

Structures narratives so they tell a story, not just list facts. Used in executive summaries and quarterly review narratives.

**Example**: "The inference gateway is on track for Q3 GA (Situation). Load testing revealed p99 latency spikes at 200+ concurrent requests (Complication). The team redesigned the scheduling loop, cutting p99 by 40% (Answer). The GA timeline holds."

### Traffic Light Criteria

Status colors earned by evidence, not vibes:
- **GREEN**: Next milestone reachable, no blockers, velocity steady. Evidence required.
- **YELLOW**: Specific risk identified with mitigation in progress. Name the risk.
- **RED**: Blocker that the team cannot resolve alone. Include a specific ask.

### The "So What?" Test

Every bullet must answer "why does this matter?" without the reader having to ask.

- Bad: "Updated Helm chart values"
- Good: "Updated Helm chart to support multi-model routing, unblocking Q3 milestone (PR #51)"

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated for full GitHub data
- Git configured with your name and email

Without `gh` authentication, the commands still work but are limited to local git log data. Team reports and executive summaries require `gh` to be authenticated with access to the relevant org.

## How It Works

These are Claude Code slash commands: markdown files that act as prompt templates with embedded shell commands for data gathering. When you run `/status-report`, Claude Code reads the command file, executes the shell commands to gather data, applies chain-of-thought reasoning and quality checks, and formats the results into a presentation-ready report.

No external services. No API keys beyond what Claude Code and `gh` already use. The optional `~/.status-config` file lets you set defaults so you can run `/status-report` with no arguments and get a report scoped to your repos and team.

## License

Apache-2.0
