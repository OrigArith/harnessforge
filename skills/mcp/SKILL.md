---
name: mcp
description: "Use this skill when developing a new MCP server, designing MCP tools, writing tool descriptions, or reviewing an existing MCP server's quality. Covers the three MCP primitives (Tools, Resources, Prompts), tool description writing standards, parameter schema requirements, structured error handling, transport selection (stdio vs Streamable HTTP), OAuth 2.1 integration, and MCP Inspector testing. Also use when debugging an existing MCP server — agent calls wrong tools, tools not discovered, capability negotiation failures, or tool description quality issues. Trigger keywords: MCP, MCP server, Model Context Protocol, tool description, tool schema, MCP tool, Resources, Prompts, .mcp.json, Inspector, MCP开发, debug MCP, MCP tool not working, agent calls wrong tool, tool description review, MCP调试, 工具调用错误."
license: MIT
compatibility: "Requires Node.js >= 18 or Python >= 3.10 for MCP server development. MCP SDK (@modelcontextprotocol/sdk or mcp[cli]) recommended."
metadata:
  author: harnessforge
  version: "0.7.2"
  category: mcp-development
allowed-tools: Bash Read Edit Write Glob Grep
---

# forge:mcp — MCP Server Development Skill

MCP (Model Context Protocol) is the unified tool and data layer for agent ecosystems. It defines how AI agents discover, understand, and invoke external capabilities. Every MCP server exposes functionality through exactly three primitives: **Tools** (model-controlled actions), **Resources** (application-driven context), and **Prompts** (user-controlled templates). Treat tool descriptions as the primary API contract -- agents rely on them to decide when and how to call your server.

When building or reviewing an MCP server, follow every section below in order. Do not skip the tool description standards -- they are the single highest-impact factor in whether agents use your server correctly.

---

## Three Primitives Design Guide

Select the correct primitive for each capability you expose. Misclassifying a primitive breaks agent expectations.

| Primitive | Controlled By | Purpose | When to Use |
|-----------|--------------|---------|-------------|
| **Tools** | Model (model-controlled) | Execute actions, produce side effects | The agent needs to *do* something: create a PR, run a query, send a message |
| **Resources** | Application (application-driven) | Provide read-only context | The agent needs to *read* something: a file, a config, a database record |
| **Prompts** | User (user-controlled) | Parameterized workflow templates | The user triggers a discoverable template: "summarize this repo", "review this PR" |

**Decision rules:**

1. If the capability modifies state or calls an external API, make it a **Tool**.
2. If the capability returns static or semi-static context addressable by URI, make it a **Resource**.
3. If the capability is a reusable user-facing workflow entry point, make it a **Prompt**.
4. Never expose a write operation as a Resource. Never expose a read-only lookup as a Tool when a Resource would suffice.

**Core fields per primitive:**

- **Tool**: `name`, `title`, `description`, `inputSchema` (required, must be `type: "object"`), `outputSchema` (optional), `annotations` (`readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`).
- **Resource**: `uri` (or `uriTemplate` for parameterized sets using RFC 6570), `name`, `description`, `mimeType`, `annotations` (`audience`, `priority`).
- **Prompt**: `name`, `description`, `arguments`.

Remember: `annotations` are hints only. Never rely on them as security guarantees. A `readOnlyHint: true` annotation does not make a tool safe to call without review.

---

## Tool Description Standards

This is the most critical section. The tool `description` is not a comment -- it is the sole basis on which an agent decides whether and how to invoke the tool. Any semantic change to a description is a **breaking change** and must follow semver major version rules.

### Mandatory description elements

Every tool description must include all of the following:

1. **What the tool does** -- one sentence, verb-object format.
2. **When to use it** -- positive trigger conditions ("Use when the user asks to create a pull request").
3. **When NOT to use it** -- negative exclusion conditions ("Do NOT use for draft reviews or local-only operations").
4. **Expected input format** -- briefly describe key parameters, constraints, and examples.
5. **Side effects** -- state whether the tool modifies data, calls external APIs, costs money, or is irreversible.
6. **Required permissions** -- mention scopes or credentials needed ("Requires repo:write scope").

