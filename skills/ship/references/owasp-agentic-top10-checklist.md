# OWASP Agentic Top 10 (2026) — Audit Checklist

Use this checklist when performing a security audit on an agent ecosystem project (MCP server, agent plugin, tool registry). For each risk, complete the specific checks and apply the recommended mitigations where gaps are found.

## Evidence Levels

- **Confirmed Incident**: Public CVE, vendor advisory, or official post-mortem exists.
- **Confirmed Attack Vector**: Standards or official documentation recognize this as an exploitable pattern; public incident evidence is limited.
- **Theoretical / Frontier Risk**: Identified by OWASP or research community with PoCs; large-scale exploitation evidence is limited.

---

## ASI01 — Agent Goal Hijack

**Description:** An attacker rewrites the agent's current goal by injecting instructions through web pages, emails, documents, or tool return values.

**Evidence Level:** Confirmed Incident (EchoLeak / CVE-2025-32711)

**Checks for agent ecosystem projects:**

- [ ] Tool results containing free text are treated as untrusted input
- [ ] External content (issues, web pages, emails, PR comments) is parsed and field-extracted before entering the prompt chain
- [ ] No tool result is spliced directly into system or developer prompts
- [ ] Structured output (`structuredContent` / JSON) is used wherever possible
- [ ] Rich text, URLs, and executable fragments are stripped from external content

**Mitigations:**

1. Return structured data from tools instead of free-form text.
2. Parse external content into typed fields; apply allowlists before forwarding.
3. Implement output length limits and truncation on all tool results.
4. Log and monitor goal-change patterns in agent reasoning traces.

---

## ASI02 — Tool Misuse & Exploitation

**Description:** An attacker induces the agent to call a legitimate tool with dangerous parameters or to invoke tools outside the intended scope.

**Evidence Level:** Confirmed Incident (Amazon Q / Kiro advisory, GitHub MCP exploit)

**Checks for agent ecosystem projects:**

- [ ] Every tool parameter has a JSON Schema with type, format, pattern, enum, or range constraints
- [ ] Input validation is enforced in application code (Zod, Pydantic, JSON Schema validator)
- [ ] Tool descriptions do not contain conditional logic or cross-tool orchestration hints
- [ ] The exposed tool set is the minimum necessary for the stated purpose
- [ ] Unused or development-only tools are not registered in production

**Mitigations:**

1. Validate every input parameter in code; do not rely on model compliance.
2. Reduce the registered tool set to the minimum required.
3. Write tool descriptions that are short, factual, and scope-bounded.
4. Add rate limiting per tool to detect anomalous usage patterns.

---

## ASI03 — Identity & Privilege Abuse

**Description:** The agent operates with user identity or overly broad scopes, creating a confused deputy scenario.

**Evidence Level:** Confirmed Attack Vector

**Checks for agent ecosystem projects:**

- [ ] Each MCP server authenticates independently; no token passthrough
- [ ] Token audience is validated by the receiving server
- [ ] OAuth scopes are fine-grained (read/write split, action-level, resource-scoped)
- [ ] Long-lived refresh tokens are avoided or tightly controlled
- [ ] Write operations require per-action user approval

**Mitigations:**

1. Issue per-server tokens with minimal scopes.
2. Validate token audience and issuer on every request.
3. Use short-lived access tokens with controlled refresh.
4. Never forward user tokens to downstream services.

---

## ASI04 — Agentic Supply Chain

**Description:** A dependency, plugin, registry entry, or remote MCP server is compromised, injecting malicious code or prompt payloads.

**Evidence Level:** Confirmed Attack Vector

**Checks for agent ecosystem projects:**

- [ ] Lock file is committed and CI uses locked install commands
- [ ] SBOM is generated for every release
- [ ] Publishing uses OIDC Trusted Publishing (no long-lived tokens)
- [ ] Third-party GitHub Actions are pinned to full commit SHA
- [ ] `GITHUB_TOKEN` permissions are explicitly scoped
- [ ] Dependency review action runs on PRs
- [ ] Secret scanning is enabled on the repository
- [ ] Tool descriptions from third-party servers are reviewed for injection payloads

**Mitigations:**

1. Pin all dependencies with lock files and verify hashes.
2. Generate SBOM (SPDX or CycloneDX) on every release.
3. Adopt Trusted Publishing for npm / PyPI.
4. Pin GitHub Actions to commit SHA; minimize CI token permissions.
5. Treat third-party tool descriptions as untrusted input.

---

## ASI05 — Unexpected Code Execution

**Description:** Seemingly legitimate input is processed in a way that results in shell, eval, or exec execution.

**Evidence Level:** Confirmed Incident (git-mcp-server command injection — GHSA-3q26-f695-pp76)

