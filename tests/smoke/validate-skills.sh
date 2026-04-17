#!/bin/bash
set -euo pipefail

# HarnessForge Skill Validator
# Checks all SKILL.md files for structural correctness.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/skills"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0
CHECKED=0

record_pass() {
    echo -e "  ${GREEN}PASS${NC} $1"
}

record_error() {
    echo -e "  ${RED}FAIL${NC} $1"
    ERRORS=$((ERRORS + 1))
}

normalize_scalar() {
    local value="$1"

    value="$(printf '%s' "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    if [[ ${#value} -ge 2 && "$value" == \"*\" && "$value" == *\" ]]; then
        value="${value:1:${#value}-2}"
    fi

    if [[ ${#value} -ge 2 && "$value" == \'*\' && "$value" == *\' ]]; then
        value="${value:1:${#value}-2}"
    fi

    printf '%s' "$value"
}

extract_scalar_field() {
    local skill_md="$1"
    local field="$2"
    local raw

    raw="$(awk -v field="$field" '
        BEGIN { in_frontmatter=0; capture=0; block=0; value="" }
        NR==1 {
            if ($0 == "---") {
                in_frontmatter=1
                next
            }
            exit
        }
        !in_frontmatter { next }
        $0 == "---" {
            if (capture && block) {
                print value
            }
            exit
        }
        capture && block {
            if ($0 ~ /^[^[:space:]#][A-Za-z0-9_-]*:[[:space:]]*/) {
                print value
                exit
            }
            if ($0 ~ /^[[:space:]]*$/) {
                next
            }
            if ($0 ~ /^[[:space:]]+/) {
                line = $0
                sub(/^[[:space:]]+/, "", line)
                sub(/[[:space:]]+$/, "", line)
                value = value (value == "" ? "" : " ") line
                next
            }
            print value
            exit
        }
        !capture && $0 ~ ("^" field ":[[:space:]]*") {
            capture = 1
            line = $0
            sub("^" field ":[[:space:]]*", "", line)
            sub(/[[:space:]]+$/, "", line)
            if (line ~ /^[>|][+-]?$/) {
                block = 1
                next
            }
            print line
            exit
        }
    ' "$skill_md")"

    normalize_scalar "$raw"
}

extract_mapping_lines() {
    local skill_md="$1"
    local field="$2"

    awk -v field="$field" '
        BEGIN { in_frontmatter=0; capture=0 }
        NR==1 {
            if ($0 == "---") {
                in_frontmatter=1
                next
            }
            exit
        }
        !in_frontmatter { next }
        $0 == "---" { exit }
        capture {
            if ($0 ~ /^[^[:space:]#][A-Za-z0-9_-]*:[[:space:]]*/) {
                exit
            }
            if ($0 ~ /^[[:space:]]+/) {
                print $0
            }
            next
        }
        $0 ~ ("^" field ":[[:space:]]*$") {
            capture=1
        }
    ' "$skill_md"
}

check_skill() {
    local skill_dir="$1"
    local skill_name
    local skill_md
    local first_line
    local end_line
    local fm_name
    local fm_desc
    local fm_license
    local fm_compatibility
    local fm_allowed_tools
    local metadata_lines
    local line_count
    local body_text
    local refs
    local examples
    local ref_errors=0

    skill_name="$(basename "$skill_dir")"
    skill_md="$skill_dir/SKILL.md"

    CHECKED=$((CHECKED + 1))
    echo "Checking $skill_name..."

    if [[ ! -f "$skill_md" ]]; then
        record_error "SKILL.md not found"
        return
    fi

    first_line="$(head -1 "$skill_md")"
    if [[ "$first_line" != "---" ]]; then
        record_error "Missing YAML frontmatter (first line must be ---)"
        return
    fi

    end_line="$(awk 'NR>1 && /^---$/{print NR; exit}' "$skill_md")"
    if [[ -z "$end_line" || "$end_line" -le 2 ]]; then
        record_error "Could not find closing --- for frontmatter"
        return
    fi

    fm_name="$(extract_scalar_field "$skill_md" "name")"
    if [[ -z "$fm_name" ]]; then
        record_error "Missing 'name' field in frontmatter"
    elif [[ ! "$fm_name" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ || "$fm_name" == *--* ]]; then
        record_error "Invalid skill name '$fm_name' (expected lowercase letters, digits, and single hyphens)"
    elif [[ "$fm_name" != "$skill_name" ]]; then
        record_error "name '$fm_name' does not match directory '$skill_name'"
    else
        record_pass "name matches directory"
    fi

    fm_desc="$(extract_scalar_field "$skill_md" "description")"
    if [[ -z "$fm_desc" ]]; then
        record_error "Missing 'description' field in frontmatter"
    elif [[ ${#fm_desc} -gt 1024 ]]; then
        record_error "description is ${#fm_desc} characters (max 1024)"
    elif [[ "$fm_desc" != Use\ this\ skill\ when* ]]; then
        record_error "description must start with 'Use this skill when'"
    else
        record_pass "description format correct"
    fi

    fm_license="$(extract_scalar_field "$skill_md" "license")"
    if [[ -z "$fm_license" ]]; then
        record_error "Missing 'license' field in frontmatter"
    else
        record_pass "license field present"
    fi

    fm_compatibility="$(extract_scalar_field "$skill_md" "compatibility")"
    if [[ -z "$fm_compatibility" ]]; then
        record_error "Missing 'compatibility' field in frontmatter"
    else
        record_pass "compatibility field present"
    fi

    metadata_lines="$(extract_mapping_lines "$skill_md" "metadata")"
    if [[ -z "$metadata_lines" ]]; then
        record_error "Missing 'metadata' field in frontmatter"
    else
        record_pass "metadata field present"
    fi

    fm_allowed_tools="$(extract_scalar_field "$skill_md" "allowed-tools")"
    if [[ -z "$fm_allowed_tools" ]]; then
        record_error "Missing 'allowed-tools' field in frontmatter"
    elif [[ ! "$fm_allowed_tools" =~ ^[A-Za-z][A-Za-z0-9_-]*(\ [A-Za-z][A-Za-z0-9_-]*)*$ ]]; then
        record_error "Invalid 'allowed-tools' field format"
    else
        record_pass "allowed-tools field present"
    fi

    line_count="$(wc -l < "$skill_md" | tr -d ' ')"
    if [[ "$line_count" -gt 500 ]]; then
        record_error "SKILL.md is $line_count lines (max 500)"
    else
        record_pass "$line_count lines (< 500)"
    fi

    body_text="$(awk '/^```/{skip=!skip; next} !skip{print}' "$skill_md")"
    refs="$(echo "$body_text" | grep -oE 'references/[a-zA-Z0-9_-]+\.md' 2>/dev/null | sort -u || true)"
    for ref in $refs; do
        local ref_base
        ref_base="$(basename "$ref" .md)"
        if [[ ${#ref_base} -le 1 ]]; then
            continue
        fi
        if [[ ! -f "$skill_dir/$ref" ]]; then
            record_error "Referenced file not found: $ref"
            ref_errors=$((ref_errors + 1))
        fi
    done

    examples="$(echo "$body_text" | grep -oE 'examples/[a-zA-Z0-9_-]+\.md' 2>/dev/null | sort -u || true)"
    for ex in $examples; do
        local ex_base
        ex_base="$(basename "$ex" .md)"
        if [[ ${#ex_base} -le 1 ]]; then
            continue
        fi
        if [[ ! -f "$skill_dir/$ex" ]]; then
            record_error "Referenced file not found: $ex"
            ref_errors=$((ref_errors + 1))
        fi
    done

    if [[ "$ref_errors" -eq 0 ]]; then
        record_pass "reference integrity"
    fi
}

echo "========================================="
echo "  HarnessForge Skill Validation"
echo "========================================="
echo ""

for skill_dir in "$SKILLS_DIR"/forge-*; do
    if [[ -d "$skill_dir" ]]; then
        check_skill "$skill_dir"
        echo ""
    fi
done

echo "========================================="
echo "  Results: $CHECKED skills checked"
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"
echo "========================================="

if [[ "$ERRORS" -gt 0 ]]; then
    echo -e "${RED}VALIDATION FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}ALL CHECKS PASSED${NC}"
    exit 0
fi
