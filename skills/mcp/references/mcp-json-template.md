# .mcp.json Configuration Template

Place `.mcp.json` in the project root as the single source of truth for MCP server configuration. Generate platform-specific configs from this file.

---

## Full Template

```json
{
  "mcpServers": {
    "{{SERVER_NAME}}": {
      "command": "{{COMMAND}}",
      "args": [{{ARGS}}],
      "env": {
        "{{ENV_VAR_NAME}}": "${{{ENV_VAR_REF}}}"
      }
    },
    "{{REMOTE_SERVER_NAME}}": {
      "url": "{{REMOTE_URL}}",
      "headers": {
        "Authorization": "Bearer ${{{AUTH_TOKEN_REF}}}"
      }
    }
  }
}
```

---

## stdio Server (Local)

Use this pattern for servers distributed via npm, pip, or Docker that run as local subprocesses.

### Node.js / npm

```json
{
  "mcpServers": {
    "{{SERVER_NAME}}": {
      "command": "npx",
      "args": ["-y", "{{NPM_PACKAGE}}"],
      "env": {
        "{{API_KEY_NAME}}": "${{{API_KEY_REF}}}"
      }
    }
  }
}
```

**Example:**

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Python / uvx

```json
{
  "mcpServers": {
    "{{SERVER_NAME}}": {
      "command": "uvx",
      "args": ["{{PYTHON_PACKAGE}}"],
      "env": {
        "{{API_KEY_NAME}}": "${{{API_KEY_REF}}}"
      }
    }
  }
}
```

### Python / pip + module

```json
{
  "mcpServers": {
    "{{SERVER_NAME}}": {
      "command": "python",
      "args": ["-m", "{{PYTHON_MODULE}}"],
      "env": {
        "{{API_KEY_NAME}}": "${{{API_KEY_REF}}}"
      }
    }
  }
}
```

### Docker

```json
{
  "mcpServers": {
    "{{SERVER_NAME}}": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "{{DOCKER_IMAGE}}"],
      "env": {
        "{{API_KEY_NAME}}": "${{{API_KEY_REF}}}"
      }
    }
  }
}
```

---

## Streamable HTTP Server (Remote)

Use this pattern for servers hosted as remote services with OAuth or token-based auth.

### Remote with Bearer Token

```json
{
  "mcpServers": {
    "{{SERVER_NAME}}": {
      "url": "https://{{HOST}}/{{PATH}}",
      "headers": {
        "Authorization": "Bearer ${{{AUTH_TOKEN_REF}}}"
      }
    }
  }
}
```

### Remote with OAuth (URL-only)

When the server implements OAuth 2.1, the client handles the auth flow automatically. Just provide the URL.

```json
{
  "mcpServers": {
    "{{SERVER_NAME}}": {
      "url": "https://{{HOST}}/{{PATH}}"
    }
  }
}
```

---

## Combined Example (stdio + Remote)

```json
{
  "mcpServers": {
    "local-github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "remote-notion": {
      "url": "https://mcp.notion.so/sse"
    },
    "remote-custom": {
      "url": "https://mcp.example.com/api",
      "headers": {
        "Authorization": "Bearer ${CUSTOM_API_TOKEN}"
      }
    }
  }
}
```

---

## Claude Code Installation

Claude Code uses two separate files for MCP server management. Do NOT put `mcpServers` in `settings.json` — it will be rejected.

| File | Purpose | Location |
|------|---------|----------|
| `.mcp.json` | Server startup commands and env vars | Project root (project-scoped) or `~/.claude/.mcp.json` (global) |
| `settings.json` | Approve/enable servers via `mcpServers` allowlist | `~/.claude/settings.json` or `.claude/settings.json` |

**Workflow:**

1. Define the server in `.mcp.json` (command, args, env).
2. Claude Code reads `.mcp.json` automatically on startup — no manual approval step needed for project-scoped servers.
3. If you need to allow a server globally or manage permissions, use `settings.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__your_server__tool_name"
    ]
  }
}
```

**Common mistake**: Adding `"mcpServers": {...}` to `settings.json` — this field is not recognized there. Server definitions always go in `.mcp.json`.

---

## Platform-Specific Config Generation

The `.mcp.json` format is native to Claude Code and OpenClaw. For other platforms, convert:

### Codex (codex.toml)

```toml
[mcp.{{SERVER_NAME}}]
command = "{{COMMAND}}"
args = [{{TOML_ARGS}}]

[mcp.{{SERVER_NAME}}.env]
{{ENV_VAR_NAME}} = "${{ENV_VAR_REF}}"
```

### OpenCode (opencode.jsonc)

```jsonc
{
  "mcp": {
    "{{SERVER_NAME}}": {
      "command": "{{COMMAND}}",
      "args": [{{ARGS}}],
      "env": {
        "{{ENV_VAR_NAME}}": "${{{ENV_VAR_REF}}}"
      }
    }
  }
}
```

**Note on env var syntax**: Claude Code and OpenClaw use `${VAR}`. Codex uses `$VAR`. OpenCode uses `${VAR}`. Account for this difference in sync scripts.

---

## Environment Variable Security Rules

1. Never hardcode secrets in `.mcp.json`. Always use variable references (`${VAR}`).
2. Add `.env` to `.gitignore`. Never commit credential files.
3. For CI/CD, use the platform's secret store (GitHub Secrets, etc.).
4. For remote production, prefer OAuth 2.1 or workload identity over static tokens.
