# Codex .codex-plugin/plugin.json Template

Place this file at `.codex-plugin/plugin.json` relative to the plugin root directory.
Replace all `{{PLACEHOLDER}}` markers with actual values before use.

## Minimal Manifest

Use this for the simplest possible working Codex plugin. All four fields are required.

```json
{
  "name": "{{PLUGIN_NAME}}",
  "version": "{{VERSION}}",
  "description": "{{ONE_LINE_DESCRIPTION}}",
  "skills": "./skills/"
}
```

## Complete Manifest

Use this when publishing to a Marketplace or when the plugin includes MCP Servers or display metadata.

```json
{
  "name": "{{PLUGIN_NAME}}",
  "version": "{{VERSION}}",
  "description": "{{ONE_LINE_DESCRIPTION}}",
  "author": {
    "name": "{{AUTHOR_NAME}}",
    "url": "{{AUTHOR_URL}}"
  },
  "homepage": "{{PROJECT_URL}}",
  "repository": "{{GIT_REPO_URL}}",
  "license": "{{SPDX_LICENSE_ID}}",
  "keywords": ["{{KEYWORD_1}}", "{{KEYWORD_2}}", "{{KEYWORD_3}}"],

  "skills": "./skills/",

  "mcpServers": {
    "{{MCP_SERVER_NAME}}": {
      "command": "{{LAUNCH_COMMAND}}",
      "args": ["{{ARG_1}}", "{{ARG_2}}"]
    }
  },

  "interface": {
    "displayName": "{{DISPLAY_NAME}}",
    "shortDescription": "{{SHORT_MARKETPLACE_DESCRIPTION}}",
    "category": "{{CATEGORY}}",
    "brandColor": "{{HEX_COLOR}}"
  }
}
```

## Field Reference

### Identity and metadata (all four required)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Kebab-case plugin identifier. Must be unique within the distribution context. |
| `version` | string | Yes | Semantic version string. Required for all Codex plugins (stricter than Claude Code). |
| `description` | string | Yes | Single sentence describing what the plugin does. |
| `skills` | string | Yes | Relative path to the skills directory. At least one content entry (`skills`, `mcpServers`, or `apps`) must be present. |

### Author and project links

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `author` | object | Recommended | Object with `name` (string) and optionally `url` (string) and `email` (string). Note: this is an object, not a plain string like Claude Code. |
| `homepage` | string | Recommended | URL to the project's homepage or documentation. |
| `repository` | string | Recommended | URL to the source code repository. |
| `license` | string | Recommended | SPDX license identifier. |
| `keywords` | string[] | Recommended | Array of search keywords for marketplace indexing. |

### Content entries

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `skills` | string | Yes | Relative path to the skills directory. |
| `mcpServers` | object | Optional | Map of server names to launch configurations. Same JSON schema as Claude Code: each entry has `command` (string) and `args` (string[]). |
| `apps` | object | Optional | App integration declarations for Codex's app ecosystem. |

### Marketplace display (interface block)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `interface.displayName` | string | Recommended | Human-readable name for marketplace display. |
| `interface.shortDescription` | string | Recommended | Brief description for marketplace cards. |
| `interface.category` | string | Recommended | Plugin category (e.g., `developer-tools`, `testing`, `deployment`). |
| `interface.brandColor` | string | Recommended | Hex color code for marketplace branding (e.g., `#2563EB`). |

## Companion File: agents/openai.yaml

For each skill that needs Codex-specific metadata, create `skills/<skill-name>/agents/openai.yaml`:

```yaml
interface:
  display_name: "{{SKILL_DISPLAY_NAME}}"
  short_description: "{{SKILL_SHORT_DESCRIPTION}}"
  brand_color: "{{HEX_COLOR}}"

policy:
  allow_implicit_invocation: {{true_OR_false}}

dependencies:
  tools:
    - type: "mcp"
      value: "{{MCP_SERVER_NAME}}"
      description: "{{TOOL_DESCRIPTION}}"
      transport: "{{stdio_OR_streamable_http}}"
      url: "{{HTTP_ENDPOINT_IF_APPLICABLE}}"
```

### agents/openai.yaml field reference

| Block | Field | Description |
|-------|-------|-------------|
| `interface` | `display_name` | Human-readable skill name in Codex UI. |
| `interface` | `short_description` | Brief description for skill cards. |
| `interface` | `brand_color` | Hex color for visual identity. |
| `policy` | `allow_implicit_invocation` | Whether the skill can be triggered by description matching without explicit `/invoke`. Default `false`. |
| `dependencies.tools[]` | `type` | Tool type. Use `mcp` for MCP Server dependencies. |
| `dependencies.tools[]` | `value` | MCP Server name matching a declared server. |
| `dependencies.tools[]` | `description` | Human-readable description of the tool dependency. |
| `dependencies.tools[]` | `transport` | Transport type: `stdio` or `streamable_http`. |
| `dependencies.tools[]` | `url` | HTTP endpoint URL (only for `streamable_http` transport). |

## MCP Configuration in config.toml

When MCP Servers need project-level configuration outside the plugin manifest, use `config.toml`:

```toml
[mcp_servers.{{SERVER_NAME}}]
command = "{{LAUNCH_COMMAND}}"
args = ["{{ARG_1}}", "{{ARG_2}}"]
cwd = "."
enabled = true
startup_timeout_ms = 10000
tool_timeout_sec = 60
supports_parallel_tool_calls = false

[mcp_servers.{{SERVER_NAME}}.env]
{{ENV_VAR_NAME}} = "{{ENV_VAR_VALUE}}"
```

### config.toml MCP field reference

| Field | Type | Description |
|-------|------|-------------|
| `command` | string | Server launch command. |
| `args` | string[] | Command arguments. |
| `cwd` | string | Working directory for the server process. |
| `env` | table | Environment variables passed to the server. |
| `enabled` | bool | Whether the server is active. |
| `startup_timeout_ms` | int | Maximum time to wait for server startup. |
| `tool_timeout_sec` | int | Maximum time for a single tool call. |
| `supports_parallel_tool_calls` | bool | Whether the server handles concurrent calls. |
| `enabled_tools` | string[] | Whitelist of tool names to expose. |
| `disabled_tools` | string[] | Blacklist of tool names to hide. |
| `required` | bool | Whether startup failure should be fatal. |
| `oauth_resource` | string | OAuth resource identifier for HTTP transport. |
| `scopes` | string | OAuth scopes for HTTP transport. |
| `http_headers` | table | Custom HTTP headers for HTTP transport. |

## Validation

Use the built-in plugin creator to verify the skeleton:

```bash
codex install ./path-to-plugin/
```

Alternatively, use the `$plugin-creator` built-in to scaffold and validate a new plugin structure.
