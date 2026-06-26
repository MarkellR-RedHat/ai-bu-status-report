# Weekly Status Report Generator

Generate a weekly status report that reads like a seasoned PM wrote it. Every claim backed by data, every status justified by evidence, every risk paired with a mitigation.

## Arguments

$ARGUMENTS can specify:
- A custom timeframe (e.g., "last 2 weeks", "since 2025-06-01")
- A specific repo filter (e.g., "repo:my-org/my-repo")
- Focus area (e.g., "focus:engineering" or "focus:content")
- Output detail level (e.g., "detail:brief" or "detail:full")
- Both combined (e.g., "last 2 weeks repo:my-org/my-repo focus:engineering")

If no arguments are provided, default to the past 7 days across all repos the user has access to.

## Config File Support

Before starting, check if `~/.status-config` exists. If it does, read it and apply any defaults. Config values are overridden by explicit $ARGUMENTS. See the README for config file format.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

## Thinking Process

Before generating any output, work through this chain of thought silently:

1. **Quantify what shipped**: Count every PR merged, issue closed, and commit landed. Do not proceed until you have exact numbers.
2. **Assess trajectory against goals**: Compare this week's output to last week if data is available. Is velocity increasing, flat, or declining?
3. **Identify risks with specifics**: Any PR open more than 5 days without review? Any failing CI? Any blocked issues? Each risk needs a concrete description and a recommended action.
4. **Build the narrative**: What story does the data tell? "We shipped X, which unblocks Y, but Z is at risk because W."
5. **Self-critique before output**: Verify every claim has a number or link. Remove any sentence containing "some progress," "good momentum," "making progress," or "on track" unless backed by specific evidence. Ensure no bad news is hidden behind positive framing.

## Anti-Patterns to Avoid

Do NOT:
- List activities without outcomes ("updated the repo" tells the reader nothing)
- Report "on track" without evidence (what metric proves it?)
- Hide bad news in positive framing ("despite challenges, we made progress" is a red flag)
- Use "making progress" without specifying exactly how much
- Say "several" or "various" or "many" when you have exact counts
- Write "worked on X" instead of "shipped X" or "X is at 60% complete"
- Include filler items to make the report look busier than it is

## Instructions

### Step 1: Determine Timeframe and Scope

Parse $ARGUMENTS to extract:
- **Timeframe**: Default to "7 days ago" if not specified. Support natural language like "last 2 weeks", "since Monday", or specific dates. If a default is set in `~/.status-config`, use that when no timeframe is provided.
- **Repo filter**: If a repo is specified via argument or config, scope all queries to that repo. Otherwise, scan broadly.

### Step 2: Gather Git Commit Activity

Run the following to collect commits:

```bash
# Get the git user's email/name for filtering
git config user.email
git config user.name

# For each repo (or the filtered repo), scan commits
git log --since="<timeframe>" --author="<user>" --pretty=format:"%h %s (%ar)" --no-merges

# Count total commits for metrics
git log --since="<timeframe>" --author="<user>" --oneline --no-merges | wc -l

# Get lines changed for impact summary
git log --since="<timeframe>" --author="<user>" --no-merges --shortstat
```

