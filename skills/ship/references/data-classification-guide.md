# Data Classification Guide for Agent Ecosystem Projects

Four-level classification framework for data handled by MCP servers, skills, and agent-facing tools. Every data element that flows through tools, resources, logs, or caches must be assigned a level. Handling rules are non-negotiable per level.

## Four Classification Levels

| Level | Label | Examples | TTL | Handling Requirements |
|-------|-------|----------|-----|----------------------|
| **L1** | Credentials | API keys, tokens, passwords, SSH keys, OAuth secrets, session cookies | **Never persisted** | Never log (not even in debug). Never cache. Never return in tool output. Never include in error messages. Redact from all telemetry. |
| **L2** | PII | Email addresses, phone numbers, IP addresses, user IDs with name resolution, location data | **7-30 days** | TTL-enforce in all caches and stores. Strip before memory/context writes. Hash or pseudonymize in logs. Require explicit consent for cross-tool transfer. |
| **L3** | Business Secrets | Proprietary algorithms, internal API endpoints, pricing data, unreleased product details, internal org structure | **24-72 hours** | TTL-enforce in caches. Do not expose through tool descriptions or error messages. Restrict to tools with explicit authorization. |
| **L4** | Low Risk | Public documentation, open-source code, published API specs, non-sensitive configuration | **90 days** | Standard cache management. May appear in logs and tool outputs. No special handling required. |

## Classification Workflow

For each data element your project handles:

1. **Identify the data element.** Name it and describe what it contains.
2. **Assign the highest applicable level.** If a field contains both L2 (email) and L4 (public name), classify as L2.
3. **Map the data flow.** Trace where the data enters (tool input, API response, file read), where it is stored (memory, cache, log), and where it exits (tool output, error message, telemetry).
4. **Verify handling at every point in the flow.** Check each storage and exit point against the level's handling requirements.
5. **Document the classification.** Add to SECURITY.md or an internal data inventory.

## Common Violations in Agent Projects

| Violation | Level Violated | How It Happens |
|-----------|---------------|----------------|
| API key in tool error message | L1 | Catch block includes `error.config.headers` in the response |
| User email in MCP server log | L2 | `console.log(params)` without field filtering |
| Internal endpoint in tool description | L3 | Description says "connects to api.internal.company.com" |
| Token in tool result | L1 | Tool returns raw API response including auth headers |
| PII in agent memory/context | L2 | Tool output containing user data gets stored in conversation context without TTL |

## Redaction Checklist

When implementing log/error sanitization, strip these field types:

- `authorization` / `Authorization` headers
- `cookie` / `Cookie` headers
- Any field matching `*token*`, `*key*`, `*secret*`, `*password*`, `*credential*`
- Email addresses (regex: `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`)
- File paths containing user home directories
- Database connection strings
- IP addresses in non-public contexts

## Integration with Security Audit

During Security Audit Step 6 (Classify data and verify handling):

1. Create the data inventory using the workflow above.
2. For each L1 element: verify it never appears in logs, caches, tool outputs, or error messages.
3. For each L2 element: verify TTL is enforced and data is stripped before memory writes.
4. For each L3 element: verify it is not exposed in tool descriptions or public-facing errors.
5. Document findings and attach to the security audit report.
