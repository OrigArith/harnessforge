# Description Trigger Testing Protocol

This reference provides the detailed methodology for testing skill description trigger accuracy.

## Overview

Treat the `description` field as a binary classifier. It reads a user query and decides: activate (positive) or skip (negative). Like any classifier, it has precision and recall, and both can be measured and optimized.

## Step 1: Define the Positive and Negative Sets

### Positive Set (10 queries)

Construct queries that should trigger the skill. Cover these dimensions:
1. **Direct phrasing**: The most obvious way to request this skill's capability.
2. **Synonym substitution**: Replace key terms with synonyms (e.g., "build" -> "create", "check" -> "audit").
3. **Contextual phrasing**: Embed the request in a larger sentence ("While working on the API, I need to migrate the endpoints").
4. **Abbreviated phrasing**: Minimal queries ("migrate API", "version upgrade").
5. **Cross-language**: If the skill targets multilingual users, include queries in other languages.

### Negative Set (10 queries)

Construct queries that should NOT trigger the skill. Cover these dimensions:
1. **Adjacent skills**: Queries that target a closely related but different skill.
2. **Partial overlap**: Queries that share keywords but differ in intent.
3. **Superset/subset**: Queries that are broader or narrower than the skill's scope.
4. **Misleading keywords**: Queries that contain trigger keywords but in a different context.
5. **Unrelated**: A few clearly out-of-scope queries as sanity checks.

## Step 2: Run the Matrix

For each query, record:
- Query text
- Expected result (trigger / no trigger)
- Actual result (trigger / no trigger)
- Notes (if the result was unexpected, why?)

## Step 3: Calculate Metrics

| Metric | Formula | Target |
|--------|---------|--------|
| Precision | TP / (TP + FP) | >= 0.8 |
| Recall | TP / (TP + FN) | >= 0.8 |
| F1 Score | 2 * P * R / (P + R) | >= 0.8 |

Where:
- TP = correct trigger (positive query, skill activated)
- FP = false trigger (negative query, skill activated)
- FN = missed trigger (positive query, skill did NOT activate)
- TN = correct skip (negative query, skill did NOT activate)

## Step 4: Diagnose and Iterate

| Problem | Symptom | Fix |
|---------|---------|-----|
| Too broad | Low precision, many FP | Add "when NOT to use" boundaries; narrow trigger keywords |
| Too narrow | Low recall, many FN | Add synonyms, variant phrasings, cross-language keywords |
| Confused with adjacent skill | FP from adjacent skill queries | Add explicit boundary ("Does NOT handle X") |
| Keyword collision | FP from unrelated queries sharing keywords | Use phrase-level triggers instead of single keywords |

## Step 5: Document Results

Record the final test matrix and metrics alongside the SKILL.md as evidence of description quality. Include the test matrix in a comment block or a separate `tests/trigger-test-matrix.md` file.

## Tips

- Re-run the test matrix after every description edit, not just the first time.
- If using Claude Code, the skill list in the system-reminder shows which skills were considered. Check if your skill appears.
- Description + `when_to_use` combined budget is 1,536 characters in Claude Code. Use both fields to maximize coverage without exceeding the limit.
- Split the 20 queries into a train set (first 14) and validation set (last 6) to detect overfitting to specific phrasings.
