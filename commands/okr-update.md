# OKR Progress Update

You map daily engineering work to organizational goals honestly. An OKR update that stretches mappings to look good is worse than one that shows gaps, because gaps are opportunities to reallocate before it is too late.

Your manager wants to know two things: are you working on the right stuff, and where do you need help?

Lead with the alignment score and the biggest gap, then support with details. Conclusion first, evidence second.

## Arguments

$ARGUMENTS should include OKR descriptions. Accepted formats:
- Inline: "O1: Improve inference performance KR1: Reduce p99 latency by 30% KR2: Ship model router v2"
- File path: "okrs:~/okrs.txt"
- From a previous conversation: "use the OKRs I shared earlier"

Optionally include:
- A timeframe (e.g., "last 2 weeks", "since 2025-06-01"). Defaults to the past 14 days.
- A repo filter (e.g., "repo:my-org/my-repo")

If no OKRs are provided, check `~/.status-config` for an `okr_file` setting. If none exists there either, stop and ask the user before proceeding.

```bash
if [ -f "$HOME/.status-config" ]; then cat "$HOME/.status-config"; fi
```

```bash
# If an okr_file path is configured in ~/.status-config:
if [ -f "<okr_file_path>" ]; then cat "<okr_file_path>"; fi
```

## Gather Recent Activity

```bash
git config user.email
git config user.name
git log --since="<timeframe>" --author="<user>" --pretty=format:"%h %s (%ar)" --no-merges

gh search prs --author=@me --created=">$(date -v-14d +%Y-%m-%d)" --json title,url,state,repository,createdAt,additions,deletions,mergedAt
gh search prs --reviewed-by=@me --created=">$(date -v-14d +%Y-%m-%d)" --json title,url,state,repository,createdAt
gh search issues --assignee=@me --closed=">$(date -v-14d +%Y-%m-%d)" --json title,url,repository,closedAt
gh search issues --assignee=@me --state=open --json title,url,repository,labels,milestone
```

## Mapping Rules

For each PR, commit, and issue, determine which KR it advances. Apply these rules strictly:

1. A connection must be direct and defensible. If you have to argue why a PR maps to a KR, it does not map.
2. A single item can map to multiple KRs only if it genuinely advances each one.
3. Anything that does not map goes in the Unmapped Activity section. Do not hide it.
4. Never confuse activity with progress. Ten commits mean nothing if the KR metric did not move.

Calibration examples:
- Bad: "Contributed to O1 by working on infrastructure."
- Good: "O1 KR1 (reduce p99 by 30%): Shipped scheduling optimization, p99 dropped from 500ms to 300ms (40% reduction, exceeding target). 2 PRs merged, +340/-57 lines."

- Bad: "Made progress toward KR2 by improving the deployment pipeline."
- Good: "O2 KR2 (deploy time under 10 min): Parallelized container builds in CI, deploy time dropped from 18 min to 7 min (PR #72). KR exceeded, marking complete."

- Bad: "Spent time researching options for the model router."
- Good: "O1 KR3 (ship model router v2): 0 PRs merged, 0 issues closed. Spike completed but no code produced yet. At current pace, this KR will miss the Q3 deadline by 3 weeks. Recommend allocating 2 dedicated days next sprint."

- Bad: "Supported multiple team objectives this quarter."
- Good: "68% of work items mapped to OKRs. 32% went to unplanned incident response (3 P1 pages, 2 customer escalations). Recommend adding an 'operational resilience' objective next quarter to capture this work."

For each KR, classify its status using evidence only:
- **On Track**: Multiple recent activities directly advance this KR, and trajectory suggests the target is achievable. Requires at least 2 concrete evidence items.
- **At Risk**: Some related activity exists, but the pace or direction is not sufficient to hit the target. State what is missing.
- **Off Track**: No recent activity maps to this KR, or activity exists but is not moving the metric. State the gap plainly.

Never rate a KR as "On Track" based on effort rather than measurable movement toward the target.

## Output Format

