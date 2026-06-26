# Executive Summary Generator

Produce a concise, one-paragraph executive summary of what the team shipped. Suitable for skip-level updates, all-hands presentations, or stakeholder emails.

## Arguments

$ARGUMENTS can specify:
- A GitHub org or team (e.g., "org:openshift" or "team:ai-bu")
- A list of GitHub usernames (e.g., "users:alice,bob,carol")
- A timeframe (e.g., "last 2 weeks", "this sprint"). Defaults to the past 7 days.
- A repo filter (e.g., "repo:my-org/my-repo")
- An audience hint (e.g., "for:vp", "for:all-hands", "for:stakeholders")

At minimum, either an org/team, a user list, or a repo is required. If nothing is provided, fall back to the current user's individual activity.

## Config File Support

Check if `~/.status-config` exists. If it does, read it for default org, team members, or repos.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Instructions

### Step 1: Gather Data

Use the same data-gathering approach as the team report. For a single user, use the status report approach.

```bash
# For team/org scope
gh search prs --author=<username> --merged=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,additions,deletions

# For each team member, repeat the above

# Issues closed across the team
gh search issues --assignee=<username> --closed=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository
```

Collect enough data to answer: What shipped? How much? What impact does it have?

### Step 2: Identify the Top Themes

From all merged PRs and closed issues, identify 2-4 high-level themes. Think in terms that a VP or skip-level manager cares about:
- Features shipped or milestones hit
- Performance or reliability improvements
- Developer experience or tooling wins
- Technical debt reduction
- Customer-facing changes

### Step 3: Write the Executive Summary

Produce **exactly one paragraph** of 3-5 sentences. Follow this structure:

1. **Opening sentence**: State what the team accomplished at a high level, with a key metric (e.g., "The team merged X PRs across Y repos this week, shipping [biggest thing].")
2. **Middle sentences**: Cover 2-3 specific highlights with concrete details. Use numbers, not adjectives.
3. **Closing sentence**: Note what is coming next or any risk worth flagging.

### Step 4: Provide the Supporting Data

After the paragraph, include a compact data section:

---

## Executive Summary

[The one paragraph goes here.]

### Supporting Metrics

| Metric | Count |
|--------|-------|
| PRs Merged | X |
| Issues Closed | X |
| Active Contributors | X |
| Repos Touched | X |

### Key Deliverables

- [Deliverable 1] ([PR #NNN](url))
- [Deliverable 2] ([PR #NNN](url))
- [Deliverable 3] ([PR #NNN](url))

---

### Output Rules

- The summary paragraph must stand on its own. A reader should understand what happened without looking at the supporting data.
- Write at the altitude of a project lead or engineering manager. Do not mention individual commits or minor fixes unless they had outsized impact.
- Use active voice. Say "shipped" not "was shipped." Say "closed" not "were closed."
- Always quantify. Say "merged 12 PRs" not "merged PRs." Say "reduced latency by 30%" not "improved latency."
- Keep the paragraph under 100 words. Brevity is the point.
- If the audience hint is "for:vp" or "for:all-hands", bias toward business impact over technical details.
- If the audience hint is "for:stakeholders", include customer-facing language where applicable.
- Do not fabricate accomplishments or metrics. Only report what the data shows.
