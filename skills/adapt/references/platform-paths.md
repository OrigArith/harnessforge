# Agent Platform Install Paths Reference

Comprehensive mapping of 15+ agent platforms and their install paths, discovery mechanisms, and maturity levels. Data sourced from GSD (15 platforms), autoresearch, agentsys, superpowers, gstack, and official platform documentation.

## Platform Install Path Table

| Platform | Global Path | Local Path | Manifest Entry Point | Discovery Status |
|----------|-------------|------------|---------------------|-----------------|
| **Claude Code** | `~/.claude/` | `./.claude/` | `.claude-plugin/plugin.json` | Stable — marketplace + local install |
| **Codex** | `~/.codex/` or `~/.agents/` | `./.codex/` or `./.agents/` | `.codex-plugin/plugin.json` | Stable — path split between `.codex/` and `.agents/` |
| **OpenCode** | `~/.config/opencode/` | `./.opencode/` | `opencode.jsonc` (6-path discovery) | Stable — ESM plugin format |
| **Cursor** | `~/.cursor/` | `./.cursor/` | `.cursor-plugin/plugin.json` | Stable — extends Claude Code schema |
| **Kiro** | `~/.kiro/` or `~/.config/kilo/` | `./.kiro/` | — | Emerging — paths may change |
| **Windsurf** | `~/.codeium/windsurf/` | `./.windsurf/` | — | Emerging |
| **Copilot CLI** | `~/.github/` | `./.github/` | — | Emerging |
| **Gemini CLI** | `~/.gemini/` | — | `.gemini/settings.json` | Emerging — no local project path |
| **Augment** | `~/.augment/` | `./.augment/` | — | Emerging |
| **Trae** | `~/.trae/` | `./.trae/` | — | Emerging |
| **Qwen Code** | `~/.qwen/` | `./.qwen/` | — | Emerging |
| **CodeBuddy** | `~/.codebuddy/` | `./.codebuddy/` | — | Emerging |
| **Cline** | `~/.cline/` | `./.clinerules` | — | Emerging — unique local path convention |
| **Factory Droid** | `~/.factory/` | — | — | Experimental |
| **Slate** | `~/.slate/` | — | — | Experimental |

## Discovery Status Definitions

| Status | Meaning |
|--------|---------|
| **Stable** | Official plugin/manifest format documented; path conventions settled; safe to target |
| **Emerging** | Platform exists and accepts instruction files; manifest format may not exist or may change |
| **Experimental** | Early-stage platform; paths observed but not officially documented |

## Cross-Platform Discovery Conventions

All platforms share one universal convention: **AGENTS.md** at the project root is read by every platform. This is the only truly cross-platform instruction file.

Platform-specific entry points:

| Platform | Entry Point | Relationship to AGENTS.md |
|----------|-------------|--------------------------|
| Claude Code | `CLAUDE.md` | Imports via `@AGENTS.md` |
| Codex | `AGENTS.md` (direct) | Native entry point |
| OpenCode | `AGENTS.md` or `.opencode/agents.md` | 6-path discovery fallback chain |
| Cursor | `.cursorrules` or `AGENTS.md` | Falls back to AGENTS.md |
| Cline | `.clinerules` or `AGENTS.md` | Falls back to AGENTS.md |

## Codex Path Split Detail

Codex has a known path split across the ecosystem:

| Convention | Used By | Path |
|-----------|---------|------|
| `.codex/skills/` | GSD, gstack | Codex-native directory |
| `.agents/skills/` | autoresearch | Cross-platform convention |
| `.codex-plugin/` + `adapters/codex/skills` | agentsys | Plugin manifest + adapter pattern |

This divergence means any Codex adapter must document which path convention it follows. The `.codex-plugin/plugin.json` manifest is the official discovery mechanism — it overrides path-based discovery when present.

## Practical Guidance

### Minimum Viable Cross-Platform Support

To reach the widest audience with minimum effort:

1. **AGENTS.md** at project root (reaches all platforms)
2. **CLAUDE.md** importing `@AGENTS.md` (Claude Code)
3. **`.claude-plugin/plugin.json`** (Claude Code marketplace install)
4. **`.codex-plugin/plugin.json`** (Codex marketplace install)

These four files cover the two dominant platforms and provide fallback instruction for all others via AGENTS.md.

### Extending to Emerging Platforms

For emerging platforms without official plugin formats, the pattern is:

1. Create `.<platform>/` directory at project root
2. Copy or symlink AGENTS.md into the platform's expected location
3. If the platform supports a settings/config file, add MCP server configuration there
4. Document the install steps in README under a platform-specific section

### When to Wait

Do not create adapter directories for Experimental-status platforms. Their paths and formats are likely to change. Instead, note compatibility in README ("may work with Factory Droid — place AGENTS.md at project root") and wait for the platform to stabilize.
