# Security Policy

## Supported Versions

| Version | Status |
|---------|--------|
| 0.x     | Active development — security fixes applied |

## Reporting Vulnerabilities

**Do not report security issues via public GitHub Issues.**

Use [GitHub Private Vulnerability Reporting](https://github.com/OrigArith/harnessforge/security/advisories/new) to submit reports.

Include:
1. Description and impact
2. Reproduction steps
3. Affected versions
4. Suggested fix (if any)

## Response Timeline

| Stage | Time |
|-------|------|
| Acknowledgment | 48 hours |
| Initial assessment | 5 business days |
| Fix (Critical) | 7 business days |
| Fix (High) | 14 business days |
| Fix (Medium/Low) | Next regular release |

## Security Scope

The following are in-scope for HarnessForge:

### Prompt Injection in Skill Content
- SKILL.md descriptions containing hidden instructions that manipulate agent behavior
- Reference files containing instruction-override payloads

### Malicious Template Content
- Templates in `references/` that inject harmful code when expanded by agents
- {{PLACEHOLDER}} patterns designed to trick agents into unsafe operations

### Install Script Vulnerabilities
- `install.sh` performing operations beyond symlink creation
- Path traversal in symlink targets

### Supply Chain
- Compromised dependencies (if any are added in future)
- Malicious modifications to plugin.json manifests

## Out of Scope

- Vulnerabilities in Claude Code, Codex, or other agent platforms themselves
- User misconfiguration of installed skills
- Social engineering attacks

## Acknowledgments

We thank all researchers who report security issues responsibly. Credits are included in CHANGELOG.md after fixes ship (unless anonymity is requested).
