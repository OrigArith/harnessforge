# AGENTS.md

## Project Overview

HarnessForge — a cross-platform skill pack that teaches coding agents how to build production-grade agent ecosystem projects (skills, MCP servers, plugins). Pure content, no runtime dependencies.

Tech stack: Markdown (SKILL.md). No build step required.

## Directory Guide

- `skills/` — 5 skill directories (init, skill, mcp, ship, adapt), each with SKILL.md + references/ + optional examples/
- `.claude-plugin/` — Claude Code plugin manifest + marketplace.json
- `.codex-plugin/` — Codex plugin manifest
- `.codex/` — Codex manual install instructions (clone + symlink alternative)
- `tests/smoke/` — Skill validation scripts
- `config/` — Default configuration

## Code Standards

- All SKILL.md files must have valid frontmatter. Required per open standard: name, description. Required per HarnessForge convention: all 6 fields (name, description, license, compatibility, metadata, allowed-tools)
- Skill `name` must match its parent directory name (e.g., `init/SKILL.md` → `name: init`)
- Skill `description` must start with "Use this skill when"
- Each SKILL.md body must stay under 500 lines / 5,000 tokens
- References and templates go in `references/` subdirectory, not in SKILL.md body
- Conditional references: use "When X, read `references/Y.md`" — never vague "see references/"

## Build & Test

```bash
# No build step needed — pure content project

# Validate all skills
./tests/smoke/validate-skills.sh
```

## Commit Standards

Format: `<type>(<scope>): <description>`

Types: feat, fix, docs, refactor, test, chore
Scopes: init, skill, mcp, ship, adapt, infra

Examples:
- `feat(init): add MCP Server template to references`
- `fix(skill): correct frontmatter validation rule for name field`
- `docs(readme): update quick start instructions`

**Breaking changes**: Any modification to a SKILL.md description or trigger condition is a breaking change — use `feat!` or add `BREAKING CHANGE:` footer.

## Security Constraints

- SKILL.md must not contain executable code that runs automatically
- No secrets, API keys, or credentials anywhere in the repository

## Available Skills

| Skill | Trigger |
|-------|---------|
| `forge:init` | Creating/initializing a project + writing AGENTS.md / CLAUDE.md |
| `forge:skill` | Creating, reviewing, or testing SKILL.md trigger accuracy |
| `forge:mcp` | Developing or debugging MCP servers |
| `forge:ship` | Release readiness + security auditing |
| `forge:adapt` | Adding Claude Code or Codex platform adapters |
