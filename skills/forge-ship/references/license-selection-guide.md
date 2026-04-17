# LICENSE Selection Guide

Choose a license based on the project's role in the ecosystem.

## Comparison

| Criterion | MIT | Apache 2.0 |
|-----------|-----|------------|
| Best for | Single-purpose plugins, examples, templates, lightweight tools | Protocols, SDKs, reference implementations, cross-vendor components |
| Patent grant | No explicit patent clause | Explicit patent grant with termination clause |
| Ecosystem friction | Lowest -- universally recognized, minimal legal review | Low -- well understood by enterprise legal teams |
| Typical precedent | LangChain, LlamaIndex, CrewAI main repos | Agent Skills standard repos, MCP specification |

## Decision Rule

If the project defines a protocol, implements an SDK, or serves as a cross-vendor foundation, use Apache 2.0 for the patent protection. For everything else, use MIT for minimal friction.

Do not use restrictive or custom licenses on ecosystem infrastructure. Licenses with additional conditions (e.g., non-compete clauses, usage restrictions) create legal review overhead that directly slows ecosystem adoption.
