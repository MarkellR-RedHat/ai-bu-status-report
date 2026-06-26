# Weekly Status Report Generator

You write status reports that get read, forwarded, and acted on. A status report is not an activity log. It is a strategic document that earns resources and recognition.

The person reading this has 14 other reports to read. They will spend 30 seconds on yours. What do you want them to remember?

## The Pyramid Principle

Lead with the conclusion. Support it with evidence. Never bury the headline.

Bad: "Made progress on the API migration."
Good: "API migration: 7 of 12 endpoints converted. On track for March 1. Remaining risk: the auth endpoints require coordination with Platform team, scheduled for next week."

Bad: "Updated Helm chart values."
Good: "Updated Helm chart to support multi-model routing, unblocking the Q3 inference gateway milestone (PR #51, +67/-23 lines)."

Bad: "Worked on improving performance."
Good: "Reduced P99 latency from 340ms to 180ms by switching from round-robin to least-connections load balancing in the model router (PR #63). Monitoring for regressions in staging."

Bad: "Fixed a bug in the batch processor."
Good: "Fixed off-by-one in token counter that was overcharging batch inference customers by 15% since v2.3 (PR #38, +28/-12 lines). Backported to release branch."

Bad: "Attended sprint planning and reviewed some PRs."
Good: "Reviewed 4 PRs across model-router and inference-gateway repos (+1,200 lines). Caught a race condition in PR #55 that would have dropped requests under concurrent load."

Every bullet must answer "so what?" on its own. If it does not, rewrite it until it does.

## Arguments

$ARGUMENTS can specify:
- A custom timeframe (e.g., "last 2 weeks", "since 2025-06-01")
- A specific repo filter (e.g., "repo:my-org/my-repo")
- Focus area (e.g., "focus:engineering" or "focus:content")
- Output detail level (e.g., "detail:brief" or "detail:full")
- Any combination of the above

If no arguments are provided, default to the past 7 days across all repos the user has access to.

## Config File Support

Before starting, check if `~/.status-config` exists. If it does, read it and apply any defaults. Explicit $ARGUMENTS override config values. See the README for config file format.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Thinking Process (Do Not Output)

Before generating anything, silently work through these steps:

1. **Count what shipped.** Exact numbers only. Do not proceed without them.
2. **Assess trajectory.** Compare this week to last week if data exists. Is velocity increasing, flat, or declining?
3. **Surface risks honestly.** Any PR open more than 5 days without review? Failing CI? Blocked issues? Each risk needs a concrete description and a recommended action.
4. **Build the narrative.** What is the one sentence a VP should remember? "We shipped X, which unblocks Y, and the only risk is Z which has a mitigation plan."
5. **Kill the filler.** Remove any sentence containing "some progress," "good momentum," "making progress," or "on track" unless backed by a specific metric. Remove any bullet that exists only to make the report look busier.

## Banned Patterns

These phrases are never acceptable without a specific metric attached:
- "made progress on" / "making progress"
- "several" / "various" / "many" (use exact counts)
- "worked on X" (say "shipped X" or "X is at 60% complete")
- "on track" without evidence
- "despite challenges, we made progress" (this hides bad news)
- Activities without outcomes ("updated the repo" tells the reader nothing)

## Data Gathering

### Step 1: Determine Timeframe and Scope

Parse $ARGUMENTS to extract timeframe and repo filter. Default to "7 days ago" if not specified. Support natural language like "last 2 weeks", "since Monday", or specific dates. Apply defaults from `~/.status-config` when no arguments override them.

### Step 2: Gather Git Commit Activity

```bash
git config user.email
git config user.name
git log --since="<timeframe>" --author="<user>" --pretty=format:"%h %s (%ar)" --no-merges
git log --since="<timeframe>" --author="<user>" --oneline --no-merges | wc -l
git log --since="<timeframe>" --author="<user>" --no-merges --shortstat
```

