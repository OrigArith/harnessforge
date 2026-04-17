#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_VALIDATOR="$PROJECT_ROOT/tests/smoke/validate-skills.sh"

RUN_OUTPUT=""
RUN_STATUS=0

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

run_validator_fixture() {
    local builder="$1"
    local tmpdir
    local output_file

    tmpdir="$(mktemp -d)"
    output_file="$tmpdir/output.log"

    mkdir -p "$tmpdir/tests/smoke" "$tmpdir/skills"
    ln -s "$SOURCE_VALIDATOR" "$tmpdir/tests/smoke/validate-skills.sh"

    "$builder" "$tmpdir"

    if (cd "$tmpdir" && bash tests/smoke/validate-skills.sh >"$output_file" 2>&1); then
        RUN_STATUS=0
    else
        RUN_STATUS=$?
    fi

    RUN_OUTPUT="$(cat "$output_file")"
    rm -rf "$tmpdir"
}

build_multiline_description_fixture() {
    local root="$1"

    mkdir -p "$root/skills/forge-demo"
    cat >"$root/skills/forge-demo/SKILL.md" <<'EOF'
---
name: forge-demo
description: >
  Use this skill when validating folded YAML descriptions.
  It ensures the validator reads the full scalar value.
license: MIT
compatibility: "No runtime dependencies."
metadata:
  owner: harnessforge
allowed-tools: Bash Read
---

# Forge Demo

Minimal body.
EOF
}

build_missing_allowed_tools_fixture() {
    local root="$1"

    mkdir -p "$root/skills/forge-demo"
    cat >"$root/skills/forge-demo/SKILL.md" <<'EOF'
---
name: forge-demo
description: "Use this skill when validating required frontmatter fields."
license: MIT
compatibility: "No runtime dependencies."
metadata:
  owner: harnessforge
---

# Forge Demo

Minimal body.
EOF
}

build_missing_license_fixture() {
    local root="$1"

    mkdir -p "$root/skills/forge-demo"
    cat >"$root/skills/forge-demo/SKILL.md" <<'EOF'
---
name: forge-demo
description: "Use this skill when validating missing license handling."
compatibility: "No runtime dependencies."
metadata:
  owner: harnessforge
allowed-tools: Bash Read
---

# Forge Demo

Minimal body.
EOF
}

test_multiline_description_passes_without_warnings() {
    run_validator_fixture build_multiline_description_fixture

    [[ "$RUN_STATUS" -eq 0 ]] || fail "expected multiline description fixture to pass"
    [[ "$RUN_OUTPUT" == *"PASS"* ]] || fail "expected validator output to contain PASS"
    [[ "$RUN_OUTPUT" != *"WARN"* ]] || fail "expected multiline description fixture to avoid warnings"
}

test_missing_allowed_tools_is_blocking_error() {
    run_validator_fixture build_missing_allowed_tools_fixture

    [[ "$RUN_STATUS" -ne 0 ]] || fail "expected missing allowed-tools fixture to fail"
    [[ "$RUN_OUTPUT" == *"Missing 'allowed-tools' field"* ]] || fail "expected missing allowed-tools error"
}

test_missing_license_is_blocking_error() {
    run_validator_fixture build_missing_license_fixture

    [[ "$RUN_STATUS" -ne 0 ]] || fail "expected missing license fixture to fail"
    [[ "$RUN_OUTPUT" == *"Missing 'license' field"* ]] || fail "expected missing license error"
}

test_multiline_description_passes_without_warnings
test_missing_allowed_tools_is_blocking_error
test_missing_license_is_blocking_error

echo "PASS: validator regression checks"
