# SECURITY.md Template

Use this template when generating the project's SECURITY.md. Replace all `{{PLACEHOLDER}}` markers. This template addresses agent-ecosystem-specific threat categories that standard SECURITY templates do not cover.

---

```markdown
# Security Policy

## Security Boundary Statement

{{PROJECT_NAME}} is {{BOUNDARY_STATEMENT}}.

<!-- Choose one and customize:
     - "an MCP server that executes tools on behalf of AI agents. It is NOT a security boundary. Callers must enforce their own access controls."
     - "a skill pack that provides instructions to AI agents. It does not execute code on its own but may instruct agents to run scripts."
     - "a plugin that bundles tools, skills, and lifecycle hooks. It has access to {{SCOPE}} and operates within the host agent's permission model."
-->

## Threat Model

The following threat categories are specific to agent ecosystem projects. Each category lists the attack surface and the mitigations this project implements.

### 1. Tool Description Injection

**Threat:** A malicious or poorly written tool description causes the agent to invoke the tool in unintended contexts, leak data to the tool, or bypass safety checks.

**Mitigations:**
- Tool descriptions are reviewed for injection vectors on every PR (see CONTRIBUTING.md breaking change policy).
- Descriptions state exactly what the tool does, what it accesses, and what side effects it has.
- No tool description contains instructions that override the agent's system prompt.

### 2. Parameter Schema Manipulation

**Threat:** An attacker supplies crafted input parameters that exploit insufficient validation, causing path traversal, command injection, or data exfiltration.

**Mitigations:**
- All tool parameters are validated against JSON Schema before execution.
- File path parameters are resolved and checked against `{{ALLOWED_PATHS_CONFIG}}`.
- {{ADDITIONAL_INPUT_VALIDATION}}

### 3. Cross-Tool Composition Risk

**Threat:** Multiple MCP tools (from this project or others) are composed by an agent in ways that produce unintended privilege escalation or data flow. Individual tools are safe; the combination is not.

**Mitigations:**
- This project documents the scope and side effects of each tool (see API / Tool Reference in README).
- Write and delete operations require explicit approval by default (`security.require_approval_for` in `config/default.json`).
- {{COMPOSITION_GUARDRAILS}}

### 4. Credential and Secret Exposure

**Threat:** API keys, tokens, or other secrets are leaked through tool responses, error messages, logs, or checked-in configuration.

**Mitigations:**
- `example.env` contains placeholder values only. Real secrets are never checked in.
- `.gitignore` excludes `.env`, `*.pem`, `*.key`, and user config directories.
- Error messages are sanitized to exclude secret values before returning to the agent.
- {{ADDITIONAL_SECRET_PROTECTIONS}}

### 5. Excessive Permission Scope

**Threat:** The project requests more permissions than necessary, creating a larger attack surface if the project or its dependencies are compromised.

**Mitigations:**
- Default configuration uses minimum permissions: `allowed_hosts: []`, advanced capabilities disabled.
- Users must explicitly opt in to write, delete, and network access capabilities.
- The project follows the principle of capability trimming: advanced features are off by default.

### 6. Dependency Supply Chain

**Threat:** A compromised or malicious dependency introduces vulnerabilities into the project.

**Mitigations:**
- CI runs `{{AUDIT_COMMAND}}` (e.g., `npm audit`, `pip audit`) on every PR.
- Dependabot is enabled for automated dependency updates.
- Lock files (`package-lock.json` / `poetry.lock`) are committed and reviewed.
- {{ADDITIONAL_SUPPLY_CHAIN_PROTECTIONS}}

## Supported Versions

| Version | Supported |
|---|---|
| {{LATEST_VERSION}} | Yes |
| < {{MINIMUM_SUPPORTED}} | No |

## Reporting a Vulnerability

**Do NOT open a public issue for security vulnerabilities.**

1. Use [GitHub Private Vulnerability Reporting](https://github.com/{{ORG}}/{{REPO}}/security/advisories/new) to submit a report.
2. Include: affected version, reproduction steps, impact assessment, and suggested fix if available.
3. You will receive an acknowledgment within **{{ACK_SLA}}** (recommended: 48 hours).
4. We aim to release a fix within **{{FIX_SLA}}** (recommended: 7 days for critical, 30 days for moderate).
5. We will coordinate disclosure timing with you before publishing any advisory.

## Security Contacts

- Primary: {{PRIMARY_CONTACT}}
- Backup: {{BACKUP_CONTACT}}

## Disclosure Policy

We follow [coordinated vulnerability disclosure](https://en.wikipedia.org/wiki/Coordinated_vulnerability_disclosure). After a fix is released, we will:
1. Publish a GitHub Security Advisory.
2. Add an entry to CHANGELOG.md.
3. Credit the reporter (unless they prefer anonymity).
```

---

**Template rules:**
- The six threat categories (tool description injection, parameter schema manipulation, cross-tool composition, credential exposure, excessive permissions, dependency supply chain) are mandatory for agent ecosystem projects. Add project-specific categories as needed but do not remove these six.
- The vulnerability reporting section MUST include response SLAs (acknowledgment and fix timelines).
- `SECURITY.md` MUST be placed at the project root, not inside `docs/`.
