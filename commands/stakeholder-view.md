# Stakeholder View Generator

Generate the same status data tailored to a specific audience. Executives get business impact and timelines. PMs get feature status and dependencies. Engineers get technical detail and blockers. External stakeholders get polished highlights. Same data, different altitude.

## Arguments

$ARGUMENTS must include an audience type as the first argument:
- **exec** - Executive/VP view: business impact, timelines, risks, resource needs
- **pm** - Product Manager view: feature status, dependencies, sprint progress, customer impact
- **eng** - Engineering view: technical detail, architecture decisions, code metrics, blockers
- **external** - External stakeholder view: polished highlights, milestone progress, value delivered

Additional optional arguments:
- A timeframe (e.g., "last 2 weeks", "since 2025-06-01"). Defaults to the past 7 days.
- A repo filter (e.g., "repo:my-org/my-repo")
- A team scope (e.g., "org:my-org" or "users:alice,bob,carol")
- A project focus (e.g., "project:inference-gateway")

If no audience is specified, default to "exec" and note the available options.

## Config File Support

Check if `~/.status-config` exists. If it does, read it for defaults.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Thinking Process

Before generating any output, work through this chain of thought silently:

1. **Gather all data first**: The underlying data is the same regardless of audience. Collect everything before filtering.
2. **Apply the audience filter**: What does this audience care about? What would they skip? What would confuse them?
3. **Choose the right altitude**: Execs think in quarters and business outcomes. PMs think in sprints and features. Engineers think in PRs and architecture. External stakeholders think in value and milestones.
4. **Translate, do not omit**: A "reduced p99 latency by 200ms" becomes "improved application response time by 40%" for execs, "latency SLO now met for the enterprise tier" for PMs, "optimized the vLLM scheduling loop, cutting p99 from 500ms to 300ms" for engineers, and "faster AI responses for your users" for external.
5. **Self-critique**: Would this audience actually read this? If an exec sees PR numbers, you failed. If an engineer does not see technical depth, you failed.

## Instructions

### Step 1: Gather All Data

Use the same data-gathering approach as the status report and team report:

```bash
# Git activity
git config user.email
git config user.name
git log --since="<timeframe>" --author="<user>" --pretty=format:"%h %s (%ar)" --no-merges
git log --since="<timeframe>" --author="<user>" --no-merges --shortstat

# PRs
gh search prs --author=@me --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt,additions,deletions,mergedAt
gh search prs --author=@me --merged=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,additions,deletions
gh search prs --reviewed-by=@me --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository

# Issues
gh search issues --assignee=@me --closed=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,closedAt
gh search issues --assignee=@me --state=open --json title,url,repository,labels,milestone

# Open/stale PRs for risk detection
gh search prs --author=@me --state=open --json title,url,repository,createdAt,reviewDecision
```

For team scope, repeat for each team member.

### Step 2: Route to Audience-Specific Output

Based on the audience argument, generate ONE of the following four report formats.

---

## If audience = "exec"

### Executive Status Update

**Period**: [start date] to [end date]
**Status**: [GREEN / YELLOW / RED] - [one-sentence justification with evidence]

#### Bottom Line

One paragraph, 3-5 sentences. Structure:
1. What shipped and its business impact (not technical description)
2. Key metric or milestone progress
3. The one thing that needs executive attention (if any)

Rules for exec view:
- No PR numbers, no line counts, no repo names unless the exec specifically tracks that repo
- Translate all technical work to business outcomes: "reduced inference cost by 20%" not "optimized GPU scheduling"
- Timelines in weeks or quarters, not days
- Risks stated as business impact: "Q3 milestone at risk" not "PR #42 needs review"

#### Key Outcomes This Period

Rank-ordered by business impact:
1. **[Business outcome]** - [Impact in business terms]
2. **[Business outcome]** - [Impact in business terms]
3. **[Business outcome]** - [Impact in business terms]

#### Timeline Status

| Milestone | Target Date | Status | Notes |
|-----------|------------|--------|-------|
| [Milestone] | [Date] | [On Track/At Risk/Delayed] | [Brief context] |

#### Resource or Decision Needs

Only include if there is a specific ask. If nothing is needed, omit entirely.
- [Specific need]: [Why and what is the impact of not addressing it]

---

## If audience = "pm"

### Product Status Update

**Period**: [start date] to [end date]
**Sprint**: [sprint name/number if identifiable from milestone data]

#### Status Summary

2-3 sentences covering: features shipped, sprint progress, and any dependency or scope changes.

#### Feature Status

| Feature / Epic | Status | Progress | Dependencies | Notes |
|---------------|--------|----------|--------------|-------|
| [Feature name] | [Shipped/In Progress/Blocked/Not Started] | [X of Y items done] | [List or "None"] | [Brief context] |

#### What Shipped

Grouped by feature or user story, not by repo:

**[Feature/Story Name]**
- [What was delivered in user-facing terms] ([PR #NNN](url))
- [What was delivered] ([PR #NNN](url))

#### Dependencies and Blockers

| Dependency | Status | Impact if Delayed | Owner |
|-----------|--------|-------------------|-------|
| [Dependency] | [Clear/At Risk/Blocked] | [What gets delayed] | [@owner] |

#### Sprint Velocity

| Metric | This Sprint | Last Sprint | Trend |
|--------|------------|-------------|-------|
| Items Completed | X | Y | ↑/→/↓ |
| PRs Merged | X | Y | ↑/→/↓ |
| Scope Changes | X items added, Y removed | | |

#### Customer Impact

For items that shipped:
- [Feature]: [How it affects users/customers, stated in product terms]

#### Coming Next Sprint

- [Feature/item] - [Priority: P0/P1/P2] - [Owner]

---

## If audience = "eng"

### Engineering Status Update

**Period**: [start date] to [end date]
**Repos**: [list of repos with activity]

#### Technical Summary

2-3 sentences on the engineering work: what was built, what architectural decisions were made, what technical debt was addressed.

#### Metrics

| Metric | Count |
|--------|-------|
| Commits | X |
| PRs Merged | X |
| PRs Reviewed | X |
| Issues Closed | X |
| Lines Added | +X |
| Lines Removed | -X |
| Avg PR Size | X lines |
| Avg PR Cycle Time | X days |

#### What Shipped (Technical Detail)

Grouped by system component or repo:

**[Component/Repo]**
- **[PR Title]** ([PR #NNN](url)) - +X/-Y lines
  - Technical detail: [What changed architecturally, what approach was used, why]
  - Testing: [What tests were added or updated]
  - Performance impact: [If measurable]

#### Architecture Decisions

List any significant technical decisions made this period:
- **[Decision]**: [Context, options considered, rationale for choice]

#### Technical Debt

| Item | Type | Severity | Status |
|------|------|----------|--------|
| [Debt item] | [Code/Infra/Test/Doc] | [High/Med/Low] | [Addressed/Identified/Deferred] |

#### Code Review Activity

| Reviewer | PRs Reviewed | Avg Response Time | Notable Reviews |
|----------|-------------|-------------------|-----------------|
| @member | X | X hours/days | [PR #NNN - brief note] |

#### Blockers and Risks (Technical)

| Issue | Type | Impact | Recommended Fix |
|-------|------|--------|-----------------|
| [Description with link] | [CI/Review/Dependency/Design] | [What it blocks] | [Specific technical action] |

#### Open Questions

List any unresolved technical questions or design decisions pending:
- [Question] - [Context and who needs to weigh in]

---

## If audience = "external"

### Project Update

**Period**: [start date] to [end date]
**Project**: [project name inferred from repos or arguments]

#### Highlights

Write 3-5 bullet points in polished, professional language suitable for sharing with customers, partners, or the public. Focus on value delivered, not internal process.

- **[Highlight]**: [What was delivered and why it matters to users, stated without internal jargon]
- **[Highlight]**: [Value-focused description]
- **[Highlight]**: [User benefit]

#### Progress Summary

A brief, accessible paragraph (4-6 sentences) describing the project's trajectory. Use language appropriate for a blog post or partner newsletter. No internal metrics, no repo names, no PR numbers.

#### Milestones

| Milestone | Status | Expected Completion |
|-----------|--------|-------------------|
| [User-facing milestone] | [Complete/In Progress/Upcoming] | [Date or quarter] |

#### What Is Coming Next

2-3 forward-looking items, stated as user benefits:
- [Upcoming capability and why it matters]
- [Upcoming improvement and who it helps]

#### Resources

Include links to any public-facing outputs from this period:
- [Blog posts, documentation, release notes, demos]

If no public resources exist, omit this section.

---

### Final Quality Check

Before outputting, verify based on the audience:

**For exec**: No PR numbers in the body. No repo names unless exec-relevant. Every item translates to business impact. Status color is justified.

**For pm**: Features are described in user story terms, not code terms. Dependencies are explicit. Sprint velocity is tracked.

**For eng**: Technical depth is present. Architecture decisions are documented. Metrics include code-level detail (lines, cycle time, PR sizes).

**For external**: No internal jargon. No org names or internal tools. Everything is stated in terms of user value. Professional tone suitable for public sharing.

### Output Rules

- Parse the audience from the first word of $ARGUMENTS. If it does not match exec/pm/eng/external, ask the user to specify.
- Use the same underlying data for all views. The difference is in framing, altitude, and detail level.
- Do not fabricate data for any audience.
- Write in active voice for all audiences.
- Exec and external views should be shorter (under 500 words). PM and eng views can be longer (up to 1000 words).
- If no audience is specified, default to exec and include a note: "Specify an audience for a tailored view: exec, pm, eng, or external."