Start the report with the alignment score and the single biggest gap. Then expand into the full structure below.

---

## OKR Progress Update

**Period**: [start] to [end] | **Author**: [git user name]
**Alignment Score**: [X]% of work items mapped to OKRs
**Biggest Gap**: [Name the KR with the least activity relative to its priority, in one sentence]

### Alignment Overview

| Metric | Count |
|--------|-------|
| Total Work Items | X |
| Mapped to OKRs | X |
| Unmapped | X |
| KRs On Track | X of Y |
| KRs At Risk | X of Y |
| KRs Off Track | X of Y |

### Time Allocation vs. OKR Priority

| Objective | Work Items | % of Total Effort | Expected Priority |
|-----------|------------|-------------------|-------------------|
| [Obj 1] | X | Y% | [High/Medium/Low] |
| Unmapped Work | X | Y% | - |

Flag misalignment directly: "You spent 40% of your time on Objective 2 (Medium priority) while Objective 1 (High priority) received only 15%. This is worth discussing with your manager."

### Per-Objective Detail

For each Objective and KR, follow this structure:

#### Objective N: [Title]

**KR N.1: [Description with measurable target]**
Status: [On Track / At Risk / Off Track]
Evidence:
- [PR/commit/issue] ([link]) - [date] - [specific metric movement or contribution]

Impact: [X PRs merged, Y issues closed, +Z/-W lines directly advancing this KR]

### Gap Analysis

This is the most important section. Be ruthlessly honest. List every KR that is At Risk or Off Track.

| Key Result | Status | Days Since Last Activity | What Is Needed |
|-----------|--------|--------------------------|----------------|
| [KR] | [Status] | [X days or "No activity"] | [Specific next step: "Open PR for X", "Allocate 2 days to Y"] |

If a KR has had no activity in 14 days, say so directly. Do not soften it.

### Unmapped Activity

Work that did not map to any OKR. This reveals missing OKR coverage or unplanned work.

| Item | Type | Impact |
|------|------|--------|
| [Description] ([link]) | [PR/Issue/Commit] | [Lines changed or outcome] |

**Assessment**: "[X]% of effort went to unplanned work. [Specific recommendation: add these items to OKRs, or deprioritize them next cycle.]"

---

## Edge Cases

**No activity in the timeframe**: Report 0% alignment score and state every KR as "Off Track - No activity." This is valuable information for an OKR check-in. Suggest expanding the timeframe or verifying that work is tracked in the scanned repos.

**All work is unmapped**: Report the alignment score as 0% and surface every work item in the Unmapped Activity section. State directly: "None of the work completed in this period maps to the defined OKRs. Either the OKRs need revision to reflect actual priorities, or the team's work needs to realign with stated goals." This is the most important finding an OKR update can surface.

**OKRs not provided and no config file**: Stop and ask the user. Do not generate a report without OKRs to map against. State: "No OKRs provided and no okr_file found in ~/.status-config. Provide your OKRs inline, as a file path, or add okr_file to your config."

**Solo contributor**: The OKR mapping works identically. Skip team-level allocation analysis. Focus on personal time allocation vs. priority.

**Very long timeframe (full quarter)**: When scanning 90 days, group activity by month and show OKR progress trajectory across the quarter. Note which KRs saw early-quarter vs. late-quarter activity, and whether the pacing suggests on-time completion.

## Cross-Tool Suggestions

After the report, include one line:

> Run `/quarterly-review` to expand this into a full narrative ready for performance reviews.

## Final Checks

Before outputting, verify:
1. The alignment score and biggest gap appear at the top of the report.
2. No KR is marked "On Track" without at least 2 concrete, directly relevant evidence items.
3. The gap analysis names every At Risk and Off Track KR with a specific next step.
4. Unmapped work is surfaced, not hidden.
5. Every status classification cites evidence, not judgment.
6. The time allocation table exposes any mismatch between stated priorities and actual effort.
7. You used exact counts throughout. Write "0 PRs" rather than "no significant PRs."
8. You did not fabricate activity or progress.
