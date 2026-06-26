# ai-bu-status-report

Claude Code commands that generate weekly status reports and quarterly summaries by scanning your git activity, GitHub PRs, and closed issues.

Built for engineers who want to stop manually reconstructing what they did last week.

## What It Does

### `/status-report`

Scans your recent work and produces a structured status report. It pulls data from:

- **Git log**: Your commits in the past week (or a custom timeframe)
- **GitHub PRs**: PRs you opened, reviewed, or merged
- **GitHub Issues**: Issues you closed or commented on

All activity is grouped into themes: Engineering, Content, Reviews, and Community. The output follows a standard format with sections for Completed, In Progress, Planned Next Week, and Blockers.

### `/quarterly-review`

A longer-range variant for quarterly summaries. Scans 3 months of activity and groups everything by initiative or project. Includes impact metrics like PRs merged, lines changed, and repos contributed to. Useful for performance reviews, planning docs, or stakeholder updates.

## Installation

Clone the repo and run the install script:

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-status-report.git
cd ai-bu-status-report
chmod +x install.sh
./install.sh
```

This copies the command files into `~/.claude/commands/` where Claude Code picks them up automatically.

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

## Example Output

### Weekly Status Report

```
## Weekly Status Report

Period: 2025-06-16 to 2025-06-23
Author: Markell Robinson

### Completed

**Engineering**
- Added streaming support to inference gateway (PR #42)
- Fixed token counting bug in batch processor (PR #38)

**Content**
- Published llm-d architecture overview blog post

**Reviews**
- Reviewed model router refactor (PR #45)
- Reviewed CI pipeline update (PR #41)

### In Progress
- Quota management API design (PR #50)

### Planned Next Week
- Finalize quota management PR
- Begin load testing for multi-model routing

### Blockers
- No blockers identified.
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated for full GitHub data
- Git configured with your name and email

Without `gh` authentication, the commands will still work but will be limited to local git log data.

## How It Works

These are Claude Code slash commands, which are markdown files that act as prompt templates. When you run `/status-report`, Claude Code reads the command file, executes the shell commands to gather data, and then formats the results into a clean report. No external services, no API keys beyond what Claude Code and `gh` already use.

## License

Apache-2.0
