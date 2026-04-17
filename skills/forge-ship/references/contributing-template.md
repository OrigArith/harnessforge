# CONTRIBUTING.md Template

Use this template to create a CONTRIBUTING.md file for an agent ecosystem project.
Replace all `{{PLACEHOLDER}}` markers with actual values.
This template includes agent-ecosystem-specific sections that go beyond standard contributing guides.

---

## Template

```markdown
# Contributing to {{PROJECT_NAME}}

Thank you for your interest in contributing. This guide explains how to submit
changes and what standards your contributions must meet.

## Quick Start

1. Fork the repository.
2. Create a feature branch from `main`: `git checkout -b feat/your-feature`.
3. Make your changes.
4. Run the test suite: `{{TEST_COMMAND}}`.
5. Run the linter: `{{LINT_COMMAND}}`.
6. Commit using Conventional Commits format (see below).
7. Open a Pull Request against `main`.

## Public API Definition

In this project, the public API extends beyond code interfaces. The following
changes are all treated as public API changes and require a compatibility impact
statement in the PR description.

**Any change to these surfaces must follow the API change process:**

- Tool name, resource name, or prompt name (add, rename, or delete)
- Tool description or `when_to_use` text (any semantic change, even "just rewording")
- Parameter schema (new required fields, deleted fields, type changes)
- Return value schema (field type or semantic meaning changes)
- Manifest or frontmatter fields (plugin.yaml, SKILL.md metadata)
- Auth, permission, or transport changes
- Environment variable names (renamed or newly required)
- Install entry point changes (CLI commands, package names)

**Why description changes matter:** Agents use tool descriptions to decide
whether to invoke a tool. A seemingly minor rewording -- such as changing
"Search local files" to "Search files" -- can cause an agent to trigger the tool
in contexts where it previously did not, or stop triggering it where it previously
did. Treat description changes with the same rigor as function signature changes.

## Compatibility Impact Statement

Every PR that touches the public API (as defined above) must include the following
in the PR description:

1. **Change type:** `breaking` | `deprecation` | `additive`
2. **Affected scope:** Which host platforms or agent frameworks are impacted
3. **Migration path:** If breaking, what must users change
4. **Test verification:** Which hosts or environments the change has been tested on

Example:

```
## Compatibility Impact

- **Change type:** breaking
- **Affected scope:** All hosts that use implicit tool invocation (Claude Code, Codex)
- **Migration path:** Update any prompt templates that reference the old tool name
  "search-files" to use the new name "workspace-search"
- **Test verification:** Tested on Claude Code v1.x with stdio transport
```

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code restructure with no behavior change |
| `test` | Adding or updating tests |
| `chore` | Build, CI, dependency updates |

### Scopes

| Scope | When to Use |
|-------|-------------|
| `tools` | Tool definition and implementation |
| `schema` | JSON Schema changes |
| `manifest` | Manifest or frontmatter changes |
| `auth` | Authentication and authorization |
| `transport` | Transport layer (stdio, SSE, HTTP) |
| `desc` | Tool description changes (usually breaking!) |

### Breaking Change Indicator

Append `!` after the scope for breaking changes. Add a `BREAKING CHANGE:` footer
with migration details.

```
feat(desc)!: rewrite file-search description to narrow trigger scope

BREAKING CHANGE: file-search description changed from "Search files" to
"Search files in the current workspace directory". Agents that previously
triggered this tool for general file searches may no longer do so.
Migration: Update any workflows that relied on the broader trigger scope
to use the new "global-search" tool instead.
```

## New Tool / Integration Admission Criteria

New tools or integrations entering the main repository must satisfy all of the
following:

- [ ] Tracked by a GitHub issue with a clear user scenario
- [ ] Complete schema definition with typed, described parameters
- [ ] Complete tool description reviewed for invocation accuracy
- [ ] At least one host platform smoke test passing
- [ ] Documentation added (README section + inline API reference)
- [ ] Maintainer sponsor identified (who owns ongoing maintenance)

## Testing Requirements

### Before Submitting a PR

- [ ] All existing tests pass: `{{TEST_COMMAND}}`
- [ ] New code has corresponding tests
- [ ] Linter passes with no new warnings: `{{LINT_COMMAND}}`
- [ ] If you changed a manifest or schema, run: `{{SCHEMA_VALIDATION_COMMAND}}`
- [ ] If you changed a tool description, run: `{{DESCRIPTION_DIFF_COMMAND}}`

### For Public API Changes

- [ ] MCP Inspector contract test passes: `{{MCP_INSPECTOR_COMMAND}}`
- [ ] Install smoke test passes in a clean environment
- [ ] Tested on at least one real agent host

## AI-Generated Code Policy

- AI-assisted code contributions are welcome. The submitter is fully responsible
  for the quality and correctness of all submitted code, regardless of how it
  was generated.
- All AI-generated content undergoes the same review standards as human-written code.
- Tool descriptions generated by AI require explicit human review of their impact
  on invocation semantics. The reviewer must confirm that the description does not
  inadvertently widen or narrow the tool's trigger scope.

## Code of Conduct

This project follows the [Contributor Covenant](https://www.contributor-covenant.org/)
Code of Conduct. In addition to the standard provisions:

- Do not embed adversarial prompts or hidden instructions in tool descriptions.
- Do not submit intentionally misleading schemas.
- Report security vulnerabilities through the private channel described in
  [SECURITY.md]({{SECURITY_MD_LINK}}), never as public issues.

## Getting Help

- **Bug reports:** [GitHub Issues]({{ISSUES_LINK}}) -- use the bug report template
- **Feature proposals and design discussions:** [GitHub Discussions]({{DISCUSSIONS_LINK}})
- **Real-time help:** [{{CHAT_PLATFORM}}]({{CHAT_LINK}})
- **Security vulnerabilities:** [SECURITY.md]({{SECURITY_MD_LINK}}) -- private channel only
```

---

## Placeholder Reference

| Placeholder | Description |
|-------------|-------------|
| `{{PROJECT_NAME}}` | Name of the project |
| `{{TEST_COMMAND}}` | Command to run the full test suite (e.g., `npm test`) |
| `{{LINT_COMMAND}}` | Command to run the linter (e.g., `npm run lint`) |
| `{{SCHEMA_VALIDATION_COMMAND}}` | Command to validate schemas (e.g., `npm run validate:schema`) |
| `{{DESCRIPTION_DIFF_COMMAND}}` | Command to detect description changes (e.g., `node scripts/detect-description-changes.js`) |
| `{{MCP_INSPECTOR_COMMAND}}` | Command to run MCP Inspector tests |
| `{{SECURITY_MD_LINK}}` | Relative or absolute path to SECURITY.md |
| `{{ISSUES_LINK}}` | URL to the GitHub Issues page |
| `{{DISCUSSIONS_LINK}}` | URL to the GitHub Discussions page |
| `{{CHAT_PLATFORM}}` | Name of the chat platform (e.g., Discord, Slack) |
| `{{CHAT_LINK}}` | Invite URL for the chat platform |

---

## Checklist Before Committing

- [ ] All `{{PLACEHOLDER}}` markers replaced with actual values.
- [ ] Public API definition section accurately reflects the project's API surfaces.
- [ ] Test commands are correct and runnable.
- [ ] Community links point to valid URLs.
- [ ] SECURITY.md link resolves correctly.
