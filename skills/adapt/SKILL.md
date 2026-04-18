---
name: adapt
description: "Use this skill when adding Claude Code or Codex platform support to an agent ecosystem project, writing plugin.json manifests, setting up cross-platform directory structure, or reviewing platform compatibility. Covers three packaging patterns (root-level manifests, adapters directory, content triplication), the five-layer compatibility matrix, Claude Code plugin.json + marketplace.json specification, Codex .codex-plugin/plugin.json specification, and manifest field mapping between platforms. Trigger keywords: platform adapter, Claude Code plugin, Codex plugin, plugin.json, marketplace.json, cross-platform, manifest, compatibility, adapters, 平台适配, 跨平台兼容."
license: MIT
compatibility: "No runtime dependencies. Works with any coding agent that supports SKILL.md."
metadata:
  author: harnessforge
  version: "0.7.2"
  category: platform-adaptation
allowed-tools: Bash Read Edit Write Glob Grep
---

# Forge Adapt

What can be unified is content; what cannot be unified is the host extension ABI.
Do not attempt to produce a single plugin package that works on every agent platform.
Instead, choose the packaging pattern that matches the project's complexity, then keep shared content maximized and platform-specific files minimized.

## Three Packaging Patterns

The ecosystem uses three distinct patterns for cross-platform plugin distribution. Choose based on project complexity.

### Pattern A: Root-Level Manifests

The repo root IS the plugin root. Manifests live at the top level alongside shared content.

```text
project/
├── .claude-plugin/
│   ├── plugin.json          # Claude Code manifest
│   └── marketplace.json     # Claude Code marketplace discovery
├── .codex-plugin/
│   └── plugin.json          # Codex manifest
├── .codex/
│   └── INSTALL.md           # Codex manual install alternative
├── skills/                  # Shared content
│   └── my-skill/
│       └── SKILL.md
├── AGENTS.md
└── README.md
```

**When to use**: The project IS the plugin. Pure content (skill packs, knowledge bases). No MCP server, no hooks, no complex per-platform logic. Paths in manifests use `"./skills/"`.

**Real-world examples**: superpowers, oh-my-claudecode, HarnessForge itself.

**Key rule**: Both Claude Code and Codex copy plugins to a cache directory on install (`~/.claude/plugins/cache/` and `~/.codex/plugins/cache/` respectively). External paths (`../../`) break after copy. Root-level manifests with `./` paths survive this.

### Pattern B: Adapters Directory

Shared content lives in `skills/`, `src/`, `hooks/`. Platform-specific manifests and install scripts live under `adapters/<platform>/`.

```text
project/
├── skills/                  # Shared content
├── src/                     # MCP server (shared)
├── hooks/                   # Hook logic scripts (shared)
├── adapters/
│   ├── claude/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json  # skills: "../../skills/"
│   │   └── hooks/
│   │       └── hooks.json   # Platform-specific hook config
│   ├── codex/
│   │   ├── install.sh       # Clone + path substitution
│   │   └── README.md
│   └── opencode/
│       └── install.sh
├── AGENTS.md
└── README.md
```

**When to use**: The project has MCP servers, lifecycle hooks, per-platform install scripts, or needs path variable substitution (`${CLAUDE_PLUGIN_ROOT}` → `~/.codex/project/`). Typically, projects with both `skills/` and `src/`.

**Real-world examples**: agentsys (19 plugins, per-platform install scripts with path substitution).

**Key rule**: Each adapter directory is a plugin root. The `skills` path in manifests is relative to that adapter root, typically `"../../skills/"`. This pattern works for development and direct install but breaks on marketplace install (cache isolation strips external paths). Use this pattern only when marketplace install is not the primary distribution channel.

### Pattern C: Content Triplication (discouraged)

Full copies of skills in each platform's native discovery directory.

```text
project/
├── .claude/skills/my-skill/SKILL.md
├── .agents/skills/my-skill/SKILL.md
├── .opencode/skills/my-skill/SKILL.md
└── README.md
```

**When to use**: Only when platform-specific SKILL.md differences are substantial (rare). This pattern is maintenance-heavy — every content change must be replicated N times.

**Real-world examples**: autoresearch (triplicated across 3 platform directories).

**Recommendation**: Avoid this pattern for new projects. If you need minor per-platform tweaks, use Pattern A or B with platform-specific overrides, not full copies.

### Decision Table

