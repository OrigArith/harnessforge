# Directory Templates

Three canonical directory structures for agent ecosystem projects. Copy the tree for the selected template and adapt placeholders.

---

## Template A: MCP Server

Use when the project exposes tools or data to agents via the MCP protocol.

```text
{{PROJECT_NAME}}/
├── README.md                          # One-liner + install + first run
├── LICENSE                            # Apache-2.0 recommended for MCP servers
├── CONTRIBUTING.md                    # Agent-ecosystem contribution guide
├── SECURITY.md                        # Security boundary + vuln disclosure
├── CHANGELOG.md                       # Conventional commits format
├── AGENTS.md                          # Cross-platform shared instructions
│
├── .mcp.json                          # MCP config (shared source of truth)
├── config/
│   ├── default.json                   # Zero-config first run defaults
│   └── example.env                    # Env var template (no real secrets)
│
├── src/                               # --- Shared Content Layer ---
│   ├── server.ts                      # MCP server entry point
│   ├── tools/                         # Tool implementations
│   │   ├── {{TOOL_A}}.ts              #   One file per tool
│   │   └── {{TOOL_B}}.ts
│   ├── resources/                     # Resource implementations (optional)
│   └── utils/                         # Shared utilities
│
├── tests/                             # --- Test Layer ---
│   ├── unit/                          # Unit tests for tools and utils
│   ├── contract/                      # MCP Inspector schema validation
│   └── smoke/                         # Cross-platform install-and-run checks
│
├── adapters/                          # --- Platform Adapter Layer ---
│   ├── claude/                        # Claude Code adapter
│   │   ├── CLAUDE.md                  #   @AGENTS.md + Claude-specific rules
│   │   └── plugin.json               #   Claude Code manifest (<30 lines)
│   ├── codex/                         # Codex adapter
│   │   ├── .codex-plugin/
│   │   │   └── plugin.json            #   Codex plugin manifest (official entry)
│   │   ├── install.sh                 #   Clone + path substitution (manual install)
│   │   ├── README.md                  #   Codex install instructions
│   │   └── agents/
│   │       └── openai.yaml            #   Codex vendor extensions
│   ├── opencode/                      # OpenCode adapter
│   │   ├── opencode.jsonc             #   OpenCode configuration
│   │   └── plugin.ts                  #   OpenCode runtime module
│   └── openclaw/                      # OpenClaw adapter
│       ├── openclaw.plugin.json       #   OpenClaw native manifest
│       └── entry.ts                   #   definePluginEntry SDK entry
│
└── .github/                           # --- CI/CD Layer ---
    ├── workflows/
    │   ├── ci.yml                     #   lint + type-check + test + contract
    │   ├── release.yml                #   release-please auto-versioning
    │   └── security.yml               #   Dependabot + CodeQL + secret scan
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.yml             #   Includes "Affected Platform" field
    │   └── feature_request.yml        #   Includes "Cross-platform Impact" field
    └── pull_request_template.md       #   Breaking change checklist
```

**Key constraints:**
- `src/` must NOT import from `adapters/`. Deletion of `adapters/` must not break `src/`.
- `config/default.json` must enable a working first run with zero user edits.
- Root entry count: 10 items (well under the 15-entry ceiling).

---

## Template B: Skill Pack

Use when the project packages domain knowledge, workflows, or checklists as reusable agent skills with no external system interaction. The repo root IS the plugin root — manifests live at root level for marketplace compatibility.

```text
{{PROJECT_NAME}}/
├── README.md                          # One-liner + install + first run
├── LICENSE                            # MIT recommended for skill packs
├── CONTRIBUTING.md                    # Agent-ecosystem contribution guide
├── AGENTS.md                          # Cross-platform shared instructions
├── CLAUDE.md                          # @AGENTS.md import shell (Claude Code entry)
│
├── .claude-plugin/                    # --- Claude Code Plugin (root = plugin root) ---
│   ├── plugin.json                    #   Plugin identity + skill paths (./skills/)
│   └── marketplace.json               #   Marketplace discovery metadata
│
├── .codex-plugin/                     # --- Codex Plugin ---
│   └── plugin.json                    #   Codex manifest (name, version, description, skills)
│
├── .codex/                            # --- Codex Manual Install (alternative) ---
│   └── INSTALL.md                     #   Clone + symlink instructions for non-marketplace install
│
├── skills/                            # --- Shared Content Layer ---
│   ├── {{SKILL_A}}/                   # Each skill gets its own subdirectory
│   │   ├── SKILL.md                   #   Skill definition (frontmatter + body)
│   │   ├── scripts/                   #   Executable scripts
│   │   │   ├── validate.sh            #     Validation script
│   │   │   └── transform.py           #     Transformation script
│   │   ├── references/                #   Domain knowledge docs
│   │   │   ├── domain-guide.md        #     Deep reference material
│   │   │   └── checklist.md           #     Operational checklist
│   │   ├── examples/                  #   Input/output examples
│   │   │   ├── input-sample.md
│   │   │   └── output-sample.md
│   │   └── assets/                    #   Diagrams, images (optional)
│   └── {{SKILL_B}}/                   # Additional skill (same structure)
│       ├── SKILL.md
│       ├── scripts/
│       └── references/
│
├── tests/
│   └── skill-smoke/                   #   Skill invocation smoke tests
│       └── test-trigger.md            #   Test trigger phrases and expected behavior
│
└── .github/
    └── workflows/
        └── ci.yml                     #   lint + smoke test
```

