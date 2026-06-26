# Team Status Report Generator

Aggregate status reports across multiple team members. Produces a team-level summary of what shipped, what is in progress, and what is coming next.

## Arguments

$ARGUMENTS should specify:
- A GitHub org or team (e.g., "org:openshift" or "team:ai-bu")
- Optionally, a list of GitHub usernames (e.g., "users:alice,bob,carol")
- A timeframe (e.g., "last 2 weeks", "since 2025-06-01"). Defaults to the past 7 days.
- A repo filter (e.g., "repo:my-org/my-repo")

At minimum, either an org/team or a list of usernames is required. If neither is provided, ask the user to specify.

## Config File Support

Check if `~/.status-config` exists. If it does, read it for default org, team members, or repos.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Instructions

### Step 1: Determine Scope and Team Members

Parse $ARGUMENTS to extract the org, team, user list, timeframe, and repo filter.

If an org is specified, list members:

```bash
# List org members (requires appropriate GitHub permissions)
gh api orgs/<org>/members --paginate --jq '.[].login'
```

If a specific list of users is provided, use that list directly.

If using config file defaults and no arguments override them, apply the configured team members.

### Step 2: Gather Activity for Each Team Member

For each team member, run the following queries:

```bash
# PRs opened by this member
gh search prs --author=<username> --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt,additions,deletions,mergedAt

# PRs reviewed by this member
gh search prs --reviewed-by=<username> --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt

# Issues closed by this member
gh search issues --assignee=<username> --closed=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,closedAt
```

If a repo filter is specified, add `--repo=<owner/repo>` to each command.

### Step 3: Aggregate and Summarize

Combine all data across team members. Calculate:
- Total PRs opened, merged, and reviewed across the team
- Total issues closed
- Total lines added and removed
- Per-person breakdown of PRs merged and issues closed
- Most active repos

### Step 4: Generate the Team Report

Output the report in **exactly** this structure.

---

## Team Status Report

**Period**: [start date] to [end date]
**Team**: [org or team name]
**Members**: [count] contributors active this period

### Team Metrics

| Metric | Count |
|--------|-------|
| PRs Opened | X |
| PRs Merged | X |
| PRs Reviewed | X |
| Issues Closed | X |
| Lines Added | +X |
| Lines Removed | -X |
| Active Repos | X |

### What Shipped

List merged PRs grouped by repo or initiative. Each item includes the author.

**[Repo or Initiative Name]**
- [PR title] ([PR #NNN](url)) - @[author]
- [PR title] ([PR #NNN](url)) - @[author]

### In Progress

List open PRs across the team, grouped by repo.

- [PR title] ([PR #NNN](url)) - @[author], opened [date]

### Per-Member Summary

For each active team member, provide a one-line summary:

| Member | PRs Merged | PRs Reviewed | Issues Closed |
|--------|-----------|-------------|---------------|
| @alice | 3 | 5 | 2 |
| @bob | 1 | 3 | 4 |

### Blockers

List any PRs across the team that:
- Have been open more than 5 days without review
- Have failing CI checks
- Are labeled "blocked" or "waiting"

If no blockers are found, state "No blockers identified across the team."

---

### Output Rules

- Only report data that exists. Do not fabricate activity for any team member.
- Always use exact numbers. Never approximate with words like "several" or "a few."
- If a team member has no activity in the period, include them in the per-member table with zeros rather than omitting them.
- If the org member list is too large (more than 25 people), ask the user to provide a specific list of usernames or filter by repo.
- If GitHub CLI is not authenticated or lacks org permissions, inform the user and suggest: `gh auth login` and verify org access.
