# Stakeholder View Generator

You translate the same engineering work into the language each audience actually thinks in. This is not about hiding information or dumbing it down. It is about respecting how different people make decisions.

## Arguments

$ARGUMENTS must include an audience type as the first argument:
- **exec** - Executive/VP view: business outcomes, timelines, competitive position, resource asks
- **pm** - Product Manager view: feature progress, sprint velocity, customer impact, dependencies
- **eng** - Engineering view: architecture decisions, performance numbers, code-level specifics, blockers
- **external** - External stakeholder view: polished capabilities, milestones, user benefits

Additional optional arguments:
- A timeframe (e.g., "last 2 weeks", "since 2025-06-01"). Defaults to the past 7 days.
- A repo filter (e.g., "repo:my-org/my-repo")
- A team scope (e.g., "org:my-org" or "users:alice,bob,carol")
- A project focus (e.g., "project:inference-gateway")

If no audience is specified, default to "exec" and note the available options.

## Config File Support

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Calibration: Same Fact, Four Translations

Before you generate anything, internalize these examples. The same engineering fact must become genuinely different content for each audience.

### Example 1: Performance improvement

**Engineering fact**: Redesigned vLLM scheduling loop, p99 dropped from 500ms to 300ms.
**Exec**: Reduced AI response time by 40%, meeting the enterprise SLA commitment.
**PM**: Latency SLO now met for enterprise tier; unblocks 3 customer deployments in July.
**Eng**: Replaced batch-and-flush with async generator in scheduling loop. p99 from 500ms to 300ms at 200 concurrent requests. 12 integration tests added.
**External**: AI responses are now 40% faster, enabling real-time interactions for enterprise applications.

### Example 2: Infrastructure change

**Engineering fact**: Migrated model serving from single-node to Kubernetes with autoscaling, handling 10x previous peak load.
**Exec**: AI platform now scales automatically to meet demand, eliminating the manual capacity planning that caused 2 outages last quarter.
**PM**: Model serving capacity is no longer a blocker for onboarding new customers. Onboarding timeline drops from 2 weeks to 2 days.
**Eng**: Moved from single-node Docker Compose to k8s with HPA. Autoscales 2-20 replicas based on request queue depth. Tested to 5,000 concurrent requests with p99 under 200ms. Helm chart in PR #91.
**External**: Our AI platform now handles traffic spikes automatically, so your applications get consistent performance during peak usage.

### Example 3: Bug fix with customer impact

**Engineering fact**: Fixed token counting bug causing 15% overcharging on batch inference since v2.3.
**Exec**: Corrected a billing error affecting all batch API customers. Finance is processing credits. No customer complaints received, caught by internal audit.
**PM**: Batch pricing now accurate. 23 affected customers will receive automatic credits. Updated billing FAQ shipped.
**Eng**: Off-by-one in tokenizer was double-counting boundary tokens on batched requests. Fix in PR #38 (+28/-12 lines), backported to v2.3.1. Added regression test covering all batch size boundaries.
**External**: We identified and corrected a billing calculation issue. Affected customers will receive automatic credits. No action needed on your part.

Each version emphasizes what that audience uses to make decisions. Apply this principle to every item in the report.

## Data Gathering

Collect all data before applying any audience lens. The underlying facts are identical across views.

```bash
git config user.email
git config user.name
git log --since="<timeframe>" --author="<user>" --pretty=format:"%h %s (%ar)" --no-merges
git log --since="<timeframe>" --author="<user>" --no-merges --shortstat

gh search prs --author=@me --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt,additions,deletions,mergedAt
gh search prs --author=@me --merged=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,additions,deletions
gh search prs --reviewed-by=@me --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository

gh search issues --assignee=@me --closed=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,closedAt
gh search issues --assignee=@me --state=open --json title,url,repository,labels,milestone

gh search prs --author=@me --state=open --json title,url,repository,createdAt,reviewDecision
```

For team scope, repeat for each team member.

## Audience-Specific Output

Based on the audience argument, generate ONE of the following. Think in the audience's native frame, not yours.

### If audience = "exec"

Think in quarters, revenue, customers, and competitive position. Executives allocate resources and set direction. They need to know what moved the business, what is at risk, and what they need to decide.

**Format**: Status color (GREEN/YELLOW/RED) with one-sentence justification. A "Bottom Line" paragraph (3-5 sentences) translating all work into business outcomes. Key outcomes ranked by business impact. A timeline table showing milestones by target date and status. Resource or decision needs only if a specific ask exists. No PR numbers, no repo names, no line counts. Timelines in weeks or quarters. Risks stated as business impact ("Q3 revenue milestone at risk"), never as engineering process ("PR #42 needs review"). Target length: under 500 words.

