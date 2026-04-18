---
name: forge-ship
description: "Use this skill when preparing an agent ecosystem project for release, checking release readiness, setting up CI/CD, choosing a license, writing CHANGELOG, reviewing versioning strategy, performing a security audit, or writing SECURITY.md. Covers the 54-item publishing checklist across 5 lifecycle stages, SemVer for agent projects (description change = breaking change), CI/CD four gates, CHANGELOG conventions, LICENSE selection, OWASP Agentic Top 10, supply chain security, and prompt injection defense. Trigger keywords: release, publish, ship, version, SemVer, CHANGELOG, CI/CD, license, checklist, security audit, security review, SECURITY.md, prompt injection, supply chain, OWASP, permissions, vulnerability, 发布, 发版, 版本管理, 安全审计, 安全合规."
license: MIT
compatibility: "No runtime dependencies. Works with any coding agent that supports SKILL.md."
metadata:
  author: harnessforge
  version: "0.4.0"
  category: release-management
allowed-tools: Bash Read Edit Write Glob Grep
---

# Forge Ship

Shipping an agent ecosystem project requires more than `npm publish`.
In agent projects, tool descriptions, skill trigger keywords, parameter schemas, and manifest structures are all part of the public API.
A rewording of a tool description can break downstream agent behavior just as surely as removing a function.
Apply the standards in this skill to version correctly, gate releases with CI, maintain changelogs, and run the full release readiness checklist before every publish.

## Required Execution Rules

1. Never tag a release without confirming that all four CI gates pass (metadata lint, tests, compatibility, security).
2. Treat any tool description or skill trigger keyword change as a potential breaking change. Evaluate it explicitly before assigning a version bump.
3. Always update the CHANGELOG before creating a release tag. Use the conventions defined in this skill.
4. When the project lacks a LICENSE file, add one before any other release activity. Do not publish unlicensed code.
5. When generating a CHANGELOG entry, read `references/changelog-template.md` for the required format.

## SemVer for Agent Projects

Standard SemVer applies, but the definition of "public API" is broader in agent projects.
The public API includes every surface that an agent depends on to discover, invoke, or parse results from your project.

### Expanded Public API Surface

| Surface | Examples | Why It Matters |
|---------|----------|----------------|
| Tool name / description / when_to_use | Name string, description text, trigger hints | Agents use these to decide whether to invoke the tool |
| Parameter schema | JSON Schema input fields, required vs optional | Agents construct calls based on this schema |
| Return schema | Output field names, types, semantics | Downstream agents parse results using this structure |
| Manifest / frontmatter fields | plugin.yaml, SKILL.md metadata | Affects discovery, loading, and distribution |
| Auth / permission / transport | OAuth scopes, stdio vs SSE vs HTTP | Affects deployment and runtime connectivity |
| Environment variables | Required env vars | Affects installation and configuration |
| Install entry point | CLI command, package name, registry path | Affects first-use experience |

### Version Bump Decision Table

Use this table to determine the correct version bump for any change.

| Change | Bump | Rationale |
|--------|------|-----------|
| Delete or rename a tool / resource / prompt | MAJOR | Existing agent calls will break |
| Add a new required parameter field | MAJOR | Existing agent calls omit the field and fail |
| Change a return field's type or semantic meaning | MAJOR | Downstream parsing breaks |
| Change auth method or transport protocol (removing old) | MAJOR | Deployment configuration breaks |
| Rewrite a tool description that narrows or widens trigger scope | MAJOR | Agents that relied on old trigger behavior change invocation patterns |
| Add a new optional parameter field | MINOR | Backward compatible; existing calls still work |
| Add a new tool / resource / prompt | MINOR | Additive; no existing behavior changes |
| Add a new transport without removing old ones | MINOR | Additive; existing connections unaffected |
| Fix a bug without changing the call contract | PATCH | Internal improvement only |
| Fix a typo that does not change semantic meaning | PATCH | No behavioral change |
| Performance optimization with identical outputs | PATCH | No contract change |

When in doubt about whether a description change is breaking, apply the **implicit contract test**: if an agent that previously triggered (or did not trigger) on a given prompt would now behave differently, it is a MAJOR change.

## CI/CD Four Gates

Configure the CI pipeline as a four-gate sequence. Each gate must pass before the next gate runs. A failure at any gate blocks the release.

