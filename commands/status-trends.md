# Status Trends Analyzer

Analyze multiple weeks of git and GitHub activity to surface trends that single-week reports miss. Is velocity increasing or declining? Are PR cycle times improving or degrading? Is review coverage expanding or concentrating? This command turns raw activity into a trends dashboard with visual indicators and "what this means" analysis.

## Arguments

$ARGUMENTS can specify:
- Number of weeks to analyze (e.g., "8 weeks", "12 weeks"). Defaults to 6 weeks.
- A repo filter (e.g., "repo:my-org/my-repo")
- A team scope (e.g., "org:my-org" or "users:alice,bob,carol")
- Specific metrics to focus on (e.g., "focus:velocity" or "focus:review-time" or "focus:all")

If no arguments are provided, defaults to 6 weeks of the current user's activity across all accessible repos.

## Config File Support

Check if `~/.status-config` exists. If it does, read it for defaults.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Thinking Process

Before generating any output, work through this chain of thought silently:

1. **Collect per-week data**: Break the analysis window into weekly buckets. For each week, count commits, PRs opened, PRs merged, issues closed, and lines changed.
2. **Calculate rates of change**: Is each metric going up, down, or flat week over week? A single bad week is noise. Three declining weeks is a trend.
3. **Identify inflection points**: Did anything change dramatically? A week with 2x the normal commits might indicate a crunch. A week with zero PRs merged might indicate a blocker.
4. **Correlate metrics**: If commits are up but merges are down, PRs might be stuck in review. If merges are up but lines changed are down, the team might be shipping smaller, faster PRs (usually good).
5. **Self-critique**: Does the analysis tell a story or just restate numbers? Every trend should have a "what this means" interpretation.

## Instructions

### Step 1: Determine Analysis Window

Parse $ARGUMENTS to extract:
- **Window size**: Default to 6 weeks. Support "4 weeks", "8 weeks", "12 weeks", "this quarter".
- **Scope**: Individual user, team, or org.
- **Repo filter**: If specified, scope all queries.

Calculate the date boundaries for each week in the window.

### Step 2: Gather Per-Week Data

For each week in the analysis window, gather:

```bash
# Commits per week
git log --since="<week_start>" --until="<week_end>" --author="<user>" --oneline --no-merges | wc -l

# Lines changed per week
git log --since="<week_start>" --until="<week_end>" --author="<user>" --no-merges --shortstat

# PRs opened per week
gh search prs --author=@me --created="<week_start>..<week_end>" --json title,url,state,repository,createdAt,additions,deletions

# PRs merged per week
gh search prs --author=@me --merged="<week_start>..<week_end>" --json title,url,repository,mergedAt,createdAt

# PRs reviewed per week
gh search prs --reviewed-by=@me --created="<week_start>..<week_end>" --json title,url,repository

# Issues closed per week
gh search issues --assignee=@me --closed="<week_start>..<week_end>" --json title,url,repository
```

For team scope, repeat for each team member and aggregate.

### Step 3: Calculate PR Cycle Time Trend

For each week's merged PRs, calculate the average time from creation to merge:

```bash
# For each merged PR, compute: mergedAt - createdAt in days
# Average across all PRs merged that week
```

Track this week over week. Improving cycle time (going down) is a strong positive signal. Increasing cycle time (going up) indicates review bottlenecks or scope creep.

### Step 4: Generate Sparkline Charts

Use Unicode block characters to create visual trend lines. Use these characters for the sparklines:

- Full blocks for filled bars: ` ` `░` `▒` `▓` `█`
- For inline sparklines: `▁` `▂` `▃` `▄` `▅` `▆` `▇` `█`

Scale each metric to fit the available characters. The highest value in the series = `█`, the lowest = `▁`.

### Step 5: Calculate Trend Indicators

For each metric, compute:
- **Direction**: Compare the last 2 weeks' average to the first 2 weeks' average
- **Indicator**: Use arrows to show direction
  - `↑` Increasing (last 2 weeks avg > first 2 weeks avg by more than 10%)
  - `→` Stable (within 10% either way)
  - `↓` Decreasing (last 2 weeks avg < first 2 weeks avg by more than 10%)
- **Verdict**: One sentence explaining what the trend means

### Step 6: Generate the Trends Dashboard

Output the report in this structure:

---

## Activity Trends Dashboard

**Analysis Window**: [start date] to [end date] ([X weeks])
**Scope**: [user / team / org name]
**Repos**: [list or count]

### Trend Summary

Write 2-3 sentences interpreting the overall trajectory. Example: "Shipping velocity increased 25% over the past 6 weeks, driven by smaller PRs with faster review cycles. PR merge time improved from 3.2 days to 1.8 days, suggesting the team's review process is maturing. One concern: review load remains concentrated on 2 of 5 team members."