If working inside a single repo, scan that repo. If the user wants cross-repo scanning, check for repos under common workspace directories (~/projects, ~/src, or wherever the user's repos live). Ask the user if the location is unclear.

### Step 3: Gather GitHub PR Activity

Use the GitHub CLI to pull PR data:

```bash
# PRs opened by the user in the timeframe
gh search prs --author=@me --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt,additions,deletions

# PRs reviewed by the user
gh search prs --reviewed-by=@me --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt

# PRs merged by the user
gh search prs --author=@me --merged=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt,additions,deletions
```

If a repo filter is specified, add `--repo=<owner/repo>` to each command.

### Step 4: Gather Issue Activity

```bash
# Issues closed by the user
gh search issues --author=@me --closed=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,closedAt

# Issues the user commented on recently
gh search issues --commenter=@me --updated=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,updatedAt
```

### Step 5: Gather Open Issues for "Planned Next Week"

Pull issues assigned to the user that are still open. These feed the "Planned Next Week" section.

```bash
# Open issues assigned to the user
gh search issues --assignee=@me --state=open --json title,url,repository,labels,milestone

# Open PRs authored by the user (still in progress)
gh search prs --author=@me --state=open --json title,url,repository,createdAt,labels
```

### Step 6: Detect Risks and Blockers

Actively scan for problems. Do not wait for the user to flag these.

```bash
# PRs open more than 5 days without a review
gh search prs --author=@me --state=open --created="<$(date -v-5d +%Y-%m-%d)" --json title,url,repository,createdAt,reviewDecision

# PRs with failing CI checks
gh pr list --author=@me --state=open --json title,url,statusCheckRollup
```

For each risk found, classify it:
- **Severity**: How bad is it if this is not resolved? (blocks release, slows team, cosmetic)
- **Urgency**: When does this need action? (today, this week, next sprint)
- **Recommended action**: What specific step should be taken? (assign reviewer X, rebase and re-run CI, escalate to tech lead)

### Step 7: Categorize Work into Themes

Review all collected data and group items by outcome, not activity:

- **Shipped**: Merged PRs, closed issues, completed deliverables. What is done and in production or main?
- **Engineering**: Code contributions with measurable impact (performance gains, bug fixes with user impact, new capabilities)
- **Content**: Documentation, blog posts, tutorials, presentations. Only include if they shipped (merged), not drafts.
- **Reviews**: PR reviews with specifics (how many lines reviewed, any significant feedback given)
- **Community**: Issue triage, upstream contributions, conference talks. Include links.

### Step 8: Apply the "So What?" Test

For every bullet point in the report, ask: "So what? Why does this matter?" If the answer is not obvious from the bullet itself, rewrite it to include the impact.

Bad: "Updated Helm chart values"
Good: "Updated Helm chart to support multi-model routing, unblocking the Q3 inference gateway milestone (PR #51, +67/-23 lines)"

Bad: "Fixed bug in batch processor"
Good: "Fixed token counting bug that was causing 15% overcharging on batch inference requests (PR #38, +28/-12 lines)"

### Step 9: Generate the Status Report

Output the report in this structure:

---

## Weekly Status Report

**Period**: [start date] to [end date]
**Author**: [git user name]
**Repos**: [list of repos included]

### Summary

Write 2-3 sentences that tell the story of the week. Lead with the most important thing that shipped. Mention any significant risk. Use this pattern: "This week shipped [biggest deliverable], which [why it matters]. [Secondary accomplishments]. [Risk or upcoming item that needs attention]."

### Impact Metrics

| Metric | This Week | Trend |
|--------|-----------|-------|
| Commits | X | [up/down/flat vs last week if data available] |
| PRs Merged | X | |
| PRs Reviewed | X | |
| Issues Closed | X | |
| Lines Changed | +X / -Y | |

### What Shipped

Group by significance, not by type. Lead with the highest-impact items.

Each item follows this format:
- **[Outcome description]** ([PR #NNN](url)) - +X/-Y lines
  - Why it matters: [one sentence on impact or what it unblocks]

Only include items that are done (merged PRs, closed issues). Do not list work-in-progress here.

### In Progress

List open PRs and active work. For each item, include:
- What it is and why it matters
- How far along it is (if assessable from commits or PR description)
- How many days it has been open
- Whether it has reviewers assigned

Format:
- **[Description]** ([PR #NNN](url)) - opened [date], [X days old], [reviewers: @name or "no reviewer assigned"]

### Planned Next Week

Populate from open issues assigned to the user. For each item, include the repo, milestone context, and why it is the priority.

- **[Issue title]** ([Issue #NNN](url)) - [repo name], [milestone if any]

If no open assigned issues are found, state: "No assigned issues found. Update your GitHub issues or fill in manually."

### Risks and Blockers

For each identified risk:

| Risk | Severity | Days Open | Recommended Action |
|------|----------|-----------|-------------------|
| [Description with link] | [High/Medium/Low] | [X days] | [Specific action] |

If no risks are found, state "No risks or blockers identified this period."

---

### Final Quality Check

Before outputting the report, verify:
1. Every bullet has a number, a link, or both. Remove any that do not.
2. No weasel words survive: "some," "several," "various," "good," "great," "significant progress" are all banned unless followed by a specific metric.
3. The Summary section could stand alone as an email to a VP. If not, rewrite it.
4. Bad news is stated directly, not buried. If a PR has been waiting 10 days for review, say so plainly.
5. The "So What?" test passes for every bullet in "What Shipped."
6. Status colors or labels are justified by evidence, not vibes.

### Output Rules

- Keep descriptions concise but impactful. One to two lines per item.
- Always quantify: include PR numbers, line counts, issue counts.
- If data is sparse (fewer than 3 commits and no PRs), note that explicitly and suggest expanding the timeframe.
- If GitHub CLI is not authenticated, inform the user and provide instructions: `gh auth login`.
- Do not fabricate activity. Only report what the data shows.
- Use the report format specified in `~/.status-config` if one is set (markdown or plain text). Default to markdown.
- Write in active voice. "Shipped," "Fixed," "Closed" not "was shipped," "was fixed," "was closed."
