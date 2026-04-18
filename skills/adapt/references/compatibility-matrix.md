# Five-Layer Cross-Platform Compatibility Matrix

This reference provides the full per-layer analysis of cross-platform compatibility between Claude Code and Codex. Use it when you need to make detailed decisions about what to share and what to adapt.

## Layer 1: Instruction Files (~85% Compatible)

### What is shared

The content body of project instructions: coding standards, test commands, directory explanations, branch rules, definition of done, and behavioral constraints. Write these once in `AGENTS.md`.

### What is platform-specific

The entry-point filename and import mechanism.

| Platform | Entry File | Import Mechanism | Load Behavior |
|----------|-----------|------------------|---------------|
| Claude Code | `CLAUDE.md` | `@AGENTS.md` syntax pulls in shared content | Reads at session start; supports sub-directory hierarchy |
| Codex | `AGENTS.md` | Native entry point; no import needed | Reads from root to cwd, concatenating each level; supports `AGENTS.override.md` |

### Main differences

- Claude Code requires a thin `CLAUDE.md` shell file that imports `AGENTS.md`. Codex reads `AGENTS.md` directly.
- Claude Code supports `@path` syntax for importing other files into CLAUDE.md. Codex does not have an equivalent import mechanism.
- Codex supports `AGENTS.override.md` for local overrides. Claude Code does not have this convention.
- Both platforms process sub-directory instruction files, but the merge strategy (concatenation vs override) differs.

### Adaptation cost

Minimal. Write `AGENTS.md` once. Create a one-line `CLAUDE.md` containing `@AGENTS.md` for Claude Code. Total adapter effort: one file, one line.

---

## Layer 2: Skills (~80-90% Compatible)

### What is shared

