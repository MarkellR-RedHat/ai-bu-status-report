# Weekly Status Report Generator

Generate a weekly status report by scanning git activity, GitHub PRs, and issues.

## Arguments

$ARGUMENTS can be used to specify:
- A custom timeframe (e.g., "last 2 weeks", "since 2024-01-15")
- A specific repo filter (e.g., "repo:ai-bu-hub-build")
- Both combined (e.g., "last 2 weeks repo:ai-bu-hub-build")

If no arguments are provided, default to the past 7 days across all repos the user has access to.

## Config File Support

Before starting, check if `~/.status-config` exists. If it does, read it and apply any defaults. Config values are overridden by explicit $ARGUMENTS. See the README for config file format.

```bash
if [ -f "$HOME/.status-config" ]; then
  cat "$HOME/.status-config"
fi
```

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

### Step 6: Categorize Work into Themes

Review all collected data and group items into these categories:

- **Content**: Documentation, blog posts, tutorials, presentations, demos
- **Engineering**: Code contributions, bug fixes, new features, infrastructure work
- **Reviews**: PR reviews, code review comments, design review participation
- **Community**: Issue triage, community responses, upstream contributions, conference work

Use commit messages, PR titles, and issue titles to determine the best category. If something does not fit neatly, use your best judgment.

### Step 7: Generate the Status Report

Output the report in **exactly** this structure. Do not add, remove, or rename sections.

---

## Weekly Status Report

**Period**: [start date] to [end date]
**Author**: [git user name]
**Repos scanned**: [list of repos included]

### Impact Summary

| Metric | Count |
|--------|-------|
| Commits | X |
| PRs Opened | X |
| PRs Merged | X |
| PRs Reviewed | X |
| Issues Closed | X |
| Lines Added | +X |
| Lines Removed | -X |

### Completed

Group completed items by theme. Each item must include a brief description AND a link to the PR or issue when available.

**Engineering**
- [item description] ([PR #NNN](url)) - [+X/-Y lines]

**Content**
- [item description] ([link if available])

**Reviews**
- Reviewed [PR title] ([PR #NNN](url))

**Community**
- [item description] ([link if available])

Only include theme headings that have items. If a theme has no items, omit it entirely.

### In Progress

List open PRs and any work that appears ongoing based on recent commits without a corresponding merged PR. Include links where available.

- [item description] ([PR #NNN](url)) - opened [date], [X days old]

### Planned Next Week

Populate this from open issues assigned to the user (gathered in Step 5). List each with its repo and any milestone or label context.

- [issue title] ([repo name], [milestone if any]) ([Issue #NNN](url))

If no open assigned issues are found, state: "No assigned issues found. Fill in manually or assign issues to yourself on GitHub."

### Blockers

Check for:
- PRs that have been open for more than 5 days without review
- Issues labeled as "blocked" or "waiting"
- Any failed CI checks on open PRs

If no blockers are found, state "No blockers identified."

---

### Output Rules

- Keep descriptions concise. One line per item.
- Always quantify: include PR numbers, line counts, issue counts. Do not use vague language like "several" or "various."
- If data is sparse (fewer than 3 commits and no PRs), note that and suggest the user may want to expand the timeframe.
- If GitHub CLI is not authenticated, inform the user and provide instructions: `gh auth login`.
- Do not fabricate activity. Only report what the data shows.
- Use the report format specified in `~/.status-config` if one is set (markdown or plain text). Default to markdown.
