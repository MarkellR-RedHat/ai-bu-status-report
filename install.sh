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

echo "Installed commands:"
echo "  /status-report    - Weekly status report from git and GitHub activity"
echo "  /quarterly-review - Quarterly summary grouped by initiative"
echo ""
echo "Usage:"
echo "  /status-report"
echo "  /status-report last 2 weeks"
echo "  /status-report repo:my-org/my-repo"
echo "  /quarterly-review Q1 2025"
echo ""
echo "Done. Commands are ready to use in Claude Code."
