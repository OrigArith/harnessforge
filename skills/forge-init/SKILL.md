---
name: forge-init
description: "Use this skill when initializing a new agent ecosystem project, scaffolding project structure, writing AGENTS.md, writing CLAUDE.md, reviewing directive files, or creating agent instruction files. Covers directory structure, root-level files, configuration strategy, template selection, directive authoring principles, and self-check protocols. Trigger keywords: project init, scaffold, create project, new repo, directory structure, project template, AGENTS.md, CLAUDE.md, directive file, instruction file, agent instructions, 项目初始化, 目录结构, 指令文件."
license: MIT
compatibility: "No runtime dependencies. Works with any coding agent that supports SKILL.md."
metadata:
  author: harnessforge
  version: "0.2.0"
  category: project-setup
allowed-tools: Bash Read Edit Write Glob Grep
---

# forge-init

This skill initializes the directory structure and root-level files for an agent ecosystem project.
It supports three project archetypes: MCP Server, Skill Pack, and Full Plugin.
Before invoking this skill, confirm the project name, target platforms, and primary language with the user.
If the user has not decided on a project type, use the decision table in "Template Selection" below.
All generated structures enforce the "shared content layer + thin adapter layer" architecture.

When the project includes directive files (AGENTS.md, CLAUDE.md), this skill also governs their content structure, authoring principles, and quality verification.

## Template Selection

Choose one template based on the project's primary purpose. When in doubt, start with the lightest template that covers the use case -- you can always upgrade later.

| User's Goal | Template | Key Indicator |
|---|---|---|
| Expose tools/data to agents via MCP protocol (DB queries, API proxies, CI/CD ops) | **A: MCP Server** | Project needs `src/` with tool implementations and an MCP transport layer |
| Package domain knowledge, workflows, or checklists as reusable agent skills | **B: Skill Pack** | Core value is in SKILL.md files, scripts, and reference docs -- no external system calls |
| Ship an installable plugin with skills + MCP tools + lifecycle hooks via marketplace | **C: Full Plugin** | Needs both `skills/` and `src/`, plus per-platform hooks and plugin manifests |

After selecting the template, load `references/directory-template.md` to retrieve the canonical ASCII tree for the chosen template.

## Required Execution Rules

Obey these four rules unconditionally when scaffolding. Violation of any rule means the scaffold is non-conformant.

### Rule 1: Root directory contains 15 entries or fewer

Count every file and directory in the project root (including hidden ones like `.github/`). The total must not exceed 15. If the count would exceed 15, move development support files into hidden directories (`.github/`, `.vscode/`) or consolidate them into `config/`.

### Rule 2: Content-host separation

The `skills/` and `src/` directories form the shared content layer. The `adapters/` directory is the platform-specific host layer. These two layers must never cross-import each other. Validate separation with this test: deleting the entire `adapters/` directory must leave `skills/` and `src/` independently runnable and testable.

Do NOT place `.claude-plugin/`, `.codex-plugin/`, `openclaw.plugin.json`, or any platform manifest in the project root. All platform-specific files go under `adapters/<platform>/`.

### Rule 3: Three-layer configuration strategy

Create configuration in three layers with ascending priority:

```
config/default.json          <- Project defaults (checked in, zero-config first run)
adapters/<platform>/config   <- Platform-specific overrides (checked in)
~/.config/<project>/user.json <- User personal overrides (NOT checked in)
```

`config/default.json` must exist and contain sensible defaults for every field. Users must never be required to create a config file before first run. Name the env template `example.env` (not `.env.example`) to prevent accidental auto-loading by dotenv libraries.

### Rule 4: Minimum Viable Entry -- clone, install, run in three steps

The generated `README.md` must contain complete install-and-run commands within its first 30 lines. If the project requires API keys, login tokens, or paid subscriptions, declare those prerequisites BEFORE the install command, not buried later.

## Canonical Workflow

Execute these steps in order when scaffolding a new project.

1. **Confirm inputs.** Ask the user for: project name, template choice (A/B/C), target platforms (claude-code, codex, opencode, openclaw), primary language (TypeScript, Python, etc.), license preference (MIT or Apache-2.0).

2. **Create root directory.** Run `mkdir -p <project-name>` and `cd` into it. Initialize git: `git init`.

3. **Generate directory tree.** Read `references/directory-template.md` for the chosen template. Create all directories using `mkdir -p`. For Template A, the key directories are: `src/tools/`, `src/resources/`, `src/utils/`, `tests/unit/`, `tests/contract/`, `tests/smoke/`, `config/`, `adapters/`, `.github/workflows/`. For Template B: `skills/<skill-name>/scripts/`, `skills/<skill-name>/references/`, `skills/<skill-name>/examples/`, `tests/skill-smoke/`, `adapters/`, `.github/workflows/`. For Template C: both `skills/` and `src/` subtrees plus `tests/integration/`.

