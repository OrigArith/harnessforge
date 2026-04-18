#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

count="$(cd "$PROJECT_ROOT" && ls -A1 | wc -l | tr -d ' ')"
if [[ "$count" -gt 18 ]]; then
    fail "root directory has $count entries when counted with hidden files (max 18)"
fi

ds_store_path="$(find "$PROJECT_ROOT" -name '.DS_Store' -print -quit)"
if [[ -n "$ds_store_path" ]]; then
    fail "unexpected .DS_Store tracked in repository: ${ds_store_path#$PROJECT_ROOT/}"
fi

skill_count="$(ls -d "$PROJECT_ROOT"/skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
if [[ "$skill_count" -ne 5 ]]; then
    fail "expected 5 skills but found $skill_count"
fi

if grep -q '/forge-scaffold' "$PROJECT_ROOT/CLAUDE.md"; then
    fail "CLAUDE.md still references removed /forge-scaffold command"
fi

if grep -q 'All 7 forge-\* skills' "$PROJECT_ROOT/CLAUDE.md"; then
    fail "CLAUDE.md still claims there are 7 forge skills"
fi

echo "PASS: project consistency checks"