| Question | If Yes → Pattern | If No → Next Question |
|----------|------------------|-----------------------|
| Is the project pure content (no MCP server, no hooks)? | **A: Root-Level** | ↓ |
| Does it need per-platform install scripts or path substitution? | **B: Adapters** | ↓ |
| Are SKILL.md files substantially different per platform? | **C: Triplication** | **B: Adapters** (default for complex projects) |

## Five-Layer Compatibility Matrix

Before writing any adapter, assess which layers of your project can be shared and which require per-platform work.

| Layer | Cross-Platform Compatibility | What Is Shared | What Is Platform-Specific | Key Differences |
|-------|------------------------------|----------------|---------------------------|-----------------|
| Instruction files | ~85% | `AGENTS.md` content body | Entry-point filename (`CLAUDE.md` vs `AGENTS.md`) | Claude Code uses `@AGENTS.md` import syntax; Codex reads `AGENTS.md` natively |
| Skills | ~80-90% | `SKILL.md` frontmatter + instruction body | Vendor-specific frontmatter fields | Codex has `agents/openai.yaml` per skill; unknown frontmatter fields are safely ignored |
| MCP | ~90% | MCP Server source code; `.mcp.json` as shared description | Client-side config format (JSON vs TOML) | Claude Code reads `.mcp.json` natively; Codex uses `config.toml` with `[mcp_servers]` blocks |
| Plugins | <50% | Shared payload (`skills/`, `src/`, assets) | Manifest format and required fields | Claude Code = `.claude-plugin/plugin.json` + marketplace; Codex = `.codex-plugin/plugin.json` (official manifest); definitions differ in required fields and distribution flow |
| Hooks | <50% | Design intent (e.g., "block destructive commands") | Event names, handler types, config format | Claude Code has ~22 events + 4 handler types (stable); Codex hooks are experimental with limited events |

Consult `references/compatibility-matrix.md` for the full per-layer analysis when you need deeper detail.

## Adding Claude Code Support

### For Pattern A (Root-Level)

Follow these steps when the repo root is the plugin root.

#### Step 1: Create the manifest directory

```bash
mkdir -p .claude-plugin
```

#### Step 2: Write plugin.json

Create `.claude-plugin/plugin.json`:

```json
{
  "name": "{{PLUGIN_NAME}}",
  "version": "{{VERSION}}",
  "description": "{{ONE_LINE_DESCRIPTION}}",
  "skills": "./skills/"
}
```

Required fields: `name` (kebab-case, becomes the namespace prefix for skill invocation), `description`.
Recommended fields: `version` (semver), `author`, `homepage`, `repository`, `license`, `keywords`.

Path rules:
- All paths are relative to the plugin root (the directory containing `.claude-plugin/`).
- Paths must start with `./` — never use `../` or `../../`.
- The `skills` field replaces the default discovery path; it does not append.
- Use `${CLAUDE_PLUGIN_ROOT}` to reference the plugin install root in hook commands.

See `references/claude-code-plugin-json-template.md` for the complete field reference with placeholders.

#### Step 3: Write marketplace.json

Create `.claude-plugin/marketplace.json` for marketplace discovery:

```json
{
  "name": "{{PLUGIN_NAME}}",
  "description": "{{ONE_LINE_DESCRIPTION}}",
  "owner": {
    "name": "{{AUTHOR_OR_ORG}}",
    "url": "{{AUTHOR_URL}}"
  },
  "plugins": [
    {
      "name": "{{PLUGIN_NAME}}",
      "description": "{{SHORT_DESCRIPTION}}",
      "version": "{{VERSION}}",
      "source": "./"
    }
  ]
}
```

The `plugins` array allows a single repo to host multiple plugins. For most projects, one entry with `"source": "./"` is sufficient.

#### Step 4: Write the CLAUDE.md import shell

If the project has an `AGENTS.md`, create `CLAUDE.md` at the repo root:

```markdown
@AGENTS.md

## Claude Code Specific
<!-- Claude Code specific additions below -->
```

#### Step 5: Configure MCP mapping (if applicable)

If the project has MCP Servers, declare them in `plugin.json`:

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

#### Step 6: Validate

```bash
claude plugin validate .
```

### For Pattern B (Adapters Directory)

Follow these steps when manifests live under `adapters/claude/`.

#### Step 1: Create the adapter directory

```bash
mkdir -p adapters/claude/.claude-plugin
```

#### Step 2: Write plugin.json

Create `adapters/claude/.claude-plugin/plugin.json`:

```json
{
  "name": "{{PLUGIN_NAME}}",
  "version": "{{VERSION}}",
  "description": "{{ONE_LINE_DESCRIPTION}}",
  "skills": "../../skills/",
  "mcpServers": {}
}
```

Path rules for Pattern B:
- Paths are relative to `adapters/claude/` (the adapter root, which IS the plugin root).
- `"../../skills/"` traverses up to the repo root's `skills/` directory.
- This works for direct install (`claude plugin install ./adapters/claude/`) but breaks on marketplace install (cache isolation removes external paths).

#### Step 3: Write the CLAUDE.md import shell

Create `adapters/claude/CLAUDE.md`:

```markdown
@../../AGENTS.md

<!-- Claude Code specific additions below -->
```

#### Step 4: Add hooks (optional)

Create `adapters/claude/hooks/hooks.json`:

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

Reference the shared hook scripts from `hooks/` using `${CLAUDE_PLUGIN_ROOT}` paths.

#### Step 5: Validate

```bash
claude plugin validate ./adapters/claude/
```

## Adding Codex Support

Codex uses `.codex-plugin/plugin.json` as the official plugin manifest entry point. Codex discovers plugins through `marketplace.json` files at two scopes: personal (`~/.agents/plugins/marketplace.json`) and repo-scoped (`$REPO_ROOT/.agents/plugins/marketplace.json`). Installed plugins are cached at `~/.codex/plugins/cache/`. The public Plugin Directory (self-serve publishing) is coming soon.

### For Pattern A (Root-Level)

#### Step 1: Write .codex-plugin/plugin.json

Create `.codex-plugin/plugin.json` at the repo root:

```json
{
  "name": "{{PLUGIN_NAME}}",
  "version": "{{VERSION}}",
  "description": "{{ONE_LINE_DESCRIPTION}}",
  "skills": "./skills/"
}
```

Required fields: `name`, `version`, `description`. The `skills` field points Codex to the skill directory.

See `references/codex-plugin-json-template.md` for the complete field reference.

#### Step 2: Write .codex/INSTALL.md (local install instructions)

Provide local plugin install instructions alongside `.codex-plugin/plugin.json`. Until the public Plugin Directory supports self-serve publishing, users install via local marketplace registration:

```markdown
# Installing {{PROJECT_NAME}} for Codex

## Personal Install (available across all repos)

1. Clone into the Codex plugins directory:
   ```bash
   git clone {{REPO_URL}} ~/.codex/plugins/{{PROJECT_NAME}}
   ```

2. Register in your personal marketplace (`~/.agents/plugins/marketplace.json`):
   ```json
   {
     "name": "local-plugins",
     "interface": { "displayName": "Local Plugins" },
     "plugins": [
       {
         "name": "{{PLUGIN_NAME}}",
         "source": { "source": "local", "path": "./../../.codex/plugins/{{PROJECT_NAME}}" },
         "policy": { "installation": "AVAILABLE", "authentication": "NONE" },
         "category": "{{CATEGORY}}"
       }
     ]
   }
   ```

3. Restart Codex. Open Plugin Directory (`/plugins`) and install.

## Updating

```bash
cd ~/.codex/plugins/{{PROJECT_NAME}} && git pull
```

## Uninstalling

Remove the entry from marketplace.json, then:
```bash
rm -rf ~/.codex/plugins/{{PROJECT_NAME}}
```
```

### For Pattern B (Adapters Directory)

For Pattern B, the adapter directory is the plugin root. The primary entry point is `.codex-plugin/plugin.json` inside the adapter directory.

#### Step 1: Create `adapters/codex/.codex-plugin/plugin.json`

```json
{
  "name": "{{PROJECT_NAME}}",
  "version": "{{VERSION}}",
  "description": "{{DESCRIPTION}}",
  "author": { "name": "{{AUTHOR}}", "url": "{{URL}}" },
  "license": "MIT",
  "skills": "../../skills/"
}
```

Note: `../../skills/` paths work for direct install but will NOT survive marketplace cache isolation. Document this limitation in README and provide the install script below as an alternative.

#### Step 2: Create `adapters/codex/install.sh` (local install script)

Create `adapters/codex/install.sh` that copies content into the Codex plugins directory and registers a local marketplace entry:

```bash
#!/usr/bin/env bash
set -euo pipefail
PLUGIN_NAME="{{PLUGIN_NAME}}"
INSTALL_DIR="${HOME}/.codex/plugins/${PLUGIN_NAME}"
MARKETPLACE="${HOME}/.agents/plugins/marketplace.json"

# Copy plugin content (flatten to avoid broken ../../ paths)
mkdir -p "$INSTALL_DIR/skills" "$INSTALL_DIR/.codex-plugin"
cp -r ../../skills/ "$INSTALL_DIR/skills/"
cp -r ../../hooks/ "$INSTALL_DIR/hooks/" 2>/dev/null || true

# Write a self-contained manifest (skills path is now local)
cat > "$INSTALL_DIR/.codex-plugin/plugin.json" << EOF
{
  "name": "${PLUGIN_NAME}",
  "version": "{{VERSION}}",
  "description": "{{DESCRIPTION}}",
  "skills": "./skills/"
}
EOF

# Register in personal marketplace
mkdir -p "$(dirname "$MARKETPLACE")"
echo "Installed to $INSTALL_DIR — register in $MARKETPLACE and restart Codex."
```

### Codex-Specific Metadata (optional, per skill)

If a skill needs Codex-specific display metadata, create `skills/<skill-name>/agents/openai.yaml`:

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

This file is a Codex vendor extension. Place it alongside the SKILL.md it describes. Other platforms will ignore it.

### Codex MCP Configuration

Codex reads MCP configuration from `config.toml`, not `.mcp.json`:

```toml
[mcp_servers.{{SERVER_NAME}}]
command = "npx"
args = ["-y", "{{NPM_PACKAGE}}"]
enabled = true
```

Alternatively, declare MCP Servers inside the plugin manifest under `mcpServers` (same JSON format as Claude Code). Codex plugin.json supports this.

## Manifest Field Mapping

When translating a manifest between Claude Code and Codex, read `references/manifest-field-mapping.md` for the complete field-by-field mapping table.

Key equivalences: `name`, `version`, `description`, `license`, `keywords`, `skills`, and `mcpServers` map directly. Main differences: Claude Code `author` is a string, Codex `author` is an object; Codex has `interface` for display metadata, Claude Code has `hooks` and `outputStyles`.

## Required Execution Rules

Follow these rules whenever you create or modify platform adapters.

1. **Choose the pattern that matches project complexity.** Use Pattern A for pure content plugins. Use Pattern B for projects with MCP servers, hooks, or per-platform install scripts. Never use Pattern C unless platform-specific SKILL.md differences are substantial.

2. **Manifests must stay under 30 lines.** If a manifest exceeds 30 lines, you are putting content in the wrong place. Move logic to skills, scripts, or MCP Servers.

3. **Shared payload must constitute 70-80% of the project.** Measure by file count. If platform-specific files outnumber shared files, refactor to extract shared content.

4. **Version numbers must match across platforms.** When `.claude-plugin/plugin.json` says `"version": "1.2.0"`, the marketplace.json and any Codex metadata must agree. Automate this with a script or CI check.

5. **Skill paths must resolve correctly from each plugin root.** For Pattern A: `ls ./skills/` from repo root. For Pattern B: `ls ../../skills/` from adapter directory. If the path does not reach `skills/`, it is wrong.

6. **Never hardcode environment-specific values in manifests.** Use `${CLAUDE_PLUGIN_ROOT}` for Claude Code. Use environment variables for Codex. Keep credentials out of committed files.

7. **Test each adapter independently.** Install the Claude Code adapter using `claude plugin validate`. Install the Codex adapter using `codex install ./` or by following the clone + symlink instructions in `.codex/INSTALL.md`. Verify that skills are discovered.

8. **Keep AGENTS.md as the single source of truth for instructions.** Claude Code imports it via `CLAUDE.md` with `@AGENTS.md`. Codex reads it directly. Do not maintain two divergent instruction files.

9. **Do not put hook registration in shared directories.** Hook event names and config formats differ between platforms. Keep hook config in platform-specific directories. Keep hook logic scripts shared.

## References

Load these files on demand when you need deeper detail. Do not load all of them upfront.

- `references/compatibility-matrix.md` -- Full five-layer compatibility analysis with per-layer detail on what is shared, what is platform-specific, and the main differences.
- `references/claude-code-plugin-json-template.md` -- Complete Claude Code plugin.json template with all fields, comments, and placeholder markers.
- `references/codex-plugin-json-template.md` -- Complete Codex plugin.json template with all fields, comments, and placeholder markers.
- `examples/dual-platform-directory-tree.md` -- Annotated directory trees showing both Pattern A (root-level, skill pack) and Pattern B (adapters directory, full plugin) with shared vs platform-specific files clearly marked.
