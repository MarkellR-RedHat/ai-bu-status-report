# Executive Summary Generator

Produce an executive summary so crisp that a VP can forward it unedited. No fluff, no filler, no "making great progress." Just what shipped, what it means, and what needs attention.

## Arguments

$ARGUMENTS can specify:
- A GitHub org or team (e.g., "org:openshift" or "team:ai-bu")
- A list of GitHub usernames (e.g., "users:alice,bob,carol")
- A timeframe (e.g., "last 2 weeks", "this sprint"). Defaults to the past 7 days.
- A repo filter (e.g., "repo:my-org/my-repo")
- An audience hint (e.g., "for:vp", "for:all-hands", "for:stakeholders", "for:board")

At minimum, either an org/team, a user list, or a repo is required. If nothing is provided, fall back to the current user's individual activity.

## Config File Support

Check if `~/.status-config` exists. If it does, read it for default org, team members, or repos.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Thinking Process

Before generating any output, work through this chain of thought silently:

1. **Extract the signal from the noise**: Out of all the PRs merged and issues closed, which 2-4 items would a VP actually care about? Not "updated config file" but "shipped the feature that unblocks the Q3 revenue target."
2. **Quantify the headline**: What is the single most impressive true metric? "Shipped X, reducing Y by Z%" or "Merged N PRs that complete the [milestone] deliverable."
3. **Identify the one risk worth mentioning**: VPs do not want a list of 10 risks. They want to know the one thing that could derail the timeline, stated plainly.
4. **Draft at VP altitude**: Business impact, customer value, timeline implications. Not "merged PR #42" but "shipped streaming inference support, enabling real-time model serving for the enterprise tier."
5. **Self-critique**: Read the draft. Would a VP forward this to their boss? If any sentence requires engineering context to understand, rewrite it. If any sentence says "progress" without a percentage, rewrite it.

## Anti-Patterns to Avoid

Do NOT:
- Write more than one paragraph for the summary (that is not a summary, that is a report)
- Use engineering jargon without translating to business impact
- Say "making progress" or "on track" without a completion percentage or milestone reference
- List activities instead of outcomes ("held 3 meetings" is not an accomplishment)
- Bury the lead: the most important thing goes in the first sentence, period
- Include items that do not pass the "would a VP care?" filter
- Use passive voice: "was completed" should be "completed" or "shipped"

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
- Revenue-enabling or customer-facing changes
- Performance or reliability improvements (with numbers)
- Risk reduction or technical debt paydown (with business justification)
- Developer experience wins that accelerate future delivery

Filter ruthlessly. If a theme does not affect the business, the customer, or the timeline, drop it.

### Step 3: Apply the SCQA Framework

Structure your thinking (not the output) using SCQA:
- **Situation**: What is the current state of the project/initiative?
- **Complication**: What challenge or opportunity drove this week's work?
- **Question**: What needed to happen?
- **Answer**: What did the team deliver, and what does it mean?

This framework ensures the summary tells a story, not just lists facts.

### Step 4: Write the Executive Summary

Produce **exactly one paragraph** of 3-5 sentences. Follow this structure:

1. **Opening sentence**: The headline. State the single most important accomplishment with a key metric. This sentence should work as a subject line if someone forwarded just the first line.
2. **Middle sentences**: Cover 2-3 specific outcomes with concrete details. Translate engineering work to business impact. Use numbers: "reduced by X%," "completed Y of Z deliverables," "unblocked the [milestone] timeline."
3. **Closing sentence**: State the single most important thing coming next, OR the single risk worth knowing about. Not both. Pick the one the VP would ask about.

### Step 5: Write the Status Line

After the paragraph, add a one-line status indicator:

**Overall Status**: [GREEN/YELLOW/RED] - [one-sentence justification]

Status criteria:
- **GREEN**: On track to hit the next milestone. No blockers. Velocity is steady or increasing.
- **YELLOW**: A specific risk threatens the timeline, but mitigation is in progress. State what the risk is and what is being done.
- **RED**: A blocker exists that the team cannot resolve alone. State what it is and what decision or resource is needed.

Never use GREEN without evidence. Never use RED without a specific ask.

### Step 6: Provide Supporting Data

After the paragraph, include a compact data section:

---

## Executive Summary

[The one paragraph goes here.]

**Status**: [GREEN/YELLOW/RED] - [justification]

### Key Deliverables

Rank-ordered by business impact, not chronologically:

1. **[Deliverable]** - [one sentence on business impact] ([PR #NNN](url))
2. **[Deliverable]** - [one sentence on business impact] ([PR #NNN](url))
3. **[Deliverable]** - [one sentence on business impact] ([PR #NNN](url))

### Metrics

| Metric | Count |
|--------|-------|
| PRs Merged | X |
| Issues Closed | X |
| Active Contributors | X |
| Repos Touched | X |

### What Is Next

One to three bullets on what ships next week, stated as outcomes not activities:
- [What will be delivered and why it matters]

### Needs Attention

Only include if there is something requiring leadership awareness or action. If nothing, omit this section entirely. Do not write "No items" as that wastes a VP's time.

- [Specific issue] - [what is needed: decision, resource, escalation]

---

### Final Quality Check

Before outputting, verify:
1. The summary paragraph is under 100 words. Count them. If over, cut.
2. Every sentence in the paragraph contains at least one number, percentage, or concrete outcome.
3. A VP could forward this email with zero edits. If you would add context before forwarding, the summary is not done.
4. The status color is justified by the evidence, not by optimism.
5. No sentence requires engineering knowledge to understand. "Shipped vLLM integration" means nothing to a VP. "Shipped GPU scheduling optimization that reduces inference costs by 20%" does.
6. The "Needs Attention" section, if present, includes a specific ask, not just a problem statement.

### Output Rules

- The summary paragraph must stand on its own. A reader should understand what happened without looking at the supporting data.
- Write at the altitude of a VP or director. Not individual commits. Not minor fixes. Outcomes and impact.
- Use active voice. "Shipped" not "was shipped." "Closed" not "were closed."
- Always quantify. "Merged 12 PRs" not "merged PRs." "Reduced latency by 30%" not "improved latency."
- Keep the paragraph under 100 words. Brevity is the entire point.
- If the audience hint is "for:vp" or "for:board", maximize business impact language and minimize technical detail.
- If the audience hint is "for:all-hands", balance technical accomplishment with team recognition.
- If the audience hint is "for:stakeholders", include customer-facing language where applicable.
- Do not fabricate accomplishments or metrics. Only report what the data shows.
