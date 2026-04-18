---
name: skill
description: "Use this skill when creating a new SKILL.md file, reviewing an existing skill's quality, or packaging domain knowledge as a reusable agent skill. Covers the 6 core frontmatter fields, body writing rules, Progressive Disclosure three-tier model, token budgets, vendor extensions for Claude Code and Codex, and the six-step publishing flow. Trigger keywords: SKILL.md, create skill, skill authoring, skill review, frontmatter, Progressive Disclosure, skill quality, 技能开发, 技能编写."
license: MIT
compatibility: "No runtime dependencies. Works with any coding agent that supports SKILL.md."
metadata:
  author: harnessforge
  version: "0.7.0"
  category: skill-development
allowed-tools: Bash Read Edit Write Glob Grep
---

# Forge Skill

SKILL.md is the atomic unit of reusable agent capability in the Agent Skills open standard.
Every skill you create must be written for agents, not humans.
Treat SKILL.md as a loadable playbook: concise, imperative, and machine-optimized.
Your goal is to teach an agent how to think and act in a specific domain, not to document an API for human readers.

## Frontmatter Specification

The Agent Skills open standard defines 6 frontmatter fields, of which only `name` and `description` are required.
HarnessForge recommends using all 6 as an opinionated best-practice profile for production-grade skills. The additional 4 fields (license, compatibility, metadata, allowed-tools) are optional per the standard but provide valuable context for distribution, runtime prerequisites, and cross-platform discovery. Unknown frontmatter fields are safely ignored by platforms that do not support them.

### Field Reference

| Field | Required | Type | Constraints | Purpose |
|-------|----------|------|-------------|---------|
| `name` | Yes | string | 1-64 chars. Lowercase letters, digits, hyphens only. No leading/trailing hyphen. No consecutive hyphens. Must match parent directory name. | Stable identifier used for explicit invocation (`/name` or `$name`). |
| `description` | Yes | string | 1-1024 chars. Must start with "Use this skill when ...". | Primary trigger for agent activation. Must cover what the skill does and when to use it. |
| `license` | No | string | Keep short (e.g., `MIT`, `Apache-2.0`). | License declaration for public distribution. |
| `compatibility` | No | string | 1-500 chars. | Declare runtime requirements, system packages, or network dependencies. Omit if the skill has none. |
| `metadata` | No | map<string, string> | Use unique keys to avoid collisions. | Attach ecosystem data not defined by the spec (author, version, category). |
| `allowed-tools` | No | string | Space-separated tool names. Experimental. | Pre-approve tools when the skill activates. Support varies across platforms. |

### Frontmatter Example

```yaml
---
name: api-migration-helper
description: >
  Use this skill when migrating REST API endpoints between major versions.
  Handles route mapping, request/response schema transformation, deprecation
  annotation, and backward-compatible wrapper generation. Trigger keywords:
  API migration, version upgrade, endpoint mapping, schema transform.
license: MIT
compatibility: "Requires Node.js >= 18 and jq installed."
metadata:
  author: your-team
  version: "1.2.0"
  category: refactoring
allowed-tools: Bash Read Edit Glob Grep
---
```

## Body Structure

The body follows the frontmatter and must stay under 5000 tokens (~500 lines).
Write in imperative, agent-facing sentences. Structure the body into these 4 required sections.

### 1. Opening (3-8 lines)

State the skill's purpose, scope, and preconditions in 3-8 lines.
This is the first thing the agent reads after activation. Make it count.

```markdown
# Skill Title

Use this skill to [primary action]. It handles [scope summary].
Preconditions: [list any required state, tools, or environment].
```

### 2. Required Execution Rules

List hard constraints the agent must always obey during execution.
Use a numbered list. These are non-negotiable rules, not suggestions.

```markdown
## Required Execution Rules

1. Always run `scripts/validate.sh` before making changes.
2. Treat non-zero exit codes as blocking errors.
3. Never modify files outside the target directory.
```

### 3. Canonical Workflows

Describe the step-by-step process the agent must follow.
Use numbered steps. Each step should be a concrete, verifiable action.

