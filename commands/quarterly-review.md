# Quarterly Review Generator

Generate a quarterly summary by scanning 3 months of git activity, GitHub PRs, and issues. Groups work by initiative and project for use in performance reviews, planning docs, or stakeholder updates.

## Arguments

$ARGUMENTS can be used to specify:
- A specific quarter (e.g., "Q1 2025", "Q4 2024")
- A custom date range (e.g., "2024-10-01 to 2024-12-31")
- A repo filter (e.g., "repo:ai-bu-hub-build")
- An org filter (e.g., "org:MarkellR-RedHat")

If no arguments are provided, default to the past 90 days.

## Config File Support

Before starting, check if `~/.status-config` exists. If it does, read it and apply any defaults (repos, org, format). Config values are overridden by explicit $ARGUMENTS.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Instructions

### Step 1: Determine Timeframe

Parse $ARGUMENTS to figure out the date range:
- "Q1 2025" maps to 2025-01-01 through 2025-03-31
- "Q2 2025" maps to 2025-04-01 through 2025-06-30
- "Q3 2025" maps to 2025-07-01 through 2025-09-30
- "Q4 2025" maps to 2025-10-01 through 2025-12-31
- If a custom range is given, use those dates directly
- If nothing is specified, use the last 90 days

### Step 2: Gather All Git Activity

```bash
# Get user identity
git config user.email
git config user.name

# Pull all commits in the timeframe
git log --since="<start_date>" --until="<end_date>" --author="<user>" --pretty=format:"%h %s (%ai)" --no-merges

# Get a summary of file changes for impact analysis
git log --since="<start_date>" --until="<end_date>" --author="<user>" --stat --no-merges

# Total commit count
git log --since="<start_date>" --until="<end_date>" --author="<user>" --oneline --no-merges | wc -l
```

### Step 3: Gather All GitHub Activity

```bash
# All PRs authored in the period
gh search prs --author=@me --created="<start_date>..<end_date>" --limit=200 --json title,url,state,repository,createdAt,mergedAt,additions,deletions

# All PRs reviewed
gh search prs --reviewed-by=@me --created="<start_date>..<end_date>" --limit=200 --json title,url,state,repository,createdAt

# All issues closed
gh search issues --author=@me --closed="<start_date>..<end_date>" --limit=200 --json title,url,repository,closedAt

# All issues commented on
gh search issues --commenter=@me --updated="<start_date>..<end_date>" --limit=200 --json title,url,repository,updatedAt
```

### Step 4: Identify Projects and Initiatives

Group all activity by repository first, then look for patterns across repos that represent larger initiatives. For example:
- Multiple repos related to "llm-d" would be grouped under an "llm-d" initiative
- Documentation repos might form a "Developer Education" initiative
- CI/CD and tooling repos might form an "Infrastructure" initiative

Use repo names, PR titles, and commit messages to identify these groupings. If the user has specified an org filter, use that to scope the search.

### Step 5: Calculate Impact Metrics

For each project/initiative, calculate these exact numbers:
- Total PRs opened, merged, and reviewed
- Total issues closed
- Lines of code added and removed (from PR data or git stats)
- Number of repos contributed to
- Average PR turnaround time (created to merged) in days

At the overall level, also compute:
- Total commits across all repos
- Week-over-week activity trend (increasing, steady, or decreasing)
- Busiest week by commit count

### Step 6: Generate the Quarterly Report

Output the report in **exactly** this structure. Do not add, remove, or rename sections.

---

## Quarterly Summary

**Period**: [start date] to [end date]
**Author**: [git user name]
**Repos**: [total count of repos contributed to]

### Executive Summary

Write 2-3 sentences summarizing the quarter's work at a high level. Include specific numbers: X PRs merged across Y repos, Z issues closed, N total commits. Highlight the single most significant initiative or accomplishment.

### Metrics Summary

| Metric | Count |
|--------|-------|
| Total Commits | X |
| PRs Opened | X |
| PRs Merged | X |
| PRs Reviewed | X |
| Issues Closed | X |
| Repos Contributed To | X |
| Lines Added | +X |
| Lines Removed | -X |
| Avg PR Turnaround | X days |

### Work by Initiative

For each identified initiative or project:

#### [Initiative Name]

**Repos**: [list of repos involved]
**Impact**: [X PRs merged, Y issues closed, +Z/-W lines changed]

Key accomplishments:
- [accomplishment with specific metrics, e.g., "Reduced inference latency by 30% (PR #42)"]
- [accomplishment 2]
- [accomplishment 3]

Notable PRs:
- [PR title] ([PR #NNN](url)) - [+X/-Y lines]

#### [Next Initiative]

(repeat the pattern)

### Review Activity

Summarize code review contributions with exact counts:
- Total PRs reviewed: [count]
- Repos reviewed across: [list]
- Notable reviews: [list any large or significant PRs reviewed, with line counts]

### Community and Collaboration

- Issues triaged or responded to: [count]
- Upstream contributions: [list any with links]
- Cross-team collaboration: [note any PRs or issues involving other teams, with links]

### Looking Ahead

Based on open PRs and recent activity patterns, note:
- Work that is still in progress (with links to open PRs)
- Areas that may need continued attention
- Any open blockers or risks

---

### Output Rules

- This report pulls real data only. It does not fabricate or estimate activity.
- Always use exact numbers. Never say "several," "many," or "various." If the count is 0, say 0.
- If GitHub CLI is not authenticated, the report will be limited to local git data. Run `gh auth login` to enable full GitHub scanning.
- For very active quarters, the output may be long. The user can filter by repo or org to narrow scope.
- If data appears incomplete, suggest expanding the search to additional repo directories or checking that the git author email matches across all repos.
- Use the report format specified in `~/.status-config` if one is set. Default to markdown.