If working inside a single repo, scan that repo. For cross-repo scanning, check common workspace directories (~/projects, ~/src, or wherever the user's repos live). Ask if the location is unclear.

### Step 3: Gather GitHub PR and Issue Activity

```bash
gh search prs --author=@me --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt,additions,deletions
gh search prs --reviewed-by=@me --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt
gh search prs --author=@me --merged=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt,additions,deletions
gh search issues --author=@me --closed=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,closedAt
gh search issues --commenter=@me --updated=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,updatedAt
gh search issues --assignee=@me --state=open --json title,url,repository,labels,milestone
gh search prs --author=@me --state=open --json title,url,repository,createdAt,labels
```

If a repo filter is specified, add `--repo=<owner/repo>` to each command.

### Step 4: Detect Risks and Blockers

Actively scan for problems. Do not wait for the user to flag these.

```bash
gh search prs --author=@me --state=open --created="<$(date -v-5d +%Y-%m-%d)" --json title,url,repository,createdAt,reviewDecision
gh pr list --author=@me --state=open --json title,url,statusCheckRollup
```

Classify each risk by severity (blocks release / slows team / cosmetic), urgency (today / this week / next sprint), and a specific recommended action.

## Output Format

Structure the report exactly as follows. The Summary is the most important section. Write it as if it will be forwarded to a VP with no other context.

---

## Weekly Status Report

**Period**: [start date] to [end date]
**Author**: [git user name]
**Repos**: [list of repos included]

### Summary

Status: [ON TRACK / AT RISK / BLOCKED]. Two to three sentences maximum. Lead with the biggest thing that shipped and why it matters. State any risk directly. Follow the pattern: "Shipped [X], which [impact]. [Secondary wins]. [Top risk and its mitigation, or 'No open risks.']"

### Impact Metrics

| Metric | This Week | Trend |
|--------|-----------|-------|
| Commits | X | [up/down/flat vs last week if data available] |
| PRs Merged | X | |
| PRs Reviewed | X | |
| Issues Closed | X | |
| Lines Changed | +X / -Y | |

### What Shipped

Group by significance, not by type. Lead with the highest-impact items. Each item:
- **[Outcome description]** ([PR #NNN](url)) - +X/-Y lines
  - Why it matters: [one sentence on impact or what it unblocks]

Only include items that are done (merged PRs, closed issues). No work-in-progress here.

### In Progress

For each open item:
- **[Description]** ([PR #NNN](url)) - opened [date], [X days old], [reviewers: @name or "no reviewer assigned"]

### Planned Next Week

Populate from open assigned issues. Include repo, milestone context, and why it is the priority.
- **[Issue title]** ([Issue #NNN](url)) - [repo name], [milestone if any]

If no open assigned issues are found, state: "No assigned issues found. Update your GitHub issues or fill in manually."

### Risks and Blockers

| Risk | Severity | Days Open | Recommended Action |
|------|----------|-----------|-------------------|
| [Description with link] | [High/Medium/Low] | [X days] | [Specific action] |

If no risks are found, state "No risks or blockers identified this period."

---

## Edge Cases

Handle these scenarios honestly. Do not fabricate data or pad the report.

**No git activity in the timeframe**: State it plainly. "Zero commits and zero merged PRs in the past 7 days." Then suggest concrete next steps: check if work happened on a different branch (`git branch -a`), a different repo, or under a different git email. Also note whether the timeframe is too narrow (e.g., a holiday week or planning sprint with no code output). Do not apologize for the data; report it.

**All PRs still in review**: Report the review bottleneck directly. "3 PRs opened this week, 0 merged, all awaiting review." Calculate how long each has been waiting. If any have been open 3+ days without a reviewer assigned, flag it as a risk. This is useful information, not a failure.

**No merges in a custom time range**: State the count (zero) and the range. Suggest expanding the window or checking adjacent repos. If PRs were opened but not merged, report those under "In Progress" with their review status.

**Solo contributor (team of 1)**: Skip comparative metrics ("vs. team average"). Focus on personal velocity trends, shipped outcomes, and self-identified blockers. The report should still be VP-readable; a solo contributor's status matters as much as a team's.

**Large team (15+ people)**: If scanning an org with many members, warn that the report may take longer to generate and suggest narrowing scope with a repo filter or username list. Group activity by initiative rather than listing every person's commits individually.

## Depth Levels

Adapt the report to the user's needs based on context and arguments:

**Quick status** (default, or `detail:brief`): Produce the standard format above. Tight summary, impact metrics table, top 3 shipped items, top risk. Target: under 500 words. This is the Friday afternoon version.

**Full status** (`detail:full`): Expand every section. Include all shipped items (not just top 3), full risk analysis with severity scoring, per-repo breakdowns, and review activity. Target: 800-1200 words. This is the "my manager asked for more detail" version.

## Cross-Tool Suggestions

After the report, include one line:

> Run `/risk-register` to expand the risk section into a scored register with mitigations.

## Final Quality Gate

Before outputting, verify:
1. Every bullet has a number, a link, or both. Remove any that do not.
2. No weasel words survived the edit. "Some," "several," "various," and "significant progress" are banned without a metric.
3. The Summary section works as a standalone email to a VP. If it does not, rewrite it.
4. Bad news is stated directly, not buried. A PR waiting 10 days for review gets called out plainly.
5. The report uses active voice throughout. "Shipped," "Fixed," "Closed" not "was shipped," "was fixed."
6. If data is sparse (fewer than 3 commits and no PRs), note that explicitly and suggest expanding the timeframe.
7. If GitHub CLI is not authenticated, inform the user and provide instructions: `gh auth login`.
8. Do not fabricate activity. Only report what the data shows.
9. Use the format from `~/.status-config` if set (markdown or plain text). Default to markdown.
