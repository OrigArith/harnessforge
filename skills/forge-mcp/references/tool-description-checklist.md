# Tool Description Quality Checklist

Use this checklist to review every MCP tool description before release. A tool that fails any mandatory item must be fixed before shipping.

---

## Naming (3 rules)

- [ ] **1. Verb-noun `name` format.** The `name` field uses `verb_noun` style: `search_issues`, `create_pull_request`, `delete_branch`. No vague names like `do_thing` or `handler`.

- [ ] **2. Stable `name` across versions.** The `name` has not changed from the previous release. If it must change, a semver major bump and deprecation alias are in place.

- [ ] **3. Human-readable `title`.** The `title` field exists and uses title case: "Search Issues", "Create Pull Request". It is distinct from `name`.

---

## Description Content (7 rules)

- [ ] **4. States what the tool does.** The first sentence is a clear verb-object statement of the tool's purpose. Example: "Create a new pull request in the specified repository."

- [ ] **5. States when to use it.** The description includes at least one positive trigger condition. Example: "Use when the user explicitly asks to create a PR."

- [ ] **6. States when NOT to use it.** The description includes at least one negative exclusion condition. Example: "Do NOT use for draft reviews or local-only operations. Use {{ALTERNATIVE_TOOL}} instead."

- [ ] **7. Describes expected input.** The description mentions key parameters and their format or constraints. Example: "Pass the branch name as `head`. Title is limited to 256 characters."

- [ ] **8. Declares side effects.** The description states whether the tool modifies external state, calls remote APIs, incurs costs, or is irreversible. Example: "This is a write operation that will create a visible PR on the remote."

- [ ] **9. Lists required permissions.** If the tool needs specific scopes, API keys, or roles, the description says so. Example: "Requires `repo:write` scope."

- [ ] **10. Contains no instruction injection.** The description does not contain system-prompt-style instructions ("You are a helpful assistant"), marketing copy ("The best tool for..."), or unrelated directives aimed at the model.

---

## Schema Completeness (3 rules)

- [ ] **11. Every parameter has a `description`.** No parameter in `inputSchema.properties` lacks a `description` field. Each description tells the agent what value to pass and in what format.

- [ ] **12. Constraints are encoded in schema.** Finite value sets use `enum`. Numeric ranges use `minimum`/`maximum`. String limits use `maxLength`. Defaults use `default`. Required fields are listed in `required`.

- [ ] **13. `inputSchema` type is `"object"`.** The top-level `inputSchema` has `"type": "object"`. This is a protocol requirement.

---

## Error Guidance (1 rule)

- [ ] **14. Description mentions error scenarios.** The description hints at what can go wrong or what preconditions must hold. Example: "Fails if the branch does not exist in the repository." This helps the agent anticipate and handle errors.

---

## Bonus (recommended but not blocking)

- [ ] **15. `outputSchema` is defined.** The tool declares `outputSchema` so clients can parse structured results.

- [ ] **16. Annotations are set.** The tool includes `annotations` with at least `readOnlyHint` and `destructiveHint`.

- [ ] **17. Namespace prefix for multi-server contexts.** If the server may coexist with others offering similar tools, the `name` uses a namespace prefix: `github_create_issue` vs `gitlab_create_issue`.

- [ ] **18. Description length is under 500 characters.** Keep descriptions concise. Long descriptions waste context tokens and reduce model selection accuracy across large tool catalogs.

---

## How to Use This Checklist

1. Before releasing any MCP server version, run through items 1-14 for every tool.
2. Fix all mandatory failures before release.
3. Track bonus items (15-18) as improvements for the next version.
4. When reviewing an existing MCP server, score it against this checklist and report the pass rate.