**Checks for agent ecosystem projects:**

- [ ] No tool uses `exec()` or shell-based command construction with string interpolation
- [ ] All shell commands use `execFile()` or equivalent with argument arrays
- [ ] CLI argument parsing uses `--` to terminate option parsing
- [ ] User-supplied strings are never used as file paths without allowlist validation
- [ ] No `eval()`, `Function()`, or dynamic code generation with user input

**Mitigations:**

1. Replace all `exec()` calls with `execFile()` and argument arrays.
2. Use `--` to separate options from arguments in CLI invocations.
3. Apply path allowlists for file system operations.
4. Run tool execution in a sandboxed environment where feasible.

---

## ASI06 — Memory & Context Poisoning

**Description:** Malicious content enters long-term memory, caches, or vector stores, persistently influencing future agent behavior.

**Evidence Level:** Theoretical / Frontier Risk (rapidly weaponizing)

**Checks for agent ecosystem projects:**

- [ ] L1 (credentials) and L2 (PII) data are stripped before any memory write
- [ ] All caches and memory stores have enforced TTL
- [ ] Memory write operations have approval gates or are audit-logged
- [ ] Vector store entries include provenance metadata (source, timestamp, trust level)
- [ ] A mechanism exists to purge or invalidate poisoned memory entries

**Mitigations:**

1. Strip sensitive data before writing to any persistent store.
2. Enforce TTL on all caches: 0 for credentials, 7-30 days for PII, 24-72 hours for business data.
3. Log all memory writes with source attribution.
4. Provide a purge mechanism for administrators.

---

## ASI07 — Insecure Inter-Agent Communication

**Description:** Multi-agent communication lacks identity verification and capability boundaries, enabling lateral movement.

**Evidence Level:** Confirmed Attack Vector

**Checks for agent ecosystem projects:**

- [ ] Every inter-agent message boundary includes sender identity verification
- [ ] Capability boundaries are enforced: an agent cannot invoke tools beyond its declared scope via another agent
- [ ] Message content from other agents is treated as untrusted input
- [ ] No agent can escalate its own permissions by relaying through another agent

**Mitigations:**

1. Authenticate and authorize at every message boundary.
2. Enforce capability constraints independently per agent.
3. Treat inter-agent messages with the same suspicion as external user input.

---

## ASI08 — Cascading Failures

**Description:** A partially incorrect output from one tool is consumed as truth by downstream tools, triggering chain-reaction side effects.

**Evidence Level:** Confirmed Attack Vector

**Checks for agent ecosystem projects:**

- [ ] Tool outputs include confidence or status indicators that downstream consumers can check
- [ ] Error states are explicitly returned (not masked as partial success)
- [ ] Downstream tools validate upstream output before acting on it
- [ ] Side-effect tools have independent confirmation gates (not auto-triggered by upstream output)

**Mitigations:**

1. Return explicit error codes and status fields in tool outputs.
2. Require downstream validation before side-effect execution.
3. Implement circuit breakers for multi-step tool chains.
4. Log the full chain of tool calls for post-incident analysis.

---

## ASI09 — Human-Agent Trust Exploitation

**Description:** The agent generates plausible-looking confirmation prompts that mislead users into approving dangerous actions.

**Evidence Level:** Confirmed Attack Vector

**Checks for agent ecosystem projects:**

- [ ] Approval UIs display raw action details (target, parameters, scope) not model-generated summaries
- [ ] Destructive actions show explicit consequences ("will delete X", "will send to Y")
- [ ] Approval prompts cannot be auto-dismissed or timed-out to "approved"
- [ ] Batch approvals are not available for destructive operations

**Mitigations:**

1. Design approval interfaces that show structured action data, not model prose.
2. Require explicit user input (not just "confirm") for destructive actions.
3. Never auto-approve on timeout.
4. Separate read approvals from write/delete/send approvals.

---

## ASI10 — Rogue Agents

**Description:** An agent in a long-running task gradually exceeds its design boundaries, evading shutdown or bypassing approval processes.

**Evidence Level:** Theoretical / Frontier Risk

**Checks for agent ecosystem projects:**

- [ ] Hard timeout is configured for all long-running tool operations
- [ ] Retry count has an enforced upper limit
- [ ] Approval gates cannot be skipped regardless of retry or timeout state
- [ ] Resource consumption (API calls, tokens, compute) has per-session caps
- [ ] Administrative kill switch exists and is documented

**Mitigations:**

1. Set non-overridable timeouts on all operations.
2. Cap retries and escalate to human review on repeated failures.
3. Implement per-session resource budgets.
4. Provide a documented kill switch for administrators.
