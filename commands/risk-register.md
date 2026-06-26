# Risk Register Generator

Generate a formal risk register by analyzing project activity for risks, blockers, and warning signs. Each risk is scored, categorized, and paired with mitigations and recommended actions. Includes a 2x2 risk matrix for visual prioritization.

## Arguments

$ARGUMENTS can specify:
- A repo filter (e.g., "repo:my-org/my-repo")
- A team scope (e.g., "org:my-org" or "users:alice,bob,carol")
- A timeframe for activity scanning (e.g., "last 4 weeks"). Defaults to 4 weeks.
- A risk focus (e.g., "focus:delivery" or "focus:technical" or "focus:operational")
- A threshold (e.g., "threshold:medium" to only show medium-and-above risks)

If no arguments are provided, defaults to 4 weeks of the current user's activity.

## Config File Support

Check if `~/.status-config` exists. If it does, read it for defaults.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Thinking Process

Before generating any output, work through this chain of thought silently:

1. **Scan for risk signals**: Stale PRs, failing CI, unreviewed code, abandoned branches, issues without assignees, overdue milestones. These are facts, not opinions.
2. **Classify each risk**: Is it a delivery risk (timeline), technical risk (quality/architecture), operational risk (process/people), or external risk (dependency on another team)?
3. **Score honestly**: Likelihood and impact on a 1-5 scale. Do not default everything to "medium." A PR that has been open 30 days without review is high likelihood of delay, not medium.
4. **Identify existing mitigations**: What is already being done about this risk? If nothing, say nothing.
5. **Recommend specific actions**: Not "monitor the situation" but "assign @alice to review PR #42 by Friday" or "escalate the API dependency to the platform team lead."
6. **Self-critique**: Is any risk scored lower than it should be because the truth is uncomfortable? Raise it. A risk register that hides risks is worse than no risk register.

## Instructions

### Step 1: Gather Risk Signals

Scan for these specific risk indicators:

```bash
# Stale PRs (open more than 7 days)
gh search prs --author=@me --state=open --created="<$(date -v-7d +%Y-%m-%d)" --json title,url,repository,createdAt,reviewDecision

# PRs with no reviewers assigned
gh search prs --author=@me --state=open --json title,url,repository,createdAt,reviewDecision,assignees

# PRs with failing CI
gh pr list --state=open --json title,url,statusCheckRollup,author

# Overdue milestones
gh api repos/<owner>/<repo>/milestones --jq '.[] | select(.due_on != null) | select(.due_on < now | todate)'

# Issues labeled as blocked or waiting
gh search issues --label=blocked --state=open --json title,url,repository
gh search issues --label=waiting --state=open --json title,url,repository

# Issues without assignees in active milestones
gh search issues --no-assignee --state=open --json title,url,repository,milestone

# Old open issues (open more than 30 days)
gh search issues --state=open --created="<$(date -v-30d +%Y-%m-%d)" --json title,url,repository,createdAt
```

For team scope, repeat queries for each team member.

### Step 2: Analyze Velocity Risks

```bash
# Compare recent activity to historical baseline
# Last 2 weeks commits
git log --since="2 weeks ago" --author="<user>" --oneline --no-merges | wc -l

# Previous 2 weeks commits (for comparison)
git log --since="4 weeks ago" --until="2 weeks ago" --author="<user>" --oneline --no-merges | wc -l
```

If velocity dropped more than 30%, flag it as a risk signal. The cause might be legitimate (vacation, planning week) or concerning (blocked, context-switching).

### Step 3: Score Each Risk

Use this scoring framework:

**Likelihood** (1-5):
- 1: Unlikely (less than 10% chance)
- 2: Possible (10-30% chance)
- 3: Likely (30-60% chance)
- 4: Very Likely (60-90% chance)
- 5: Almost Certain (more than 90% chance)

**Impact** (1-5):
- 1: Minimal (cosmetic, no user impact)
- 2: Low (minor inconvenience, easy workaround)
- 3: Moderate (feature delayed, partial functionality)
- 4: High (milestone missed, significant rework)
- 5: Critical (release blocked, data loss, security issue)

**Risk Score** = Likelihood x Impact (range: 1-25)

Risk levels:
- 1-4: **Low** (accept and monitor)
- 5-9: **Medium** (mitigate within the sprint)
- 10-15: **High** (escalate and address this week)
- 16-25: **Critical** (stop other work and address immediately)

### Step 4: Build the Risk Matrix

Create a 2x2 (simplified) or 5x5 (detailed) risk matrix in ASCII:

```
                    IMPACT
                Low  Med  High Crit
           ┌────┬────┬────┬────┐
    High   │    │    │ R3 │ R1 │
LIKELIHOOD ├────┼────┼────┼────┤
    Low    │ R5 │ R4 │ R2 │    │
           └────┴────┴────┴────┘
```

Place each risk's ID in the appropriate cell.

### Step 5: Identify Mitigations and Actions

For each risk, determine:
- **Current mitigations**: What is already in place? (e.g., "PR has been rebased and CI re-triggered")
- **Recommended actions**: What specific step should be taken next? Include who should do it and by when.
- **Owner**: Who is responsible for this risk? Default to the PR author, issue assignee, or team lead.

### Step 6: Generate the Risk Register

Output the report in this structure:

---

## Risk Register

**Generated**: [current date]
**Analysis Window**: [start date] to [end date]
**Scope**: [user / team / org]
**Total Risks Identified**: [X]

### Risk Summary

Write 2-3 sentences summarizing the overall risk posture. Example: "3 risks identified, 1 critical and 2 medium. The critical risk is an unreviewed PR blocking the Q3 milestone, open for 12 days with no reviewer assigned. The 2 medium risks relate to velocity decline and an external API dependency."

### Risk Matrix

```
                          IMPACT
              1-Min  2-Low  3-Mod  4-High  5-Crit
            ┌──────┬──────┬──────┬───────┬───────┐
5-Certain   │      │      │      │       │       │
            ├──────┼──────┼──────┼───────┼───────┤
4-V.Likely  │      │      │      │ [R1]  │       │
            ├──────┼──────┼──────┼───────┼───────┤
LIKELIHOOD  │      │      │ [R3] │       │       │
3-Likely    ├──────┼──────┼──────┼───────┼───────┤
2-Possible  │      │ [R4] │      │ [R2]  │       │
            ├──────┼──────┼──────┼───────┼───────┤
1-Unlikely  │      │      │      │       │       │
            └──────┴──────┴──────┴───────┴───────┘
```

### Risk Register Detail

Sorted by risk score (highest first):

#### R1: [Risk Title]

| Field | Detail |
|-------|--------|
| **Category** | [Delivery / Technical / Operational / External] |
| **Description** | [Clear, specific description of the risk] |
| **Likelihood** | [X/5] - [justification] |
| **Impact** | [X/5] - [justification] |
| **Risk Score** | [X/25] - [Low/Medium/High/Critical] |
| **Evidence** | [Link to PR, issue, or data point that surfaced this risk] |
| **Current Mitigations** | [What is already being done, or "None"] |
| **Recommended Action** | [Specific next step] |
| **Owner** | [@username] |
| **Due Date** | [Suggested date for resolution] |

#### R2: [Risk Title]

(repeat the pattern, sorted by risk score descending)

### Risk Trends

If this is not the first time running the risk register, compare to previous analysis:

| Risk | Previous Score | Current Score | Trend |
|------|---------------|---------------|-------|
| [Risk] | [X] | [Y] | [↑ Worsening / → Stable / ↓ Improving] |

If no previous data is available, state: "No previous risk register data available for trend comparison. Run this command periodically to track risk trends."

### Risk Categories Summary

| Category | Count | Highest Score | Key Concern |
|----------|-------|--------------|-------------|
| Delivery | X | [score] | [one-line summary] |
| Technical | X | [score] | [one-line summary] |
| Operational | X | [score] | [one-line summary] |
| External | X | [score] | [one-line summary] |

### Recommended Priority Actions

Top 3 actions to reduce overall risk exposure, ordered by impact:

1. **[Action]** - Reduces [Risk ID] from [current score] to [estimated score after mitigation]. Owner: @[name]. Target: [date].
2. **[Action]** - [Details]
3. **[Action]** - [Details]

---

### Final Quality Check

Before outputting, verify:
1. Every risk has concrete evidence (a link, a number, a date). No "gut feeling" risks.
2. Scores are justified, not defaulted. A PR open 1 day is not the same risk as a PR open 15 days.
3. Recommended actions are specific: who, what, when. "Monitor" is not an action.
4. The risk matrix accurately places risks based on their scores.
5. Critical risks have escalation paths, not just "fix it."
6. No risk is scored lower than evidence warrants. Intellectual honesty is the entire point.

### Output Rules

- Only report risks with evidence. Do not invent hypothetical risks.
- Score every risk on both dimensions. Do not skip scoring.
- Sort by risk score descending. The most urgent risks come first.
- If no risks are found, state: "No risks identified in the analysis window. This is unusual for an active project; consider expanding the scope or timeframe."
- Do not soft-pedal risks. If something is critical, call it critical.
- Write in direct, active voice. "PR #42 has been open 12 days without review" not "There may be some concern about review timeliness."
