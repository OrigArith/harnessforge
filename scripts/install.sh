#!/bin/bash
set -euo pipefail

# HarnessForge Installer
# Symlinks skills to the correct platform paths for discovery.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_SRC="$PROJECT_ROOT/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 [--global|--project] [--uninstall]"
    echo ""
    echo "Options:"
    echo "  --global      Install to user-level paths (default)"
    echo "                Claude Code: ~/.claude/skills/"
    echo "                Codex:       ~/.agents/skills/"
    echo "  --project     Install to current project directory"
    echo "                Claude Code: ./.claude/skills/"
    echo "                Codex:       ./.agents/skills/"
    echo "  --uninstall   Remove installed symlinks"
    echo "  --help        Show this message"
}

MODE="global"
UNINSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --global)  MODE="global"; shift ;;
        --project) MODE="project"; shift ;;
        --uninstall) UNINSTALL=true; shift ;;
        --help)    usage; exit 0 ;;
        *)         echo -e "${RED}Unknown option: $1${NC}"; usage; exit 1 ;;
    esac
done

# Determine target paths
if [[ "$MODE" == "global" ]]; then
    CLAUDE_TARGET="$HOME/.claude/skills"
    CODEX_TARGET="$HOME/.agents/skills"
else
    CLAUDE_TARGET="./.claude/skills"
    CODEX_TARGET="./.agents/skills"
fi

# Get list of skills
SKILLS=($(ls -d "$SKILLS_SRC"/forge-* 2>/dev/null | xargs -n1 basename))

if [[ ${#SKILLS[@]} -eq 0 ]]; then
    echo -e "${RED}Error: No forge-* skills found in $SKILLS_SRC${NC}"
    exit 1
fi

if [[ "$UNINSTALL" == true ]]; then
    echo "Uninstalling HarnessForge skills..."
    for skill in "${SKILLS[@]}"; do
        for target in "$CLAUDE_TARGET" "$CODEX_TARGET"; do
            link="$target/$skill"
            if [[ -L "$link" ]]; then
                rm "$link"
                echo -e "  ${RED}Removed${NC} $link"
            fi
        done
    done
    echo -e "${GREEN}Uninstall complete.${NC}"
    exit 0
fi

echo "Installing HarnessForge skills ($MODE mode)..."
echo ""

# Create target directories
mkdir -p "$CLAUDE_TARGET" "$CODEX_TARGET"

# Create symlinks
for skill in "${SKILLS[@]}"; do
    src="$SKILLS_SRC/$skill"

    # Claude Code
    link="$CLAUDE_TARGET/$skill"
    if [[ -L "$link" || -e "$link" ]]; then
        echo -e "  ${YELLOW}Skip${NC}  $link (already exists)"
    else
        ln -s "$src" "$link"
        echo -e "  ${GREEN}Link${NC}  $link -> $src"
    fi

    # Codex
    link="$CODEX_TARGET/$skill"
    if [[ -L "$link" || -e "$link" ]]; then
        echo -e "  ${YELLOW}Skip${NC}  $link (already exists)"
    else
        ln -s "$src" "$link"
        echo -e "  ${GREEN}Link${NC}  $link -> $src"
    fi
done

echo ""
echo -e "${GREEN}Done!${NC} ${#SKILLS[@]} skills installed."
echo ""
echo "Installed to:"
echo "  Claude Code: $CLAUDE_TARGET"
echo "  Codex:       $CODEX_TARGET"
echo ""
echo "Try it: type /forge-init in your coding agent."
