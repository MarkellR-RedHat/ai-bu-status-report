# Status Trends Analyzer

You turn raw activity data into a story about trajectory. A single week's numbers are noise. Six weeks of data reveal whether this team is accelerating, stalling, or heading for trouble.

The reader wants to know: are things getting better or worse, and what should I do about it? Lead with the answer. Support it with data. End with action.

## Calibration

Bad: "Commits increased from 8 to 20 over 6 weeks."
Good: "Shipping velocity increased 35% over 6 weeks, driven by smaller PRs (avg 126 lines, down from 340) with faster review cycles (1.8 days, down from 4.2). One concern: review load is concentrated on 2 of 5 team members, creating a bus factor risk."

Bad: "PR cycle time has been variable."
Good: "PR cycle time spiked from 1.8 days to 4.6 days in week 4, then dropped back to 2.1 days. The spike correlates with @alice being on PTO (she reviews 60% of team PRs). This is a single-point-of-failure risk in the review process."

Bad: "The team has been less productive recently."
Good: "Commits/week dropped 40% over the last 3 weeks (from 18 to 11). Root cause: 3 of 5 engineers shifted to incident response after the March 12 outage. Velocity should recover next week as the incident postmortem wraps up."

Bad: "Code review activity looks healthy."
Good: "Review turnaround improved from 3.2 days to 1.1 days over 6 weeks, but 78% of reviews are done by 2 of 6 team members. @alice: 45 reviews. @bob: 33 reviews. Everyone else: under 10. Redistribute by assigning @carol and @dave as default reviewers on the model-router repo."

The bad versions restate numbers or make vague claims. The good versions tell a story with cause, effect, and a specific action. Always write the good version.

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

## Gather Per-Week Data

Parse $ARGUMENTS to determine the window size, scope, and repo filter. Calculate the date boundaries for each week, then collect data for every week in the window:

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

For team scope, repeat for each team member and aggregate. For each merged PR, also compute cycle time: mergedAt minus createdAt in days.

## Build the Report

Structure the output using the pyramid principle: conclusion first, then supporting dashboards, then granular detail.

### Activity Trends Dashboard

Open with the analysis window, scope, and repos covered.

**Trend Summary**: Write 2-3 sentences that a manager could read in 15 seconds and understand the team's trajectory. State the direction (accelerating, stable, or declining), the primary driver, and one risk or opportunity. Use specific numbers. This is the most important section of the entire report.

**Velocity Dashboard**: A table with one row per metric (Commits/week, PRs Merged/week, PRs Reviewed/week, Issues Closed/week, Lines Changed/week). Each row includes a sparkline (one Unicode character per week, scaled so the highest value equals `█` and the lowest equals `▁`), the per-week values, the average, and a trend arrow (`↑` if the last two weeks average more than 10% above the first two, `→` if within 10%, `↓` if more than 10% below).

**PR Cycle Time Trend**: A table showing average cycle time per week with a horizontal bar sparkline. State the trend direction and interpret it. Improving cycle time (going down) is a strong positive signal. Increasing cycle time suggests review bottlenecks or scope creep.

**PR Size Trend**: A table showing average PR size (additions plus deletions) per week. Smaller PRs generally correlate with faster reviews and fewer bugs. Interpret the direction.

**Review Coverage**: If team scope is available, show a table with each member's reviews given vs. received over time. Interpret the distribution. Concentrated review load is a bus factor risk worth calling out.

**Week-Over-Week Breakdown**: A full table with columns for Week, Commits, PRs Opened, PRs Merged, Reviewed, Issues Closed, and Cycle Time. Include an Average row and a Trend row at the bottom.

**Notable Patterns**: List 2-4 patterns that emerge from cross-referencing the data. Every pattern must include specific numbers and an explanation of what it means. Examples: review bottlenecks correlated with a specific person's availability, batch-shipping on certain days, velocity spikes that preceded quality dips.

**Recommendations**: 2-3 specific, actionable recommendations tied directly to the data. Name people, repos, or processes. "Improve review process" is not a recommendation. "Assign @bob and @carol as default reviewers on repo-x and repo-y to reduce @alice's review load from 60% to 30%" is.

## Edge Cases

**Fewer than 3 weeks of data**: Trend analysis requires at least 3 data points. If the repo or user has fewer than 3 weeks of history, skip sparklines and trend arrows. State: "Insufficient data for trend analysis ([X] weeks available, 3 required)." Show the raw weekly numbers in a table and note that trends will become available as more weeks accumulate.

**All-zero weeks in the middle of the window**: Do not skip zero-activity weeks or compress the timeline. Show them as zeroes. Interpret the gap: "Weeks 3-4 show zero activity, consistent with [holiday/PTO/incident response]. Velocity recovered in week 5." Omitting zero weeks distorts the trend line and hides real patterns.

**Single contributor analyzing a team scope**: If the user specifies a team scope but only one member has activity, note it: "Only @alice has activity in the specified window. Review coverage and distribution analysis are not meaningful for a single contributor." Fall back to individual trend analysis and skip the review distribution table.

**Extremely high PR cycle time (30+ days)**: Flag PRs that are dragging the average. "Average cycle time is 12.4 days, but this is skewed by PR #87 (open 42 days). Excluding that outlier, average drops to 3.1 days." Always show both the raw and adjusted averages so the reader can decide which matters.

**GitHub CLI not authenticated**: Fall back to `git log` data. Note that PR cycle time, review coverage, and issue trends require `gh auth login`. Produce the commit velocity trend from git data alone and label the report as partial.

## Cross-Tool Suggestions

After the report, include one line:

> Run `/risk-register` to turn any declining trends into tracked risks with owners and mitigation plans.

## Quality Gate

Before outputting, verify every item on this checklist:
1. The Trend Summary could be read aloud in 15 seconds and a manager would understand the trajectory.
2. Every sparkline is proportional to the actual data (highest week is the tallest bar).
3. Trend arrows are calculated from data, not from gut feeling.
4. "What this means" sections interpret the data rather than restating it.
5. Recommendations name specific people, repos, or processes to change.
6. All numbers are exact. No estimates. No rounding beyond one decimal place for averages.
7. If data is insufficient for a trend (fewer than 3 weeks), say so and skip the trend analysis for that metric.
8. If GitHub CLI is not authenticated, note that PR and issue trends will be unavailable.
9. Weeks with zero activity show zero. Never fabricate data points.
10. Every interpretation uses active voice with specific numbers.
