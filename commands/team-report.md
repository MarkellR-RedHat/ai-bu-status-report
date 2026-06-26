# Team Status Report Generator

Aggregate status across multiple team members into a report an engineering manager can use in their staff meeting. Shows what shipped, where bottlenecks are, who needs support, and what is coming next.

## Arguments

$ARGUMENTS should specify:
- A GitHub org or team (e.g., "org:openshift" or "team:ai-bu")
- Optionally, a list of GitHub usernames (e.g., "users:alice,bob,carol")
- A timeframe (e.g., "last 2 weeks", "since 2025-06-01"). Defaults to the past 7 days.
- A repo filter (e.g., "repo:my-org/my-repo")
- Focus (e.g., "focus:bottlenecks" or "focus:velocity")

At minimum, either an org/team or a list of usernames is required. If neither is provided, ask the user to specify.

## Config File Support

Check if `~/.status-config` exists. If it does, read it for default org, team members, or repos.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Thinking Process

Before generating any output, work through this chain of thought silently:

1. **Assess team throughput**: Total PRs merged, issues closed, and reviews completed. Is this week's output higher, lower, or the same as a typical week?
2. **Identify bottlenecks**: Are PRs piling up without reviews? Is one person carrying the review load? Are there stale PRs that need attention?
3. **Spot collaboration patterns**: Who is reviewing whose code? Are there silos where people only work in their own repos?
4. **Find the story**: What is the one-sentence summary an engineering manager would use to describe this week's team output?
5. **Self-critique**: Is the report surfacing problems or hiding them? A good team report makes a manager smarter about where to spend their 1:1 time.

## Anti-Patterns to Avoid

Do NOT:
- Report individual metrics without team context (5 PRs is great for a team of 2, mediocre for a team of 15)
- Hide uneven distribution (if one person merged 80% of the PRs, say so, that is a bus factor risk)
- List "no blockers" without checking for stale PRs, unreviewed work, or CI failures
- Report team totals without per-member breakdowns (totals hide distribution problems)
- Include members with zero activity without noting it (zero activity in a week is a signal worth surfacing)
- Treat all PRs as equal (a 5-line config change is not equivalent to a 500-line feature)

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

# Open PRs by this member (for bottleneck detection)
gh search prs --author=<username> --state=open --json title,url,repository,createdAt,reviewDecision
```

If a repo filter is specified, add `--repo=<owner/repo>` to each command.

### Step 3: Analyze Team Dynamics

Beyond raw counts, analyze:
- **Review load distribution**: Who is doing most of the reviews? Is it balanced?
- **PR cycle time per member**: Whose PRs get merged fast? Whose sit?
- **Cross-pollination**: Are team members reviewing each other's code, or is it siloed?
- **Unreviewed work**: Any PRs open more than 3 days without a review?

### Step 4: Aggregate and Summarize

Combine all data across team members. Calculate:
- Total PRs opened, merged, and reviewed across the team
- Total issues closed
- Total lines added and removed
- Per-person breakdown with contribution percentages
- Most active repos
- Average PR age for open PRs

### Step 5: Generate the Team Report

Output the report in this structure:

---

## Team Status Report

**Period**: [start date] to [end date]
**Team**: [org or team name]
**Active Members**: [count] of [total team size] contributed this period

### Team Summary

Write 2-3 sentences summarizing the team's week. Lead with what shipped. Note any capacity or bottleneck concerns. Use this pattern: "The team shipped [X], closing [Y issues] across [Z repos]. [Highlight or concern]. [What is next or what needs attention]."

### Team Metrics

| Metric | Count | Per Member Avg |
|--------|-------|----------------|
| PRs Opened | X | X.X |
| PRs Merged | X | X.X |
| PRs Reviewed | X | X.X |
| Issues Closed | X | X.X |
| Lines Added | +X | |
| Lines Removed | -X | |
| Open PRs (end of period) | X | |
| Avg PR Age (open) | X days | |

### What Shipped

Group merged PRs by initiative or outcome, not by person. Lead with the highest-impact items.

**[Initiative or Outcome]**
- **[PR title]** ([PR #NNN](url)) - @[author], +X/-Y lines
  - Impact: [one sentence on what this delivers or unblocks]

### Bottleneck Report

This section surfaces problems an engineering manager needs to act on.

**Unreviewed PRs** (open more than 3 days without review):

| PR | Author | Days Open | Action Needed |
|----|--------|-----------|---------------|
| [title](url) | @author | X days | Assign reviewer |

**Review Load Distribution**:

| Member | PRs Authored | PRs Reviewed | Review Ratio |
|--------|-------------|-------------|--------------|
| @alice | 3 | 8 | 2.7x |
| @bob | 5 | 1 | 0.2x |

Flag imbalances: "Review load is concentrated: @alice reviewed 60% of all PRs this period. Consider redistributing review assignments."

**Failing CI**: List any open PRs with failing checks, with the specific failure.

### Per-Member Summary

| Member | PRs Merged | PRs Reviewed | Issues Closed | Lines Changed | Status |
|--------|-----------|-------------|---------------|---------------|--------|
| @alice | 3 | 5 | 2 | +450/-120 | Active |
| @bob | 1 | 3 | 4 | +80/-30 | Active |
| @carol | 0 | 0 | 0 | 0 | [No activity - check in recommended] |

For members with zero activity, note it explicitly. This is a signal for managers, not a judgment.

### In Progress

List open PRs across the team, ordered by age (oldest first):

| PR | Author | Days Open | Reviewers | Status |
|----|--------|-----------|-----------|--------|
| [title](url) | @author | X days | @reviewer or "None" | [Waiting for review / Changes requested / Approved] |

### What Is Next

Based on open issues assigned to team members:
- [Issue/item] - assigned to @member, [milestone if any]

### Manager Action Items

Based on the data, recommend specific actions:
- [ ] Assign reviewer to [PR #NNN] (open X days, no reviewer)
- [ ] Check in with @member (no activity this period)
- [ ] Redistribute review load (currently concentrated on @member)
- [ ] Investigate CI failure on [PR #NNN]

If no action items, state "No immediate action items identified."

---

### Final Quality Check

Before outputting, verify:
1. The Team Summary could be read aloud in a staff meeting. If it is too technical or too vague, rewrite it.
2. The Bottleneck Report surfaces real problems, not just metrics. If a PR has been open 10 days, that is a problem worth calling out.
3. Zero-activity members are noted, not hidden. This is not punitive; it is informational.
4. Manager Action Items are specific and actionable, not generic advice.
5. Per-member percentages add up. Totals match.
6. The "What Shipped" section groups by outcome, not by person.

### Output Rules

- Only report data that exists. Do not fabricate activity for any team member.
- Always use exact numbers. Never approximate with words like "several" or "a few."
- If a team member has no activity in the period, include them with zeros and flag it.
- If the org member list is too large (more than 25 people), ask the user to provide a specific list of usernames or filter by repo.
- If GitHub CLI is not authenticated or lacks org permissions, inform the user and suggest: `gh auth login` and verify org access.
- Write in active voice throughout.
