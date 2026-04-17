# MCP Servers for This Distro

This distro supports MCP integrations, but it does not assume every developer needs every server.

The intended workflow is:

1. Install the distro with `make install`
2. Choose the MCPs that match your workflow
3. Install or provision those MCP servers first when required
4. Enable them through `~/.config/opencode.local.env`
5. Re-run `make install` to regenerate `opencode.json`

## Recommended Baseline

These are the broadest-value integrations in this distro.

### Atlassian

- Why: useful if you work with Jira or Confluence
- Type: remote MCP
- Prerequisites: valid Atlassian access/auth in OpenCode
- Env flags: none required for the baseline entry
- Notes: included in generated config by default

### Context7

- Why: helps with current package and framework documentation lookup
- Type: local MCP wrapper around an external entrypoint
- Prerequisites:
  - `node` installed
  - a valid Context7 MCP entrypoint available locally
  - `CONTEXT7_API_KEY`
- Env flags:
  - `ENABLE_CONTEXT7=true`
  - `CONTEXT7_MCP_ENTRY=/absolute/path/to/context7-mcp-entry.js`
  - `CONTEXT7_API_KEY=...`
- Notes: install/provision Context7 first, then enable it in this distro

## Optional Integrations

### Sourcebot

- Why: strong repo discovery for multi-repo work, flow tracing, and broad code search
- Type: remote MCP
- Recommended flow:
  - install and run Sourcebot first
  - confirm its MCP endpoint is reachable
  - then enable it in this distro
- Baseline env flags:
  - `ENABLE_SOURCEBOT=true`
  - `SOURCEBOT_MCP_URL=http://localhost:3000/api/mcp`
- Notes:
  - this distro treats Sourcebot as recommended but optional
  - the generic default is a single Sourcebot endpoint named `sourcebot`

### Workspace Docs

- Why: useful when you want local document retrieval from a Python MCP server
- Type: local MCP
- Prerequisites:
  - `python3`
  - the `workspace_docs_mcp.server` module installed in that Python environment
- Env flags:
  - `ENABLE_WORKSPACE_DOCS=true`
  - `WORKSPACE_DOCS_PYTHON=/absolute/path/to/python3` if needed
  - `WORKSPACE_DOCS_MODULE=workspace_docs_mcp.server`
  - `WORKSPACE_DOCS_ENABLE_IMAGE_OCR=true` if you want OCR support
- Notes: the distro only launches the module; it does not install the Python package for you

### Chrome DevTools

- Why: browser inspection and debugging against a Chrome DevTools MCP endpoint
- Type: local MCP launched with `npx`
- Prerequisites:
  - Chrome/Chromium running with a reachable remote debugging port
  - `npx` available
- Env flags:
  - `ENABLE_CHROME_DEVTOOLS=true`
  - `CHROME_DEVTOOLS_BROWSER_URL=http://127.0.0.1:9222`
- Notes: this distro can launch the MCP command, but the browser debug target must already be available

### Figma

- Why: useful for teams that work directly from Figma context
- Type: remote MCP
- Prerequisites: valid Figma access/auth in OpenCode
- Env flags:
  - `ENABLE_FIGMA=true`
- Notes: not everyone needs this, so it stays optional

## Advanced / Personalized Integrations

### Secondary Sourcebot Endpoint

Use this only if you intentionally run more than one Sourcebot MCP endpoint.

- Type: remote MCP
- Env flags:
  - `ENABLE_SOURCEBOT_SECONDARY=true`
  - `SOURCEBOT_SECONDARY_MCP_URL=http://localhost:3001/api/mcp`
- Result:
  - primary endpoint is exposed as `sourcebot`
  - secondary endpoint is exposed as `sourcebot-secondary`
- Notes: this exists for advanced or personalized setups; most users should keep a single Sourcebot endpoint

## Quick Reference

| MCP | Category | Needs external setup first | Main env flags |
| --- | --- | --- | --- |
| Atlassian | Recommended baseline | Yes | none |
| Context7 | Recommended baseline | Yes | `ENABLE_CONTEXT7`, `CONTEXT7_MCP_ENTRY`, `CONTEXT7_API_KEY` |
| Sourcebot | Optional | Yes | `ENABLE_SOURCEBOT`, `SOURCEBOT_MCP_URL` |
| Workspace Docs | Optional | Yes | `ENABLE_WORKSPACE_DOCS`, `WORKSPACE_DOCS_PYTHON`, `WORKSPACE_DOCS_MODULE` |
| Chrome DevTools | Optional | Yes | `ENABLE_CHROME_DEVTOOLS`, `CHROME_DEVTOOLS_BROWSER_URL` |
| Figma | Optional | Yes | `ENABLE_FIGMA` |
| Sourcebot secondary | Advanced | Yes | `ENABLE_SOURCEBOT_SECONDARY`, `SOURCEBOT_SECONDARY_MCP_URL` |

## Regenerating Config

After changing any MCP-related env flag in `~/.config/opencode.local.env`, run:

```bash
make install
```

That re-renders `~/.config/opencode/opencode.json` with the MCP entries you enabled.
