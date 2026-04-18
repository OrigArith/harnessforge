# Claude Code plugin.json Template

Place this file at `.claude-plugin/plugin.json` relative to the plugin root directory.
Replace all `{{PLACEHOLDER}}` markers with actual values before use.

## Minimal Manifest

Use this when you need the simplest possible working manifest.

```json
{
  "name": "{{PLUGIN_NAME}}",
  "version": "{{VERSION}}",
  "description": "{{ONE_LINE_DESCRIPTION}}",
  "skills": "./skills/"
}
```

## Complete Manifest

Use this when publishing to a Marketplace or when the plugin includes MCP Servers, hooks, subagents, or user configuration.

```json
{
  "name": "{{PLUGIN_NAME}}",
  "version": "{{VERSION}}",
  "description": "{{ONE_LINE_DESCRIPTION}}",
  "author": "{{AUTHOR_NAME_OR_ORG}}",
  "homepage": "{{PROJECT_URL}}",
  "repository": "{{GIT_REPO_URL}}",
  "license": "{{SPDX_LICENSE_ID}}",
  "keywords": ["{{KEYWORD_1}}", "{{KEYWORD_2}}", "{{KEYWORD_3}}"],

  "skills": ["./skills/"],
  "agents": ["./agents/"],
  "hooks": "./hooks/hooks.json",
  "outputStyles": ["./output-styles/"],

  "mcpServers": {
    "{{MCP_SERVER_NAME}}": {
      "command": "{{LAUNCH_COMMAND}}",
      "args": ["{{ARG_1}}", "{{ARG_2}}"]
    }
  },

  "userConfig": {
    "{{CONFIG_KEY}}": {
      "type": "string",
      "description": "{{CONFIG_DESCRIPTION}}",
      "required": true,
      "secret": false
    },
    "{{SECRET_CONFIG_KEY}}": {
      "type": "string",
      "description": "{{SECRET_CONFIG_DESCRIPTION}}",
      "required": true,
      "secret": true
    }
  },

  "channels": {}
}
```

## Field Reference

### Identity and metadata

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Kebab-case plugin identifier. Forms the namespace prefix for skill invocation (`plugin-name:skill-name`). |
| `version` | string | Recommended | Semantic version string. Start stable plugins at `1.0.0`. The update mechanism depends on this field. |
| `description` | string | Yes | Single sentence describing what the plugin does. Affects Marketplace search ranking. |
| `author` | string | Recommended | Author or organization name. Plain string (not an object). |
| `homepage` | string | Recommended | URL to the project's homepage or documentation site. |
| `repository` | string | Recommended | URL to the source code repository. |
| `license` | string | Recommended | SPDX license identifier (e.g., `MIT`, `Apache-2.0`). |
| `keywords` | string[] | Recommended | Array of search keywords for Marketplace indexing. |

### Content paths

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `skills` | string or string[] | Optional | Path(s) to skill directories. Replaces the default `./skills/` discovery path. If you need both default and custom paths, include both in the array. |
| `agents` | string or string[] | Optional | Path(s) to subagent definition files. Replaces the default `./agents/` path. |
| `hooks` | string or object | Optional | Path to `hooks.json` file, or an inline hooks configuration object. |
| `outputStyles` | string[] | Optional | Path(s) to output style definition directories. |

### MCP Servers

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `mcpServers` | object | Optional | Map of server names to launch configurations. Each entry has `command` (string) and `args` (string[]). |

### User configuration

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userConfig` | object | Optional | Map of configuration keys to their definitions. Each key defines `type`, `description`, `required`, `default` (optional), and `secret` (optional). Values are accessible via `${user_config.KEY}` in hooks and MCP configurations. |

### Channels

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `channels` | object | Optional | External event stream declarations. Requires an MCP Server that supports the `claude/channel` capability. |

## Path Rules

1. All paths must be relative to the plugin root directory (the directory containing `.claude-plugin/`).
2. Paths should start with `./` for clarity.
3. Use `${CLAUDE_PLUGIN_ROOT}` to reference the installed plugin root in hook commands and scripts.
4. Use `${CLAUDE_PLUGIN_DATA}` to reference the persistent data directory for the plugin.
5. Never assume the development directory layout survives installation. Always use variable references for dynamic paths.
6. Setting a path field replaces the default discovery path; it does not append to it.

## Validation

Run from the plugin root directory:

```bash
claude plugin validate .
```

This checks manifest structure, path resolution, and required field presence.