4. **Create adapter subdirectories.** For each target platform, create `adapters/<platform>/`. Only create adapters the user explicitly requested. Do not generate adapters for platforms the user did not select.

5. **Generate root-level files.** Create each file listed in the "Root-Level File Requirements" table below. Use the templates in `references/` as starting points:
   - Read `references/readme-template.md` when creating `README.md`.
   - Read `references/contributing-template.md` when creating `CONTRIBUTING.md`.
   - Read `references/security-template.md` when creating `SECURITY.md`.
   - For `AGENTS.md`, read `references/agents-md-template.md` and apply the Directive File Rules below.
   - For `CLAUDE.md`, read `references/claude-md-template.md` and apply the CLAUDE.md Import Shell rules below.
   - For `LICENSE`, use the full text of the chosen license (MIT or Apache-2.0).
   - For `CHANGELOG.md`, create a stub with the header and an "Unreleased" section.

6. **Generate config/default.json.** Include all configurable fields with safe defaults. For MCP servers, include: `capabilities` (with advanced features defaulting to `false`), `security.allowed_hosts` (default `[]`), `security.require_approval_for` (default `["write", "delete"]`), and `mcp.transport` (default `"stdio"`).

7. **Generate platform manifests.** For each selected adapter, create the minimum viable manifest file inside `adapters/<platform>/`. Keep manifests under 30 lines. Do not embed UI metadata, brand colors, or default prompts in manifests.

8. **Generate CI workflows.** Create `.github/workflows/ci.yml` with lint + type-check + unit-test stages. For Template A and C, also create `release.yml` and `security.yml`. Add a platform smoke test matrix that covers each selected adapter.

9. **Count root entries.** Run `ls -A <project-root> | wc -l` and verify the count is 15 or fewer. If it exceeds 15, consolidate files into subdirectories until compliant.

10. **Run validation.** Verify: (a) `config/default.json` exists and is valid JSON; (b) `README.md` contains install commands in its first 30 lines; (c) no platform-specific files exist outside `adapters/`; (d) `skills/` and `src/` contain no imports from `adapters/`.

## Six Good Patterns / Six Anti-Patterns

### Good Patterns (enforce these)

- [GP1] **Minimum Viable Entry.** README first 30 lines contain clone-install-run commands. Default config works out of the box.
- [GP2] **Content-host separation.** `skills/` + `src/` are platform-agnostic. `adapters/` holds all vendor files. Deleting `adapters/` breaks nothing in core.
- [GP3] **Three-layer config.** `config/default.json` -> `adapters/<platform>/config` -> user local. Each layer only overrides what differs.
- [GP4] **Run-to-Understand README order.** One-liner -> Quick Start -> Expected Output -> Security Notice -> Extended Config -> Directory Map -> API Reference.
- [GP5] **Up-front security declaration.** `SECURITY.md` at root (not in `docs/`). README security notice placed after Quick Start, before Extended Config.
- [GP6] **Capability trimming over stacking.** Advanced features default to `false`. Provide grouped toggles (`capabilities`, `toolsets`), not individual switches for every feature.

### Anti-Patterns (block these)

- [AP1] **Marketing-style "zero friction" hiding real deps.** If install needs API keys, paid accounts, or multi-tool chains, declare them before the install command. Do not write "one command" if reality requires five steps.
- [AP2] **Bloated manifest.** If `plugin.json` exceeds 30 lines, extract UI metadata and brand assets to `assets/`. Manifest = declaration only.
- [AP3] **Vendor files in root.** Never place `.claude-plugin/`, `.codex-plugin/`, or `openclaw.plugin.json` in the project root. Always use `adapters/`.
- [AP4] **Undeclared dependency chains.** List every external dependency (runtime, CLI tools, accounts, tokens) in a prerequisites tree in README. If the tree exceeds 3 levels or 5 external deps, reduce required deps and make the rest optional.
- [AP5] **Demo-grade examples.** Every file in `examples/` must include error handling and timeout protection. Mark project maturity level in README: `experimental` / `beta` / `production-ready`.
- [AP6] **MCP as security boundary.** MCP is an interop protocol, not a sandbox. State this in SECURITY.md. Default to minimum permissions (`allowed_hosts: []`).

## Root-Level File Requirements

