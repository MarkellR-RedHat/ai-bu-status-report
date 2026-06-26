# Weekly Status Report Generator

Generate a weekly status report by scanning git activity, GitHub PRs, and issues.

## Arguments

$ARGUMENTS can be used to specify:
- A custom timeframe (e.g., "last 2 weeks", "since 2024-01-15")
- A specific repo filter (e.g., "repo:ai-bu-hub-build")
- Both combined (e.g., "last 2 weeks repo:ai-bu-hub-build")

If no arguments are provided, default to the past 7 days across all repos the user has access to.

## Instructions

### Step 1: Determine Timeframe and Scope

Parse $ARGUMENTS to extract:
- **Timeframe**: Default to "7 days ago" if not specified. Support natural language like "last 2 weeks", "since Monday", or specific dates.
- **Repo filter**: If a repo is specified, scope all queries to that repo. Otherwise, scan broadly.

### Step 2: Gather Git Commit Activity

Run the following to collect commits:

```bash
# Get the git user's email/name for filtering
git config user.email
git config user.name

# For each repo (or the filtered repo), scan commits
git log --since="<timeframe>" --author="<user>" --pretty=format:"%h %s (%ar)" --no-merges
```

If working inside a single repo, scan that repo. If the user wants cross-repo scanning, check for repos under common workspace directories (~/projects, ~/src, or wherever the user's repos live). Ask the user if the location is unclear.

### Step 3: Gather GitHub PR Activity

Use the GitHub CLI to pull PR data:

```bash
# PRs opened by the user in the timeframe
gh search prs --author=@me --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt

# PRs reviewed by the user
gh search prs --reviewed-by=@me --created=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt

# PRs merged by the user
gh search prs --author=@me --merged=">$(date -v-7d +%Y-%m-%d)" --json title,url,state,repository,createdAt
```

If a repo filter is specified, add `--repo=<owner/repo>` to each command.

### Step 4: Gather Issue Activity

```bash
# Issues closed by the user
gh search issues --author=@me --closed=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,closedAt

# Issues the user commented on recently
gh search issues --commenter=@me --updated=">$(date -v-7d +%Y-%m-%d)" --json title,url,repository,updatedAt
```

### Step 5: Categorize Work into Themes

Review all collected data and group items into these categories:

- **Content**: Documentation, blog posts, tutorials, presentations, demos
- **Engineering**: Code contributions, bug fixes, new features, infrastructure work
- **Reviews**: PR reviews, code review comments, design review participation
- **Community**: Issue triage, community responses, upstream contributions, conference work

Use commit messages, PR titles, and issue titles to determine the best category. If something does not fit neatly, use your best judgment.

### Step 6: Generate the Status Report

Output the report in this format:

---

## Weekly Status Report

**Period**: [start date] to [end date]
**Author**: [git user name]

### Completed

Group completed items by theme. Each item should include a brief description and a link to the PR or issue if available.

**Engineering**
- [item description] ([PR #NNN](url))

**Content**
- [item description]

**Reviews**
- Reviewed [PR title] ([PR #NNN](url))

**Community**
- [item description]

### In Progress

List open PRs and any work that appears ongoing based on recent commits without a corresponding merged PR. Include links where available.

- [item description] ([PR #NNN](url))

### Planned Next Week

Based on open issues assigned to the user and any patterns in recent work, suggest what might be coming next. If unsure, note that this section should be filled in manually.

- [item or placeholder]

### Blockers

Check for:
- PRs that have been open for more than 5 days without review
- Issues labeled as "blocked" or "waiting"
- Any failed CI checks on open PRs

If no blockers are found, state "No blockers identified."

---

### Notes

- Keep descriptions concise. One line per item.
- If data is sparse (few commits, no PRs), note that and suggest the user may want to expand the timeframe.
- If GitHub CLI is not authenticated, inform the user and provide instructions: `gh auth login`.
- Do not fabricate activity. Only report what the data shows.
