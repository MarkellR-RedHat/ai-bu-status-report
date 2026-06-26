#!/bin/bash
# install.sh - Install ai-bu-status-report commands into Claude Code

set -e

COMMANDS_DIR="$HOME/.claude/commands"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/commands"

echo "Installing ai-bu-status-report commands..."

# Create the commands directory if it does not exist
mkdir -p "$COMMANDS_DIR"

# Copy command files
cp "$SOURCE_DIR/status-report.md" "$COMMANDS_DIR/status-report.md"
cp "$SOURCE_DIR/quarterly-review.md" "$COMMANDS_DIR/quarterly-review.md"
cp "$SOURCE_DIR/team-report.md" "$COMMANDS_DIR/team-report.md"
cp "$SOURCE_DIR/okr-update.md" "$COMMANDS_DIR/okr-update.md"
cp "$SOURCE_DIR/executive-summary.md" "$COMMANDS_DIR/executive-summary.md"

echo "Installed commands:"
echo "  /status-report      - Weekly status report from git and GitHub activity"
echo "  /quarterly-review   - Quarterly summary grouped by initiative"
echo "  /team-report        - Aggregate status across multiple team members"
echo "  /okr-update         - Map recent work to your OKRs"
echo "  /executive-summary  - One-paragraph summary for skip-level or all-hands"
echo ""
echo "Usage:"
echo "  /status-report"
echo "  /status-report last 2 weeks"
echo "  /status-report repo:my-org/my-repo"
echo "  /quarterly-review Q1 2025"
echo "  /team-report org:my-org"
echo "  /okr-update O1: Ship model router KR1: Reduce latency by 30%"
echo "  /executive-summary org:my-org for:vp"
echo ""
echo "Optional: Create ~/.status-config to set defaults. See README for format."
echo ""
echo "Done. Commands are ready to use in Claude Code."