### Naming conventions

- Use `verb_noun` format for `name`: `search_issues`, `create_pull_request`, `delete_branch`.
- Keep `name` stable across versions -- it is a programmatic identifier that clients may hardcode.
- Use `title` for human-readable display names: "Search Issues", "Create Pull Request".
- For large catalogs (20+ tools), add namespace prefixes: `github_create_issue`, `gitlab_create_issue`.

### Absolute prohibitions

- Do NOT write marketing copy in descriptions.
- Do NOT inject instructions aimed at the model's system prompt (no "You are a helpful assistant" in tool descriptions).
- Do NOT leave descriptions vague ("Does stuff with issues").
- Do NOT change parameter names without a compatibility migration window.

### Description change protocol

When you must change a description:

1. Treat it as a semver major bump.
2. Announce the change in CHANGELOG.
3. If renaming parameters, accept both old and new names during a deprecation window of at least one minor version.
4. Test with MCP Inspector to verify agent behavior is preserved.

For the full checklist, load: `references/tool-description-checklist.md`

---

## Parameter Schema Requirements

Every tool must define `inputSchema` as a JSON Schema object with `type: "object"`. Encode all statically-determinable constraints directly in the schema.

### Required practices

1. **Every parameter gets a `description`** -- no exceptions. The description tells the agent what to pass.
2. **Mark required parameters** in the `required` array. Do not make everything optional.
3. **Use `enum`** for parameters with a finite set of valid values.
4. **Use `minimum` / `maximum`** for numeric ranges.
5. **Declare `default` values** so agents know what happens when they omit a parameter.
6. **Use `maxLength`** for string fields with length limits.
7. **Use `items` with typed schemas** for array parameters.

### What NOT to put in schemas

- Do not encode business-logic validation in the schema. Runtime validation failures belong in tool execution errors, not schema constraints.
- Do not over-constrain with `pattern` regexes unless the format is truly fixed (e.g., ISO dates, UUIDs).

### Output schema

Prefer defining `outputSchema` alongside `inputSchema`. This lets clients parse structured results without relying on free-text extraction.

```json
{
  "outputSchema": {
    "type": "object",
    "properties": {
      "id": { "type": "integer" },
      "url": { "type": "string" },
      "status": { "type": "string", "enum": ["created", "failed"] }
    }
  }
}
```

Filter, paginate, and truncate output. Never return raw HTML, full email bodies, or unprocessed external content. Extract only the necessary fields.

---

## Structured Error Handling

MCP has two error layers. Use the correct one.

### Protocol-layer errors (JSON-RPC)

