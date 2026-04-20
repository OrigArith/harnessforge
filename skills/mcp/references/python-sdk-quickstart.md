# Python MCP SDK Quickstart

This reference covers the `mcp` Python package (install via `pip install mcp[cli]` or `uv add mcp[cli]`). Use when building an MCP server in Python.

---

## Minimal Server Skeleton

```python
from mcp.server.fastmcp import FastMCP

app = FastMCP("my-server")

@app.tool()
async def search_items(query: str, limit: int = 10) -> str:
    """Search for items by keyword. Use when the user wants to find specific items.
    Do NOT use for listing all items without filters."""
    results = await do_search(query, limit)
    return json.dumps(results)

if __name__ == "__main__":
    app.run(transport="stdio")
```

**Key points:**
- `FastMCP` is the high-level API — handles JSON-RPC framing, capability negotiation, and tool registration.
- `@app.tool()` registers a function as an MCP tool. The function name becomes the tool name.
- Type hints on parameters auto-generate `inputSchema`. Use `str`, `int`, `bool`, `list[str]`, `Optional[str]`, etc.
- The docstring becomes the tool `description` — write it to the tool description standard (what/when/when NOT/side effects).
- Return a string for `TextContent`, or return a list of content blocks for multi-part responses.

---

## Adding Annotations

```python
from mcp.server.fastmcp import FastMCP
from mcp.types import Annotations

app = FastMCP("my-server")

@app.tool(annotations=Annotations(
    readOnlyHint=True,
    destructiveHint=False,
    idempotentHint=True,
    openWorldHint=True,
))
async def get_user(user_id: str) -> str:
    """Get user profile by ID. Read-only, no side effects."""
    ...
```

---

## Returning Structured Errors

```python
from mcp.types import TextContent, CallToolResult

@app.tool()
async def create_item(name: str) -> CallToolResult:
    if not name.strip():
        return CallToolResult(
            content=[TextContent(
                type="text",
                text="INVALID_INPUT: Parameter 'name' cannot be empty. "
                     "Provide a non-blank string. Recoverable — retry with a valid name."
            )],
            isError=True,
        )
    item = await db.create(name)
    return CallToolResult(
        content=[TextContent(type="text", text=json.dumps({"id": item.id, "name": item.name}))],
        isError=False,
    )
```

**Note**: When you return `CallToolResult` directly, you have full control over `isError`, `content`, and `structuredContent`. When you return a plain string, FastMCP wraps it in a successful `TextContent` response automatically.

---

## outputSchema Caveat (Claude Code)

As of 2026-04, the Python `mcp` SDK's `FastMCP` does not automatically generate `structuredContent` from return values. If you manually declare `outputSchema` on a tool, Claude Code will expect `structuredContent` in the response and reject plain `TextContent`.

**Recommended approach for Python servers targeting Claude Code:**
- Omit `outputSchema` declaration.
- Return well-structured JSON strings in `TextContent` — agents can still parse them.
- When the SDK adds native `structuredContent` support, re-enable `outputSchema`.

---

## Resources and Prompts

```python
@app.resource("config://app")
async def get_config() -> str:
    """Application configuration."""
    return json.dumps(config_dict)

@app.prompt()
async def summarize_repo(repo_path: str) -> str:
    """Summarize the structure and purpose of a repository."""
    return f"Analyze the repository at {repo_path} and provide a summary..."
```

---

## Running and Testing

```bash
# Run the server (stdio mode, for local/IDE use)
python -m my_server

# Test with MCP Inspector
npx @modelcontextprotocol/inspector python -m my_server

# Install as editable for development
pip install -e .
```

## .mcp.json Configuration

```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["-m", "my_server"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

---

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Writing to stdout | Server hangs or garbles JSON-RPC | Use `stderr` for all logging; never `print()` |
| Declaring `outputSchema` without `structuredContent` | Claude Code rejects response | Omit `outputSchema` until SDK supports it |
| Sync function with `@app.tool()` | Blocks event loop, timeouts | Always use `async def` |
| Missing type hints | Empty `inputSchema` generated | Add type hints to all parameters |
| `hatchling` on Python 3.13 | Build fails with AttributeError | Use `setuptools` backend or update hatchling |
