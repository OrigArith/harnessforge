# Plugin Manifest Schema Comparison

Side-by-side comparison of plugin.json structures across Claude Code, Codex, and Cursor. Data sourced from official documentation and cross-validated against 16 real-world projects (agentsys, autoresearch, superpowers, oh-my-claudecode, codex-plugin-cc, etc.).

## Schema Comparison Table

| Field | Claude Code | Codex | Cursor |
|-------|------------|-------|--------|
| **Location** | `.claude-plugin/plugin.json` | `.codex-plugin/plugin.json` | `.cursor-plugin/plugin.json` |
| `name` | Required (string) | Required (string) | Required (string) |
| `version` | Recommended (semver) | Required (semver) | Recommended (semver) |
| `description` | Required (string) | Required (string) | Required (string) |
| `author` | String (`"name"`) | Object (`{ "name", "url" }`) | String |
| `repository` | String (URL) | String (URL) | String (URL) |
| `license` | String (SPDX ID) | String (SPDX ID) | String (SPDX ID) |
| `keywords` | Array of strings | Array of strings | Array of strings |
| `skills` | Path string (`"./skills/"`) | Path string (`"./skills/"`) | Path string (`"./"`) |
| `mcpServers` | Object (server configs) | Object (server configs) | Object (server configs) |
| `hooks` | Path string (hooks.json) | — (experimental, see below) | — |
| `outputStyles` | Object (custom output) | — | — |
| `interface` | — | Object (display metadata) | — |
| `interface.displayName` | — | String | — |
| `interface.shortDescription` | — | String | — |
| `interface.category` | — | String | — |
| `interface.capabilities` | — | Array of strings | — |
| `interface.defaultPrompt` | — | String | — |
| `interface.icons` | — | Object (`{ light, dark }`) | — |
| `interface.brand_color` | — | String (hex) | — |
| `policy` | — | Object (install policy) | — |
| `agents` | — | — | Path string (`"./"`) |
| `commands` | — | — | Path string (`"./"`) |
| `hooks` (path) | — | — | Path string (`"./hooks/"`) |

## Key Differences

### Claude Code (most minimal)

Core schema is intentionally minimal. The manifest is a pointer to content, not a metadata store.

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "One-line description",
  "author": "author-name",
  "repository": "https://github.com/org/repo",
  "license": "MIT",
  "keywords": ["mcp", "tools"],
  "skills": "./skills/",
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/server/index.js"]
    }
  }
}
```

Unique features:
- `${CLAUDE_PLUGIN_ROOT}` variable for plugin-relative paths in MCP server commands
- `hooks` field pointing to a hooks.json file for lifecycle event handling
- `outputStyles` for custom output formatting
- Marketplace discovery via separate `marketplace.json` file

### Codex (richest metadata)

Codex adds `interface` for display metadata and `policy` for install behavior.

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "One-line description",
  "author": { "name": "Author", "url": "https://example.com" },
  "license": "MIT",
  "skills": "./skills/",
  "interface": {
    "displayName": "My Plugin",
    "shortDescription": "Short display text",
    "category": "development",
    "capabilities": ["code-generation", "debugging"],
    "defaultPrompt": "Help me with...",
    "icons": { "light": "./icons/light.svg", "dark": "./icons/dark.svg" },
    "brand_color": "#4A90D9"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "NONE"
  }
}
```

Unique features:
- `interface` block for marketplace display
- `policy` with installation options: `AVAILABLE`, `INSTALLED_BY_DEFAULT`, `NOT_AVAILABLE`
- `author` is an object, not a string
- Hooks are experimental and limited (Bash-only interception, Windows not supported)

### Cursor (extends Claude Code)

Cursor starts from the Claude Code schema and adds content discovery paths.

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "One-line description",
  "skills": "./",
  "agents": "./",
  "commands": "./",
  "hooks": "./hooks/hooks-cursor.json"
}
```

Unique features:
- `agents`, `commands` fields for additional content types
- `hooks` field (similar to Claude Code but with platform-specific event names)
- Otherwise identical to Claude Code schema

## Translation Rules

When creating manifests for multiple platforms from a single source of truth:

1. **name, version, description, license, keywords, skills, mcpServers** — copy directly.
2. **author** — Claude Code/Cursor use string; Codex uses object. Transform: `"author-name"` → `{ "name": "author-name" }`.
3. **interface** — Codex-only. Generate from project metadata if targeting Codex marketplace.
4. **policy** — Codex-only. Default to `{ "installation": "AVAILABLE" }`.
5. **hooks** — Claude Code and Cursor only. Codex hooks are experimental and limited.
6. **${CLAUDE_PLUGIN_ROOT}** — Claude Code only. For Codex MCP configs, use absolute paths or environment variables.

## Validation Commands

```bash
# Claude Code
python3 -m json.tool .claude-plugin/plugin.json > /dev/null

# Codex
python3 -m json.tool .codex-plugin/plugin.json > /dev/null

# Cross-platform version consistency
claude_ver=$(grep '"version"' .claude-plugin/plugin.json | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
codex_ver=$(grep '"version"' .codex-plugin/plugin.json | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
[ "$claude_ver" = "$codex_ver" ] || echo "Version mismatch: Claude=$claude_ver Codex=$codex_ver"
```