### Velocity Dashboard

```
Metric              Trend    Sparkline              Avg    Direction
Commits/week        ▁▃▅▆▇█   12 > 8 > 15 > 18 > 20   14.6   ↑ Increasing
PRs Merged/week     ▃▃▅▅▇█   3 > 3 > 5 > 5 > 7 > 8   5.2    ↑ Increasing
PRs Reviewed/week   ▇▅▃▃▃▁   8 > 5 > 3 > 3 > 3 > 1   3.8    ↓ Decreasing
Issues Closed/week  ▃▃▃▅▃▃   2 > 2 > 2 > 4 > 2 > 2   2.3    → Stable
Lines Changed/week  ▃▅▇▅▃█   200>400>800>400>200>900  483    ↑ Variable
```

(Adapt the sparkline characters to match actual data. Each sparkline should have one character per week.)

### PR Cycle Time Trend

```
Week        Avg Cycle Time    Sparkline
Week 1      4.2 days          ████████░░
Week 2      3.8 days          ███████░░░
Week 3      3.1 days          ██████░░░░
Week 4      2.5 days          █████░░░░░
Week 5      1.9 days          ████░░░░░░
Week 6      1.8 days          ████░░░░░░
```

**Trend**: [↑ Getting slower / → Stable / ↓ Getting faster]
**What this means**: [Interpretation, e.g., "PR cycle time dropped 57% over 6 weeks. The team is reviewing and merging faster, likely due to smaller PR sizes and better review coverage."]

### PR Size Trend

Track average PR size (additions + deletions) per week:

```
Week        Avg PR Size       Sparkline
Week 1      450 lines         ████████░░
Week 2      320 lines         ██████░░░░
...
```

**Trend**: [Direction]
**What this means**: [Interpretation. Smaller PRs generally correlate with faster reviews and fewer bugs.]

### Review Coverage

If team scope is available:

```
Member          Reviews Given    Reviews Received    Ratio
@alice          ▁▃▅▇██  (avg 6)  ▃▃▃▃▃▃  (avg 3)    2.0x giver
@bob            ▃▃▃▁▁▁  (avg 2)  ▅▅▇▇██  (avg 7)    0.3x giver
```

**What this means**: [Interpretation of review distribution changes over time]

### Week-Over-Week Breakdown

| Week | Commits | PRs Opened | PRs Merged | Reviewed | Issues Closed | Cycle Time |
|------|---------|-----------|-----------|----------|--------------|------------|
| [date range] | X | X | X | X | X | X.X days |
| [date range] | X | X | X | X | X | X.X days |
| ... | | | | | | |
| **Average** | **X** | **X** | **X** | **X** | **X** | **X.X days** |
| **Trend** | **↑/→/↓** | **↑/→/↓** | **↑/→/↓** | **↑/→/↓** | **↑/→/↓** | **↑/→/↓** |

### Notable Patterns

List 2-4 patterns that emerge from the data:

1. **[Pattern name]**: [Description with numbers. E.g., "Review bottleneck: PR cycle time correlates with @alice's availability. Weeks where @alice reviewed fewer than 3 PRs saw average cycle times 2x higher."]
2. **[Pattern name]**: [Description. E.g., "Friday shipping: 40% of PR merges happen on Fridays, suggesting a batch-review pattern. Consider spreading reviews across the week."]

### Recommendations

Based on the trends, provide 2-3 specific, actionable recommendations:

1. **[Recommendation]**: [What to do and why, based on the data. E.g., "Distribute review load: @alice is reviewing 3x more PRs than anyone else. Assign @bob and @carol as default reviewers on 2 repos each to balance the load."]
2. **[Recommendation]**: [Action and justification]

---

### Final Quality Check

Before outputting, verify:
1. Every sparkline accurately represents the data (highest week = tallest bar).
2. Trend arrows are mathematically justified, not vibes-based.
3. "What this means" sections interpret data, not just restate it.
4. Recommendations are specific (name people, repos, or processes to change) not generic ("improve review process").
5. The Trend Summary could be read to a manager in 15 seconds and they would understand the team's trajectory.

### Output Rules

- All numbers are exact. No estimates, no rounding beyond one decimal place for averages.
- Sparklines must be proportional to actual data.
- If data is insufficient for a trend (fewer than 3 weeks), state that and skip the trend analysis for that metric.
- If GitHub CLI is not authenticated, note that PR and issue trends will be unavailable.
- Do not fabricate data points. If a week has zero activity, show zero.
- Write interpretations in active voice with specific numbers.