The full SKILL.md content body and core frontmatter fields (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`). These follow the Agent Skills open standard and work identically on both platforms.

The `scripts/`, `references/`, and asset directories within each skill are also fully shared.

### What is platform-specific

| Element | Claude Code | Codex | Shared? |
|---------|-------------|-------|---------|
| SKILL.md body | Read as-is | Read as-is | Yes |
| Core frontmatter (name, description) | Supported | Supported | Yes |
| `allowed-tools` frontmatter | Supported (experimental) | Supported (experimental) | Yes |
| Unknown frontmatter fields | Safely ignored | Safely ignored | Yes |
| `agents/openai.yaml` | Not used | Vendor extension for display metadata and tool deps | No (Codex only) |
| Skill discovery path | `skills/` default | `skills/` default | Yes |
| Invocation syntax | `/plugin-name:skill-name` | `/plugin-name:skill-name` | Yes |
| Progressive disclosure | Name + description loaded first; full body on activation | Name + description loaded first; full body on activation | Yes |

### Main differences

- Codex supports an optional `agents/openai.yaml` file per skill for marketplace display metadata (`display_name`, `short_description`, `brand_color`), implicit invocation policy, and MCP tool dependency declarations. Claude Code ignores this file.
- Claude Code supports subagents (agents/*.md) as a separate concept. Codex does not have a subagent system.

### Adaptation cost

Low. Skills work across platforms without modification. The only Codex-specific addition is the optional `agents/openai.yaml`, which requires a few lines of YAML per skill.

---

## Layer 3: MCP (~90% Compatible)

### What is shared

The MCP Server implementation itself is 100% shared. Both platforms speak the same MCP protocol (stdio and streamable HTTP transports). A server built once works everywhere.

The `.mcp.json` file serves as the shared MCP Server description source. Claude Code reads it natively.

### What is platform-specific

The client-side configuration format for declaring which MCP Servers to connect to.

| Platform | Config Location | Config Format | Example |
|----------|----------------|---------------|---------|
| Claude Code | `.mcp.json` (project root) | JSON: `{ "mcpServers": { "name": { "command": "...", "args": [...] } } }` | Native; no translation needed |
| Codex | `config.toml` (user or project) | TOML: `[mcp_servers.name]` block with `command`, `args`, `env` | Requires format conversion from `.mcp.json` |

### Main differences

- Claude Code natively reads `.mcp.json`. Codex requires the equivalent information in TOML format within `config.toml`.
- Codex `config.toml` supports additional per-server fields not present in `.mcp.json`: `enabled`, `startup_timeout_ms`, `tool_timeout_sec`, `supports_parallel_tool_calls`, `enabled_tools`, `disabled_tools`, `required`, `oauth_resource`, `scopes`.
- Both platforms support MCP Server declarations inside `plugin.json` under `mcpServers` using the same JSON schema. This is the simplest path for plugin-bundled servers.
- Codex supports per-tool `approval_mode` for fine-grained permission control.

### Adaptation cost

Very low when using plugin.json `mcpServers`. Both platforms accept the same JSON format inside the manifest. Conversion is only needed for project-level `config.toml` usage in Codex.

---

## Layer 4: Plugins (<50% Compatible)

### What is shared

The shared payload: `skills/` directory, `src/` directory, hook scripts, assets, tests, README, and LICENSE. These constitute 70-80% of the project by file count.

### What is platform-specific

Everything about the manifest and packaging contract.

| Dimension | Claude Code | Codex |
|-----------|-------------|-------|
| Manifest location | `.claude-plugin/plugin.json` + `marketplace.json` | `.codex-plugin/plugin.json` (official manifest); `.codex/INSTALL.md` as manual install alternative |
| Plugin model | Directory content pack | Lightweight bundle |
| Required manifest fields | `name` (manifest itself is optional for local use) | `name`, `version`, `description`, `skills` (all four required) |
| Content layout convention | `skills/`, `agents/`, `hooks/`, `.mcp.json` | `skills/`, `.mcp.json`, `assets/` |
| Distribution | Marketplace / GitHub / npm | Marketplace / GitHub / local install |
| Unique features | `userConfig` for user-provided settings; `hooks` in manifest; `agents` path; `outputStyles`; `channels` | `interface` block for marketplace display; `author` as object |

### Main differences

- Claude Code is more lenient: it can auto-discover components even without a manifest. Codex requires an explicit manifest with four mandatory fields.
- Claude Code supports `userConfig` for prompting users to fill in settings at install time. Codex uses environment variable injection instead.
- Claude Code supports `hooks`, `agents`, `outputStyles`, and `channels` in the manifest. Codex does not have equivalents for these in plugin.json.
- Codex has an `interface` block for marketplace presentation metadata that Claude Code lacks.
- The `author` field is a plain string in Claude Code but an object (`{name, url}`) in Codex.

### Adaptation cost

Moderate. Each platform needs its own plugin.json (typically under 30 lines). The shared payload is reused via relative paths. Most effort goes into understanding each platform's required fields and path conventions.

---

## Layer 5: Hooks (<50% Compatible)

### What is shared

The design intent behind hooks (e.g., "validate commands before execution," "run lint after file edits," "inject context at session start") can be documented once and implemented separately per platform.

Hook implementation scripts (`.sh`, `.py` files containing the actual logic) can be shared if they accept input via stdin JSON and return results via exit codes.

### What is platform-specific

| Dimension | Claude Code | Codex |
|-----------|-------------|-------|
| Stability | Stable | Experimental (requires feature flag) |
| Event count | ~22 lifecycle events | Limited set (SessionStart, PreToolUse for Bash only, etc.) |
| Handler types | 4 types: `command`, `http`, `prompt`, `agent` | `command` type only |
| Config location | `hooks/hooks.json` or in plugin.json `hooks` field | `.codex/hooks.json` (separate from plugin.json) |
| Exit code semantics | 0 = pass, 1 = non-blocking error, 2 = block action | Similar but less documented |
| Matcher syntax | `*` for all tools; tool names; regex | Similar pattern-based matching |
| Platform support | All platforms | Not supported on Windows |

### Main differences

- Claude Code hooks are mature with broad event coverage. Codex hooks are experimental and limited.
- Claude Code supports `prompt` and `agent` handler types, allowing hooks to inject text or spawn sub-agents. Codex only supports `command` handlers.
- Codex hooks require enabling a feature flag (`codex_hooks = true` in `config.toml`).
- For Codex, prefer implementing hook-equivalent logic in Skills or MCP Servers rather than relying on the unstable hooks system.

### Adaptation cost

High if your project depends heavily on hooks. Low if hooks are used only for optional safety checks. The recommended approach: implement critical logic in Skills/MCP (shared), reserve hooks for platform-specific safety gates only.

---

## Summary Decision Table

| If you need to... | Adaptation approach |
|--------------------|--------------------|
| Share project instructions | Write `AGENTS.md` once. Create one-line `CLAUDE.md` import shell for Claude Code. |
| Share skills | Put all skills in `skills/`. Add optional `agents/openai.yaml` for Codex marketplace metadata. |
| Share MCP Servers | Build the server once. Declare in `.mcp.json`. Use `mcpServers` in both plugin.json files. |
| Package for distribution | Write two plugin.json files (one per platform), each under 30 lines, pointing to shared `skills/`. |
| Add lifecycle hooks | Document the intent once. Implement in Claude Code hooks (stable). For Codex, prefer Skill/MCP alternatives. |
