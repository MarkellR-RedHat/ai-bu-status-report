#!/bin/bash
# install.sh - Install ai-bu-status-report commands into Claude Code

set -e

COMMANDS_DIR="$HOME/.claude/commands"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/commands"

echo ""
echo "  ai-bu-status-report"
echo "  Status reports worth reading."
echo ""

# Create the commands directory if it does not exist
mkdir -p "$COMMANDS_DIR"

# Copy command files
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

for cmd in "${COMMANDS[@]}"; do
  cp "$SOURCE_DIR/$cmd.md" "$COMMANDS_DIR/$cmd.md"
done

echo "  Installed 8 commands:"
echo ""
echo "  Core Reports:"
echo "    /status-report        Weekly status with impact metrics and risk detection"
echo "    /executive-summary    VP-ready paragraph with traffic light status"
echo "    /team-report          Team rollup with bottleneck analysis"
echo "    /quarterly-review     Quarter summary ready for performance reviews"
echo ""
echo "  Analysis Tools:"
echo "    /okr-update           Map work to OKRs with gap analysis"
echo "    /status-trends        Multi-week trends with sparkline charts"
echo "    /risk-register        Risk register with scoring and mitigations"
echo "    /stakeholder-view     Same data tailored to exec, pm, eng, or external"
echo ""
echo "  Try it now:"
echo ""
echo "    /status-report"
echo "    /executive-summary org:my-org for:vp"
echo "    /stakeholder-view exec"
echo ""
echo "  Optional: Create ~/.status-config for defaults (repos, team, timeframe)."
echo "  See the README for format."
echo ""
echo "  Done."
echo ""