```markdown
## Canonical Workflow

1. Read the input configuration.
2. Validate the schema against `references/schema-rules.md`.
3. Generate the output artifact.
4. Run the dry-run validation script.
5. Apply changes only after dry-run passes.
```

### 4. Error Handling and Conditional References

Define what to do when things go wrong. Use conditional references to load Tier 3 content on demand.
Never dump reference material into the body. Point to files under `references/` or `scripts/`.

```markdown
## Error Handling

When validation fails with a schema error, read `references/error-codes.md`
for the complete error table and remediation steps.

When generating output artifacts, use the template at
`assets/output-template.yaml` as the base structure.
```

### Token Budget Breakdown

Allocate your ~5000 token budget as follows:

| Section | Budget |
|---------|--------|
| Opening | ~300 tokens |
| Required Execution Rules | ~1000 tokens |
| Canonical Workflows | ~2000 tokens |
| Error Handling + Conditional References | ~1200 tokens |
| Headroom | ~500 tokens |

If content exceeds these limits, extract it into `references/` and add a conditional reference.

## Progressive Disclosure Model

Progressive Disclosure is the core loading mechanism of the Agent Skills standard.
It prevents context window exhaustion by loading skill content in three tiers.

| Tier | Content | Token Budget | When Loaded | Purpose |
|------|---------|--------------|-------------|---------|
| Tier 1: Discovery | `name` + `description` from frontmatter | ~100 tokens per skill | Agent startup. All skills' Tier 1 loaded together. | Agent decides whether this skill matches the current task. |
| Tier 2: Execution | Full SKILL.md (frontmatter + body) | < 5000 tokens per skill | After skill is triggered / activated. | Agent follows the instructions to execute the task. |
| Tier 3: On-Demand | Files in `scripts/`, `references/`, `assets/` | No fixed limit. Loaded per file. | During execution, when a conditional reference is hit. | Detailed references, executable scripts, templates. |

### Rules for Each Tier

**Tier 1 rules:**
- The `description` field is your only chance to win activation. Write it carefully.
- 20 skills at ~100 tokens each = ~2000 tokens. This must fit comfortably in any context window.
- Include trigger keywords and synonyms in the description.

**Tier 2 rules:**
- Keep the full SKILL.md under 500 lines / 5000 tokens.
- Put step-by-step workflows, hard rules, and conditional references here.
- Never put large lookup tables, full API docs, or schema definitions here.

**Tier 3 rules:**
- Always use conditional references: "When X happens, read `references/Y.md`."
- Never write "see references/" without specifying a condition and exact file.
- Scripts must be non-interactive (no TTY prompts, no password dialogs).
- All script inputs come from command-line arguments, environment variables, or stdin.

## Description Writing Rules

The `description` field is the most important line in your skill.
It determines whether the agent activates the skill or ignores it.

### Format

Always start with: `"Use this skill when ..."`

### Coverage Checklist

Every description must cover these four elements:

1. **Main use case**: What the skill does (e.g., "migrating REST API endpoints").
2. **Variant expressions**: Synonyms and alternative phrasings agents might encounter (e.g., "version upgrade, endpoint mapping, schema transform").
3. **Boundaries**: What the skill does NOT do, if ambiguity is likely (e.g., "Does not handle GraphQL migrations").
4. **Trigger keywords**: Explicit keywords at the end to maximize matching (e.g., "Trigger keywords: API migration, version upgrade").

### Testing Your Description

Treat the description as a mini-classifier. Prepare ~20 test queries:
- 8-10 queries that SHOULD trigger the skill.
- 8-10 queries that should NOT trigger the skill.

Split into train/validation sets to avoid overfitting the wording.

For good and bad description examples, read `examples/good-vs-bad-descriptions.md`.

## Description Trigger Testing

The `description` field is a trigger classifier. Test it like one.

### Generate Test Queries

Create a test matrix of 20 queries for the target skill:

- **10 positive queries** (should trigger the skill): Cover the main use case, variant phrasings, synonyms, and edge cases that should match.
- **10 negative queries** (should NOT trigger the skill): Cover adjacent skills, similar-sounding but different tasks, and out-of-scope requests.

Example for an API migration skill:

| Query | Expected | Rationale |
|-------|----------|-----------|
| "Migrate the REST endpoints to v3" | Trigger | Main use case |
| "Update the API version" | Trigger | Synonym |
| "Help me refactor the database schema" | No trigger | Adjacent but out of scope |
| "Create a new REST endpoint" | No trigger | Creation, not migration |

### Run the Tests

In Claude Code, type each query as a message and observe whether the skill activates. In Codex, observe the skill selection panel. Record the result for each query.

### Evaluate Precision and Recall

- **Precision** = correct triggers / total triggers. A low precision means the description is too broad -- it activates on irrelevant queries.
- **Recall** = correct triggers / total positive queries. A low recall means the description is too narrow -- it misses valid use cases.

Target: precision >= 0.8 AND recall >= 0.8. If either metric is below threshold, iterate on the description wording:
- Low precision → Add "when NOT to use" boundaries and narrow trigger keywords.
- Low recall → Add synonym coverage and variant phrasings to the description.

### Iterate

Adjust the description, re-run the test matrix, and re-evaluate. Two to three iterations typically suffice to reach stable precision/recall.

For a detailed testing protocol with more examples, read `references/description-trigger-testing.md`.

## Vendor Extensions

The 6 core frontmatter fields work on all platforms. Vendor extensions add platform-specific capabilities.
Never mix vendor extensions into core spec if you want cross-platform compatibility.

### Claude Code Extensions

Claude Code adds three categories of extensions to SKILL.md frontmatter:

**Invocation Control:**

| Field | Purpose |
|-------|---------|
| `when_to_use` | Additional guidance for when the model should activate this skill. |
| `argument-hint` | Hint text shown in slash-command autocomplete. |
| `disable-model-invocation` | Set `true` to require explicit user invocation only. |
| `user-invocable` | Set `false` to allow only model-initiated activation. |
| `paths` | Glob pattern (e.g., `"src/**/*.ts"`) controlling automatic activation. |

**Execution Isolation:**

| Field | Purpose |
|-------|---------|
| `context: fork` | Execute the skill in a forked subagent for isolation. |
| `agent` | Subagent type: `Explore`, `Plan`, etc. |
| `model` | Specify the model for the subagent (e.g., `sonnet`). |
| `effort` | Reasoning effort level: `low`, `medium`, `high`. |

**Context Injection:**

| Field | Purpose |
|-------|---------|
| `allowed-tools` | Pre-approve tools (also in core spec as experimental). |
| `hooks.pre-activate` | Run a script before the skill activates. |
| `shell` | Shell type for `!` commands: `bash` or `powershell`. |

**Claude Code description budget:** `description` + `when_to_use` max 1,536 characters combined.

**Claude Code discovery paths:**

```
~/.claude/skills/<name>/SKILL.md          # Personal
.claude/skills/<name>/SKILL.md            # Project
<plugin>/skills/<name>/SKILL.md           # Plugin (namespace: plugin-name:skill-name)
```

### Codex Extensions

Codex keeps extensions in a separate file: `agents/openai.yaml`.
This is the cleanest separation strategy -- core SKILL.md stays pure.

```yaml
# agents/openai.yaml
interface:
  display_name: "Skill Display Name"
  short_description: "Brief description for UI"
  icon_small: "assets/icon-16.png"
  icon_large: "assets/icon-64.png"
  brand_color: "#4A90D9"
  default_prompt: "Default prompt text"

policy:
  allow_implicit_invocation: true

dependencies:
  tools:
    - type: mcp
      value: "@my-org/tool-server"
      description: "MCP server description"
      transport: stdio
      url: "https://registry.example.com/tool"
```

**Codex discovery paths:**

```
.agents/skills/                           # Project level
$HOME/.agents/skills/                     # User level
/etc/codex/skills/                        # System level
```

### Cross-Platform Strategy

For maximum compatibility:
- Core SKILL.md frontmatter: only 6 standard fields.
- Codex UI/policy/dependency declarations: `agents/openai.yaml`.
- Claude Code private fields: inject into frontmatter directly (OpenCode ignores unknown fields) or use a build script to add them during export.