### Gate 1: Metadata Lint

Validate all machine-readable metadata before anything else. Metadata errors are the most fundamental failure -- if the manifest is malformed, nothing downstream works.

Checks to run:
- Validate plugin.yaml / plugin.json against its JSON Schema.
- Validate SKILL.md frontmatter (name format, description length, required fields).
- Validate MCP tool schemas against the MCP JSON Schema.
- Detect description changes between the PR branch and the base branch. Flag any diff for human review.

Example commands:
```bash
npx ajv validate -s schemas/plugin-manifest.schema.json -d plugin.yaml
npx ajv validate -s schemas/mcp-tool.schema.json -d 'src/tools/*/schema.json'
node scripts/lint-frontmatter.js
node scripts/detect-description-changes.js --base origin/main --head HEAD
```

### Gate 2: Unit Tests and Contract Tests

Run the standard test suite plus MCP Inspector contract validation.

Checks to run:
- All unit tests pass.
- MCP Inspector verifies transport connection, capability negotiation, tool/resource/prompt registration, and error handling.

Example commands:
```bash
npm test
npx @modelcontextprotocol/inspector \
  --transport stdio \
  --check-tools --check-resources --check-error-handling \
  --fail-on-error
```

### Gate 3: Cross-Platform Compatibility

Full cross-host UI testing is unrealistic in CI. Use a pragmatic three-layer strategy:
1. **Protocol-layer CI (every PR)**: MCP schema validation, manifest format check, install smoke test.
2. **Key host smoke test (every PR)**: Pick 1-2 primary hosts and run minimal connectivity tests.
3. **Full host UI test (periodic / manual)**: Reserve for pre-release manual verification.

Example commands:
```bash
# Protocol compliance
npm run test:protocol -- --transport stdio
npm run test:protocol -- --transport sse

# Install smoke test in a clean environment
npm pack
cd /tmp && mkdir test-install && cd test-install
npm init -y && npm install /path/to/package.tgz
node -e "require('@your-org/your-tool')"
```

### Gate 4: Security Scanning

Run the four security tools plus a credential redaction test.

| Tool | Purpose |
|------|---------|
| Dependabot / Renovate | Dependency vulnerability alerts and automated update PRs |
| CodeQL | Static code analysis for security flaws |
| Secret scanning + push protection | Detect leaked credentials before they reach the remote |
| OpenSSF Scorecard | Composite security posture score (branch protection, pinned actions, token permissions) |

Additionally, verify that tool outputs do not leak injected credentials. Run a test that provides a dummy secret as input and asserts the output does not contain it.

Example commands:
```bash
# CodeQL (typically configured as a GitHub Action)
# github/codeql-action/analyze@v3

# OpenSSF Scorecard (typically configured as a GitHub Action)
# ossf/scorecard-action@v2

# Credential redaction test
npm run test:redaction
```

## Security Audit

When performing a security audit or checking security posture before release, follow this section. Security audit corresponds to Gate 4 in the CI/CD pipeline and Stage 3 in the lifecycle checklist.

### Three Fundamental Security Errors

Before any audit, verify the project does NOT commit these errors:

1. **Treating the model as a validator.** The model is probabilistic, not a security boundary. Enforce all validation in application code.
2. **Treating natural language as a trusted interface.** Tool descriptions, tool results, and system prompts are attack vectors. A poisoned tool description can alter agent behavior directly. Metadata is payload.
3. **Treating the publish chain as ordinary npm/pip.** Agent plugins carry dual risk: code supply chain AND prompt chain. A tampered tool description is as dangerous as a tampered binary.

### OWASP Agentic Top 10 Quick Reference

| ID | Risk | One-Line Mitigation |
|----|------|---------------------|
| ASI01 | Agent Goal Hijack | Treat all tool results as untrusted; never splice free text into planner prompts |
| ASI02 | Tool Misuse & Exploitation | Expose minimum tool set; validate every parameter in code |
| ASI03 | Identity & Privilege Abuse | Independent auth per server; never pass through user tokens |
| ASI04 | Agentic Supply Chain | Pin deps, generate SBOM, use Trusted Publishing, verify provenance |
| ASI05 | Unexpected Code Execution | Ban string concatenation for shell commands; use execFile / arg arrays |
| ASI06 | Memory & Context Poisoning | Strip L1/L2 data before memory write; enforce TTL on all caches |
| ASI07 | Insecure Inter-Agent Communication | Validate identity and capability at every message boundary |
| ASI08 | Cascading Failures | Validate upstream tool output before downstream consumption |
| ASI09 | Human-Agent Trust Exploitation | Design approval UIs that show raw action details, not model-generated summaries |
| ASI10 | Rogue Agents | Enforce hard timeouts, retry caps, and non-skippable approval gates |

