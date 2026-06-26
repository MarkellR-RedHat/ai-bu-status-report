# ai-bu-status-report

It's 4:30 PM on Friday. Your status report is due in 30 minutes. You've been heads-down in code all week and can't remember what happened Monday. You open a blank doc, start typing "Made progress on...", then delete it because even you know that's useless.

These Claude Code slash commands fix that. They scan your git history, GitHub PRs, and issues, then generate status reports that a seasoned PM would sign off on. Every claim backed by data. Every status justified by evidence. Every risk paired with a mitigation.

Here is what the output looks like:

```
## Executive Summary

The platform team shipped streaming inference support and fixed batch pricing
accuracy across 4 repos this week, completing 3 of 4 Q3 deliverables on
schedule. The streaming capability enables real-time model serving for the
3 enterprise deployments in July. The quota management API needs a reviewer
assigned this week to hit the July 15 feature-complete deadline.

Status: GREEN - 3 of 4 Q3 deliverables complete, 2 weeks of buffer remaining
```

A VP would forward that to their boss. No editing. No context needed.

## The Problem

Status reports should be strategic documents, but most engineers write them like activity logs. "Updated the Helm chart." "Worked on the API." "Attended planning meeting." Nobody reading that knows whether the project is on track, what shipped, or what needs their help.

The person reading your status report has 14 other reports to read and will spend 30 seconds on yours. What do you want them to remember?

These commands apply three principles to every report:

1. **Pyramid Principle**: Lead with the conclusion. "Status: ON TRACK. We shipped X, unblocked Y, and the only risk is Z." The supporting detail comes after.

2. **The "So What?" Test**: Every bullet must answer "why does this matter?" without the reader asking. Not "Updated Helm chart values" but "Updated Helm chart to support multi-model routing, unblocking the Q3 milestone (PR #51)."

3. **Honest Risk Surfacing**: Bad news stated directly, not buried behind positive framing. "PR #50 has been open 12 days with no reviewer assigned" not "we continue to make progress on the quota API."

## Commands

### Core Reports

| Command | What It Produces |
|---------|-----------------|
| `/status-report` | Weekly status with impact metrics, risk detection, and the "So What?" test on every bullet |
| `/executive-summary` | VP-ready single paragraph with traffic light status and narrative structure |
| `/team-report` | Team rollup with bottleneck analysis, review load distribution, and manager action items |
| `/quarterly-review` | Quarter summary with initiative narratives, velocity trends, and performance-review-ready prose |

### Analysis Tools

| Command | What It Produces |
|---------|-----------------|
| `/okr-update` | Maps work to OKRs with alignment scoring, gap analysis, and time allocation vs. priority |
| `/status-trends` | Multi-week trends dashboard with sparkline charts and "what this means" analysis |
| `/risk-register` | Formal risk register with likelihood/impact scoring, risk matrix, and priority actions |
| `/stakeholder-view` | Same data tailored to audience: exec (business impact), pm (features), eng (technical), external (polished) |

## Installation

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-status-report.git
cd ai-bu-status-report
chmod +x install.sh
./install.sh
```

This copies all 8 command files into `~/.claude/commands/` where Claude Code picks them up automatically.

## Quick Start

Run any command with no arguments and it scans your recent activity:

```
/status-report
/executive-summary
/risk-register
```

Add arguments to narrow scope:

```
/status-report last 2 weeks repo:my-org/my-repo
/executive-summary org:my-org for:vp
/team-report users:alice,bob,carol
/stakeholder-view exec
```

## Configuration

Create `~/.status-config` to set defaults so every command just works with no arguments:

```yaml
# Default repos to scan (comma-separated)
repos: my-org/repo-one, my-org/repo-two

# Default org for team reports
org: my-org

# Default team members (GitHub usernames)
team: alice, bob, carol, dave

# Default timeframe
timeframe: 7 days

# OKR file path for /okr-update
okr_file: ~/okrs.txt

# Output format: markdown or plain
format: markdown
```

## What the Output Looks Like

### Weekly Status Report

```markdown
## Weekly Status Report

Period: 2025-06-16 to 2025-06-23
Author: Markell Robinson

### Summary

