# Full Publish Checklist (54 Items)

Use this checklist to verify release readiness across the entire project lifecycle.
Copy this into a GitHub issue or PR description and check off each item.
Items are organized by the five lifecycle stages. Work through stages in order for a new release; revisit earlier stages when doing major version releases.

---

## Stage 1: Repo Creation (Day One)

Complete these items on the day you run `git init` or `gh repo create`. They form the foundation that everything else builds on.

### Legal and Community

- [ ] **1.1** LICENSE file added. Use MIT for plugins/tools/templates. Use Apache 2.0 for SDKs, protocols, and reference implementations.
- [ ] **1.2** CODE_OF_CONDUCT.md added. Use Contributor Covenant v2.1 or later. Include a violation reporting email. Include agent-ecosystem additions: no adversarial prompts in tool descriptions, no misleading schemas, security issues go through SECURITY.md.

### Documentation

- [ ] **1.3** README.md created with: one-line project description, 5-minute Getting Started section (clone, install, run), badge area (CI status, version, license type). If content is not ready, add `## TODO` placeholder sections.
- [ ] **1.4** CONTRIBUTING.md created. Includes fork-branch-PR flow. Defines tool description changes as public API changes. Requires compatibility impact statements on public API PRs. States AI-generated code policy.
- [ ] **1.5** SECURITY.md created. Includes vulnerability reporting channel (prefer GitHub Private Vulnerability Reporting). States response SLA (e.g., 72h acknowledgment, 14d fix plan). Lists supported version range.

### Engineering

- [ ] **1.6** .gitignore configured. Covers language-specific artifacts (node_modules, __pycache__, .env). Covers IDE files (.vscode/, .idea/). Covers OS files (.DS_Store, Thumbs.db). Explicitly excludes .env and any secret-containing files.
- [ ] **1.7** CI baseline configured. GitHub Actions workflow with at least lint + test. All action references use SHA pinning (not floating tags).
- [ ] **1.8** Branch protection enabled on main/master. Requires PR for merge. Requires at least one reviewer approval. Requires CI pass as merge condition.

---

## Stage 2: Development (Ongoing)

Check these items during daily development. Review before every PR merge.

### Project Structure

- [ ] **2.1** Root directory has 15 or fewer top-level entries (Progressive Disclosure principle).
- [ ] **2.2** Content layer (skills/, src/, docs/, tests/) and adapter layer (adapters/) are clearly separated.
- [ ] **2.3** Clone, install, run works in three steps with no hidden dependencies. All external dependencies are explicitly declared.

### Instruction and Skill Files

- [ ] **2.4** AGENTS.md written. Covers project overview, code standards, testing requirements, security constraints, and available tools for agents.
- [ ] **2.5** If Claude Code is supported, CLAUDE.md exists and references AGENTS.md.
- [ ] **2.6** SKILL.md frontmatter complete (if project ships skills). All 6 core fields present: name, description, license, compatibility, metadata, allowed-tools. Description targets agents, not humans. Trigger conditions are explicit.
- [ ] **2.7** Progressive Disclosure tiers are correct. Tier 1 (frontmatter, ~100 tokens) supports discovery. Tier 2 (full SKILL.md, <5000 tokens) supports execution. Tier 3 (references/scripts/assets) loads on demand only.

### MCP Server (if applicable)

- [ ] **2.8** MCP Inspector contract test passes. Tools, Resources, and Prompts register correctly. Capability negotiation succeeds. Transport (stdio / HTTP) connects.
- [ ] **2.9** Tool descriptions reviewed by a human. Descriptions are clear, accurate, and unambiguous. No content exploitable as prompt injection. Description changes logged as potential breaking changes.
- [ ] **2.10** Parameter schemas are complete. Every parameter has type, description, and example. Required vs optional is correctly annotated. Return values are structured (not free text).
- [ ] **2.11** Errors use structured format. Error objects include error code and message. No reliance on natural language for error signaling. Agents can make programmatic decisions from error codes.

### Permissions and Security Baseline

- [ ] **2.12** Permissions follow least-privilege. Only necessary OAuth scopes are requested. File system access scope is explicitly declared. Write operations require explicit user approval (human-in-the-loop).
- [ ] **2.13** MCP is not used as a security boundary. All security checks happen in application code, not the protocol layer.

---

## Stage 3: Security Audit (Pre-Release)

Run the full audit before each release. For major version releases, treat this as mandatory and thorough.

### Supply Chain

- [ ] **3.1** Dependency lock file committed and current. Node.js: package-lock.json or pnpm-lock.yaml. Python: poetry.lock or requirements.txt with hashes. Go: go.sum.
- [ ] **3.2** SBOM generated in SPDX or CycloneDX format. CI generates it automatically and attaches it to the release.
- [ ] **3.3** GitHub Actions use SHA-pinned references (not floating tags). Dependabot or Renovate keeps pinned SHAs up to date.
- [ ] **3.4** Dependabot or Renovate enabled for automated vulnerability detection and update PRs.

### Secrets and Data

- [ ] **3.5** No hardcoded secrets. GitHub Secret Scanning enabled and passing. .env in .gitignore. Repository history contains no leaked tokens or keys (if any were leaked, they have been rotated).
- [ ] **3.6** Logs contain no sensitive data. No tokens, passwords, or PII in log output. Error stack traces do not expose internal paths or configuration.

