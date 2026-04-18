---
name: forge-adapt
description: "Use this skill when adding Claude Code or Codex platform support to an agent ecosystem project, writing plugin.json manifests, setting up cross-platform directory structure, or reviewing platform compatibility. Covers the five-layer compatibility matrix, shared content + thin adapter shell strategy, Claude Code plugin.json specification, Codex .codex-plugin specification, and manifest field mapping between platforms. Trigger keywords: platform adapter, Claude Code plugin, Codex plugin, plugin.json, cross-platform, manifest, compatibility, adapters, 平台适配, 跨平台兼容."
license: MIT
compatibility: "No runtime dependencies. Works with any coding agent that supports SKILL.md."
metadata:
  author: harnessforge
  version: "0.3.0"
  category: platform-adaptation
allowed-tools: Bash Read Edit Write Glob Grep
---

# Forge Adapt

What can be unified is content; what cannot be unified is the host extension ABI.
Do not attempt to produce a single plugin package that works on every agent platform.
Instead, apply the canonical strategy: one shared content source plus thin platform adapter shells.

The shared content source holds everything platform-agnostic: SKILL.md files, MCP Server source code, hook scripts, reference documents, and AGENTS.md.
Each adapter shell is a minimal manifest file (typically under 30 lines of JSON) that points into the shared content and satisfies one platform's packaging contract.

When you add a platform adapter, you are not duplicating content.
You are writing a declaration that tells one specific host where to find the capabilities your project already provides.

## Five-Layer Compatibility Matrix

Before writing any adapter, assess which layers of your project can be shared and which require per-platform work.
Use this matrix to set expectations and scope the adaptation effort.

| Layer | Cross-Platform Compatibility | What Is Shared | What Is Platform-Specific | Key Differences |
|-------|------------------------------|----------------|---------------------------|-----------------|
| Instruction files | ~85% | `AGENTS.md` content body | Entry-point filename (`CLAUDE.md` vs `AGENTS.md`) | Claude Code uses `@AGENTS.md` import syntax; Codex reads `AGENTS.md` natively |
| Skills | ~80-90% | `SKILL.md` frontmatter + instruction body | Vendor-specific frontmatter fields | Codex has `agents/openai.yaml` per skill; unknown frontmatter fields are safely ignored |
| MCP | ~90% | MCP Server source code; `.mcp.json` as shared description | Client-side config format (JSON vs TOML) | Claude Code reads `.mcp.json` natively; Codex uses `config.toml` with `[mcp_servers]` blocks |
| Plugins | <50% | Shared payload (`skills/`, `src/`, assets) | Manifest format and required fields | Claude Code = directory content pack; Codex = lightweight bundle; definitions are fundamentally different |
| Hooks | <50% | Design intent (e.g., "block destructive commands") | Event names, handler types, config format | Claude Code has ~22 events + 4 handler types (stable); Codex hooks are experimental with limited events |

Consult `references/compatibility-matrix.md` for the full per-layer analysis when you need deeper detail.

## Shared Content vs Platform Shell

Organize the project so that platform-agnostic content lives in the root and shared directories, while platform-specific adapters live under `adapters/`.

### Shared directories (platform-agnostic)

| Directory / File | Content |
|------------------|---------|
| `skills/` | All SKILL.md files, their `scripts/`, `references/`, and assets |
| `src/` | MCP Server implementation, business logic |
| `.mcp.json` | MCP Server declarations (Claude Code reads natively; other platforms derive from it) |
| `AGENTS.md` | Cross-platform instruction file (canonical source of truth) |
| `hooks/` (scripts only) | Hook implementation scripts (`.sh`, `.py`) that contain the actual logic |
| `tests/` | Platform-agnostic test cases |

### Platform-specific directories

| Directory | Content |
|-----------|---------|
| `adapters/claude/` | `.claude-plugin/plugin.json`, optional `CLAUDE.md` import shell |
| `adapters/codex/` | `.codex-plugin/plugin.json`, optional `agents/openai.yaml` files |

### Litmus test for placement

Ask these questions about each file:

1. Does it declare platform identity, version, or packaging metadata? Place it in `adapters/<platform>/`.
2. Does it teach an agent how to perform a task? Place it in `skills/`.
3. Does it connect to an external system via MCP? Place it in `src/` (implementation) and `.mcp.json` (declaration).
4. Does it contain hook registration config (event-to-handler mapping)? Place it in `adapters/<platform>/`.
5. Does it contain hook logic (the script that runs)? Place it in `hooks/` (shared).

When in doubt, keep it shared. Only move a file to `adapters/` when a platform requires a specific format that no other platform can consume.

See `examples/dual-platform-directory-tree.md` for a fully annotated reference layout.

## Adding Claude Code Adapter

Follow these steps in order to add Claude Code support to an existing project.

### Step 1: Create the manifest directory

```bash
mkdir -p adapters/claude/.claude-plugin
```

### Step 2: Write plugin.json

Create `adapters/claude/.claude-plugin/plugin.json` with at minimum these fields:

```json
{
  "name": "{{PLUGIN_NAME}}",
  "version": "{{VERSION}}",
  "description": "{{ONE_LINE_DESCRIPTION}}",
  "skills": "../../skills/",
  "mcpServers": {}
}
```

Required fields: `name` (kebab-case, becomes the namespace prefix for skill invocation), `description`.
Recommended fields: `version` (semver), `author`, `homepage`, `repository`, `license`, `keywords`.

Path rules:
- All paths are relative to the plugin root (the directory containing `.claude-plugin/`).
- The `skills` field replaces the default discovery path; it does not append. If you need both the default and a custom path, list both.
- Use `${CLAUDE_PLUGIN_ROOT}` to reference the plugin install root in hook commands.
- Never assume development directory structure survives installation.

See `references/claude-code-plugin-json-template.md` for the complete field reference with placeholders.

### Step 3: Write the CLAUDE.md import shell

If the project has an `AGENTS.md`, create `adapters/claude/CLAUDE.md`:

```markdown
@../../AGENTS.md

<!-- Claude Code specific additions below -->
```

This pulls in the shared instruction content and allows Claude-only additions (e.g., `allowed-tools` declarations, Claude-specific workflow notes).

### Step 4: Configure MCP mapping

If the project has a `.mcp.json`, reference it in `plugin.json` under `mcpServers`.
Claude Code reads `.mcp.json` natively, so if the adapter directory will be installed as the plugin root, copy or symlink the shared `.mcp.json` declaration.

For MCP Servers launched via npm:

```json
{
  "mcpServers": {
    "{{SERVER_NAME}}": {
      "command": "npx",
      "args": ["-y", "{{NPM_PACKAGE}}"]
    }
  }
}
```

### Step 5: Add hooks (optional)

If the project needs lifecycle hooks, create `adapters/claude/hooks/hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/check-dangerous-cmd.sh"
          }
        ]
      }
    ]
  }
}
```

Reference the shared hook scripts from `hooks/` using relative or `${CLAUDE_PLUGIN_ROOT}` paths.

### Step 6: Validate

Run `claude plugin validate .` from the adapter directory to verify structure before publishing.

## Adding Codex Adapter

Follow these steps in order to add Codex support to an existing project.

### Step 1: Create the manifest directory

```bash
mkdir -p adapters/codex/.codex-plugin
```

### Step 2: Write plugin.json

Create `adapters/codex/.codex-plugin/plugin.json` with the four mandatory fields:

```json
{
  "name": "{{PLUGIN_NAME}}",
  "version": "{{VERSION}}",
  "description": "{{ONE_LINE_DESCRIPTION}}",
  "skills": "../../skills/"
}
```

All four fields (`name`, `version`, `description`, `skills`) are required for Codex. This is stricter than Claude Code.

Recommended additional fields: `author` (object with `name`, `url`), `homepage`, `repository`, `license`, `keywords`, `interface` block.

See `references/codex-plugin-json-template.md` for the complete field reference with placeholders.

### Step 3: Write agents/openai.yaml (optional, per skill)

If a skill needs Codex-specific display metadata or tool dependency declarations, create `skills/<skill-name>/agents/openai.yaml`:

```yaml
interface:
  display_name: "{{DISPLAY_NAME}}"
  short_description: "{{SHORT_DESCRIPTION}}"
  brand_color: "{{HEX_COLOR}}"

policy:
  allow_implicit_invocation: false

dependencies:
  tools:
    - type: "mcp"
      value: "{{MCP_SERVER_NAME}}"
      description: "{{TOOL_DESCRIPTION}}"
```

