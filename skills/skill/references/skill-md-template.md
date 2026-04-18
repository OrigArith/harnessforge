# SKILL.md Template

Use this template to create a new SKILL.md. Replace all `{{PLACEHOLDER}}` markers with actual values.

---

## Frontmatter

```yaml
---
name: {{SKILL_NAME}}
description: >
  Use this skill when {{PRIMARY_USE_CASE}}.
  Handles {{CAPABILITY_1}}, {{CAPABILITY_2}}, and {{CAPABILITY_3}}.
  Trigger keywords: {{KEYWORD_1}}, {{KEYWORD_2}}, {{KEYWORD_3}}.
license: {{LICENSE}}
compatibility: "{{RUNTIME_REQUIREMENTS_OR_REMOVE_IF_NONE}}"
metadata:
  author: {{AUTHOR}}
  version: "{{VERSION}}"
  category: {{CATEGORY}}
allowed-tools: {{SPACE_SEPARATED_TOOL_NAMES}}
---
```

## Body

```markdown
# {{SKILL_TITLE}}

{{OPENING_LINE_1_PURPOSE}}
{{OPENING_LINE_2_SCOPE}}
{{OPENING_LINE_3_PRECONDITIONS}}

## Required Execution Rules

1. {{RULE_1_HARD_CONSTRAINT}}
2. {{RULE_2_HARD_CONSTRAINT}}
3. {{RULE_3_HARD_CONSTRAINT}}

## Canonical Workflow

1. {{STEP_1_ACTION}}
2. {{STEP_2_ACTION}}
3. {{STEP_3_ACTION}}
4. {{STEP_4_VALIDATION}}
5. {{STEP_5_APPLY_OR_FINALIZE}}

## Error Handling

When {{ERROR_CONDITION_1}}, read `references/{{ERROR_REFERENCE_FILE_1}}` for
{{WHAT_THE_REFERENCE_PROVIDES}}.

When {{ERROR_CONDITION_2}}, run `scripts/{{RECOVERY_SCRIPT}}` with
`{{SCRIPT_ARGUMENTS}}` to {{RECOVERY_ACTION}}.

When {{EDGE_CASE}}, {{FALLBACK_BEHAVIOR}}.
```

---

## Placeholder Reference

| Placeholder | Description | Constraints |
|-------------|-------------|-------------|
| `{{SKILL_NAME}}` | Stable identifier matching the parent directory | 1-64 chars, lowercase + digits + hyphens |
| `{{SKILL_TITLE}}` | Human-readable title for the body heading | No constraints, but keep concise |
| `{{PRIMARY_USE_CASE}}` | Main action the skill performs | Verb phrase, agent-facing |
| `{{CAPABILITY_N}}` | Specific capabilities within scope | Concrete nouns or verb phrases |
| `{{KEYWORD_N}}` | Trigger keywords for agent matching | Terms users/agents would use |
| `{{LICENSE}}` | License identifier | e.g., MIT, Apache-2.0 |
| `{{RUNTIME_REQUIREMENTS_OR_REMOVE_IF_NONE}}` | Runtime/system dependencies | Remove the entire field if none |
| `{{AUTHOR}}` | Author or team name | String |
| `{{VERSION}}` | Semantic version | e.g., "1.0.0" |
| `{{CATEGORY}}` | Skill category | e.g., refactoring, testing, deployment |
| `{{SPACE_SEPARATED_TOOL_NAMES}}` | Pre-approved tools | e.g., "Bash Read Edit Glob Grep" |
| `{{RULE_N_HARD_CONSTRAINT}}` | Non-negotiable execution rule | Imperative sentence |
| `{{STEP_N_ACTION}}` | Workflow step | Concrete, verifiable action |
| `{{ERROR_CONDITION_N}}` | When clause for error scenario | Specific condition |
| `{{ERROR_REFERENCE_FILE_N}}` | File under references/ with details | Must exist on disk |
| `{{RECOVERY_SCRIPT}}` | Script under scripts/ for recovery | Must be non-interactive |
| `{{EDGE_CASE}}` | Boundary or unusual condition | Specific scenario |
| `{{FALLBACK_BEHAVIOR}}` | What to do for the edge case | Imperative action |

---

## Optional Vendor Extensions

### Claude Code (add to frontmatter)

```yaml
when_to_use: "{{ADDITIONAL_ACTIVATION_GUIDANCE}}"
context: fork
agent: {{SUBAGENT_TYPE}}
model: {{MODEL_NAME}}
paths: "{{GLOB_PATTERN}}"
```

### Codex (create as agents/openai.yaml)

```yaml
interface:
  display_name: "{{DISPLAY_NAME}}"
  short_description: "{{SHORT_DESCRIPTION}}"
  default_prompt: "{{DEFAULT_PROMPT}}"

policy:
  allow_implicit_invocation: {{TRUE_OR_FALSE}}

dependencies:
  tools:
    - type: mcp
      value: "{{MCP_SERVER_PACKAGE}}"
      description: "{{TOOL_DESCRIPTION}}"
```

---

## Checklist Before Committing

- [ ] All `{{PLACEHOLDER}}` markers replaced with actual values.
- [ ] `name` matches the parent directory name.
- [ ] `description` starts with "Use this skill when ...".
- [ ] `description` length is 1-1024 characters.
- [ ] Total file is under 500 lines / 5000 tokens.
- [ ] Every referenced file in `references/` and `scripts/` exists.
- [ ] Body has Opening, Required Execution Rules, Canonical Workflows, and Error Handling.