### Prompt Injection Defense

- [ ] **3.7** Prompt injection red-team testing completed. Covers cross-tool propagation (tool A output injected into tool B input). Covers instruction override attacks in tool descriptions. Covers malicious payloads in tool results.
- [ ] **3.8** Structured output preferred. Tool results use structured data (JSON) over free text. Input validation happens in code, not via model judgment.

### Permission Review

- [ ] **3.9** OAuth scopes minimized. Every scope has a documented functional justification. No speculative or future-reserved scopes. MCP token passthrough mode is not used.
- [ ] **3.10** Write operations have explicit approval. All write, delete, and publish side effects require user confirmation. Approval prompts accurately describe consequences.

---

## Stage 4: Pre-Release (Before Tag/Publish)

Complete these items after the security audit passes and before running `git tag` or `npm publish`.

### Version and Changelog

- [ ] **4.1** Version number follows SemVer. MAJOR for incompatible changes (including tool description changes that alter invocation contracts). MINOR for backward-compatible additions. PATCH for backward-compatible fixes.
- [ ] **4.2** CHANGELOG updated. Uses Conventional Commits or Keep a Changelog format. Breaking changes are explicitly labeled. Automated via release-please or changesets where possible.

### Cross-Platform Consistency

- [ ] **4.3** Manifest consistency verified. Version numbers match across all platform manifests. Capability descriptions are identical across manifests. CI script validates multi-manifest consistency.
- [ ] **4.4** .mcp.json configuration synchronized across all supported platforms.

### Supply Chain Verification

- [ ] **4.5** Trusted Publishing configured (if publishing to npm or PyPI). npm: OIDC + provenance enabled. PyPI: Trusted Publishing configured. Publishing runs through CI, not personal tokens.
- [ ] **4.6** GitHub Actions SHA-pinned in the release workflow (re-confirm).
- [ ] **4.7** Container images signed (if applicable). Cosign signing enabled. Trivy scan shows no high-severity vulnerabilities. Signatures are verifiable from the registry.

### User Experience Validation

- [ ] **4.8** README install command verified in a clean environment. Tested in a new container, new venv, or new node project. All dependencies resolve correctly. No undeclared system-level dependencies.
- [ ] **4.9** 5-minute onboarding path manually tested. A simulated new user can go from README to first successful tool call in under 5 minutes. If it takes longer, optimize the steps.
- [ ] **4.10** End-to-end test passes on at least one real agent host. Full chain tested: install, discover, invoke, parse result. CI includes an E2E test step.

### Final Gate

- [ ] **4.11** All four CI gates pass. Gate 1: metadata lint. Gate 2: unit + contract tests. Gate 3: compatibility. Gate 4: security scan.
- [ ] **4.12** SBOM attached to release assets.
- [ ] **4.13** Git tag created with correct format (e.g., v1.2.3).

---

## Stage 5: Post-Release (Within 48 Hours)

Complete these items within 48 hours of publishing. They determine whether the project transitions from "released" to "adopted."

### Distribution Channels

- [ ] **5.1** Marketplace and registry listings are accurate. Description, screenshots, and category tags are correct. npm/PyPI package page has correct description, keywords, and repository link. Version numbers match the GitHub Release across all channels.
- [ ] **5.2** Install instructions verified on all distribution channels. npm install, pip install, manual clone -- all paths work.

### Monitoring and Response

- [ ] **5.3** Monitoring and alerting configured (where applicable). Download count tracking on npm/PyPI. GitHub issue and vulnerability alert notifications enabled. Remote MCP servers have health check endpoints and availability alerts.
- [ ] **5.4** Response SLAs published. Security vulnerabilities: per SECURITY.md commitments. General issues: first response within 7 days. PR reviews: first review within 14 days.

### Community Building

- [ ] **5.5** At least 3-5 good-first-issues labeled. Each issue has a clear problem description, expected behavior, and implementation hints. Difficulty and estimated effort are noted.
- [ ] **5.6** Community channels operational. GitHub Discussions enabled. Discord/Slack channel exists if broader community interaction is needed. README includes links to all community entry points.
- [ ] **5.7** Issue and PR templates configured. Issue template includes reproduction steps, environment info, host platform, transport type, and repro prompt fields. PR template includes change type, compatibility impact, and testing checklist.

### Documentation Completion

- [ ] **5.8** CHANGELOG release notes published to GitHub Releases page.
- [ ] **5.9** Documentation site updated (if one exists).
- [ ] **5.10** Multi-language translation triggered (if the project has i18n requirements).

### Health Baseline

- [ ] **5.11** OpenSSF Scorecard run. Current score recorded. Improvement plan created for any low-scoring areas.
- [ ] **5.12** CHAOSS community health metrics baselined. Track: first response time, PR merge cycle, issue close rate, new contributor conversion rate.

---

## Quick Lookup: Which Stage to Check

| Current Situation | Check These Stages |
|-------------------|--------------------|
| Just created the repo | Stage 1 |
| Daily development | Stage 2 |
| Preparing a release | Stage 3 then Stage 4 (in order) |
| Just published | Stage 5 |
| Major version release | All stages, start to finish |
