# Ideal Project Tree: Dual-Platform (Claude Code + Codex) MCP Server

This example shows a fully scaffolded project targeting Claude Code and Codex. It implements a "file-tools" MCP server that provides file reading, writing, and a companion refactoring skill. Use this as a reference to verify your scaffold output matches the expected structure.

## Complete Directory Tree

```text
file-tools/                                # Root: 11 entries (under 15-entry ceiling)
│
├── README.md                              # [REQUIRED] Run-to-Understand ordering:
│                                          #   Line 1: "File reading, writing, and refactoring tools for coding agents."
│                                          #   Line 3-8: Prerequisites (Node.js >= 18, npm)
│                                          #   Line 10-14: Quick Start (npm install + npx command)
│                                          #   Line 16-20: Expected output (sample MCP handshake log)
│                                          #   Line 22-28: Security notice (file system access disclosure)
│                                          #   Remaining: Config, platforms, directory map, tool reference
│
├── LICENSE                                # [REQUIRED] Apache-2.0 (MCP server = protocol component)
│
├── CONTRIBUTING.md                        # [RECOMMENDED] Includes:
│                                          #   - "What Counts as Public Interface" table
│                                          #   - Breaking change policy (tool desc changes = breaking)
│                                          #   - Platform adapter contribution rules
│
├── SECURITY.md                            # [RECOMMENDED] At root, NOT in docs/. Includes:
│                                          #   - "This MCP server is NOT a security boundary"
│                                          #   - 6 threat categories (injection, schema, composition,
│                                          #     credentials, permissions, supply chain)
│                                          #   - Vuln disclosure via GitHub Private Reporting
│                                          #   - 48h ack SLA, 7-day critical fix SLA
│
├── CHANGELOG.md                           # [RECOMMENDED] Conventional commits format
│                                          #   ## [Unreleased]
│                                          #   ## [1.0.0] - 2025-XX-XX
│                                          #   ### Added
│                                          #   - Initial release with read_file, write_file tools
│
├── AGENTS.md                              # [REQUIRED] Cross-platform instructions:
│                                          #   ## Project Overview
│                                          #   ## Code Standards (TypeScript strict, no any)
│                                          #   ## Testing Requirements (unit + contract + smoke)
│                                          #   ## Security Constraints (no secrets in code, min perms)
│
├── .mcp.json                              # MCP shared configuration source
│                                          #   { "mcpServers": { "file-tools": {
│                                          #       "command": "node",
│                                          #       "args": ["src/server.ts"] } } }
│
├── config/
│   ├── default.json                       # Zero-config defaults:
│   │                                      #   { "capabilities": { "read": true, "write": false,
│   │                                      #       "delete": false },
│   │                                      #     "security": { "allowed_hosts": [],
│   │                                      #       "require_approval_for": ["write","delete"] },
│   │                                      #     "max_file_size_mb": 10,
│   │                                      #     "mcp": { "server_name": "file-tools",
│   │                                      #       "transport": "stdio" } }
│   └── example.env                        # FILE_TOOLS_API_KEY=your-key-here
│                                          # FILE_TOOLS_ALLOWED_PATHS=/home/user/projects
│
├── src/                                   # --- Shared Content Layer (MCP Server) ---
│   ├── server.ts                          # Entry point: initializes MCP transport, registers tools
│   ├── tools/
│   │   ├── read-file.ts                   # read_file tool: readOnlyHint=true, openWorldHint=false
│   │   │                                  #   Validates path against allowed_paths config
│   │   │                                  #   Returns file content as text
│   │   └── write-file.ts                  # write_file tool: readOnlyHint=false
│   │                                      #   Gated by capabilities.write (default: false)
│   │                                      #   Requires approval per security.require_approval_for
│   ├── resources/                         # (empty in this example -- reserved for future resources)
│   └── utils/
│       ├── path-validator.ts              # Resolves and validates file paths against allowed list
│       └── error-sanitizer.ts             # Strips secrets from error messages before returning
│
├── skills/                                # --- Shared Content Layer (Skills) ---
│   └── file-refactor/
│       ├── SKILL.md                       # frontmatter: name, description, license, compatibility,
│       │                                  #   metadata (version, tags), allowed-tools
│       │                                  # body: workflow steps for file refactoring
│       │                                  #   1. Scan directory structure
│       │                                  #   2. Identify move/rename targets
│       │                                  #   3. Update all cross-references
│       │                                  #   4. Validate no broken imports
│       ├── scripts/
│       │   └── validate-refs.sh           # Checks for broken file references post-refactor
│       ├── references/
│       │   └── refactor-patterns.md       # Common refactoring patterns and edge cases
│       └── examples/
│           ├── input-sample.md            # Before: messy directory with scattered utils
│           └── output-sample.md           # After: organized directory with clear module boundaries
│
├── tests/
│   ├── unit/
│   │   ├── read-file.test.ts              # Tests read_file with valid path, invalid path, too-large file
│   │   └── write-file.test.ts             # Tests write_file gating, approval requirement
│   ├── contract/
│   │   └── tools.test.ts                  # MCP Inspector validates:
│   │                                      #   - Tool schemas match declared inputSchema
│   │                                      #   - Descriptions are non-empty
│   │                                      #   - Required fields are present
│   └── smoke/
│       ├── claude-smoke.sh                # Installs via adapters/claude, runs one read_file call
│       └── codex-smoke.sh                 # Installs via adapters/codex, runs one read_file call
│
├── adapters/                              # --- Platform Adapter Layer ---
│   ├── claude/                            # Claude Code adapter
│   │   ├── CLAUDE.md                      # Contents:
│   │   │                                  #   Read and follow the instructions in @AGENTS.md.
│   │   │                                  #   Additional Claude-specific rules:
│   │   │                                  #   - Use TodoWrite for multi-step refactors
│   │   │                                  #   - Prefer Edit over Write for existing files
│   │   └── plugin.json                    # 12 lines:
│   │                                      #   { "name": "file-tools", "version": "1.0.0",
│   │                                      #     "description": "File tools for coding agents",
│   │                                      #     "skills": ["../../skills/file-refactor"],
│   │                                      #     "mcp_servers": { "file-tools": {
│   │                                      #       "command": "node",
│   │                                      #       "args": ["../../src/server.ts"] } } }
│   └── codex/                             # Codex adapter
│       ├── .codex-plugin/
│       │   └── plugin.json                # Codex manifest: name, version, description,
│       │                                  #   entryPoints, capabilities
│       └── agents/
│           └── openai.yaml                # Codex vendor extensions:
│                                          #   model_config, tool_choice preferences
│
└── .github/
    ├── workflows/
    │   ├── ci.yml                         # Jobs: lint (eslint + tsc) -> test (unit + contract)
    │   │                                  #   -> smoke (matrix: [claude, codex])
    │   ├── release.yml                    # release-please: auto version bump + CHANGELOG + npm publish
    │   └── security.yml                   # Dependabot config + CodeQL analysis + secret scanning
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.yml                 # Fields: affected platform (dropdown), affected layer,
    │   │                                  #   compatibility impact (textarea)
    │   └── feature_request.yml            # Fields: cross-platform impact assessment
    └── pull_request_template.md           # Sections: Changes, Breaking Change Checklist
                                           #   (6 items), Platform Impact (2 checkboxes for
                                           #   claude + codex)
```

## Verification Checklist

After scaffolding, verify these properties hold:

- [ ] Root directory has exactly 11 entries (under 15-entry limit).
- [ ] `ls src/` shows no imports from `adapters/`. Run: `grep -r "adapters/" src/` returns empty.
- [ ] `config/default.json` is valid JSON and contains all capability flags with defaults.
- [ ] `README.md` line 10-14 contains working install + run commands.
- [ ] `SECURITY.md` is at root (not in `docs/`).
- [ ] `adapters/` contains only `claude/` and `codex/` (the two selected platforms).
- [ ] No `.claude-plugin/`, `.codex-plugin/`, or any platform manifest exists in the project root.
- [ ] `skills/file-refactor/SKILL.md` has valid YAML frontmatter with 6 required fields.
- [ ] `tests/smoke/` has one smoke test per selected platform.
- [ ] `example.env` (not `.env.example`) exists in `config/`.
