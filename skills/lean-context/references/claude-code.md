# Claude Code specifics

Applies only when running inside Claude Code. Other harnesses should ignore this file.

## Diagnostic commands

Available in an interactive Claude Code terminal:

| Command | Shows |
|---|---|
| `/context` | Context window breakdown: system prompt, tools, MCP servers, files, messages |
| `/cost` | Token and cost totals for the session |
| `/usage` | Plan usage against limits |

`/context` is the one that matters here. It tells you which of the four line items in
[measuring.md](measuring.md) is actually heavy, so you fix the right thing.

## Tool mapping

| Operation in the skill body | Claude Code tool |
|---|---|
| content search | `Grep` - use `output_mode: "content"` with `-n` and `-C 5`, or `files_with_matches` |
| filename search | `Glob` |
| partial file read | `Read` with `offset` and `limit` |
| delegated search | `Explore` subagent via the `Agent` tool |

Notes specific to these tools:

- `Grep` defaults to `files_with_matches`, which is the cheapest mode. Reach for
  `content` only once you know you need the lines.
- `Read` reports 2000 lines by default. On a large file, always pass `offset`/`limit`.
- `Edit` and `Write` error loudly on failure, and the harness tracks file state. A
  verification `Read` after a successful edit is pure waste.
- Batch independent tool calls into one assistant message. The harness runs them in
  parallel and you pay the cached prefix once.

## Trimming the always-on cost

- Unused MCP servers are the most common large win. Their tool schemas load every turn.
- `CLAUDE.md` is prepended to every session. Keep it short and point to files instead
  of inlining their contents.
