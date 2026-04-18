# CONTRIBUTING.md Template

Use this template when generating the project's CONTRIBUTING.md. Replace all `{{PLACEHOLDER}}` markers. This template includes agent-ecosystem-specific sections that standard CONTRIBUTING templates lack.

---

```markdown
# Contributing to {{PROJECT_NAME}}

Thank you for considering a contribution. This guide covers the process and policies specific to agent ecosystem projects.

## Getting Started

1. Fork the repository and clone your fork.
2. Install dependencies: `{{INSTALL_COMMAND}}`
3. Run tests to verify your setup: `{{TEST_COMMAND}}`
4. Create a feature branch: `git checkout -b feat/your-feature`

## What Counts as a Public Interface

In agent ecosystem projects, the "public interface" extends beyond code APIs. Changes to any of the following are considered **public interface changes** and require the same care as API changes:

| Artifact | Why It Matters |
|---|---|
| **Tool name** | Agents discover and call tools by name. Renaming breaks existing agent workflows. |
| **Tool description** | Agents use descriptions to decide when to call a tool. Changing a description changes agent behavior. |
| **Parameter schema** (names, types, required fields) | Agents construct tool calls from schema. Schema changes break existing invocations. |
| **Return value structure** | Agents parse return values. Structural changes break downstream processing. |
| **SKILL.md frontmatter fields** | Platforms use frontmatter for skill discovery. Changing fields affects discoverability. |
| **SKILL.md trigger phrases** (in description) | Agents match trigger phrases to decide skill activation. |
| **Environment variable names** | Users and CI/CD reference env vars by name. Renaming breaks deployments. |
| **config/default.json field names** | Downstream config overrides reference field names. |

## Breaking Change Policy

A change is a **breaking change** if it modifies, removes, or semantically alters any public interface artifact listed above. Breaking changes MUST:

1. Be labeled with `breaking-change` in the PR.
2. Include a `BREAKING CHANGE:` footer in the commit message (conventional commits format).
3. Be documented in `CHANGELOG.md` under a `### BREAKING CHANGES` subsection.
4. Include a migration guide if the change affects tool descriptions or parameter schemas.

**Tool description changes deserve special attention.** A "clarification" that changes which queries trigger a tool is functionally a breaking change. When in doubt, treat description edits as breaking.

## Branching and Commits

- Branch naming: `feat/`, `fix/`, `docs/`, `refactor/`, `test/`, `chore/`
- Commit messages: Follow [Conventional Commits](https://www.conventionalcommits.org/).
- One logical change per commit. Do not bundle unrelated changes.

## Code Standards

- {{LANGUAGE_SPECIFIC_STANDARDS}}
- All code in `src/` and `skills/` must be platform-agnostic. No platform-specific imports (e.g., `@claude/sdk`, `@codex/runtime`) in shared code.
- Platform-specific code goes exclusively in `adapters/<platform>/`.

## Testing Requirements

Before submitting a PR, ensure:

- [ ] Unit tests pass: `{{UNIT_TEST_COMMAND}}`
- [ ] Smoke tests pass: `{{SMOKE_TEST_COMMAND}}`
- [ ] Contract tests pass (MCP servers): `{{CONTRACT_TEST_COMMAND}}`
- [ ] No new platform-specific imports in `src/` or `skills/`
- [ ] `config/default.json` remains valid JSON with all fields having defaults

## Platform Adapter Contributions

If adding or modifying a platform adapter:

1. Only modify files under `adapters/<platform>/`.
2. Do not introduce cross-adapter dependencies.
3. Update the platform's smoke test in `.github/workflows/`.
4. Update the Supported Platforms table in README.md.
5. If removing a platform adapter, update README and CI matrix accordingly.

## Security Considerations

- Never commit secrets, API keys, or tokens.
- If your change modifies file system access, network requests, or code execution capabilities, update `SECURITY.md`.
- If your change adds a new tool that performs writes or deletes, ensure it is gated behind `require_approval_for` in `config/default.json`.

## Pull Request Process

1. Fill out the PR template completely, including the **Breaking Change Checklist** and **Platform Impact** sections.
2. Ensure CI passes (lint, test, contract, security).
3. Request review from a maintainer.
4. Address review feedback with fixup commits, then squash before merge.

## Code of Conduct

This project follows the [Contributor Covenant v2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). Be respectful and constructive.
```

---

**Template rules:**
- The "What Counts as a Public Interface" table is mandatory for agent ecosystem projects. Do not omit it.
- The "Breaking Change Policy" section must explicitly call out tool description changes.
- Remove `{{CONTRACT_TEST_COMMAND}}` lines for Template B (skill packs have no contract tests).
