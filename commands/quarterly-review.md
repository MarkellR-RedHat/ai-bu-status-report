# Quarterly Review Generator

Generate a quarterly summary that is ready for performance reviews, planning docs, and stakeholder presentations. Every initiative quantified, every accomplishment linked to evidence, every trend backed by data.

## Arguments

$ARGUMENTS can be used to specify:
- A specific quarter (e.g., "Q1 2025", "Q4 2024")
- A custom date range (e.g., "2024-10-01 to 2024-12-31")
- A repo filter (e.g., "repo:ai-bu-hub-build")
- An org filter (e.g., "org:MarkellR-RedHat")
- A narrative focus (e.g., "focus:performance-review" or "focus:planning")

If no arguments are provided, default to the past 90 days.

## Config File Support

Before starting, check if `~/.status-config` exists. If it does, read it and apply any defaults (repos, org, format). Config values are overridden by explicit $ARGUMENTS.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Thinking Process

Before generating any output, work through this chain of thought silently:

1. **Build the complete picture**: Gather all data before drawing any conclusions. A quarter is long enough that early-quarter work is easy to forget.
2. **Identify initiatives, not repos**: Group by what was accomplished, not where the code lives. A single initiative may span 5 repos.
3. **Quantify impact, not effort**: "Shipped 3 features" matters. "Made 200 commits" does not, unless those commits tell a story about sustained effort on a hard problem.
4. **Find the narrative arc**: Did the quarter start with foundation-building and end with shipping? Did scope change mid-quarter? Did a production incident redirect priorities? Tell that story.
5. **Self-critique**: Would you be proud to show this to your skip-level? Does every accomplishment have evidence? Does every initiative section answer "so what?"

## Anti-Patterns to Avoid

Do NOT:
- Pad the report with minor commits to make the quarter look busier
- List repos as "initiatives" (repos are implementation details; initiatives are outcomes)
- Say "contributed to" without specifying the exact contribution and its impact
- Report commit counts as an accomplishment (commits are effort, not outcomes)
- Omit areas where nothing was accomplished (that is useful information for planning)
- Use "various improvements" or "multiple bug fixes" without listing each one
- Separate "What I Did" from "Why It Mattered" (combine them in every bullet)

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

# Week-by-week commit counts for trend analysis
git log --since="<start_date>" --until="<end_date>" --author="<user>" --format="%aI" --no-merges
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

### Step 4: Identify Initiatives (Not Repos)

Group all activity by outcome, not location. Think in terms of:
- What problems were solved?
- What capabilities were delivered?
- What was the before and after?

For example:
- "Inference Gateway" might span llm-d, llm-d-inference-sim, and helm-charts repos
- "Developer Onboarding" might span docs, examples, and CI repos
- "Platform Reliability" might span monitoring, alerting, and infrastructure repos

Use repo names, PR titles, and commit messages to identify these groupings. Merge small clusters into broader initiatives when they tell a better story.

### Step 5: Calculate Impact Metrics

For each initiative, calculate:
- Total PRs opened, merged, and reviewed
- Total issues closed
- Lines of code added and removed
- Number of repos touched
- Time span (first commit to last merge in this initiative)

At the overall level, compute:
- Total commits across all repos
- Week-over-week activity trend with direction
- Busiest week and quietest week
- Average PR cycle time (created to merged) in days
- PR merge rate (merged / opened as a percentage)

### Step 6: Build the Velocity Trend

Calculate weekly commit/PR counts across the quarter to show trajectory:

```
Week 1:  ████████░░ 8
Week 2:  ██████████ 12
Week 3:  ██████░░░░ 6
...
Week 13: ████████████ 14
```

Use Unicode block characters to create a visual trend line.

### Step 7: Generate the Quarterly Report

Output the report in this structure:

---

## Quarterly Summary

**Period**: [start date] to [end date]
**Author**: [git user name]
**Repos**: [total count] repositories across [X] initiatives

### Executive Narrative

Write 3-5 sentences that tell the story of the quarter. Use the SCQA framework internally:
- What was the situation at the start of the quarter?
- What challenges or opportunities drove the work?
- What was delivered?
- What does it mean for next quarter?

This section should be ready to paste into a performance review or planning document without edits.

### Quarter at a Glance

| Metric | Count |
|--------|-------|
| Total Commits | X |
| PRs Opened | X |
| PRs Merged | X |
| PR Merge Rate | X% |
| PRs Reviewed | X |
| Issues Closed | X |
| Repos Contributed To | X |
| Lines Added | +X |
| Lines Removed | -X |
| Avg PR Cycle Time | X days |

### Velocity Trend

```
[Week-by-week activity chart using Unicode blocks]
```

**Trend**: [Increasing / Steady / Decreasing / Variable] - [one sentence explaining the pattern, e.g., "Ramp-up in weeks 1-4 as foundation was laid, followed by steady shipping velocity through weeks 5-13."]

### Initiatives

For each identified initiative, ordered by impact:

#### [Initiative Name]

**Repos**: [list of repos involved]
**Timeline**: [first activity] to [last activity]
**Impact**: [X PRs merged, Y issues closed, +Z/-W lines changed]

**What was delivered**:
- [Accomplishment with specific metric and business impact] ([PR #NNN](url))
- [Accomplishment with specific metric and business impact] ([PR #NNN](url))
- [Accomplishment with specific metric and business impact] ([PR #NNN](url))

**Why it matters**: [2-3 sentences connecting this work to team or business goals. What is possible now that was not possible before?]

#### [Next Initiative]

(repeat the pattern)

### Review Contributions

Summarize code review impact:

| Metric | Count |
|--------|-------|
| Total PRs Reviewed | X |
| Repos Reviewed Across | X |
| Lines Reviewed (approx) | X |

Notable reviews (large scope, significant feedback, or cross-team):
- [PR title] ([PR #NNN](url)) - [what was reviewed and any significant feedback given]

### Collaboration and Community

- Upstream contributions: [count with links]
- Cross-team PRs reviewed: [count]
- Issues triaged for others: [count]
- Conference talks or blog posts: [list with links]

If none in a category, omit that category rather than writing "0."

### Looking Ahead

Based on open PRs, assigned issues, and activity patterns:
- **Carrying into next quarter**: [Open work that will continue, with links]
- **Risks to watch**: [Specific risks with context]
- **Recommended focus areas**: [Based on gap analysis, what should get more attention?]

---

### Final Quality Check

Before outputting, verify:
1. The Executive Narrative could be pasted into a performance review document today. If not, rewrite it.
2. Every initiative answers "what was delivered" AND "why it matters." Both are required.
3. The Velocity Trend tells a story, not just shows numbers.
4. No initiative section is padded with trivial items. If an initiative had 1 significant accomplishment and 5 minor ones, lead with the significant one and summarize the rest.
5. The "Looking Ahead" section is actionable, not aspirational.
6. All numbers are exact. Zero fabrication.

### Output Rules

- This report pulls real data only. It does not fabricate or estimate activity.
- Always use exact numbers. Never say "several," "many," or "various." If the count is 0, say 0.
- If GitHub CLI is not authenticated, the report will be limited to local git data. Run `gh auth login` to enable full GitHub scanning.
- For very active quarters, focus on the top 5-7 initiatives. Group minor work into an "Other Contributions" section.
- Use the report format specified in `~/.status-config` if one is set. Default to markdown.
- Write in active voice throughout. "Shipped," "Delivered," "Closed," not passive constructions.
- If the focus is "performance-review," emphasize impact and growth. If "planning," emphasize trajectory and gaps.
