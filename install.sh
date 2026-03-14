#!/usr/bin/env bash
# Morpheus — The autonomous dev loop for Claude Code
# By Evolving Intelligence AI (https://evolvingintelligence.ai)
#
# Install: curl -sSL https://raw.githubusercontent.com/evo-hydra/morpheus/main/install.sh | bash
# Or:      git clone https://github.com/evo-hydra/morpheus ~/.claude/plugins/morpheus

set -euo pipefail

PLUGIN_DIR="${HOME}/.claude/plugins/morpheus"
REPO_URL="https://github.com/evo-hydra/morpheus.git"

echo ""
echo "  Morpheus — \"I'm trying to free your mind, Neo.\""
echo "  The autonomous dev loop for Claude Code"
echo "  By Evolving Intelligence AI"
echo ""

# Check if already installed
if [ -d "$PLUGIN_DIR" ]; then
  echo "  Updating existing installation..."
  cd "$PLUGIN_DIR"
  git pull --quiet
  echo "  Updated."
else
  echo "  Installing to $PLUGIN_DIR..."
  mkdir -p "$(dirname "$PLUGIN_DIR")"
  git clone --quiet "$REPO_URL" "$PLUGIN_DIR"
  echo "  Installed."
fi

echo ""
echo "  Commands available:"
echo "    /morpheus [plan-file]  — Run the autonomous dev loop"
echo "    /plan [description]    — Create a structured development plan"
echo ""
echo "  Optional MCP servers (install for full intelligence):"
echo "    pip install git-sentinel   # Project history intelligence"
echo "    pip install seraph-ai      # Mutation testing + quality gate"
echo "    pip install niobe           # Runtime observation"
echo "    pip install merovingian     # API contract verification"
echo ""
echo "  Get started:"
echo "    1. Open Claude Code in your project"
echo "    2. Type: /plan \"describe what you want to build\""
echo "    3. Type: /morpheus plans/your-plan.md"
echo ""
echo "  Docs: https://github.com/evo-hydra/morpheus"
echo "  Suite: https://evolvingintelligence.ai"
echo ""
