# Good vs Bad Description Examples

Five pairs demonstrating common mistakes and the correct pattern for SKILL.md `description` fields.

---

## Pair 1: API Migration Skill

**Bad:**

```
description: "Helps with API stuff. Can do migrations and transformations."
```

Problems:
- Does not start with "Use this skill when ...".
- Vague ("API stuff") -- agent cannot determine when to activate.
- No trigger keywords or synonyms.
- No boundary statement.

**Good:**

```
description: >
  Use this skill when migrating REST API endpoints between major versions.
  Handles route mapping, request/response schema transformation, deprecation
  annotation, and backward-compatible wrapper generation. Does not handle
  GraphQL migrations. Trigger keywords: API migration, version upgrade,
  endpoint mapping, schema transform, REST versioning.
```

Why it works:
- Starts with "Use this skill when ...".
- States the main use case clearly (migrating REST API endpoints).
- Lists specific capabilities (route mapping, schema transformation).
- Sets a boundary (does not handle GraphQL).
- Ends with trigger keywords for matching.

---

## Pair 2: Database Schema Skill

**Bad:**

```
description: "Database schema management tool for PostgreSQL and MySQL."
```

Problems:
- Reads like a product tagline, not an agent instruction.
- Missing the "Use this skill when ..." opener.
- No variant expressions (DDL, ALTER TABLE, migration files).
- No mention of what triggers activation.

**Good:**

```
description: >
  Use this skill when generating, reviewing, or applying database schema
  changes for PostgreSQL or MySQL. Covers DDL generation, ALTER TABLE
  safety checks, migration file creation, rollback script generation,
  and schema diff analysis. Trigger keywords: database migration, DDL,
  schema change, ALTER TABLE, migration file, rollback, schema diff.
```

Why it works:
- Clear opener with three verb actions (generating, reviewing, applying).
- Specifies supported databases (PostgreSQL, MySQL).
- Covers variant operations agents might encounter.
- Rich trigger keyword list.

---

## Pair 3: Test Generation Skill

**Bad:**

```
description: >
  This skill is a comprehensive test generation framework that leverages
  advanced static analysis to produce high-quality unit tests, integration
  tests, and end-to-end tests for modern JavaScript and TypeScript
  applications using Jest, Vitest, Mocha, Playwright, and Cypress,
  with support for React Testing Library, component mocking, API
  stubbing, snapshot testing, coverage analysis, mutation testing,
  and continuous integration pipeline integration across GitHub Actions,
  GitLab CI, and CircleCI platforms.
```

Problems:
- Does not start with "Use this skill when ...".
- Marketing language ("comprehensive", "advanced", "high-quality", "leverages").
- Far too long for the primary trigger signal -- buries the intent.
- Lists every possible technology instead of focusing on when to activate.

**Good:**

```
description: >
  Use this skill when writing or updating tests for JavaScript or
  TypeScript projects. Generates unit tests, integration tests, and
  e2e tests. Supports Jest, Vitest, and Playwright. Handles component
  mocking, API stubbing, and coverage gap analysis. Trigger keywords:
  write tests, generate tests, test coverage, unit test, integration
  test, e2e test, Jest, Vitest, Playwright.
```

Why it works:
- Concise. Agent can parse the intent in one read.
- Lists the most important frameworks, not every possible one.
- Trigger keywords match natural queries an agent would encounter.

---

## Pair 4: Docker Deployment Skill

**Bad:**

```
description: "Docker"
```

Problems:
- One word. No context for the agent to decide activation.
- Fails the 1-character minimum spirit -- technically valid but useless.
- Agent has no idea whether this is for building, deploying, debugging, or composing.

**Good:**

```
description: >
  Use this skill when containerizing an application with Docker or
  debugging Docker build failures. Generates Dockerfiles, docker-compose
  configurations, and multi-stage build setups. Handles image size
  optimization, layer caching strategies, and health check configuration.
  Does not manage Kubernetes deployments -- use the k8s-deploy skill
  for that. Trigger keywords: Docker, Dockerfile, docker-compose,
  container, multi-stage build, image optimization.
```

Why it works:
- Two clear trigger scenarios (containerizing and debugging).
- Specific deliverables (Dockerfiles, compose configs, multi-stage builds).
- Explicit boundary pointing to a sibling skill (k8s-deploy).
- Trigger keywords cover the most common terms.

---

## Pair 5: Code Review Skill

**Bad:**

```
description: >
  Use this skill when you want to review code. It reviews code and
  finds bugs. It can also find security issues and performance problems.
  Use it for code review.
```

Problems:
- Starts correctly but immediately becomes circular ("reviews code ... for code review").
- No specificity about what kinds of code, languages, or patterns.
- No trigger keywords beyond "code review".
- No boundaries -- agent cannot distinguish this from a linter or a security scanner.

**Good:**

```
description: >
  Use this skill when performing a pre-merge code review on a pull
  request diff. Analyzes changed files for logic errors, security
  anti-patterns (SQL injection, XSS, hardcoded secrets), performance
  regressions, and style violations against the project's lint config.
  Produces structured findings with severity, file location, and
  suggested fix. Does not replace CI linters -- focuses on semantic
  issues linters miss. Trigger keywords: code review, PR review,
  pull request review, diff review, security review, pre-merge check.
```

Why it works:
- Specific trigger context (pre-merge, pull request diff).
- Lists concrete analysis categories (logic errors, security patterns, performance).
- Describes the output format (structured findings with severity and location).
- Sets a clear boundary (does not replace CI linters).
- Comprehensive trigger keywords.

---

## Summary of Common Mistakes

| Mistake | Fix |
|---------|-----|
| Missing "Use this skill when ..." opener | Always start with this phrase. |
| Vague language ("helps with", "stuff", "things") | Name specific actions and artifacts. |
| Marketing adjectives ("comprehensive", "advanced") | Delete them. Agents do not respond to hype. |
| No trigger keywords | Add 5-10 keywords agents and users would use. |
| No boundaries | State what the skill does NOT do when ambiguity is likely. |
| Circular definitions ("reviews code for code review") | Describe the trigger context and output, not just the action. |
| Excessive length listing every technology | Focus on the top 3-5 most important items. |
| Single word or extremely short description | Write 50-200 words covering all four coverage elements. |