This file is a Codex vendor extension. It does not belong in the Agent Skills open standard.
Place it alongside the SKILL.md it describes. Other platforms will ignore it.

### Step 4: Configure MCP mapping

Codex reads MCP configuration from `config.toml`, not `.mcp.json`.
If the project has a shared `.mcp.json`, map each server to the TOML format in project documentation or provide a generation script.

TOML format for one MCP Server:

```toml
[mcp_servers.{{SERVER_NAME}}]
command = "npx"
args = ["-y", "{{NPM_PACKAGE}}"]
enabled = true
```

Alternatively, declare MCP Servers inside the plugin manifest under `mcpServers` (same JSON format as Claude Code). Codex plugin.json supports this.

### Step 5: Add hooks (optional, experimental)

Codex hooks require a feature flag:

```toml
[features]
codex_hooks = true
```

Create `adapters/codex/.codex/hooks.json` with the same general structure as Claude Code hooks, but be aware:
- Codex hooks are experimental and actively changing.
- Event coverage is limited compared to Claude Code.
- Hooks do not support Windows.

Prefer implementing critical logic in Skills or MCP rather than Codex hooks.

### Step 6: Validate

Use the Codex built-in plugin creator (`$plugin-creator`) to verify the manifest skeleton is correct. Test by installing the plugin locally:

```bash
codex install ./adapters/codex/
```

## Manifest Field Mapping

When translating a manifest between Claude Code and Codex, read `references/manifest-field-mapping.md` for the complete field-by-field mapping table.

Key equivalences: `name`, `version`, `description`, `license`, `keywords`, `skills`, and `mcpServers` map directly. Main differences: Claude Code `author` is a string, Codex `author` is an object; Codex has `interface` for display metadata, Claude Code has `hooks` and `outputStyles`.

## Required Execution Rules

Follow these rules whenever you create or modify platform adapters.

1. **Manifests must stay under 30 lines.** If a manifest exceeds 30 lines, you are putting content in the wrong place. Move logic to skills, scripts, or MCP Servers.

2. **Shared payload must constitute 70-80% of the project.** Measure by file count. If platform-specific files outnumber shared files, refactor to extract shared content.

3. **Version numbers must match across platforms.** When `adapters/claude/.claude-plugin/plugin.json` says `"version": "1.2.0"`, `adapters/codex/.codex-plugin/plugin.json` must say the same. Automate this with a script or CI check.

4. **Skill paths must resolve correctly from each adapter root.** Test path resolution by running `ls` from the adapter directory following the relative path declared in the manifest. If `../../skills/` from `adapters/claude/` does not reach `skills/`, the path is wrong.

5. **Never hardcode environment-specific values in manifests.** Use `${CLAUDE_PLUGIN_ROOT}` for Claude Code. Use environment variables for Codex. Keep credentials out of committed files.

6. **Test each adapter independently.** Install the Claude Code adapter using `claude plugin validate`. Install the Codex adapter using `codex install`. Verify that skills are discovered and MCP Servers start.

7. **Keep AGENTS.md as the single source of truth for instructions.** Claude Code imports it via `CLAUDE.md` with `@AGENTS.md`. Codex reads it directly. Do not maintain two divergent instruction files.

8. **Do not put hook registration in shared directories.** Hook event names and config formats differ between platforms. Keep hook config in `adapters/<platform>/`. Keep hook logic scripts in `hooks/` (shared).

## References

Load these files on demand when you need deeper detail. Do not load all of them upfront.

- `references/compatibility-matrix.md` -- Full five-layer compatibility analysis with per-layer detail on what is shared, what is platform-specific, and the main differences.
- `references/claude-code-plugin-json-template.md` -- Complete Claude Code plugin.json template with all fields, comments, and placeholder markers.
- `references/codex-plugin-json-template.md` -- Complete Codex plugin.json template with all fields, comments, and placeholder markers.
- `examples/dual-platform-directory-tree.md` -- Annotated directory tree showing a project with both Claude Code and Codex adapters, with shared vs platform-specific files clearly marked.