## Six-Step Publishing Flow

Follow these steps to publish a skill that works across Claude Code, Codex, and OpenCode.

### Step 1: Write Core-Only Frontmatter

Use only the 6 standard fields in SKILL.md. No vendor-specific fields in the initial version.

### Step 2: Enforce the 500-Line / 5000-Token Budget

Extract large content (API docs, schema tables, error code listings) into `references/`.
Add conditional references in the body: "When X occurs, read `references/Y.md`."

### Step 3: Optimize the Description

Write the description using the "Use this skill when ..." format.
Cover: main use case, variant expressions, boundaries, and trigger keywords.

### Step 4: Add Codex Extensions Separately

Create `agents/openai.yaml` for Codex-specific UI metadata, invocation policy, and tool dependencies.
Never put these fields in SKILL.md frontmatter.

### Step 5: Add Claude Code Extensions as Optional Enhancements

Add Claude-specific fields (`paths`, `context: fork`, `hooks`) to SKILL.md frontmatter.
OpenCode silently ignores unknown fields, so this is safe. If strict Codex validation is needed, use a build script to inject these fields only in the Claude Code export.

### Step 6: Create a Multi-Path Install Script

Write an install script that copies the skill to all platform discovery paths:

```bash
#!/bin/bash
SKILL_NAME="my-skill"
SOURCE_DIR="$(dirname "$0")/${SKILL_NAME}"

# Claude Code
mkdir -p ".claude/skills/${SKILL_NAME}"
cp -r "${SOURCE_DIR}"/* ".claude/skills/${SKILL_NAME}/"

# Codex / Agent Skills standard
mkdir -p ".agents/skills/${SKILL_NAME}"
cp -r "${SOURCE_DIR}"/* ".agents/skills/${SKILL_NAME}/"

echo "Installed ${SKILL_NAME} to .claude/skills/ and .agents/skills/"
```

## Quality Checklist

Run this checklist before publishing any skill.

### Structural Checks

- [ ] `name` field matches the parent directory name exactly.
- [ ] `description` starts with "Use this skill when ...".
- [ ] `description` is between 1 and 1024 characters.
- [ ] `name` is 1-64 characters, lowercase alphanumeric and hyphens only.
- [ ] `name` has no leading/trailing hyphen and no consecutive hyphens.
- [ ] Total SKILL.md line count is under 500.
- [ ] Total SKILL.md token count is under 5000.

### Content Checks

- [ ] Body has all 4 sections: Opening, Required Execution Rules, Canonical Workflows, Error Handling.
- [ ] Every file referenced in the body actually exists on disk.
- [ ] Every `references/` citation is conditional ("When X, read Y"), not unconditional.
- [ ] No large lookup tables, full API docs, or schema dumps in the body.
- [ ] Scripts in `scripts/` are non-interactive and accept input via args/env/stdin only.

### Description Checks

- [ ] Description covers: main use, variant expressions, boundaries, trigger keywords.
- [ ] Combined `description` + `when_to_use` is under 1,536 characters (Claude Code limit).
- [ ] Trigger test matrix created with 20 queries (10 positive, 10 negative).
- [ ] Precision >= 0.8 and recall >= 0.8 on the test matrix.

### Validation Commands

```bash
# Verify name matches directory
test "$(basename "$(pwd)")" = "$(yq '.name' SKILL.md)"

# Verify description length
desc_len=$(yq '.description' SKILL.md | wc -c)
test "$desc_len" -le 1024

# Verify line count
line_count=$(wc -l < SKILL.md)
test "$line_count" -le 500

# Verify all referenced files exist
grep -oP 'references/\S+' SKILL.md | sed 's/[`"'"'"',.;)]*$//' | while read ref; do
  test -f "$ref" || echo "MISSING: $ref"
done
```

## References

When creating a new SKILL.md from scratch, read `references/skill-md-template.md` for a complete template with placeholder markers.

When validating frontmatter fields programmatically, read `references/frontmatter-validation-rules.md` for regex patterns and exact constraints.

When reviewing description quality, read `examples/good-vs-bad-descriptions.md` for 5 pairs of good vs bad examples.
