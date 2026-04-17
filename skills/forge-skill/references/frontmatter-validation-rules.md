# Frontmatter Validation Rules

Exact constraints and validation patterns for each of the 6 core SKILL.md frontmatter fields.

---

## name (Required)

| Property | Rule |
|----------|------|
| Type | string |
| Required | Yes |
| Min length | 1 character |
| Max length | 64 characters |
| Allowed characters | Lowercase letters (`a-z`), digits (`0-9`), hyphens (`-`) |
| Regex pattern | `^[a-z0-9]([a-z0-9-]*[a-z0-9])?$` |
| No leading hyphen | Must start with `[a-z0-9]` |
| No trailing hyphen | Must end with `[a-z0-9]` |
| No consecutive hyphens | Must not contain `--` |
| Directory match | Value must exactly equal the parent directory name: `basename(dirname(SKILL.md))` |

**Validation pseudocode:**

```
assert len(name) >= 1 and len(name) <= 64
assert re.match(r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?$', name)
assert '--' not in name
assert name == parent_directory_name
```

**Valid examples:** `api-migration-helper`, `forge-skill`, `my-tool`, `a1b2`

**Invalid examples:** `-starts-with-hyphen`, `ends-with-hyphen-`, `has--double-hyphen`, `HasUpperCase`, `has_underscore`, `has spaces`, (empty string), (65+ characters)

---

## description (Required)

| Property | Rule |
|----------|------|
| Type | string |
| Required | Yes |
| Min length | 1 character |
| Max length | 1024 characters |
| Recommended format | Must start with `"Use this skill when ..."` |
| Claude Code combined limit | `description` + `when_to_use` max 1,536 characters |

**Validation pseudocode:**

```
assert len(description) >= 1 and len(description) <= 1024
assert description.strip().startswith("Use this skill when")
```

**Content requirements (not machine-validated but essential):**
- Covers the main use case (what the skill does).
- Includes variant expressions and synonyms.
- States boundaries if ambiguity is likely.
- Ends with trigger keywords.

---

## license (Optional)

| Property | Rule |
|----------|------|
| Type | string |
| Required | No |
| Recommended values | SPDX identifiers: `MIT`, `Apache-2.0`, `BSD-3-Clause`, `GPL-3.0-only`, `ISC` |
| Constraint | Keep short. No multi-paragraph license text. |

**Validation pseudocode:**

```
if license is present:
    assert isinstance(license, str)
    assert len(license) <= 128  # practical limit
```

---

## compatibility (Optional)

| Property | Rule |
|----------|------|
| Type | string |
| Required | No |
| Min length | 1 character (if present) |
| Max length | 500 characters |
| Purpose | Declare runtime, system package, or network requirements |

**Validation pseudocode:**

```
if compatibility is present:
    assert len(compatibility) >= 1 and len(compatibility) <= 500
```

**Guidance:** Omit this field entirely if the skill has no runtime dependencies. Most skills do not need it.

---

## metadata (Optional)

| Property | Rule |
|----------|------|
| Type | map<string, string> |
| Required | No |
| Key constraints | Use unique, descriptive keys to avoid collisions across skills |
| Value constraints | All values must be strings |

**Validation pseudocode:**

```
if metadata is present:
    assert isinstance(metadata, dict)
    for key, value in metadata.items():
        assert isinstance(key, str)
        assert isinstance(value, str)
```

**Common keys:**

| Key | Example Value | Purpose |
|-----|---------------|---------|
| `author` | `"your-team"` | Skill author or team |
| `version` | `"1.0.0"` | Semantic version of the skill |
| `category` | `"refactoring"` | Skill category for organization |

---

## allowed-tools (Optional, Experimental)

| Property | Rule |
|----------|------|
| Type | string |
| Required | No |
| Format | Space-separated list of tool names |
| Regex pattern | `^[A-Za-z][A-Za-z0-9_-]*(\s+[A-Za-z][A-Za-z0-9_-]*)*$` |
| Status | Experimental. Support varies across platforms. |

**Validation pseudocode:**

```
if allowed_tools is present:
    tools = allowed_tools.split()
    assert len(tools) >= 1
    for tool in tools:
        assert re.match(r'^[A-Za-z][A-Za-z0-9_-]*$', tool)
```

**Common tool names:** `Bash`, `Read`, `Edit`, `Write`, `Glob`, `Grep`

---

## Structural Validation (Beyond Individual Fields)

| Rule | Check |
|------|-------|
| Frontmatter delimiters | File starts with `---` and has a closing `---` |
| Valid YAML | Frontmatter block parses as valid YAML |
| No unknown required fields | Only the 6 defined fields are expected by core spec |
| Body exists | Content exists after the closing `---` delimiter |
| Line count | Total file line count <= 500 |
| Token count | Total file token count <= 5000 (estimate: lines * 10) |
| Referenced files exist | Every `references/*.md` and `scripts/*` path mentioned in body exists on disk |

**Full validation script:**

```bash
#!/bin/bash
# validate-skill.sh — Run from inside the skill directory
set -euo pipefail

SKILL="SKILL.md"

# Check file exists
test -f "$SKILL" || { echo "FAIL: $SKILL not found"; exit 1; }

# Check frontmatter delimiters
head -1 "$SKILL" | grep -q '^---$' || { echo "FAIL: Missing opening ---"; exit 1; }

# Check name matches directory
DIR_NAME="$(basename "$(pwd)")"
SKILL_NAME="$(yq -r '.name' "$SKILL")"
test "$DIR_NAME" = "$SKILL_NAME" || { echo "FAIL: name '$SKILL_NAME' != dir '$DIR_NAME'"; exit 1; }

# Check description length
DESC_LEN="$(yq -r '.description' "$SKILL" | wc -c)"
test "$DESC_LEN" -le 1024 || { echo "FAIL: description is $DESC_LEN chars (max 1024)"; exit 1; }

# Check line count
LINE_COUNT="$(wc -l < "$SKILL")"
test "$LINE_COUNT" -le 500 || { echo "FAIL: $LINE_COUNT lines (max 500)"; exit 1; }

# Check referenced files exist
grep -oP '(references|scripts)/[A-Za-z0-9._-]+' "$SKILL" | sort -u | while read ref; do
  test -f "$ref" || echo "WARN: Referenced file missing: $ref"
done

echo "PASS: All validations passed"
```