Status: ON TRACK. This week shipped streaming support for the inference
gateway (PR #42, +312/-45 lines), which unblocks real-time model serving
for 3 enterprise deployments in July. The team also fixed a token counting
bug that was causing 15% overcharging on batch requests and completed 6
code reviews across the model router refactor. One risk: PR #50 (quota
management API) has been open 3 days with no reviewer assigned and needs
attention to hit the July 15 deadline.

### What Shipped

- **Streaming inference for enterprise tier** (PR #42) - +312/-45 lines
  Why it matters: Enables real-time model serving, required for 3 enterprise
  customer deployments scheduled for Q3

- **Token counting accuracy fix** (PR #38) - +28/-12 lines
  Why it matters: Resolved 15% overcharging on batch inference, affecting
  all customers using the batch API

### Risks and Blockers

| Risk | Severity | Days Open | Recommended Action |
|------|----------|-----------|-------------------|
| PR #50 has no reviewer assigned | Medium | 3 days | Assign @akumar by Monday |
```

### Stakeholder View: Same Data, Different Audience

The `/stakeholder-view` command translates the same underlying data for whoever is reading it:

**Executive view** (`/stakeholder-view exec`):
> The platform team completed 3 of 4 Q3 deliverables, reducing AI inference
> costs by 20% and enabling real-time model serving for enterprise customers.

**Engineering view** (`/stakeholder-view eng`):
> Shipped vLLM scheduling loop optimization (PR #42, +312/-45). Replaced
> batch-and-flush with async generator. p99 dropped from 500ms to 300ms
> at 200 concurrent requests. 12 integration tests added.

**PM view** (`/stakeholder-view pm`):
> Latency SLO now met for enterprise tier. Streaming inference unblocks
> 3 customer deployments in July. Quota API at risk without reviewer.

**External view** (`/stakeholder-view external`):
> AI responses are now 40% faster, enabling real-time interactions for
> enterprise applications.

### Risk Register

```markdown
## Risk Register

Total Risks: 3 (1 High, 2 Medium)

### Risk Matrix

                      IMPACT
            Low  Med  High Crit
       +----+----+----+----+
 High  |    |    | R3 | R1 |
       +----+----+----+----+
 Low   | R5 | R4 | R2 |    |
       +----+----+----+----+

R1: Quota API PR unreviewed for 12 days (Score: 16/25 - High)
    Action: Assign @akumar as reviewer by Friday
R2: External API dependency delayed 1 week (Score: 8/25 - Medium)
    Action: Confirm revised timeline with platform team lead
```

### Trends Dashboard

```markdown
## Activity Trends Dashboard (6 weeks)

Shipping velocity increased 35% over 6 weeks, driven by smaller PRs
(avg 126 lines, down from 340) with faster review cycles (1.8 days,
down from 4.2 days).

Metric              Sparkline          Avg    Direction
Commits/week        ▂▃▅▅▇█             14.2   Up
PRs Merged/week     ▃▃▅▅▇█              5.2   Up
PR Cycle Time       ████████████████     1.8d  Improving
```

## Report Frameworks

Every command uses three frameworks to ensure quality:

**SCQA (Situation, Complication, Question, Answer)**: Structures narratives so they tell a story. "The inference gateway is on track for Q3 GA (Situation). Load testing revealed p99 latency spikes at 200+ concurrent requests (Complication). The team redesigned the scheduling loop, cutting p99 by 40% (Answer)."

**Traffic Light Criteria**: Status colors earned by evidence, not vibes. GREEN means no blockers, steady velocity, and next milestone reachable. YELLOW means a named risk threatens the timeline, with mitigation in progress. RED means a blocker the team cannot resolve alone, with a specific ask.

**The "So What?" Test**: Every bullet must include impact. "Fixed bug in batch processor" becomes "Fixed token counting bug causing 15% overcharging on batch inference requests (PR #38)."

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated for full GitHub data
- Git configured with your name and email

Without `gh` authentication, the commands still work but are limited to local git data. Team reports and executive summaries require `gh` to be authenticated with access to the relevant org.

## How It Works

These are Claude Code slash commands: markdown files that act as prompt templates with embedded shell commands for data gathering. When you run `/status-report`, Claude Code reads the command file, executes the shell commands to gather your git and GitHub data, applies structured reasoning and quality checks, then formats the results into a report ready to send.

No external services. No API keys beyond what Claude Code and `gh` already use. Your data stays local.

## License

Apache-2.0
