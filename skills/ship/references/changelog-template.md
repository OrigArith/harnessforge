# CHANGELOG Template

Use this template to create or update a CHANGELOG.md file for an agent ecosystem project.
Replace all `{{PLACEHOLDER}}` markers with actual values.
Follow Keep a Changelog format with the addition of a **Breaking** section listed first in each version entry.

---

## Template

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Agent ecosystem note:** In this project, tool descriptions, parameter schemas,
return schemas, manifest fields, auth methods, and transport protocols are all part
of the public API. Changes to any of these surfaces follow the same SemVer rules as
code changes. Description rewrites that alter implicit invocation behavior are
breaking changes.

## [Unreleased]

### Breaking

- {{BREAKING_CHANGE_DESCRIPTION}}. Migration: {{MIGRATION_INSTRUCTIONS}}.

### Added

- {{NEW_FEATURE_OR_CAPABILITY}}.

### Changed

- {{MODIFIED_BEHAVIOR_DESCRIPTION}}.

### Fixed

- {{BUG_FIX_DESCRIPTION}}.

## [{{VERSION}}] - {{YYYY-MM-DD}}

### Breaking

- **Tool description rewrite (`{{TOOL_NAME}}`):** Changed from "{{OLD_DESCRIPTION}}"
  to "{{NEW_DESCRIPTION}}". This {{NARROWS|WIDENS}} the implicit invocation scope.
  Agents that previously {{DID|DID_NOT}} trigger this tool for {{USE_CASE}} may now
  behave differently. Migration: {{MIGRATION_STEPS}}.
- **Schema change (`{{TOOL_NAME}}`):** Parameter `{{PARAM_NAME}}` changed from
  {{OLD_TYPE}} to {{NEW_TYPE}}. Update all callers to use the new type.
- **Removed tool:** `{{REMOVED_TOOL_NAME}}` has been removed. Use
  `{{REPLACEMENT_TOOL_NAME}}` instead.

### Added

- New tool `{{TOOL_NAME}}`: {{SHORT_DESCRIPTION}}.
- New optional parameter `{{PARAM_NAME}}` on `{{TOOL_NAME}}`: {{PARAM_PURPOSE}}.
- New transport support: {{TRANSPORT_TYPE}} (existing transports unchanged).

### Changed

- Improved error messages for `{{TOOL_NAME}}` when {{ERROR_CONDITION}}.
- Updated `{{MANIFEST_FIELD}}` in plugin manifest to {{NEW_VALUE}}.

### Deprecated

- `{{DEPRECATED_FEATURE}}` is deprecated and will be removed in v{{REMOVAL_VERSION}}.
  Use `{{REPLACEMENT}}` instead. See migration guide: {{MIGRATION_LINK}}.

### Removed

- Removed `{{REMOVED_FEATURE}}`. This was deprecated in v{{DEPRECATION_VERSION}}.

### Fixed

- Fixed {{BUG_DESCRIPTION}} that caused {{SYMPTOM}} when {{TRIGGER_CONDITION}}.
- Fixed parameter validation for `{{PARAM_NAME}}` on `{{TOOL_NAME}}`.

### Security

- Updated `{{DEPENDENCY_NAME}}` from {{OLD_VERSION}} to {{NEW_VERSION}} to address
  {{CVE_ID}}.
- Fixed credential leak in {{COMPONENT}} output when {{CONDITION}}.

## [{{PREVIOUS_VERSION}}] - {{YYYY-MM-DD}}

{{PREVIOUS_RELEASE_ENTRIES}}

[Unreleased]: https://github.com/{{OWNER}}/{{REPO}}/compare/v{{VERSION}}...HEAD
[{{VERSION}}]: https://github.com/{{OWNER}}/{{REPO}}/compare/v{{PREVIOUS_VERSION}}...v{{VERSION}}
[{{PREVIOUS_VERSION}}]: https://github.com/{{OWNER}}/{{REPO}}/releases/tag/v{{PREVIOUS_VERSION}}
```

---

## Section Reference

| Section | When to Use | SemVer Impact |
|---------|-------------|---------------|
| **Breaking** | Tool description rewrite that changes invocation scope; removed tool/resource/prompt; required param added; return type changed; auth/transport changed | MAJOR |
| **Added** | New tool, optional param, resource, prompt, transport (without removing old) | MINOR |
| **Changed** | Backward-compatible behavior modification | MINOR or PATCH |
| **Deprecated** | Feature marked for future removal with timeline and migration path | MINOR |
| **Removed** | Feature deleted (also list under Breaking if it was public API) | MAJOR |
| **Fixed** | Bug fix with no contract change | PATCH |
| **Security** | Vulnerability patch, dependency update for CVE | PATCH |

---

## Commit Message to CHANGELOG Mapping

| Commit Prefix | CHANGELOG Section |
|---------------|-------------------|
| `feat(tools):` | Added |
| `feat(desc)!:` | Breaking |
| `feat(schema)!:` | Breaking |
| `fix(tools):` | Fixed |
| `fix(auth):` | Fixed or Security |
| `chore(deps):` (security) | Security |
| `refactor:` | Changed (only if externally visible) |
| `BREAKING CHANGE:` footer | Breaking |

---

## Placeholder Reference

| Placeholder | Description |
|-------------|-------------|
| `{{VERSION}}` | SemVer version string (e.g., 1.2.0) |
| `{{YYYY-MM-DD}}` | Release date in ISO 8601 format |
| `{{TOOL_NAME}}` | Name of the affected tool |
| `{{OLD_DESCRIPTION}}` | Previous tool description text |
| `{{NEW_DESCRIPTION}}` | Updated tool description text |
| `{{NARROWS\|WIDENS}}` | Whether the change narrows or widens trigger scope |
| `{{PARAM_NAME}}` | Name of the affected parameter |
| `{{OLD_TYPE}}` / `{{NEW_TYPE}}` | Parameter type before and after the change |
| `{{MIGRATION_STEPS}}` | Concrete steps users must take to adapt |
| `{{CVE_ID}}` | CVE identifier for security fixes |
| `{{OWNER}}` / `{{REPO}}` | GitHub repository owner and name |
