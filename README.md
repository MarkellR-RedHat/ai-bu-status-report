# ai-bu-status-report

Claude Code commands that generate status reports, quarterly summaries, team rollups, OKR mappings, and executive summaries by scanning your git activity, GitHub PRs, and closed issues.

Built for engineers who want to stop manually reconstructing what they did last week.

## What It Does

### `/status-report`

Scans your recent work and produces a structured status report. It pulls data from:

- **Git log**: Your commits in the past week (or a custom timeframe)
- **GitHub PRs**: PRs you opened, reviewed, or merged, with line counts
- **GitHub Issues**: Issues you closed or commented on
- **Open Issues**: Issues assigned to you, used to populate "Planned Next Week"

All activity is grouped into themes: Engineering, Content, Reviews, and Community. The output includes an impact metrics table and sections for Completed, In Progress, Planned Next Week, and Blockers.

### `/quarterly-review`

A longer-range variant for quarterly summaries. Scans 3 months of activity and groups everything by initiative or project. Includes impact metrics like PRs merged, lines changed, average PR turnaround time, and repos contributed to. Useful for performance reviews, planning docs, or stakeholder updates.

### `/team-report`

Aggregates status across multiple team members. Takes an org name or a list of GitHub usernames and produces a team-level summary with per-member breakdowns, a "what shipped" section, and team-wide blockers.

### `/okr-update`

Maps your recent git and GitHub activity to your OKRs. You provide your objectives and key results, and the command matches your work to each one. Highlights gaps where no recent activity aligns, so you know where to focus.

### `/executive-summary`

Generates a single-paragraph executive summary of what the team shipped, suitable for skip-level meetings, all-hands updates, or stakeholder emails. Includes supporting metrics and a list of key deliverables.

## Installation

Clone the repo and run the install script:

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-status-report.git
cd ai-bu-status-report
chmod +x install.sh
./install.sh
```

This copies the command files into `~/.claude/commands/` where Claude Code picks them up automatically.

## Configuration

You can create a `~/.status-config` file to set defaults so you do not have to pass the same arguments every time. All commands check for this file and apply its settings unless overridden by explicit arguments.

### Config File Format

Create `~/.status-config` with any of these settings:

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

All fields are optional. Only include the ones you want to set.

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

### Weekly Status Report

```
/status-report
```

With a custom timeframe:

```
/status-report last 2 weeks
```

Filtered to a specific repo:

```
/status-report repo:my-org/my-repo
```

### Quarterly Review

```
/quarterly-review Q2 2025
```

With a custom date range:

```
/quarterly-review 2025-01-01 to 2025-03-31
```

Filtered to an org:

```
/quarterly-review Q1 2025 org:my-org
```

### Team Report

```
/team-report org:my-org
```

With a specific list of team members:

```
/team-report users:alice,bob,carol
```

### OKR Update

With inline OKRs:

```
/okr-update O1: Improve inference performance KR1: Reduce p99 latency by 30% KR2: Ship model router v2
```

With OKRs from a file:

```
/okr-update okrs:~/q3-okrs.txt
```

### Executive Summary

```
/executive-summary org:my-org
```

With an audience hint:

```
/executive-summary org:my-org for:vp
```

## Example Output

### Weekly Status Report

```
## Weekly Status Report

Period: 2025-06-16 to 2025-06-23
Author: Markell Robinson
Repos scanned: openshift/llm-d, openshift/llm-d-inference-sim, MarkellR-RedHat/ai-bu-status-report

### Impact Summary

| Metric | Count |
|--------|-------|
| Commits | 14 |
| PRs Opened | 4 |
| PRs Merged | 3 |
| PRs Reviewed | 6 |
| Issues Closed | 2 |
| Lines Added | +847 |
| Lines Removed | -213 |

### Completed

**Engineering**
- Added streaming support to inference gateway (PR #42) - +312/-45 lines
- Fixed token counting bug in batch processor (PR #38) - +28/-12 lines
- Updated Helm chart values for multi-model routing (PR #51) - +67/-23 lines

**Content**
- Published llm-d architecture overview blog post (openshift/llm-d-docs#15)

**Reviews**
- Reviewed model router refactor (PR #45) - 1,200 lines changed
- Reviewed CI pipeline update (PR #41) - 340 lines changed
- Reviewed quota API design doc (PR #47) - 89 lines changed
- Reviewed contributor guide updates (PR #52) - 156 lines changed
- Reviewed inference sim test harness (PR #33) - 420 lines changed
- Reviewed scheduler priority fix (PR #49) - 78 lines changed

**Community**
- Responded to 2 issues in openshift/llm-d about deployment configuration

### In Progress

- Quota management API design (PR #50) - opened 2025-06-20, 3 days old
- Load testing framework for multi-model routing (PR #53) - opened 2025-06-22, 1 day old

### Planned Next Week

- Finalize quota management API (openshift/llm-d, Q3 Milestone) (Issue #44)
- Write load testing runbook (openshift/llm-d-docs) (Issue #18)
- Investigate memory leak in long-running inference sessions (Issue #55)

### Blockers

- PR #50 (Quota management API) has been open for 3 days with no reviewer assigned.
```

### Executive Summary

```
## Executive Summary

The AI platform team merged 11 PRs across 4 repos this week, shipping streaming
support for the inference gateway and closing out 2 long-standing deployment
issues. The team also completed 18 code reviews, with focus on the model router
refactor that lands next week. The quota management API (PR #50) needs a reviewer
assigned to stay on track for the Q3 milestone.

### Supporting Metrics

| Metric | Count |
|--------|-------|
| PRs Merged | 11 |
| Issues Closed | 5 |
| Active Contributors | 4 |
| Repos Touched | 4 |

### Key Deliverables

- Inference gateway streaming support (PR #42)
- Batch processor token counting fix (PR #38)
- Helm chart multi-model routing update (PR #51)
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated for full GitHub data
- Git configured with your name and email

Without `gh` authentication, the commands will still work but will be limited to local git log data. Team reports and executive summaries require `gh` to be authenticated with access to the relevant org.

## How It Works

These are Claude Code slash commands, which are markdown files that act as prompt templates. When you run `/status-report`, Claude Code reads the command file, executes the shell commands to gather data, and then formats the results into a clean report. No external services, no API keys beyond what Claude Code and `gh` already use.

The optional `~/.status-config` file lets you set defaults so you can just run `/status-report` without arguments and get a report scoped to your repos and team.

## License

Apache-2.0
