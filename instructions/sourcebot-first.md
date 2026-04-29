## Sourcebot-First Research

- For multi-repo work, flow tracing, and broad discovery, use Sourcebot MCP tools first, specifically tools matching `sourcebot-*_*`.
- Use local file tools for quick targeted reads and edits once the relevant targets are known.
- Prefer Sourcebot over broad local `grep`, `glob`, directory walking, or generic web search for those discovery-heavy tasks.
- Explicitly say `Using Sourcebot:` when Sourcebot is used so the Docker-backed path can be verified.
- Subagents must follow the same Sourcebot-first rule.

## Engineering Principles Baseline

- Prefer `KISS` and `DRY` by default.
- Favor low coupling and high cohesion.
- Avoid raw string literals for domain values, keys, states, event names, commands, discriminants, feature flags, routes, and comparison operands when a shared typed identifier is practical.
- Prefer enums, centralized constants, literal-union types, and shared interfaces or types over ad hoc duplicated string values.
- Prefer comparing shared identifiers to shared identifiers rather than raw string-to-string comparisons.
- Keep this rule pragmatic: user-facing copy, logs, diagnostics, tests where literals improve clarity, one-off integration boundaries, and protocol or third-party wire values may stay literal, but repeated boundary values should be centralized once reused.
- Avoid unnecessary abstractions and pattern-heavy designs.
- Apply `SOLID` and GoF patterns when they reduce complexity and improve maintainability; do not force them by default.
- Include Big-O reasoning only when algorithm or data-structure choice materially affects performance.
