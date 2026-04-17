# HarnessForge

> **Forge your agent's harness.**

Your AI agent builds skills, MCP servers, and plugins. HarnessForge ensures they're built right — so they become a harness worth shipping.

*Don't just prompt. Forge.*

---

## What is this?

HarnessForge is a **skill pack** — a collection of 5 installable skills that teach your coding agent the engineering discipline of building production-grade agent ecosystem projects.

When your agent activates a HarnessForge skill, it gains access to battle-tested best practices for:
- Structuring projects that agents can discover, understand, and safely invoke
- Writing SKILL.md, AGENTS.md, and MCP tool descriptions that actually work
- Shipping with security, cross-platform compatibility, and proper versioning

## Install

### Let your agent do it

Copy this prompt to your coding agent (Claude Code, Codex, etc.):

```
Clone https://github.com/OrigArith/harnessforge.git and run ./scripts/install.sh --global to install all skills. After install, verify by listing ~/.claude/skills/forge-* and confirm 5 skills are symlinked.
```

### Or install manually

```bash
git clone https://github.com/OrigArith/harnessforge.git
cd harnessforge
./scripts/install.sh --global
ls ~/.claude/skills/forge-*   # should show 5 symlinks
```

### Which skill do I need?

```
Starting a new project?                    → /forge-init
Creating or improving a SKILL.md?          → /forge-skill
Building or debugging an MCP server?       → /forge-mcp
Preparing to release or security auditing? → /forge-ship
Adding Claude Code / Codex support?        → /forge-adapt
```

### Use it

After installation, invoke skills as slash commands in your coding agent:

```
/forge-init    → Initialize project structure + write AGENTS.md / CLAUDE.md
/forge-skill   → Create SKILL.md files + test trigger accuracy
/forge-mcp     → Develop or debug MCP servers
/forge-ship    → Release readiness + security audit
/forge-adapt   → Add platform adapters
```

## Skills

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `forge-init` | Creating a new agent ecosystem project, writing AGENTS.md / CLAUDE.md | Project structure (Template A/B/C), root files, directive file authoring |
| `forge-skill` | Creating, reviewing, or debugging SKILL.md trigger accuracy | Frontmatter, Progressive Disclosure, token budgets, description trigger testing |
| `forge-mcp` | Building or debugging an MCP server | Tool descriptions, schema design, error handling, MCP Inspector diagnostics |
| `forge-ship` | Preparing a release or security auditing | 54-item checklist, SemVer, OWASP Agentic Top 10, supply chain security |
| `forge-adapt` | Adding Claude Code / Codex support | Cross-platform compatibility matrix and adapter templates |

## Supported Platforms

| Platform | Min Version | Status |
|----------|-------------|--------|
| Claude Code | 1.0+ | Fully supported |
| Codex CLI | 0.1+ | Fully supported |
| OpenCode | 0.1+ | Compatible (auto-discovers from `.claude/skills/` and `.agents/skills/`) |

## How it works

HarnessForge follows the **Progressive Disclosure** model:

1. **Tier 1 — Discovery** (~100 tokens per skill): Your agent reads skill names and descriptions to decide which skill matches the current task.
2. **Tier 2 — Execution** (<5,000 tokens per skill): The activated skill's full SKILL.md loads with step-by-step instructions.
3. **Tier 3 — On-demand** (no limit): Templates, checklists, and examples load from `references/` only when needed.

## Project Structure

```
harnessforge/
├── skills/              5 skill directories (core content)
├── adapters/            Platform-specific thin shells
│   ├── claude/          Claude Code plugin manifest
│   └── codex/           Codex plugin manifest
├── scripts/             Install/uninstall helpers
├── tests/               Smoke tests
├── config/              Default configuration
├── AGENTS.md            Cross-platform agent directives
├── CLAUDE.md            Claude Code entry shell
├── README.md            This file
├── LICENSE              MIT
├── CONTRIBUTING.md      Contribution guide
├── SECURITY.md          Security policy
└── CHANGELOG.md         Version history
```

## Why "HarnessForge"?

**Harness Engineering** is the emerging discipline of building runtime frameworks around AI agents — tools, constraints, verification loops, and context delivery systems that turn chaotic AI intelligence into reliable production capability.

Your agent's harness is made of skills, MCP servers, and plugins. **HarnessForge** is the skill pack that ensures each component is forged with engineering discipline — so the assembled harness actually works.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)

---
