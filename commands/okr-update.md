# OKR Progress Tracker

Map your recent work to your OKRs with ruthless honesty. This command does not make your OKR coverage look better than it is. It exposes gaps, quantifies progress, and tells you exactly where your time is going versus where it should be going.

## Arguments

$ARGUMENTS should include your OKR descriptions. You can provide them in any format:
- Inline: "O1: Improve inference performance KR1: Reduce p99 latency by 30% KR2: Ship model router v2"
- As a file path: "okrs:~/okrs.txt"
- From a previous conversation: "use the OKRs I shared earlier"

Optionally include:
- A timeframe (e.g., "last 2 weeks", "since 2025-06-01"). Defaults to the past 14 days.
- A repo filter (e.g., "repo:my-org/my-repo")

If no OKRs are provided, ask the user to supply them before proceeding.

## Config File Support

Check if `~/.status-config` exists. If it has an `okr_file` setting, read OKRs from that file.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

If an `okr_file` path is configured:

```bash
if [ -f "<okr_file_path>" ]; then
  cat "<okr_file_path>"
fi
```

## Thinking Process

Before generating any output, work through this chain of thought silently:

1. **Parse OKRs precisely**: Extract each Objective and its Key Results. If a KR has a measurable target (e.g., "reduce by 30%"), note that target explicitly.
2. **Map all work to OKRs**: For each PR, commit, and issue, determine which KR it supports. Be honest: if a PR fixes a typo in a README, it does not advance "Reduce p99 latency by 30%."
3. **Identify the gaps**: Which KRs have zero activity? These are the ones that matter most in this report.
4. **Calculate time allocation**: What percentage of the user's work went to each Objective? Is the allocation aligned with stated priorities?
5. **Self-critique**: Did you stretch any mapping to make coverage look better? Remove it. A gap honestly reported is more valuable than a false "on track."

## Anti-Patterns to Avoid

Do NOT:
- Stretch mappings to make coverage look better (fixing a CI config does not count as "improving developer experience" unless that was the actual bottleneck)
- Report "on track" for a KR with only tangential activity
- Hide gaps by omitting KRs from the report
- Use "contributed to" without specifying exactly how
- Confuse activity with progress (10 commits means nothing if the KR metric did not move)
- Rate a KR as "on track" based on effort rather than measurable movement toward the target

## Instructions

### Step 1: Parse OKRs

Extract the Objectives and Key Results from $ARGUMENTS or the config file. Structure them as:
- Objective 1
  - Key Result 1.1 [with measurable target if specified]
  - Key Result 1.2 [with measurable target if specified]
- Objective 2
  - Key Result 2.1

If the input is unstructured text, do your best to identify objectives and key results. Ask for clarification only if the input is truly ambiguous.

### Step 2: Gather Recent Activity

Use the same data-gathering approach as the status report:

```bash
# Git activity
git config user.email
git config user.name
git log --since="<timeframe>" --author="<user>" --pretty=format:"%h %s (%ar)" --no-merges

# PRs
gh search prs --author=@me --created=">$(date -v-14d +%Y-%m-%d)" --json title,url,state,repository,createdAt,additions,deletions,mergedAt

# PRs reviewed
gh search prs --reviewed-by=@me --created=">$(date -v-14d +%Y-%m-%d)" --json title,url,state,repository,createdAt

# Issues closed
gh search issues --assignee=@me --closed=">$(date -v-14d +%Y-%m-%d)" --json title,url,repository,closedAt

# Open issues assigned (for planned work)
gh search issues --assignee=@me --state=open --json title,url,repository,labels,milestone
```

### Step 3: Map Activity to OKRs

For each Key Result, scan the gathered data for related activity:
- Match by keywords in commit messages, PR titles, issue titles, and repo names
- Consider the repo context (e.g., work in an "llm-d" repo likely maps to inference-related OKRs)
- A single PR or commit can map to multiple Key Results if genuinely relevant
- Be strict: if the connection is tenuous, do not map it. Note it as unmapped instead.

