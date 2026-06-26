# ai-bu-status-report

**It's 4:55 PM on Friday. Your status report is due in 5 minutes.**

You've been heads-down in code all week. You open a blank doc and type "Made progress on..." then delete it because even you know that's useless. Your manager reads 14 status reports and spends 30 seconds on each one. What do you want them to remember?

## Before and After

**What you write today:**

> Updated Helm chart. Worked on the API. Attended sprint planning.

Nobody reading that knows if the project is on track.

**What these commands produce:**

> Status: GREEN. Shipped streaming inference support (PR #42, +312/-45 lines), unblocking 3 enterprise deployments in July. Fixed token counting bug causing 15% overcharging on batch requests (PR #38). One risk: quota management API (PR #50) has no reviewer assigned, 3 days open, needs attention by Monday to hit the July 15 deadline.

A VP would forward that to their boss. No editing. No context needed.

## Quick Start

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-status-report.git
cd ai-bu-status-report
./install.sh
```

Then open Claude Code in any repo and run:

```
/status-report
```

That's it. The command scans your git history and GitHub activity, then generates a report ready to send.

## Commands

### Core Reports

| Command | What it produces | When to use it |
|---------|-----------------|----------------|
| `/status-report` | Weekly status with impact metrics, risk detection, and evidence for every bullet | Friday afternoon, weekly standup prep |
| `/executive-summary` | Single paragraph with traffic light status and narrative structure | Slack update to your skip-level, all-hands prep |
| `/team-report` | Team rollup with bottleneck analysis, review load distribution, and action items | Manager weekly report, sprint retro |
| `/quarterly-review` | Quarter summary with initiative narratives, velocity trends, and review-ready prose | Performance review season, planning cycles |

### Analysis Tools

| Command | What it produces | When to use it |
|---------|-----------------|----------------|
| `/okr-update` | Maps work to OKRs with alignment scoring and time allocation vs. priority | OKR check-ins, proving impact at review time |
| `/status-trends` | Multi-week trends dashboard with sparkline charts and analysis | Spotting slowdowns before they become blockers |
| `/risk-register` | Formal risk register with likelihood/impact scoring and priority actions | Project reviews, escalation prep |
| `/stakeholder-view` | Same data tailored to audience: exec, pm, eng, or external | Communicating the same work to different people |

## Examples

```bash
# Narrow to a specific repo and timeframe
/status-report last 2 weeks repo:my-org/my-repo

# Executive summary for a VP audience
/executive-summary org:my-org for:vp

# Team rollup for specific people
/team-report users:alice,bob,carol

# Same data, different audience
/stakeholder-view exec
/stakeholder-view eng
/stakeholder-view pm
```

## Sample Output

```
## Weekly Status Report

Period: 2025-06-16 to 2025-06-23
Author: Markell Robinson

### Summary

Status: ON TRACK. Shipped streaming support for the inference gateway
(PR #42, +312/-45 lines), unblocking real-time model serving for 3
enterprise deployments in July. Fixed a token counting bug causing 15%
overcharging on batch requests. One risk: PR #50 (quota management API)
has been open 3 days with no reviewer assigned.

### What Shipped

- Streaming inference for enterprise tier (PR #42, +312/-45 lines)
  Why it matters: Required for 3 enterprise customer deployments in Q3

- Token counting accuracy fix (PR #38, +28/-12 lines)
  Why it matters: Resolved 15% overcharging affecting all batch API users

### Risks and Blockers

| Risk | Severity | Days Open | Recommended Action |
|------|----------|-----------|-------------------|
| PR #50 has no reviewer assigned | Medium | 3 days | Assign @akumar by Monday |
```

### Same Data, Different Audience

With `/stakeholder-view`, the same week of work becomes three different reports:

**Executive** (`/stakeholder-view exec`):
> Completed 3 of 4 Q3 deliverables, reducing AI inference costs by 20% and enabling real-time model serving for enterprise customers.

**Engineering** (`/stakeholder-view eng`):
> Shipped vLLM scheduling loop optimization (PR #42, +312/-45). Replaced batch-and-flush with async generator. p99 dropped from 500ms to 300ms at 200 concurrent requests.

**PM** (`/stakeholder-view pm`):
> Latency SLO now met for enterprise tier. Streaming inference unblocks 3 customer deployments in July. Quota API at risk without reviewer.

## Workflow

A typical Friday takes about 90 seconds:

1. **`/status-report`** scans your week and generates a VP-ready report.
2. **`/executive-summary`** distills it into a one-paragraph Slack update for your skip-level.
3. **`/stakeholder-view pm`** gives you the same data reframed for your PM's sprint review.

For deeper analysis:

- **Monthly**: Run `/status-trends 8 weeks` to spot velocity changes before your manager asks about them.
- **Quarterly**: Run `/quarterly-review Q2 2025` to generate a narrative ready to paste into a performance review.
- **Before escalation meetings**: Run `/risk-register` to walk in with scored risks and specific asks, not vague concerns.

One team reported that running `/status-report` on Fridays and `/quarterly-review` at review time cut their report-writing from 45 minutes per week to under 5. The bigger win: their reports started getting forwarded by their VP because every bullet had a number and a "so what."

## How It Works

These are Claude Code slash commands: markdown files that act as prompt templates with embedded shell commands. When you run `/status-report`, Claude Code reads the command file, executes shell commands to gather your git and GitHub data, applies structured reasoning and quality checks, then formats the results.

Every report follows three principles:

1. **Pyramid Principle**: Lead with the conclusion. Supporting detail comes after.
2. **The "So What?" Test**: Every bullet includes impact. Not "Updated Helm chart" but "Updated Helm chart to support multi-model routing, unblocking Q3 milestone (PR #51)."
3. **Honest Risk Surfacing**: Bad news stated directly, not buried. "PR #50 has been open 12 days with no reviewer" not "we continue to make progress."

## Works With Other AI BU Tools

These commands focus on turning git data into reports. For related workflows:

- Run `/meeting-notes` ([ai-bu-meeting-notes](https://github.com/MarkellR-RedHat/ai-bu-meeting-notes)) to capture decisions from the status meeting itself.
- Run `/message-polisher` ([ai-bu-message-polisher](https://github.com/MarkellR-RedHat/ai-bu-message-polisher)) to tighten an executive summary before sending it to leadership.
- Run `/cfp-generator` ([ai-bu-cfp-generator](https://github.com/MarkellR-RedHat/ai-bu-cfp-generator)) to turn a strong quarterly review into a conference talk proposal.
- Run `/shipped-digest` ([ai-bu-shipped-digest](https://github.com/MarkellR-RedHat/ai-bu-shipped-digest)) for a broader team-wide view of what shipped across multiple repos.

## Configuration (Optional)

Create `~/.status-config` to set defaults so commands work with zero arguments:

```yaml
repos: my-org/repo-one, my-org/repo-two
org: my-org
team: alice, bob, carol, dave
timeframe: 7 days
okr_file: ~/okrs.txt
format: markdown
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated for full GitHub data
- Git configured with your name and email

Without `gh`, the commands still work but pull from local git data only. Team reports and executive summaries need `gh` authenticated with org access.

## License

Apache-2.0