Use for: unknown tool name, malformed JSON-RPC request, capability mismatch.

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32602,
    "message": "Unknown tool: create_pr",
    "data": {
      "available_tools": ["create_pull_request", "list_pull_requests"],
      "suggestion": "Did you mean 'create_pull_request'?"
    }
  }
}
```

### Tool execution errors (isError: true)

Use for: API failures, invalid input values, business logic violations, permission denied.

```json
{
  "content": [
    {
      "type": "text",
      "text": "BRANCH_NOT_FOUND: Branch 'feature/login' not found in 'owner/repo'. Available branches: main, develop, feature/auth. Check the branch name and retry."
    }
  ],
  "isError": true
}
```

**Critical rule**: Return input validation failures as tool execution errors (`isError: true`), NOT as protocol errors. When you return a protocol error, the agent typically gives up. When you return a tool execution error, the agent can read the message and self-correct.

### Error message golden structure

Every error message must answer these five questions:

1. **What happened** -- error type and human-readable summary.
2. **Which parameter failed** -- field-level identification.
3. **What was expected** -- valid format, enum values, or schema hint.
4. **Is it recoverable** -- can the agent retry with different input?
5. **What to do next** -- concrete suggestion, required permissions, or prerequisite steps.

For structured error content, include `structuredContent` with machine-parseable fields (`error_type`, `field`, `expected`, `recoverable`, `suggestion`) alongside the text content.

---

## Transport Selection

Choose the transport based on deployment context. Do not default to HTTP when stdio suffices.

| Factor | stdio | Streamable HTTP |
|--------|-------|-----------------|
| **Deployment** | Local machine, IDE plugin, CLI agent | Remote service, SaaS, shared platform |
| **Connection** | Client spawns server as subprocess; communication via stdin/stdout | Server runs independently; single HTTP endpoint supports POST/GET/SSE |
| **Authentication** | Environment variables, local credential files | OAuth 2.1 (RFC 8414 discovery, PKCE S256, Bearer tokens) |
| **Session** | Process lifetime = session lifetime | `Mcp-Session-Id` header + SSE reconnection |
| **Logging** | stderr only (NEVER write to stdout) | Server-side logging + `notifications/message` |
| **Distribution** | `npx`, `uvx`, `pip install`, Docker | Docker, cloud functions, Cloudflare Workers |

**Decision guide:**

1. Building a tool for local/desktop/IDE use? Use **stdio**.
2. Building a shared service accessed by multiple users or devices? Use **Streamable HTTP**.
3. Need to support both? Implement both transports in the same server; let the config select which to activate.

**stdio safety rule**: A stdio server must NEVER write anything to stdout except JSON-RPC messages. All logs go to stderr or use `notifications/message`.

**HTTP safety rules**:
- Bind to `127.0.0.1`, not `0.0.0.0`, for local HTTP servers.
- Always validate `Origin` and `Host` headers to prevent DNS rebinding attacks.
- Implement OAuth 2.1 for remote deployments. Never ask users to paste long-lived API tokens into config files when OAuth is available.

---

## Required Execution Rules

Follow these rules on every MCP server project. They are non-negotiable.

1. **Human-review all tool descriptions before release.** Descriptions are the API contract for agents. A misleading description causes silent failures at scale.

2. **Never treat MCP as a security boundary.** Annotations are hints. Clients may ignore `readOnlyHint`. Validate permissions server-side.

3. **Test every tool with MCP Inspector before release.** Verify: initialize succeeds, capability negotiation aligns, each tool returns expected output on valid input, each tool returns structured errors on invalid input.

4. **Use `.mcp.json` as the shared configuration source.** Place it in the project root. It is the closest thing to a cross-platform standard for MCP server configuration. Generate platform-specific configs from it.

5. **Keep tool count per server under 20.** When you exceed 20 tools, agents lose selection accuracy. Split into multiple servers or use namespace prefixes and deferred loading.

6. **Never log tokens or credentials in plaintext.** Not in stdout, stderr, or server logs.

7. **Treat parameter renames as breaking changes.** Accept both old and new parameter names during a deprecation window.

8. **Filter all external content before returning it.** Strip HTML, executable fragments, and unnecessary fields. Return only what the agent needs.

---

## Diagnose & Test

### Quick Diagnosis

When the user reports "agent calls the wrong tool" or "tools don't work as expected", run this diagnostic checklist before diving deeper:

1. **Description ambiguity.** Read every tool's `description`. Are there two tools whose descriptions overlap enough that an agent might confuse them? If yes, narrow each description's "when to use" and "when NOT to use" boundaries.
2. **Missing negative conditions.** Does each description state when NOT to use the tool? Agents over-trigger on tools that only describe positive conditions.
3. **Parameter schema gaps.** Are all parameters described? Are required fields marked in the `required` array? Missing descriptions force agents to guess.
4. **Error message quality.** When a tool returns an error, does the message tell the agent what went wrong, what was expected, and what to do next? Vague errors cause retry loops.
5. **Tool count.** Does the server expose more than 20 tools? Research shows agent selection accuracy degrades beyond 20 tools. Split into multiple servers or use namespace prefixes with deferred loading.
6. **Tool space interference.** Are multiple MCP servers active simultaneously? Check if tools from different servers have overlapping names or descriptions that cause selection confusion. Namespace with prefixes if needed.
7. **Capability mismatch.** Does the server request capabilities the client doesn't support (e.g., `sampling`, `elicitation`)? Run MCP Inspector to check capability negotiation.
8. **Output format.** Are tool results structured JSON or free text? Free-text results are harder for agents to parse reliably. Prefer `structuredContent`.

If the diagnosis reveals a description or schema problem, fix it and retest. If the problem persists, proceed to the MCP Inspector workflow below.

### MCP Inspector Workflow

MCP Inspector is the official first-party debugging tool. Use it to validate your server before any integration testing.

```bash
# Test an npm-distributed server
npx @modelcontextprotocol/inspector npx -y {{YOUR_NPM_PACKAGE}}

