# Contributing to HarnessForge

Thanks for your interest in HarnessForge! This guide will help you contribute effectively.

## Before You Start

1. Read [README.md](README.md) to understand what HarnessForge is
2. Read [AGENTS.md](AGENTS.md) for code standards and project structure
3. Check [Issues](https://github.com/OrigArith/harnessforge/issues) for `good first issue` labels

## Development Setup

```bash
git clone https://github.com/<your-username>/harnessforge.git
cd harnessforge

# Validate all skills
./tests/smoke/validate-skills.sh

# Install locally for testing
./scripts/install.sh --project
```

### Requirements

- Bash >= 4.0
- A coding agent (Claude Code or Codex) for end-to-end testing

## What to Contribute

### Adding a New Skill

1. Create `skills/forge-<name>/SKILL.md` with all 6 frontmatter fields
2. Add `references/` for templates and detailed content
3. Add `examples/` for good/bad pattern illustrations
4. Ensure SKILL.md body < 500 lines
5. Update `AGENTS.md` Available Skills table
6. Update `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`

### Improving Existing Skills

- Fix inaccurate instructions
- Add missing edge cases to references
- Improve description trigger coverage
- Add examples

### Fixing Issues

- Frontmatter validation failures
- Broken references (SKILL.md points to non-existent file)
- Install script platform compatibility

## Code Standards

- SKILL.md files: English, agent-facing imperative style
- `name` must match parent directory name
- `description` must start with "Use this skill when"
- All referenced files in `references/` must exist
- Templates use `{{PLACEHOLDER}}` markers

## Breaking Changes

In agent ecosystem projects, these changes require a **major version bump**:

| Change | Why it breaks |
|--------|--------------|
| Modify a skill's `description` | Alters agent trigger matching behavior |
| Rename a skill directory | Breaks existing `/forge-*` slash commands |
| Remove a reference file | Breaks conditional loading in SKILL.md |
| Change plugin.json `skills` paths | Breaks installed plugin discovery |

Non-breaking: adding new skills, adding optional references, fixing typos in body text.

## PR Process

1. Fork and create a branch: `git checkout -b feat/forge-<scope>`
2. Make changes following the standards above
3. Run `./tests/smoke/validate-skills.sh` — all must pass
4. Update CHANGELOG.md
5. Submit PR with a clear description of what changed and why
6. Wait for review

## Commit Format

```
<type>(<scope>): <description>

Types: feat, fix, docs, refactor, test, chore
Scopes: init, skill, mcp, ship, adapt, infra
```

## Questions?

Open a [Discussion](https://github.com/OrigArith/harnessforge/discussions) or file an issue.