| File | Required? | Purpose | Template |
|---|---|---|---|
| `README.md` | Required | Project entry point. One-liner + install + first run. | `references/readme-template.md` |
| `LICENSE` | Required | Open-source license text. | Use MIT or Apache-2.0 full text |
| `CONTRIBUTING.md` | Strongly recommended | Contribution guide with agent-ecosystem specifics. | `references/contributing-template.md` |
| `SECURITY.md` | Strongly recommended | Security boundary declaration + vulnerability disclosure. | `references/security-template.md` |
| `CHANGELOG.md` | Recommended | Version change log in conventional commits format. | Create stub with Unreleased section |
| `AGENTS.md` | Required | Cross-platform shared agent instruction file. | `references/agents-md-template.md` |
| `CLAUDE.md` | Recommended (required if targeting Claude Code) | Claude Code entry shell. References AGENTS.md + Claude-specific additions. | `references/claude-md-template.md` |
| `config/default.json` | Required | Single source of truth for project configuration. | Generate per Rule 3 |
| `example.env` | Recommended | Env var template without real secrets. | Generate with placeholder comments |

## Directive File Rules

When writing AGENTS.md and CLAUDE.md in Step 5 of the Canonical Workflow, apply these rules.

### Three Authoring Principles

Apply in priority order:

1. **Explicit > Implicit.** Every rule stated in full. Never assume the agent "already knows."
   - Bad: `Follow standard code style.`
   - Good: `Use ESLint + Prettier. Config: .eslintrc.json, .prettierrc. Verify: npx eslint --max-warnings 0 src/`

2. **Constraint > Suggestion.** Replace "should", "consider", "try to" with "must", "always", "never".
   - Bad: `It is recommended to run tests before committing.`
   - Good: `Run npm test before every commit. All tests must pass. Do not commit if any test fails.`

3. **Verifiable > Non-verifiable.** Every rule checkable by running a command or inspecting an artifact.
   - Bad: `Write high-quality code.`
   - Good: `Function cyclomatic complexity must not exceed 10. Verify: npx eslint --max-warnings 0 src/`

### AGENTS.md Content Structure

A well-formed AGENTS.md contains 7 sections in order: Project Overview, Directory Layout, Code Standards, Build and Test, Commit Conventions, Security Constraints, Available Tools. Keep total length 2000-4000 characters.

When creating a new AGENTS.md, read `references/agents-md-template.md` for the complete template.

### CLAUDE.md Import Shell

CLAUDE.md must be a thin shell importing AGENTS.md:

```markdown
@AGENTS.md

## Claude Code Specific
- (Only Claude-Code-exclusive rules here)
```

Rules: `@AGENTS.md` import before any content. No rule duplication with AGENTS.md. If no Claude-specific rules exist, file is just heading + import.

When creating a new CLAUDE.md, read `references/claude-md-template.md` for the shell template.

### Self-Check Protocol

After writing any directive file, verify every rule passes three tests:
1. **Unambiguous?** Could an agent execute this without clarifying questions?
2. **Constraint?** Is it phrased as binding ("must/always/never"), not suggestive ("should/consider")?
3. **Verifiable?** Can a single command check compliance?

## Review Existing Project

When reviewing an existing project's structure instead of creating a new one, run this checklist:

- [ ] Root directory has 15 or fewer entries (run `ls -A | wc -l`)
- [ ] `skills/` and `src/` contain no imports from `adapters/` (content-host separation)
- [ ] `config/default.json` exists and is valid JSON
- [ ] `README.md` contains install commands in its first 30 lines
- [ ] No platform-specific files (`.claude-plugin/`, `.codex-plugin/`) exist outside `adapters/`
- [ ] `AGENTS.md` exists and follows the 7-section structure
- [ ] `CLAUDE.md` exists (if targeting Claude Code) and uses the `@AGENTS.md` import pattern
- [ ] Every rule in AGENTS.md passes the three-test self-check (unambiguous, constraint, verifiable)
- [ ] AGENTS.md is between 2000-4000 characters

## References

Load these reference files on demand during execution. Do not load them all upfront.

- **When generating the directory tree:** Read `references/directory-template.md` for the canonical ASCII tree of the selected template (A, B, or C).
- **When creating README.md:** Read `references/readme-template.md` for the Run-to-Understand section ordering and placeholder structure.
- **When creating CONTRIBUTING.md:** Read `references/contributing-template.md` for agent-ecosystem-specific contribution guidelines.
- **When creating SECURITY.md:** Read `references/security-template.md` for agent-ecosystem threat categories and vulnerability disclosure structure.
- **When creating AGENTS.md:** Read `references/agents-md-template.md` for the complete template with placeholder markers.
- **When creating CLAUDE.md:** Read `references/claude-md-template.md` for the thin import shell template.
- **When reviewing a completed scaffold:** Read `examples/ideal-project-tree.md` for a fully annotated reference.
