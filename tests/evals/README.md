# Trigger Evaluation Tests

This directory contains test matrices for evaluating skill trigger accuracy — whether agents activate the correct skill given a natural language query.

## Why This Matters

Structural tests (frontmatter validation, reference file existence) verify that skills are well-formed. Trigger tests verify that skills are **discoverable** — that their `description` fields actually cause agents to select them at the right time.

## Test Matrix Format

`trigger-test-matrix.csv` contains test cases in three columns:

- `query` — Natural language input to the agent
- `expected_skill` — Which forge-* skill should trigger (`none` if no skill should)
- `should_trigger` — `true` if the skill should activate, `false` if it should not

A good test matrix includes:
- 8-10 queries that SHOULD trigger each skill (positive cases)
- 8-10 queries that should NOT trigger any skill (negative cases)
- Edge cases near the boundary between two skills

## How to Use

Currently these test cases are designed for manual evaluation:

1. Start a coding agent session with HarnessForge skills installed
2. Input each query from the matrix
3. Record which skill (if any) the agent activates
4. Compare against the expected result

Automated evaluation requires an agent eval framework (e.g., OpenAI evals, custom trace analysis). This scaffold provides the test cases; automation is a future goal.

## Interpreting Results

- **Precision**: Of all times a skill triggered, how often was it the correct skill?
- **Recall**: Of all times a skill should have triggered, how often did it actually trigger?
- Target both > 80% before publishing a skill.
