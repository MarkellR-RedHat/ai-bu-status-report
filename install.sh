#!/bin/bash
# install.sh - Install ai-bu-status-report commands into Claude Code
#
# Copies 8 slash commands into ~/.claude/commands/ where Claude Code
# picks them up automatically. No other configuration required.

set -e

COMMANDS_DIR="$HOME/.claude/commands"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/commands"

echo ""
echo "  ai-bu-status-report"
echo "  Status reports worth reading."
echo ""

# Verify source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "  ERROR: commands/ directory not found."
  echo "  Make sure you are running this from the ai-bu-status-report directory."
  echo ""
  exit 1
fi

# Create the commands directory if it does not exist
mkdir -p "$COMMANDS_DIR"

# Install each command, showing progress
COMMANDS=(
  "status-report"
  "executive-summary"
  "team-report"
  "quarterly-review"
  "okr-update"
  "status-trends"
  "risk-register"
  "stakeholder-view"
)

INSTALLED=0
FAILED=0

for cmd in "${COMMANDS[@]}"; do
  if [ -f "$SOURCE_DIR/$cmd.md" ]; then
    cp "$SOURCE_DIR/$cmd.md" "$COMMANDS_DIR/$cmd.md"
    echo "  installed  /$cmd"
    INSTALLED=$((INSTALLED + 1))
  else
    echo "  MISSING    /$cmd  (file not found in commands/)"
    FAILED=$((FAILED + 1))
  fi
done

echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "  WARNING: $FAILED command(s) could not be installed."
  echo "  $INSTALLED command(s) installed successfully."
else
  echo "  All $INSTALLED commands installed."
fi

echo ""
echo "  Try it now:"
echo ""
echo "    Open Claude Code in any repo and run:"
echo ""
echo "      /status-report"
echo ""
echo "  Optional: Create ~/.status-config for defaults (repos, team, timeframe)."
echo "  See the README for format."
echo ""
