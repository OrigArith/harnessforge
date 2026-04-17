# README.md Template

Use this template when generating the project's README.md. Replace all `{{PLACEHOLDER}}` markers. Follow the Run-to-Understand ordering strictly -- do not rearrange sections.

---

```markdown
# {{PROJECT_NAME}}

{{ONE_LINE_DESCRIPTION}}

## Quick Start

{{PREREQUISITES_BLOCK}}

<!-- List every external dependency BEFORE install commands.
     If API keys, login tokens, or paid subscriptions are needed, declare them here. -->

**Prerequisites:**
- {{RUNTIME}} (e.g., Node.js >= 18, Python >= 3.11)
- {{PACKAGE_MANAGER}} (e.g., npm, pip, uv)
- {{OPTIONAL_DEPS}} (mark each as "optional" or "required")

**Install and run:**

```bash
{{INSTALL_COMMAND}}
{{RUN_COMMAND}}
```

## Expected Output

<!-- Show what a successful first run looks like.
     Use a terminal log snippet or screenshot. -->

```
{{EXPECTED_OUTPUT_SAMPLE}}
```

## Security and Permissions

<!-- Place this AFTER Quick Start and BEFORE Extended Configuration.
     Users must see risks before they start customizing. -->

{{SECURITY_NOTICE}}

- This project {{DOES_OR_DOES_NOT}} execute arbitrary code.
- This project {{DOES_OR_DOES_NOT}} access the file system.
- This project {{DOES_OR_DOES_NOT}} make network requests.
- Default permissions: {{DEFAULT_PERMISSION_SUMMARY}}
- For full security details, see [SECURITY.md](./SECURITY.md).

## Configuration

<!-- Progressive disclosure: show minimum config first, then advanced options. -->

**Minimum configuration** (works out of the box):

```json
{{MINIMUM_CONFIG_SNIPPET}}
```

**Advanced configuration** (customize as needed):

See `config/default.json` for all available fields. Override per-platform settings in `adapters/<platform>/config`. User-local overrides go in `~/.config/{{PROJECT_NAME}}/user.json` (not checked in).

## Supported Platforms

| Platform | Status | Adapter |
|---|---|---|
| Claude Code | {{STATUS}} | `adapters/claude/` |
| Codex | {{STATUS}} | `adapters/codex/` |
| OpenCode | {{STATUS}} | `adapters/opencode/` |
| OpenClaw | {{STATUS}} | `adapters/openclaw/` |

<!-- Remove rows for platforms you do not support.
     Status values: Supported, Experimental, Planned, Not supported. -->

## Directory Structure

```text
{{DIRECTORY_TREE}}
```

<!-- Keep this tree to top-level directories only.
     One line per entry with a short annotation. -->

## API / Tool Reference

<!-- For MCP servers: list each tool with name, description, and key parameters.
     For skill packs: list each skill with trigger phrases. -->

| Tool / Skill | Description |
|---|---|
| `{{TOOL_NAME}}` | {{TOOL_DESCRIPTION}} |

## Development

```bash
{{DEV_SETUP_COMMANDS}}
{{TEST_COMMANDS}}
{{LINT_COMMANDS}}
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## License

[{{LICENSE_NAME}}](./LICENSE)
```

---

**Template rules:**
- The first 30 lines of the rendered README MUST contain install and run commands.
- Prerequisites with cost implications (API keys, paid subscriptions) MUST appear before install commands.
- Security notice MUST appear before Extended Configuration.
- Do not add a badge wall above Quick Start. Badges, if any, go after the one-liner.
