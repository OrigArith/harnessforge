# Changelog

All notable changes to HarnessForge will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/). Versioning follows [Semantic Versioning](https://semver.org/).

> **Agent ecosystem rule**: Any change to a SKILL.md `description`, skill directory name, or plugin.json `skills` paths is a **breaking change** requiring a major version bump.

## [Unreleased]

## [0.2.0] - 2026-04-15

### Added
- Initial public release with 5 scene-driven skills:
  - `forge-init` — project structure initialization + directive file authoring (AGENTS.md, CLAUDE.md)
  - `forge-skill` — SKILL.md development + description trigger testing (precision/recall metrics)
  - `forge-mcp` — MCP server development + diagnostic debugging (Quick Diagnosis, Conformance Testing)
  - `forge-ship` — release readiness + security audit (OWASP Agentic Top 10, supply chain, prompt injection defense)
  - `forge-adapt` — cross-platform adapter creation (Claude Code + Codex)
- Claude Code plugin manifest (`adapters/claude/`)
- Codex plugin manifest (`adapters/codex/`)
- Install script with `--global` / `--project` / `--uninstall` modes
- Smoke test validation suite (skill validation, regression tests, project consistency checks)
- CI workflow for skill validation and manifest version matching
- README: "Which skill do I need?" decision tree + agent-friendly install prompt

---

[Unreleased]: https://github.com/OrigArith/harnessforge/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/OrigArith/harnessforge/releases/tag/v0.2.0
