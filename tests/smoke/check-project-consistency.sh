#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

count="$(cd "$PROJECT_ROOT" && ls -A1 | wc -l | tr -d ' ')"
if [[ "$count" -gt 15 ]]; then
    fail "root directory has $count entries when counted with hidden files"
fi

ds_store_path="$(find "$PROJECT_ROOT" -name '.DS_Store' -print -quit)"
if [[ -n "$ds_store_path" ]]; then
    fail "unexpected .DS_Store tracked in repository: ${ds_store_path#$PROJECT_ROOT/}"
fi

tmp_home="$(mktemp -d)"
install_output="$(HOME="$tmp_home" bash "$PROJECT_ROOT/scripts/install.sh" --global)"
rm -rf "$tmp_home"

[[ "$install_output" == *"/forge-init"* ]] || fail "install script should point users to /forge-init"
[[ "$install_output" != *"/forge-scaffold"* ]] || fail "install script should not mention removed /forge-scaffold command"

if grep -q '/forge-scaffold' "$PROJECT_ROOT/CLAUDE.md"; then
    fail "CLAUDE.md still references removed /forge-scaffold command"
fi

if grep -q 'All 7 forge-\* skills' "$PROJECT_ROOT/CLAUDE.md"; then
    fail "CLAUDE.md still claims there are 7 forge skills"
fi

echo "PASS: project consistency checks"