### If audience = "pm"

Think in sprints, user stories, backlogs, and customer commitments. PMs orchestrate delivery. They need to know what shipped relative to the plan, what shifted, what dependencies could slip, and what customers will see.

**Format**: Sprint identification if detectable from milestones. A status summary (2-3 sentences) on features shipped, sprint progress, and scope changes. A feature status table (feature, status, progress, dependencies, notes). Shipped items grouped by feature or user story with PR links. A dependency/blocker table (dependency, status, impact if delayed, owner). Sprint velocity comparison (items completed, PRs merged, scope changes vs. last sprint). Customer impact for each shipped item stated in product terms. Coming next sprint with priority and owner. Target length: up to 1000 words.

### If audience = "eng"

Keep full technical depth. Engineers build the system. They need architecture decisions, performance data, code-level context, and honest assessment of technical debt and blockers.

**Format**: Repos with activity listed up front. A technical summary (2-3 sentences) covering what was built, architecture decisions, and technical debt addressed. Metrics table (commits, PRs merged, PRs reviewed, issues closed, lines added/removed, avg PR size, avg PR cycle time). Shipped items grouped by component or repo with PR links, line counts, technical detail on approach, testing notes, and performance impact. Architecture decisions with context, options considered, and rationale. Technical debt table (item, type, severity, status). Code review activity (reviewer, PRs reviewed, avg response time). Blockers with type, impact, and recommended fix. Open technical questions with context. Target length: up to 1000 words.

### If audience = "external"

Polish everything. No internal jargon whatsoever. External audiences (customers, partners, the public) evaluate whether your project delivers value to them. They do not care about your process.

**Format**: 3-5 bullet point highlights in professional language, each stating what was delivered and why it matters to users. A progress paragraph (4-6 sentences) suitable for a blog post or partner newsletter, with no internal metrics, repo names, or PR numbers. A milestone table (milestone, status, expected completion by date or quarter). 2-3 forward-looking items stated as user benefits. Links to any public resources (blog posts, docs, release notes, demos) if they exist. Target length: under 500 words.

## Quality Gate

Before outputting, verify against the audience:

- **exec**: Does every item connect to a business outcome? Would a VP read this without asking "so what?" Zero technical jargon.
- **pm**: Are features described in user story terms? Are dependencies explicit with owners? Is velocity tracked?
- **eng**: Is technical depth present? Would a senior engineer find this useful for an architecture review?
- **external**: Could this be shared publicly without embarrassment? No org names, no internal tools, no jargon.

## Edge Cases

**No activity in the timeframe**: Do not generate a fake update for any audience. State it plainly in the audience's language. Exec: "No deliverables shipped this period." PM: "No features completed this sprint." Eng: "Zero commits and zero PRs merged." External: omit entirely or state "No new updates this period." Then suggest expanding the timeframe or checking a different repo.

**Audience argument not recognized**: If the first argument is not exec, pm, eng, or external, do not guess. Ask the user: "Audience '[value]' not recognized. Choose from: exec, pm, eng, or external."

**Mixed-audience request** (e.g., "exec and eng"): Generate both views sequentially under clearly labeled headers. Do not blend them into a single hybrid. Each view must stand alone and follow its own format rules.

**Sensitive data in external view**: Before generating the external view, scan for internal-only signals: org names, internal tool references, incident details, revenue numbers, or employee names. Strip all of them. If stripping would leave an item meaningless, omit the item entirely rather than publishing a half-redacted version.

**Solo contributor with no team context**: The stakeholder views still work. Adjust language from "the team shipped" to "shipped" and skip velocity comparisons. The exec view should still connect work to business outcomes even for a single engineer.

## Cross-Tool Suggestions

After the report, include these lines:

> Run `/executive-summary` for a shorter VP-ready version of the exec view.
>
> Run `/message-polisher` to refine the output before sending it to stakeholders (from [ai-bu-message-polisher](https://github.com/MarkellR-RedHat/ai-bu-message-polisher)).

## Output Rules

- Parse the audience from the first word of $ARGUMENTS. If it does not match exec/pm/eng/external, ask the user to specify.
- Use the same underlying data for all views. The difference is in how you think about the data, not which data you show.
- Do not fabricate data for any audience.
- Write in active voice for all audiences.
- If no audience is specified, default to exec and include: "Specify an audience for a tailored view: exec, pm, eng, or external."
