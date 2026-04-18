# Changelog

All notable changes to HarnessForge will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/). Versioning follows [Semantic Versioning](https://semver.org/).

> **Agent ecosystem rule**: Any change to a SKILL.md `description`, skill directory name, or plugin.json `skills` paths is a **breaking change** requiring a major version bump.

## [Unreleased]

## [0.6.0] - 2026-04-18

### Changed
- README: Fixed Claude Code install command. Replaced invalid
  `claude plugin install <url>` with correct two-step flow:
  `claude plugin marketplace add` then `claude plugin install`.
- forge-init: Templates A/C directory trees now include
  `.codex-plugin/plugin.json` in Codex adapter directories
  (official Codex entry point was missing since v0.4.0).
- forge-adapt: Pattern B Codex adapter section now positions
  `.codex-plugin/plugin.json` as the primary official entry point
  with `install.sh` as manual alternative.
- forge-adapt: Pattern B directory tree example updated to include
  `.codex-plugin/` in Codex adapter directory.

## [0.5.0] - 2026-04-18

### Breaking
- forge-init execution steps (3/4/7/10) now branch by template type.
  Template B uses root-level manifests; Template A/C uses adapters/.

### Changed
- Restored `.codex-plugin/plugin.json` as official Codex plugin entry point.
  Previous version incorrectly removed it; OpenAI docs confirm it as the
  required manifest location ("Every plugin has a manifest at
  `.codex-plugin/plugin.json`").
- forge-adapt: Codex section corrected to document `.codex-plugin/plugin.json`
  as official entry, Codex marketplace system, and cache install path.
  `.codex/INSTALL.md` retained as manual install alternative.
- forge-init: Steps 3/4/7/10 now properly distinguish Template B (root-level
  manifests) from Template A/C (adapters directory). Eliminates internal
  contradiction where rules allowed root-level manifests but steps forced
  adapters/.
- forge-init Template B directory tree: added `.codex-plugin/`.
- Pattern A/B directory trees in forge-adapt examples updated with `.codex-plugin/`.
- CI: re-added `.codex-plugin/plugin.json` validation and cross-platform
  version consistency check.

### Added
- `.codex-plugin/plugin.json` — Codex plugin manifest at repo root.

## [0.4.0] - 2026-04-18

### Breaking
- Removed `.codex-plugin/` directory. Codex install now uses clone + symlink
  via `.codex/INSTALL.md` (following ecosystem convention from superpowers).
- forge-init Rule 2 / AP3: Root-level plugin manifests are now valid for
  Template B (Skill Pack). Previous versions prohibited this.

### Changed
- forge-adapt: Rewritten to teach 3 packaging patterns (root-level manifests,
  adapters directory, content triplication) instead of only the adapters/ pattern.
  Decision table helps users choose the right pattern for their project.
- forge-init: Template B (Skill Pack) now includes `.claude-plugin/` at root
  and removes `adapters/` (matching ecosystem convention for pure content plugins).
- forge-init: Directory templates A and C updated to use Codex install scripts
  instead of `.codex-plugin/` manifests.
- README: Codex install changed from `codex install` to clone + symlink.
- Codex plugin template reference updated to clarify Pattern B usage only.
- Compatibility matrix updated to reflect marketplace.json and Codex install methods.

### Added
- `.claude-plugin/marketplace.json` for Claude Code marketplace discovery.
- `.codex/INSTALL.md` with Codex clone + symlink instructions.
- forge-adapt examples: Pattern A (root-level skill pack) directory tree alongside
  existing Pattern B (adapters directory full plugin).

## [0.3.0] - 2026-04-18

### Breaking
- Removed `adapters/` directory. Plugin manifests now live at repo root
  (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`), making the
  repository a self-contained, marketplace-installable plugin package.

### Changed
- Plugin manifests use `"./skills/"` paths (marketplace-compatible) instead
  of `"../../skills/"` (which broke on marketplace install due to cache isolation).
- README: replaced "battle-tested" with "curated"; added v0.x early-stage
  disclaimer; downgraded unverified platform support claims to "Tested".
- forge-skill: frontmatter section now explicitly frames the 6-field set as
  "HarnessForge's opinionated best-practice profile" rather than implying it
  is the open standard requirement.
- AGENTS.md: clarified that 6-field frontmatter is a HarnessForge convention,
  not an open standard mandate (only name + description are required per spec).
- Install instructions: plugin install is now primary method; symlink install
  is secondary with a warning about clone persistence.

### Added
- Plugin install support via `claude plugin install` and `codex install`.
- Trigger eval scaffold in `tests/evals/` with sample test matrix.

## [0.2.0] - 2026-04-15

### Added
- Initial public release with 5 scene-driven skills:
  - `forge-init` — project structure initialization + directive file authoring (AGENTS.md, CLAUDE.md)
  - `forge-skill` — SKILL.md development + description trigger testing (precision/recall metrics)
  - `forge-mcp` — MCP server development + diagnostic debugging (Quick Diagnosis, Conformance Testing)
  - `forge-ship` — release readiness + security audit (OWASP Agentic Top 10, supply chain, prompt injection defense)
  - `forge-adapt` — cross-platform adapter creation (Claude Code + Codex)
- Claude Code plugin manifest
- Codex plugin manifest
- Install script with `--global` / `--project` / `--uninstall` modes
- Smoke test validation suite (skill validation, regression tests, project consistency checks)
- CI workflow for skill validation and manifest version matching
- README: "Which skill do I need?" decision tree + agent-friendly install prompt

---

[Unreleased]: https://github.com/OrigArith/harnessforge/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/OrigArith/harnessforge/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/OrigArith/harnessforge/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/OrigArith/harnessforge/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/OrigArith/harnessforge/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/OrigArith/harnessforge/releases/tag/v0.2.0
