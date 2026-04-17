---
description: Reconcile workspace docs index and report status.
---

Refresh the workspace docs index now.

Steps:
1. Call `workspace_docs_refresh_docs` with default args.
2. Call `workspace_docs_status_docs`.
3. Return a concise summary of added/changed/deleted files and current index health.