For detailed per-risk checks, read `references/owasp-agentic-top10-checklist.md`.

### Security Audit Workflow

Execute these steps when auditing:

1. **Inventory attack surface.** List every tool (name, description, schema), external data source, side effect, and credential.
2. **Map to OWASP Agentic Top 10.** For each tool and data flow, identify applicable ASI risks.
3. **Check supply chain.** Verify: lock file exists, CI uses locked install, SBOM generated per release, Trusted Publishing for npm/PyPI, Actions pinned to SHA, GITHUB_TOKEN minimal permissions. For detailed steps, read `references/supply-chain-checklist.md`.
4. **Audit prompt injection defenses.** Read every tool description for conditional logic, cross-tool orchestration hints, or override language. Verify input validation in code, not model instructions.
5. **Audit permissions.** Verify OAuth scopes are fine-grained, no token passthrough, write/delete/send operations require approval, tool annotations match server-side enforcement.
6. **Check security documentation.** Verify SECURITY.md exists with supported versions and reporting instructions. When creating SECURITY.md, read `references/security-md-template.md`.

## Release Readiness Quick Check

Run this condensed 20-item checklist before every release. For the full 54-item checklist organized by lifecycle stage, read `references/full-publish-checklist.md`.

### Legal and Governance
- [ ] LICENSE file exists and matches the project type (MIT for plugins, Apache 2.0 for SDKs/protocols).
- [ ] CONTRIBUTING.md defines tool description changes as public API changes.
- [ ] SECURITY.md includes a vulnerability reporting channel and response SLA.

### Metadata and Schema
- [ ] All manifest files (plugin.yaml, SKILL.md frontmatter) pass schema validation.
- [ ] Version numbers are consistent across all manifests and package files.
- [ ] MCP tool schemas validate against the protocol JSON Schema.

### Versioning and Changelog
- [ ] Version bump matches the change type (MAJOR for breaking, MINOR for additive, PATCH for fixes).
- [ ] CHANGELOG is updated with all changes since the last release, following Keep a Changelog format.
- [ ] Breaking changes are explicitly called out in a dedicated CHANGELOG section.

### Tests and CI
- [ ] All four CI gates pass (metadata lint, unit/contract tests, compatibility, security).
- [ ] MCP Inspector contract test passes on all supported transports.
- [ ] At least one end-to-end test passes on a real agent host (Claude Code, Codex, or equivalent).

### Security
- [ ] No hardcoded secrets in the codebase (secret scanning passes).
- [ ] Dependency lock file is committed and up to date.
- [ ] GitHub Actions use SHA-pinned references, not floating tags.

### User Experience
- [ ] README install command works in a clean environment.
- [ ] The 5-minute onboarding path has been manually verified.

### Distribution
- [ ] Git tag is created with the correct format (e.g., v1.2.3).
- [ ] SBOM is generated and attached to the release.
- [ ] All distribution channels (npm, PyPI, container registry) publish the same version from the same commit SHA.

## CHANGELOG Conventions

Use Keep a Changelog format with one addition: a **Breaking** section for agent-ecosystem-specific breaking changes (description rewrites, schema removals, auth changes).

### Section Order

List sections in this order within each version entry:
1. **Breaking** -- Changes that alter the implicit agent invocation contract (description rewrites, removed tools, schema type changes). Always list first.
2. **Added** -- New tools, resources, prompts, optional parameters.
3. **Changed** -- Modifications to existing behavior that are backward compatible.
4. **Deprecated** -- Features marked for future removal with a migration path.
5. **Removed** -- Features deleted in this release (also listed under Breaking if they were public API).
6. **Fixed** -- Bug fixes.
7. **Security** -- Vulnerability patches.

### Commit Message Convention

Use Conventional Commits with agent-ecosystem scopes:

```
feat(tools): add file-search tool with glob support
fix(auth): correct OAuth token refresh for SSE transport
feat(desc)!: rewrite file-search description to narrow trigger scope

BREAKING CHANGE: file-search description changed from "Search files" to
"Search files in the current workspace directory". Agents that previously
triggered this tool for general file search may no longer do so.
```

Recommended scopes: `tools`, `schema`, `manifest`, `auth`, `transport`, `desc`.

When writing a CHANGELOG entry, read `references/changelog-template.md` for the full template with placeholder markers.

## LICENSE Selection

When choosing a license for a new project, read `references/license-selection-guide.md` for the MIT vs Apache 2.0 comparison and decision rules.

**Quick rule**: If the project defines a protocol, SDK, or cross-vendor foundation, use Apache 2.0 for patent protection. For everything else, use MIT.

## Five Lifecycle Stages

The full 54-item publishing checklist is organized into five stages that cover the entire project lifecycle. Each stage has a clear trigger point.

| Stage | Trigger | Key Focus |
|-------|---------|-----------|
| 1. Repo Creation | `git init` or `gh repo create` | LICENSE, CODE_OF_CONDUCT, CONTRIBUTING, SECURITY, .gitignore, CI skeleton, branch protection |
| 2. Development | Every PR merge | Directory structure, AGENTS.md, SKILL.md frontmatter, MCP Inspector tests, permission model |
| 3. Security Audit | Before each release (mandatory for major versions) | Dependency lock files, SBOM, secret scanning, prompt injection red-team, OAuth scope review |
| 4. Pre-Release | Before `git tag` / `npm publish` | SemVer compliance, CHANGELOG, manifest consistency, trusted publishing, clean-room install test, E2E host test |
| 5. Post-Release | Within 48 hours of publish | Marketplace listing accuracy, monitoring/alerting, good-first-issues, community channels, OpenSSF Scorecard baseline |

For the complete checklist with all 54 items in checkbox format, read `references/full-publish-checklist.md`.

## Canonical Workflow

Follow these steps when preparing a release.

1. Determine the release type by reviewing all changes since the last tag. Use the version bump decision table to classify each change as MAJOR, MINOR, or PATCH. The highest classification wins.
2. Run the release readiness quick check (20 items above). Fix any failing items before proceeding.
3. Update the CHANGELOG following the conventions in this skill. Read `references/changelog-template.md` if starting from scratch.
4. Bump the version number in all manifest files and package metadata. Verify consistency.
5. Commit the version bump and CHANGELOG update. Use the message format: `chore(release): vX.Y.Z`.
6. Create a git tag: `git tag vX.Y.Z`.
7. Push the tag and let CI run all four gates. Do not publish until all gates pass.
8. After CI passes, publish to all distribution channels from the same commit SHA.
9. Verify post-publish consistency: confirm the version number matches across npm/PyPI, container registry, and GitHub Release.
10. Complete the post-release checklist items within 48 hours.

## Error Handling

When the CI metadata lint gate fails on a description change diff, do not auto-fix. Read the diff, evaluate whether the description change alters implicit invocation behavior, and if so, escalate the version bump to MAJOR.

When the security gate reports a high-severity dependency vulnerability, do not release. Update the dependency, re-run the full pipeline, and only proceed when the scan is clean.

When manifest version numbers are inconsistent across files, read all manifest files, identify the source of truth (usually package.json or pyproject.toml), and propagate that version to all other manifests before re-running Gate 1.

When setting up CONTRIBUTING.md for a new project, read `references/contributing-template.md` for an agent-ecosystem-specific template with placeholder markers.

## References

When performing the full 54-item release checklist, read `references/full-publish-checklist.md` for every item organized by lifecycle stage.

When creating or updating CHANGELOG.md, read `references/changelog-template.md` for the complete template with placeholder markers.

When creating or updating CONTRIBUTING.md, read `references/contributing-template.md` for the agent-ecosystem-specific template.

- `references/owasp-agentic-top10-checklist.md` -- Full OWASP Agentic Top 10 checklist with per-risk mitigations.
- `references/security-md-template.md` -- SECURITY.md template with agent-ecosystem threat categories.
- `references/supply-chain-checklist.md` -- Supply chain security checklist with commands for SBOM, lock files, Trusted Publishing, SHA pinning.
- `references/license-selection-guide.md` -- MIT vs Apache 2.0 comparison for agent ecosystem projects.
