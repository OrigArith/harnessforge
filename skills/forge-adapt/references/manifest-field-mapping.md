# Manifest Field Mapping: Claude Code <-> Codex

Use this table when translating a manifest from one platform to the other. Fields on the same row serve equivalent purposes.

| Purpose | Claude Code (`plugin.json`) | Codex (`plugin.json`) | Notes |
|---------|-----------------------------|-----------------------|-------|
| Plugin identifier | `name` (string) | `name` (string) | Both use kebab-case. Must match across platforms. |
| Version | `version` (string) | `version` (string, required) | Use identical semver string in both manifests. |
| Description | `description` (string) | `description` (string, required) | Keep identical or near-identical across platforms. |
| Author | `author` (string) | `author` (object: `{name, url}`) | Claude Code accepts a plain string; Codex expects an object. |
| Project URL | `homepage` (string) | `homepage` (string) | Same format. |
| Repository | `repository` (string) | `repository` (string) | Same format. |
| License | `license` (string) | `license` (string) | Same SPDX identifier. |
| Search tags | `keywords` (string[]) | `keywords` (string[]) | Same format. |
| Skill path | `skills` (string or string[]) | `skills` (string, required) | Both accept relative paths. Claude Code also accepts arrays. |
| Subagent path | `agents` (string or string[]) | -- | Codex does not have a top-level agents field in plugin.json. |
| Hook config | `hooks` (string or object) | -- | Codex hooks are separate (`hooks.json`), not declared in plugin.json. |
| Output styles | `outputStyles` (string[]) | -- | Claude Code only. |
| MCP Servers | `mcpServers` (object) | `mcpServers` (object) | Same JSON structure in both manifests. |
| User config | `userConfig` (object) | -- | Claude Code only. Codex uses environment variable injection. |
| Display metadata | -- | `interface` (object) | Codex only. Contains `displayName`, `shortDescription`, `category`, `brandColor`. |
| Channels | `channels` (object) | -- | Claude Code only. Requires MCP server with `claude/channel` support. |