# Test a local Python server
npx @modelcontextprotocol/inspector python -m {{YOUR_PYTHON_MODULE}}

# Test a local Node.js server
npx @modelcontextprotocol/inspector node {{PATH_TO_DIST_INDEX}}
```

Execute these steps in order:

1. **Connectivity**: Verify `initialize` completes and returns valid `protocolVersion` and `capabilities`.
2. **Capability negotiation**: Confirm server capabilities match what your tools require. Check that the client capabilities include what your server needs (e.g., `sampling` if you use it).
3. **Happy path**: Call each tool with valid input. Verify the response structure, content types, and field values.
4. **Error paths**: Call each tool with invalid input (missing required params, out-of-range values, wrong types). Verify `isError: true` responses with actionable messages.
5. **Edge cases**: Test concurrent operations, empty result sets, maximum pagination, and large payloads.

### Conformance Testing

For CI integration and regression prevention, use the official MCP conformance tool:

```bash
# Run conformance suite against your server
npx @modelcontextprotocol/conformance --mode server --command "{{SERVER_START_COMMAND}}"

# List all available test scenarios
npx @modelcontextprotocol/conformance --list-scenarios
```

Set up an **expected-failures baseline** in CI: allow known issues while blocking new regressions. When a previously-passing scenario starts failing, treat it as a release blocker.

For GitHub Actions integration:

```yaml
- name: MCP Conformance
  run: |
    npx @modelcontextprotocol/conformance \
      --mode server \
      --command "node dist/index.js" \
      --expected-failures .mcp-expected-failures.json \
      --fail-on-new-failures
```

Run conformance tests on every PR to catch description changes, schema regressions, and capability mismatches before they reach production.

---

## Advanced Capabilities

MCP protocol version 2025-11-25 introduces three capabilities that extend beyond basic tool execution. When implementing any of these, read `references/advanced-capabilities.md` for capability declarations, request flows, implementation patterns, and security considerations.

- **Sampling**: Server requests the client to perform LLM inference. Use when the server needs reasoning but has no direct model access.
- **Elicitation**: Server requests input from the user through the client's UI. Use when a value can only come from the human (API key, preference, confirmation).
- **Tasks**: Async long-running operations with progress tracking and cancellation. Use when tool execution takes more than a few seconds.

All three capabilities require explicit declaration and client support negotiation during `initialize`. Always implement a synchronous fallback for clients that do not support these features.

---

## References

Load these references as needed for detailed templates and examples:

- **Tool description checklist** (14-point quality gate): `references/tool-description-checklist.md`
- **`.mcp.json` configuration template**: `references/mcp-json-template.md`
- **Advanced capabilities** (Sampling, Elicitation, Tasks): `references/advanced-capabilities.md`
- **Tool design patterns and anti-patterns**: `examples/tool-design-patterns.md`
