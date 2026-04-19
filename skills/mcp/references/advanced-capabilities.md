# MCP Advanced Capabilities

Three capabilities introduced in MCP protocol version 2025-11-25 that extend the server-client interaction model beyond simple tool execution. Each capability requires explicit declaration and client support negotiation.

## Sampling (Server → Client LLM Request)

Sampling allows an MCP server to request the client to perform LLM inference on its behalf. The server sends a prompt; the client runs it through its configured model and returns the result.

### When to Use

- Server needs LLM reasoning but does not have direct model access
- Generating summaries, classifications, or natural language responses as part of a tool's execution
- Multi-step workflows where intermediate LLM calls refine the final output

### Capability Declaration

Server declares support in `initialize` response:

```json
{
  "capabilities": {
    "sampling": {}
  }
}
```

Client must also declare `sampling` support in its `initialize` request for this to work.

### Request Flow

1. Server sends `sampling/createMessage` to client
2. Client presents the request to its LLM (may include human-in-the-loop approval)
3. Client returns the model response to server

```json
{
  "method": "sampling/createMessage",
  "params": {
    "messages": [
      { "role": "user", "content": { "type": "text", "text": "Summarize this data: ..." } }
    ],
    "maxTokens": 500
  }
}
```

### Security Considerations

- The client controls which model is used and may reject or modify the request
- Servers must not assume the client will execute sampling requests without user approval
- Never pass user credentials or sensitive data through sampling prompts — the prompt content may be logged by the client
- Treat sampling responses as untrusted input (the model may hallucinate or be manipulated)

## Elicitation (Server → User Input Request)

Elicitation allows an MCP server to request additional input from the user through the client's UI. Unlike sampling (which asks the LLM), elicitation asks the human.

### When to Use

- Server needs a value that only the user can provide (API key, preference, confirmation)
- Multi-step workflows where user decisions determine the next action
- Gathering configuration that should not be hardcoded

### Capability Declaration

```json
{
  "capabilities": {
    "elicitation": {}
  }
}
```

### Request Flow

1. Server sends `elicitation/create` to client
2. Client presents a UI prompt to the user
3. User responds; client forwards the response to server

```json
{
  "method": "elicitation/create",
  "params": {
    "message": "Which database should I connect to?",
    "requestedSchema": {
      "type": "object",
      "properties": {
        "database": {
          "type": "string",
          "enum": ["production", "staging", "development"],
          "description": "Target database environment"
        }
      },
      "required": ["database"]
    }
  }
}
```

### Security Considerations

- Elicitation requests are visible to the user — never use them to exfiltrate data through the UI
- Clients may refuse elicitation requests or show them in a sandboxed context
- Validate elicitation responses against the declared schema before using them
- Do not use elicitation as a substitute for proper authentication flows

## Tasks (Async Long-Running Operations)

Tasks provide a protocol-level mechanism for tracking long-running operations. Instead of blocking the client during a lengthy tool execution, the server returns a task handle that the client can poll or receive updates for.

### When to Use

- Tool execution takes more than a few seconds (builds, deployments, data processing)
- User should see progress updates during execution
- Operation can be cancelled by the user

### Capability Declaration

```json
{
  "capabilities": {
    "tasks": {}
  }
}
```

### Lifecycle

1. Tool handler returns a task ID instead of a final result
2. Client polls via `tasks/get` or subscribes via `tasks/subscribe`
3. Server sends progress notifications: `tasks/progress`
4. Server sends final result: `tasks/complete` or `tasks/error`

Task states: `pending` → `running` → `completed` | `failed` | `cancelled`

### Progress Notifications

```json
{
  "method": "notifications/tasks/progress",
  "params": {
    "taskId": "build-123",
    "progress": 0.65,
    "message": "Compiling TypeScript (65%)..."
  }
}
```

### Security Considerations

- Task IDs must be unpredictable (UUIDs, not sequential integers)
- Implement timeouts — tasks should not run indefinitely
- Cancelled tasks must clean up resources (temp files, connections, processes)
- Task results may be cached — ensure sensitive data is not persisted in task state

## Client Support Matrix

Not all clients support all capabilities. Negotiate during `initialize`:

| Capability | Claude Code | Codex | OpenCode |
|-----------|------------|-------|----------|
| Sampling | Supported | Varies | Varies |
| Elicitation | Supported | Limited | Varies |
| Tasks | Supported | Varies | Varies |

Always check the client's `initialize` response before using these capabilities. If the client does not declare support, fall back to synchronous execution and direct tool responses.

## Implementation Pattern

```typescript
const server = new McpServer({
  name: "my-server",
  version: "1.0.0",
  capabilities: {
    sampling: {},
    elicitation: {},
    tasks: {}
  }
});

server.tool("long-build", { project: z.string() }, async (params, { sampling, elicitation, tasks }) => {
  // Check client support before using advanced features
  if (tasks) {
    return tasks.create(async (task) => {
      task.progress(0.1, "Starting build...");
      // ... long operation
      task.progress(0.9, "Almost done...");
      return { status: "success" };
    });
  }
  // Fallback: synchronous execution
  return { content: [{ type: "text", text: "Build complete" }] };
});
```
