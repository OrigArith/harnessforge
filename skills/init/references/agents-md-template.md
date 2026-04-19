# AGENTS.md

## Project Overview

{{PROJECT_NAME}} is {{ONE_SENTENCE_DESCRIPTION}}.
Primary tech stack: {{LANGUAGE}} / {{RUNTIME}} / {{DATABASE}}
Repository layout: see "Directory Layout" below.

## Directory Layout

- `src/` -- {{SRC_DESCRIPTION}}
- `src/api/` -- {{API_LAYER_DESCRIPTION}}
- `src/core/` -- {{CORE_LOGIC_DESCRIPTION}}
- `src/db/` -- {{DB_LAYER_DESCRIPTION}}
- `tests/` -- {{TEST_STRUCTURE_DESCRIPTION}}
- `scripts/` -- {{SCRIPTS_DESCRIPTION}}
- `skills/` -- Agent skill definitions
- `.mcp.json` -- MCP server configuration

## Code Standards

- Use {{LANGUAGE}} {{LANGUAGE_MODE}} mode.
- Formatter: {{FORMATTER}}. Config: `{{FORMATTER_CONFIG_PATH}}`.
- Linter: {{LINTER}}. Config: `{{LINTER_CONFIG_PATH}}`.
- Function naming: {{FUNCTION_NAMING_CONVENTION}}.
- Type naming: {{TYPE_NAMING_CONVENTION}}.
- Every exported function must have a {{DOC_COMMENT_FORMAT}} comment.
- Do not use `any` type. Declare all types explicitly.
- Import order: built-in modules, then third-party dependencies, then local modules. Separate each group with a blank line.

## Build and Test

- Build: `{{BUILD_COMMAND}}`
- Unit tests: `{{UNIT_TEST_COMMAND}}`
- Integration tests: `{{INTEGRATION_TEST_COMMAND}}`
- Type check: `{{TYPE_CHECK_COMMAND}}`
- Lint: `{{LINT_COMMAND}}`
- Pre-commit gate (must pass before every commit):
  ```
  {{BUILD_COMMAND}} && {{UNIT_TEST_COMMAND}} && {{TYPE_CHECK_COMMAND}}
  ```

## Commit Conventions

- Format: `type(scope): description`
- Allowed types: feat / fix / refactor / test / docs / chore
- One logical change per commit.
- Write commit messages in {{COMMIT_LANGUAGE}}.

## Security Constraints

- Do not hardcode secrets, tokens, or passwords in any source file.
- Declare environment variables in `config/example.env`. Never commit actual `.env` files.
- Never concatenate user input into SQL strings. Use parameterized queries only.
- Do not modify files under `.github/workflows/` unless the task explicitly requires it.
- {{ADDITIONAL_SECURITY_CONSTRAINT}}

## Available Tools

MCP servers (see `.mcp.json`):
- `{{MCP_SERVER_1}}` -- {{MCP_SERVER_1_DESCRIPTION}}
- `{{MCP_SERVER_2}}` -- {{MCP_SERVER_2_DESCRIPTION}}

Skills (see `skills/` directory):
- `{{SKILL_1}}` -- {{SKILL_1_DESCRIPTION}}
- `{{SKILL_2}}` -- {{SKILL_2_DESCRIPTION}}
