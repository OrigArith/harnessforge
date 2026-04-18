# Dual-Platform Directory Tree Examples

This document shows two project archetypes with both Claude Code and Codex support.
Every file is annotated with its sharing status: `[shared]` for platform-agnostic content, `[claude]` for Claude Code specific, and `[codex]` for Codex specific.

---

## Pattern A: Root-Level Manifests (Skill Pack)

This example shows a skill pack called `ops-playbook` — pure content, no MCP server, no hooks.
The repo root IS the plugin root. Manifests live alongside shared content.

```text
ops-playbook/
│
├── .claude-plugin/                        # [claude] Claude Code plugin directory
│   ├── plugin.json                        # [claude] Plugin identity and skill paths
│   └── marketplace.json                   # [claude] Marketplace discovery metadata
│
├── .codex-plugin/                         # [codex]  Codex plugin directory
│   └── plugin.json                        # [codex]  Codex manifest (name, version, description, skills)
│
├── .codex/                                # [codex]  Codex manual install (alternative)
│   └── INSTALL.md                         # [codex]  Clone + symlink instructions
│
├── AGENTS.md                              # [shared] Cross-platform instruction file
├── CLAUDE.md                              # [claude] @AGENTS.md import shell
├── README.md                              # [shared] Project documentation
├── LICENSE                                # [shared] License file
│
├── skills/                                # [shared] All skills live here — canonical source
│   ├── incident-response/
│   │   ├── SKILL.md                       # [shared] Skill definition
│   │   ├── scripts/
│   │   │   └── collect-logs.sh            # [shared] Log collection script
│   │   └── references/
│   │       └── runbook-template.md        # [shared] Reference doc
│   └── capacity-planning/
│       ├── SKILL.md                       # [shared] Skill definition
│       └── references/
│           └── sizing-guide.md            # [shared] Reference doc
│
└── tests/
    └── smoke/
        └── validate-skills.sh             # [shared] Skill validation
```

### Plugin Manifest (.claude-plugin/plugin.json)

```json
{
  "name": "ops-playbook",
  "version": "1.0.0",
  "description": "Ops runbooks and capacity planning skills for coding agents",
  "author": {
    "name": "your-team",
    "url": "https://github.com/your-org"
  },
  "repository": "https://github.com/your-org/ops-playbook",
  "license": "MIT",
  "keywords": ["ops", "runbooks", "incident-response", "capacity"],
  "skills": "./skills/"
}
```

Line count: 12 lines.

### Marketplace Manifest (.claude-plugin/marketplace.json)

```json
{
  "name": "ops-playbook",
  "description": "Ops runbooks and capacity planning skills for coding agents",
  "owner": {
    "name": "your-team",
    "url": "https://github.com/your-org"
  },
  "plugins": [
    {
      "name": "ops-playbook",
      "description": "Incident response and capacity planning skills",
      "version": "1.0.0",
      "source": "./"
    }
  ]
}
```

### File Counts

| Category | Count | Percentage |
|----------|-------|------------|
| Shared files | 10 | ~71% |
| Claude Code specific | 3 | ~21% |
| Codex specific | 2 | ~14% |
| **Total unique** | **14** | -- |

Note: CLAUDE.md counts as Claude-specific (it imports shared AGENTS.md but is only read by Claude Code).

### Key Observations

1. **No `adapters/` directory.** The repo root is the plugin root. All paths in plugin.json start with `./`.
2. **Marketplace install works.** When Claude Code or Codex copies this repo to cache, `./skills/` resolves correctly because skills are inside the copied directory.
3. **Codex has both plugin manifest and manual install.** `.codex-plugin/plugin.json` is the official entry point. `.codex/INSTALL.md` provides clone + symlink as a manual alternative.
4. **AGENTS.md is the single source of truth.** Claude Code imports it via CLAUDE.md. Codex reads it directly.

---

## Pattern B: Adapters Directory (Full Plugin with MCP Server)

This example shows a project called `deploy-guardian` that has both skills AND an MCP server, with lifecycle hooks that differ per platform.

```text
deploy-guardian/
│
├── AGENTS.md                              # [shared] Cross-platform instruction file
│
├── .mcp.json                              # [shared] MCP Server declarations
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
│   │       └── openai.yaml                # [codex]  Codex vendor extension
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
│   │   └── hooks/
│   │       └── hooks.json                 # [claude] Hook registration config
│   │
│   └── codex/                             # [codex]  Codex adapter root
│       ├── install.sh                     # [codex]  Clone + path substitution script
│       └── README.md                      # [codex]  Codex-specific install instructions
│
└── scripts/                               # [shared] Build and maintenance scripts
    ├── sync-mcp-configs.ts                # [shared] Generates platform-specific MCP configs from .mcp.json
    └── verify-version-sync.sh             # [shared] CI check: ensures version matches across manifests
```

### File Counts

| Category | Count | Percentage |
|----------|-------|------------|
| Shared files | 19 | ~79% |
| Claude Code specific | 3 | ~13% |
| Codex specific | 3 | ~13% |
| **Total** | **25** | -- |

Note: `agents/openai.yaml` inside skills counts as Codex-specific even though it lives in the shared `skills/` directory.

### Claude Code Manifest (adapters/claude/.claude-plugin/plugin.json)

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

### Key Observations

1. **Adapters directory is necessary.** The project has hooks that differ per platform and an MCP server that needs platform-specific configuration.
2. **Shared skill path uses `../../skills/`.** This works for direct install but will NOT survive marketplace cache isolation. Document this limitation.
3. **Hook scripts are shared; hook configs are not.** The actual scripts in `hooks/` are platform-agnostic. The registration configs are platform-specific because event names and handler formats differ.
4. **Codex uses an install script, not a manifest.** `adapters/codex/install.sh` copies content and performs path substitution, following the agentsys pattern.
5. **agents/openai.yaml coexists peacefully.** It lives inside `skills/deploy/agents/` alongside the shared SKILL.md. Claude Code ignores it.