For each Key Result, classify its status using evidence:
- **On Track**: Multiple recent activities directly advance this KR, and the trajectory suggests the target is achievable. State the evidence.
- **At Risk**: Some related activity, but the pace or direction is not sufficient to hit the target. State what is missing.
- **Off Track**: No recent activity maps to this KR, or activity exists but is not moving the metric. State the gap plainly.

### Step 4: Calculate Alignment Score

Compute a simple alignment metric:
- Count total work items (PRs + issues + significant commits)
- Count how many map to at least one KR
- Alignment score = mapped items / total items as a percentage

This tells the user: "X% of your work in this period directly advanced your stated OKRs."

### Step 5: Generate the OKR Update

Output the report in this structure:

---

## OKR Progress Update

**Period**: [start date] to [end date]
**Author**: [git user name]
**Alignment Score**: [X]% of work items mapped to OKRs

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

Show where time actually went versus where OKRs say it should go:

| Objective | Work Items | % of Total Effort | Expected Priority |
|-----------|------------|-------------------|-------------------|
| [Obj 1] | X | Y% | [High/Medium/Low] |
| [Obj 2] | X | Y% | [High/Medium/Low] |
| Unmapped Work | X | Y% | - |

Flag any misalignment: "You spent 40% of your time on Objective 2 but it is rated Medium priority. Meanwhile, Objective 1 (High priority) received only 15% of effort."

### Objective 1: [Objective Title]

#### KR 1.1: [Key Result Description]
**Status**: [On Track / At Risk / Off Track]
**Evidence**:

Related activity:
- [PR/commit/issue description] ([link]) - [date] - [how it advances this KR]
- [PR/commit/issue description] ([link]) - [date] - [how it advances this KR]

Impact: [X PRs merged, Y issues closed, +Z/-W lines directly advancing this KR]

#### KR 1.2: [Key Result Description]
**Status**: [On Track / At Risk / Off Track]
**Evidence**:

Related activity:
- [items or "No activity found for this key result in the reporting period."]

### Objective 2: [Objective Title]

(repeat the pattern)

### Gap Analysis

This is the most important section. List all KRs that are At Risk or Off Track.

| Key Result | Status | Days Since Last Activity | What Is Needed |
|-----------|--------|-------------------------|---------------|
| [KR description] | [At Risk/Off Track] | [X days or "No activity found"] | [Specific next step: "Open PR for X", "Schedule design review for Y", "Allocate 2 days next sprint to Z"] |

### Unmapped Activity

Work that did not map to any OKR. This reveals either missing OKR coverage or time spent on unplanned work. Both are worth discussing with your manager.

| Item | Type | Impact |
|------|------|--------|
| [Description] ([link]) | [PR/Issue/Commit] | [Lines changed or outcome] |

**Assessment**: [One sentence: "X% of effort went to unplanned work. Consider whether [specific items] should be added to OKRs or deprioritized."]

---

### Final Quality Check

Before outputting, verify:
1. No KR is marked "On Track" without at least 2 concrete evidence items directly advancing it.
2. The Gap Analysis is brutally honest. If a KR has had no activity in 14 days, say so.
3. The Alignment Score is calculated correctly.
4. Unmapped work is surfaced, not hidden.
5. Every status classification includes specific evidence, not a judgment call.
6. The Time Allocation table exposes any mismatch between stated priorities and actual effort.

### Output Rules

- Only map activity to OKRs where there is a genuine connection. Do not stretch mappings to make coverage look better.
- Always use exact counts. State "0 PRs" rather than "no significant PRs."
- If no OKRs are provided and none are in the config, stop and ask the user. Do not generate a report without OKRs.
- Do not fabricate activity or progress.
- The gap analysis is the most important section. Be direct about where work is not happening.
- Write in active voice throughout.
