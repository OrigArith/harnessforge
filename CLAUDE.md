@AGENTS.md

## Claude Code Specific

- Skills are installed at `~/.claude/skills/` (global) or `.claude/skills/` (project-level)
- Invoke skills explicitly: `/forge-init`, `/forge-skill`, `/forge-mcp`, etc.
- All 5 forge-* skills are user-invocable via slash command
- For large projects, consider using `context: fork` to run skill in isolated subagent
