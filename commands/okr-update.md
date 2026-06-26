# OKR Update Generator

Map your recent git and GitHub activity to your OKRs. Identifies which objectives your work supports and highlights gaps where no recent activity aligns.

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

## Instructions

### Step 1: Parse OKRs

Extract the Objectives and Key Results from $ARGUMENTS or the config file. Structure them as:
- Objective 1
  - Key Result 1.1
  - Key Result 1.2
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
- A single PR or commit can map to multiple Key Results if relevant

For each Key Result, classify its status:
- **On track**: Recent activity directly supports this KR
- **Needs attention**: Some related activity, but not enough to show clear progress
- **Gap**: No recent activity maps to this KR

### Step 4: Generate the OKR Update

Output the report in **exactly** this structure.

---

## OKR Progress Update

**Period**: [start date] to [end date]
**Author**: [git user name]

### Overall Alignment

- Key Results with recent activity: [X of Y total]
- Key Results with no recent activity: [Z of Y total]

### Objective 1: [Objective Title]

#### KR 1.1: [Key Result Description]
**Status**: [On track / Needs attention / Gap]

Related activity:
- [PR/commit/issue description] ([link]) - [date]
- [PR/commit/issue description] ([link]) - [date]

Metrics: [X PRs merged, Y issues closed, +Z/-W lines related to this KR]

#### KR 1.2: [Key Result Description]
**Status**: [On track / Needs attention / Gap]

Related activity:
- [items or "No activity found for this key result in the reporting period."]

### Objective 2: [Objective Title]

(repeat the pattern)

### Gap Analysis

List all Key Results marked as "Gap" with a brief note on what kind of work would move them forward:

| Key Result | Last Related Activity | Suggested Next Step |
|-----------|----------------------|-------------------|
| [KR description] | [date or "None found"] | [suggestion] |

### Unmapped Activity

List any significant work (PRs, issues) that did not map to any OKR. This can reveal work that needs OKR coverage or distractions worth discussing with your manager.

- [PR/commit/issue description] ([link])

---

### Output Rules

- Only map activity to OKRs where there is a genuine connection. Do not stretch mappings to make coverage look better.
- Always use exact counts. State "0 PRs" rather than "no significant PRs."
- If no OKRs are provided and none are in the config, stop and ask the user. Do not generate a report without OKRs.
- Do not fabricate activity or progress.
- The gap analysis is the most important section. Be direct about where work is not happening.
