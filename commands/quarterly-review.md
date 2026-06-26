# Quarterly Review Generator

You turn a quarter of engineering work into a narrative ready to paste into a performance review or planning document. A quarterly review is not a commit log. It is a story about what changed because of this person's work.

The person reading this is deciding promotions, allocations, or next-quarter priorities. They need to understand impact, not activity.

## Calibration

Bad: "Made 200 commits across 5 repos."
Good: "Shipped the inference gateway from prototype to production-ready, reducing model serving costs by 20% and enabling 3 enterprise deployments. This required redesigning the scheduling architecture, building a load testing framework, and coordinating with 2 platform teams."

Bad: "Worked on multiple projects and contributed to team goals throughout the quarter."
Good: "Led 2 initiatives spanning 4 repos: (1) model router v2 cut request routing from 45ms to 8ms, handling 10x the previous concurrent load; (2) batch inference pipeline shipped to 12 customers, processing 2M requests/day with 99.97% uptime."

Bad: "Reviewed many PRs and helped onboard new team members."
Good: "Reviewed 47 PRs (2nd highest on the team), caught 3 bugs that would have caused production incidents. Onboarded 2 engineers to the inference codebase; both shipped their first PRs within 2 weeks."

Bad: "Participated in the incident response process."
Good: "Led incident response for the March 12 model serving outage (4h customer impact). Root cause: connection pool exhaustion under load spike. Shipped fix in PR #189, added circuit breaker, and wrote runbook that was used twice in Q2 with zero customer impact."

The difference: outcomes linked to business value, not activity counts divorced from meaning.

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

## How to Think About This

Before generating any output, work through this chain of thought silently:

1. **Build the complete picture**: Gather all data before drawing any conclusions. A quarter is long enough that early-quarter work is easy to forget.
2. **Identify initiatives, not repos**: Group by what was accomplished, not where the code lives. A single initiative may span 5 repos.
3. **Lead with the narrative**: Apply the pyramid principle. Write the executive story first (3-5 sentences capturing the quarter's arc), then support it with initiatives and metrics. The reader should understand the quarter's significance after the first paragraph alone.
4. **Find the narrative arc**: Did the quarter start with foundation-building and end with shipping? Did scope change mid-quarter? Did a production incident redirect priorities? Surface that story.
5. **Quantify impact, not effort**: "Shipped 3 features" matters. "Made 200 commits" does not, unless those commits tell a story about sustained effort on a hard problem.
6. **Self-critique for the reader**: Would the reader walk away knowing what to fund, promote, or prioritize? Does every accomplishment have evidence? Does every initiative section answer "so what?"

## Anti-Patterns to Avoid

Do NOT:
- Pad the report with minor commits to make the quarter look busier
- List repos as "initiatives" (repos are implementation details; initiatives are outcomes)
- Say "contributed to" without specifying the exact contribution and its impact
- Report commit counts as an accomplishment (commits are effort, not outcomes)
- Omit areas where nothing was accomplished (that is useful information for planning)
- Use "various improvements" or "multiple bug fixes" without listing each one
- Separate "What I Did" from "Why It Mattered" (combine them in every bullet)

## Step 1: Determine Timeframe

Parse $ARGUMENTS to figure out the date range:
- "Q1 2025" maps to 2025-01-01 through 2025-03-31
- "Q2 2025" maps to 2025-04-01 through 2025-06-30
- "Q3 2025" maps to 2025-07-01 through 2025-09-30
- "Q4 2025" maps to 2025-10-01 through 2025-12-31
- If a custom range is given, use those dates directly
- If nothing is specified, use the last 90 days

## Step 2: Gather All Git Activity

```bash
git config user.email
git config user.name
git log --since="<start_date>" --until="<end_date>" --author="<user>" --pretty=format:"%h %s (%ai)" --no-merges
git log --since="<start_date>" --until="<end_date>" --author="<user>" --stat --no-merges
git log --since="<start_date>" --until="<end_date>" --author="<user>" --oneline --no-merges | wc -l
git log --since="<start_date>" --until="<end_date>" --author="<user>" --format="%aI" --no-merges
```

## Step 3: Gather All GitHub Activity

```bash
gh search prs --author=@me --created="<start_date>..<end_date>" --limit=200 --json title,url,state,repository,createdAt,mergedAt,additions,deletions
gh search prs --reviewed-by=@me --created="<start_date>..<end_date>" --limit=200 --json title,url,state,repository,createdAt
gh search issues --author=@me --closed="<start_date>..<end_date>" --limit=200 --json title,url,repository,closedAt
gh search issues --commenter=@me --updated="<start_date>..<end_date>" --limit=200 --json title,url,repository,updatedAt
```

## Step 4: Identify Initiatives and Build the Narrative

Group all activity by outcome, not location. Think in terms of: What problems were solved? What capabilities were delivered? What was the before and after? Use repo names, PR titles, and commit messages to identify groupings. Merge small clusters into broader initiatives when they tell a better story.

For each initiative, calculate: total PRs opened/merged/reviewed, issues closed, lines added/removed, repos touched, and time span. At the overall level, compute: total commits, week-over-week activity trend, busiest and quietest weeks, average PR cycle time, and PR merge rate.

## Step 5: Generate the Report

Apply the pyramid principle throughout. The executive narrative comes first and carries the weight. Everything after it is supporting evidence.

---

## Quarterly Summary

**Period**: [start date] to [end date]
**Author**: [git user name]
**Repos**: [total count] repositories across [X] initiatives

### Executive Narrative

Write 3-5 sentences that tell the story of the quarter. This is the most important section. A reader who stops here should still understand the quarter's significance. Use the SCQA framework internally: What was the situation at the start? What challenges or opportunities drove the work? What was delivered? What does it mean for next quarter?

This section must be ready to paste into a performance review or planning document without edits. Write in active voice. Focus on what changed in the world because of this person's work.

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

Build a week-by-week chart using Unicode block characters to show trajectory.

**Trend**: [Increasing / Steady / Decreasing / Variable] with one sentence explaining the pattern, connecting it to the initiative timeline above.

### Initiatives

For each identified initiative, ordered by impact (not chronology):

#### [Initiative Name]

**Repos**: [list] | **Timeline**: [first activity] to [last activity] | **Impact**: [X PRs merged, Y issues closed, +Z/-W lines changed]

**What was delivered and why it matters**:
- [Accomplishment with specific metric and business impact] ([PR #NNN](url))
- [Accomplishment with specific metric and business impact] ([PR #NNN](url))

Each bullet must combine the what and the so-what. Never separate them.

### Review Contributions

Summarize code review impact with a table (total PRs reviewed, repos reviewed across, approximate lines reviewed). Highlight notable reviews: large scope, significant feedback, or cross-team collaboration.

### Collaboration and Community

Include upstream contributions, cross-team PRs reviewed, issues triaged for others, and conference talks or blog posts. Omit any category with zero items rather than writing "0."

### Looking Ahead

Based on open PRs, assigned issues, and activity patterns:
- **Carrying into next quarter**: Open work that will continue, with links
- **Risks to watch**: Specific risks with context
- **Recommended focus areas**: Based on gap analysis, what should get more attention

---

## Edge Cases

**Quarter with zero merged PRs**: Do not generate a padded narrative. State it: "No PRs merged during [quarter]." Then look for non-code contributions: issues triaged, reviews given, design docs authored, or planning artifacts. If the quarter was genuinely quiet (leave, reorg, ramp-up), say so directly. A performance reviewer would rather read "Joined the team mid-quarter; ramped on codebase and shipped first PR in week 10" than a fabricated impact story.

**Cross-org contributions that `gh` cannot see**: If the user contributed to repos outside their org (upstream Kubernetes, community operators, vendor forks), note that `gh search` only covers repos the authenticated user can access. Recommend the user supply additional repo URLs via arguments or list upstream contributions manually. Do not silently omit them.

**Quarter spanning a reorg or team change**: Group initiatives by the team context they happened in. If the user moved teams mid-quarter, split the narrative: "Weeks 1-6 on Platform (shipped X). Weeks 7-13 on Inference (shipped Y)." A single blended narrative hides the transition and misrepresents both halves.

**Massive commit volume (500+ commits)**: Summarize at the initiative level. Do not list every commit. Call out the total for context ("412 commits across 3 repos") and focus the narrative on the 3-5 highest-impact initiatives. Warn the user that gathering this volume may take longer.

**No GitHub access (`gh` not authenticated)**: Fall back to `git log` data only. Note that PR cycle time, review contributions, and issue metrics are unavailable. Recommend `gh auth login` to unlock the full report.

## Cross-Tool Suggestions

After the report, include these lines:

> Run `/status-trends` to see week-over-week velocity for any quarter that looks uneven.
>
> Run `/cfp-generator` to turn a strong quarter into a conference talk proposal (from [ai-bu-cfp-generator](https://github.com/MarkellR-RedHat/ai-bu-cfp-generator)).

## Final Quality Check

Before outputting, verify:
1. The Executive Narrative could be pasted into a performance review document today. If not, rewrite it.
2. Every initiative answers "what was delivered" AND "why it matters" in the same breath.
3. No initiative section is padded with trivial items. Lead with significance, summarize the rest.
4. The report tells the story of a quarter, not a list of things that happened during one.
5. All numbers are exact. Zero fabrication. Active voice throughout.
6. Use the report format specified in `~/.status-config` if one is set. Default to markdown.
7. If the focus is "performance-review," emphasize impact and growth. If "planning," emphasize trajectory and gaps.
