#!/bin/bash
#
# Cursor IDE setup for Linux kernel development
#
# Installs:
#   - Kernel skill to <linux>/.cursor/skills/kernel/SKILL.md
#   - Cursor rules to <linux>/.cursor/rules/
#
# MCP configuration (.cursor/mcp.json) is handled by semcode's own
# install script: semcode/plugin/semcode/install.sh
#
# The prompts directory is determined from this script's location.
#
# Usage:
#   cd /path/to/linux
#   /path/to/review-prompts/kernel/scripts/cursor-setup.sh [--linux <dir>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Parse arguments
LINUX_DIR=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --linux)  LINUX_DIR="$2"; shift 2 ;;
        --help)
            echo "Usage: cursor-setup.sh [--linux <linux-dir>]"
            exit 0
            ;;
        *)  echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [ -z "$LINUX_DIR" ]; then
    LINUX_DIR="$(pwd -P)"
fi

if [ ! -f "$LINUX_DIR/Makefile" ] || ! grep -q "^VERSION = " "$LINUX_DIR/Makefile" 2>/dev/null; then
    echo "Error: $LINUX_DIR does not look like a Linux kernel tree." >&2
    echo "  Run from your kernel tree:  cd ~/linux && $0" >&2
    echo "  Or specify it explicitly:   $0 --linux ~/linux" >&2
    exit 1
fi

echo "Review prompts directory: $PROMPTS_DIR"
echo "Linux kernel directory:   $LINUX_DIR"
echo ""

CURSOR_DIR="$LINUX_DIR/.cursor"

# --- Install Skill ---

SKILL_DIR="$CURSOR_DIR/skills/kernel"
SKILL_FILE="$SKILL_DIR/SKILL.md"
SOURCE_SKILL="$PROMPTS_DIR/skills/kernel.md"

if [ ! -f "$SOURCE_SKILL" ]; then
    echo "Error: Source skill file not found: $SOURCE_SKILL"
    exit 1
fi

mkdir -p "$SKILL_DIR"

sed "s|{{KERNEL_REVIEW_PROMPTS_DIR}}|$PROMPTS_DIR|g" "$SOURCE_SKILL" > "$SKILL_FILE"

echo "Installed skill:"
echo "  $SKILL_FILE"

# --- Install Cursor Rules ---
RULES_DIR="$CURSOR_DIR/rules"
RULES_SRC="$PROMPTS_DIR/cursor-rules"

mkdir -p "$RULES_DIR"

if [ -d "$RULES_SRC" ]; then
    echo ""
    echo "Installed Cursor rules:"

    for rule_file in "$RULES_SRC"/*.mdc; do
        if [ -f "$rule_file" ]; then
            rule_name=$(basename "$rule_file")
            cp "$rule_file" "$RULES_DIR/$rule_name"
            echo "  $rule_name"
        fi
    done
else
    echo "Warning: cursor-rules directory not found: $RULES_SRC"
fi

# --- Check MCP Config ---

MCP_FILE="$CURSOR_DIR/mcp.json"
if [ ! -f "$MCP_FILE" ]; then
    echo ""
    echo "Warning: $MCP_FILE not found."
    echo "  Run semcode's install script to configure the MCP server:"
    echo "    semcode/plugin/semcode/install.sh"
fi

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Run semcode/plugin/semcode/install.sh (if not done already)"
echo "  2. Open the Linux tree in Cursor"
echo "  3. Verify semcode MCP appears in Cursor settings"
echo "  4. Test: paste a lore.kernel.org URL in chat"
