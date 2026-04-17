# Dual-Platform Directory Tree Example

This example shows a project called `deploy-guardian` that supports both Claude Code and Codex.
Every file is annotated with its sharing status: `[shared]` for platform-agnostic content, `[claude]` for Claude Code specific, and `[codex]` for Codex specific.

## Directory Tree

```text
deploy-guardian/
│
├── AGENTS.md                              # [shared] Cross-platform instruction file
│                                          #          Single source of truth for project behavior rules.
│                                          #          Codex reads this directly. Claude Code imports it.
│
├── .mcp.json                              # [shared] MCP Server declarations
│                                          #          Claude Code reads natively.
│                                          #          Codex uses the same schema inside plugin.json mcpServers,
│                                          #          or converts to config.toml for project-level config.
│
├── README.md                              # [shared] Project documentation with platform install matrix
├── LICENSE                                # [shared] License file
├── package.json                           # [shared] npm package for cross-platform distribution fallback
│
├── skills/                                # [shared] All skills live here — canonical source
│   ├── deploy/
│   │   ├── SKILL.md                       # [shared] Skill definition: safe deployment workflow
│   │   ├── scripts/
│   │   │   ├── pre-check.sh               # [shared] Pre-deployment validation script
│   │   │   └── rollback.sh                # [shared] Rollback execution script
│   │   ├── references/
│   │   │   └── rollback-guide.md          # [shared] Reference doc for rollback procedures
│   │   └── agents/
│   │       └── openai.yaml                # [codex]  Codex vendor extension: display metadata,
│   │                                      #          invocation policy, MCP tool dependencies.
│   │                                      #          Claude Code ignores this file.
│   └── triage/
│       ├── SKILL.md                       # [shared] Skill definition: incident triage workflow
│       └── scripts/
│           └── collect-diagnostics.sh     # [shared] Diagnostic collection script
│
├── src/                                   # [shared] MCP Server implementation
│   ├── server.ts                          # [shared] MCP Server entry point
│   └── tools/
│       ├── deploy-tool.ts                 # [shared] Deploy tool implementation
│       └── rollback-tool.ts               # [shared] Rollback tool implementation
│
├── hooks/                                 # [shared] Hook logic scripts (shared implementations)
│   ├── check-dangerous-cmd.sh             # [shared] Script that validates Bash commands
│   └── post-deploy-audit.py              # [shared] Script that logs deployment audit trail
│
├── tests/                                 # [shared] Platform-agnostic tests
│   ├── skills/
│   │   ├── deploy.test.ts                 # [shared] Skill behavior tests
│   │   └── triage.test.ts                 # [shared] Skill behavior tests
│   └── mcp/
│       └── server.test.ts                 # [shared] MCP Server integration tests
│
├── adapters/                              # Platform-specific adapter shells
│   │
│   ├── claude/                            # [claude] Claude Code adapter root
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json                # [claude] Claude Code manifest (see below)
│   │   ├── CLAUDE.md                      # [claude] Import shell: @../../AGENTS.md
│   │   │                                  #          Plus Claude-specific notes if needed
│   │   └── hooks/
│   │       └── hooks.json                 # [claude] Hook registration config
│   │                                      #          Maps events to shared scripts in ../../hooks/
│   │
│   └── codex/                             # [codex]  Codex adapter root
│       ├── .codex-plugin/
│       │   └── plugin.json                # [codex]  Codex manifest (see below)
│       └── .codex/
│           └── hooks.json                 # [codex]  Hook registration config (experimental)
│                                          #          Maps events to shared scripts in ../../hooks/
│
└── scripts/                               # [shared] Build and maintenance scripts
    ├── sync-mcp-configs.ts                # [shared] Generates platform-specific MCP configs from .mcp.json
    └── verify-version-sync.sh             # [shared] CI check: ensures version matches across manifests
```

## File Counts

| Category | Count | Percentage |
|----------|-------|------------|
| Shared files | 19 | ~79% |
| Claude Code specific | 3 | ~13% |
| Codex specific | 3 | ~13% |
| **Total** | **25** | -- |

Note: `agents/openai.yaml` inside skills counts as Codex-specific even though it lives in the shared `skills/` directory, because only Codex reads it.

## Claude Code Manifest (adapters/claude/.claude-plugin/plugin.json)

```json
{
  "name": "deploy-guardian",
  "version": "1.2.0",
  "description": "Safe deployment workflow with pre-checks, rollback, and audit trail",
  "author": "your-team",
  "homepage": "https://github.com/your-org/deploy-guardian",
  "repository": "https://github.com/your-org/deploy-guardian",
  "license": "MIT",
  "keywords": ["deploy", "rollback", "ci-cd"],
  "skills": "../../skills/",
  "agents": "../../agents/",
  "hooks": "./hooks/hooks.json",
  "mcpServers": {
    "deploy-api": {
      "command": "npx",
      "args": ["-y", "@your-org/deploy-mcp-server"]
    }
  },
  "userConfig": {
    "deploy_target": {
      "type": "string",
      "description": "Default deployment target (staging/production)",
      "default": "staging"
    }
  }
}
```

Line count: 24 lines (under the 30-line guideline).

## Codex Manifest (adapters/codex/.codex-plugin/plugin.json)

```json
{
  "name": "deploy-guardian",
  "version": "1.2.0",
  "description": "Safe deployment workflow with pre-checks, rollback, and audit trail",
  "author": {
    "name": "your-team",
    "url": "https://github.com/your-org"
  },
  "homepage": "https://github.com/your-org/deploy-guardian",
  "repository": "https://github.com/your-org/deploy-guardian",
  "license": "MIT",
  "keywords": ["deploy", "rollback", "ci-cd"],
  "skills": "../../skills/",
  "mcpServers": {
    "deploy-api": {
      "command": "npx",
      "args": ["-y", "@your-org/deploy-mcp-server"]
    }
  },
  "interface": {
    "displayName": "Deploy Guardian",
    "shortDescription": "Safe deployment with rollback",
    "category": "developer-tools",
    "brandColor": "#2563EB"
  }
}
```

Line count: 25 lines (under the 30-line guideline).

## Key Observations

1. **Version sync.** Both manifests declare `"version": "1.2.0"`. The script `scripts/verify-version-sync.sh` enforces this in CI.

2. **Shared skill path.** Both manifests point to `../../skills/` using relative paths from their adapter root. The skills themselves are written once.

3. **MCP Server declaration.** Both manifests declare the same MCP Server under `mcpServers` using identical JSON structure. No format conversion needed.

4. **Author format divergence.** Claude Code uses `"author": "your-team"` (string). Codex uses `"author": {"name": "your-team", "url": "..."}` (object). This is the most common field-level difference.

5. **Platform-exclusive fields.** Claude Code has `userConfig` and `hooks`; Codex has `interface`. Neither platform fails on unrecognized fields, but keep manifests clean by only including fields the target platform supports.

6. **Hook scripts are shared; hook configs are not.** The actual scripts in `hooks/` are platform-agnostic (they read stdin JSON, return exit codes). The registration configs (`hooks.json`) are platform-specific because event names and handler formats differ.

7. **agents/openai.yaml coexists peacefully.** It lives inside `skills/deploy/agents/` alongside the shared SKILL.md. Claude Code ignores it. No conflict arises.
