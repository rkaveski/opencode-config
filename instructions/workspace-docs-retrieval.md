## Workspace Docs Retrieval Policy

Use the `workspace_docs_*` MCP tools first for workspace and project documentation retrieval.

### Topology conventions

Treat workspace docs as:

- `./docs/**` (shared workspace docs)
- `./projects/*/docs/**` (project-local docs)

### Retrieval behavior

- For documentation questions, documentation discovery, and doc-grounded planning or review, default to `workspace_docs_*` before reading local files directly.
- Bypass `workspace_docs_*` only when the user explicitly directs you to inspect a specific local file, folder, or alternate named source.
- Use `workspace_docs_status_docs` when docs context may matter and scope is unclear.
- Use `workspace_docs_search_docs` before reading files directly.
- Use `workspace_docs_get_doc` only after retrieval narrows relevant paths.
- In project context (`./projects/<name>/...`), prioritize that project's docs first, then workspace docs.
- For workspace-wide tasks, prioritize workspace docs and include project docs only when relevant.
- Do not search sibling project docs by default while focused on one project unless explicitly needed.
- Subagents must follow the same docs-first rule.

### Context window discipline

- Do not brute-force read all docs files.
- Retrieve small, relevant passages first.
- Read full source only for the selected files/chunks or when the user explicitly points to a local path.

### Scope and memory separation

- Workspace docs retrieval is separate from personal memory.
- Personal cross-workspace preferences belong in the memory plugin.
- Do not store workspace docs inside personal memory.