**Key constraints:**
- No `src/` directory. The skill pack has no server-side code.
- No `adapters/` directory. The repo root IS the plugin root. Plugin manifests use `"./skills/"` paths.
- Root entry count: 10 items (well under the 15-entry ceiling).
- Each skill subdirectory is self-contained: SKILL.md + scripts + references + examples.
- Marketplace install works because all content is inside the copied directory — no `../../` path escapes.

---

## Template C: Full Plugin

Use when shipping a product-grade installable plugin with skills + MCP tools + lifecycle hooks, distributed via marketplace or registry.

```text
{{PROJECT_NAME}}/
├── README.md                          # One-liner + install + first run
├── LICENSE                            # MIT or Apache-2.0
├── CONTRIBUTING.md                    # Agent-ecosystem contribution guide
├── SECURITY.md                        # Security boundary + vuln disclosure
├── CHANGELOG.md                       # Conventional commits format
├── AGENTS.md                          # Cross-platform shared instructions
│
├── skills/                            # --- Skill Layer (shared) ---
│   ├── {{WORKFLOW_A}}/
│   │   ├── SKILL.md
│   │   ├── scripts/
│   │   └── references/
│   └── {{WORKFLOW_B}}/
│       ├── SKILL.md
│       └── scripts/
│
├── src/                               # --- MCP Server Layer (shared) ---
│   ├── server.ts                      # MCP server entry point
│   ├── tools/                         # Tool implementations
│   └── resources/                     # Resource implementations
│
├── .mcp.json                          # MCP config (shared source)
├── config/
│   └── default.json                   # Zero-config defaults
│
├── adapters/                          # --- Platform Adapter Layer ---
│   ├── claude/
│   │   ├── CLAUDE.md
│   │   ├── plugin.json               #   Manifest with hooks declaration
│   │   └── hooks/                     #   Claude lifecycle hooks
│   │       ├── on-tool-start.sh
│   │       └── on-notification.sh
│   ├── codex/
│   │   ├── .codex-plugin/
│   │   │   └── plugin.json            #   Codex plugin manifest (official entry)
│   │   ├── install.sh                 #   Clone + path substitution (manual install)
│   │   ├── README.md                  #   Codex install instructions
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── hooks/                     #   Codex hooks (experimental)
│   │       └── post-tool.sh
│   ├── opencode/
│   │   ├── opencode.jsonc
│   │   └── plugin.ts                  #   Includes bus event listeners
│   └── openclaw/
│       ├── openclaw.plugin.json
│       ├── entry.ts                   #   definePluginEntry + lifecycle hooks
│       └── hooks/
│           └── gateway-hooks.ts
│
├── tests/                             # --- Test Layer ---
│   ├── unit/
│   ├── contract/                      #   MCP Inspector schema validation
│   ├── smoke/                         #   Cross-platform smoke tests
│   └── integration/                   #   End-to-end plugin integration tests
│
└── .github/
    ├── workflows/
    │   ├── ci.yml                     #   lint + test + contract
    │   ├── release.yml                #   release-please auto-versioning
    │   └── security.yml               #   Dependabot + CodeQL + secret scan
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.yml
    │   └── feature_request.yml
    └── pull_request_template.md
```

**Key constraints:**
- Hooks MUST be implemented per-platform (they are the lowest-compatibility layer, <50% shared).
- Shared payload (`skills/` + `src/`) should be 70-80% of the project. If `adapters/` is larger, content-host separation has failed.
- Manifests stay under 30 lines. Brand assets and UI metadata go in `assets/`, not in manifests.
- Root entry count: 11 items (under the 15-entry ceiling).
