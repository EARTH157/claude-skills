# Measuring before optimizing

Do not guess where tokens went. Check, then cut the biggest line item.

## In an interactive Claude Code terminal

| Command | Shows |
|---|---|
| `/context` | Current context window breakdown: system prompt, tools, MCP servers, files, messages |
| `/cost` | Token and cost totals for the session |
| `/usage` | Plan usage against limits |

`/context` is the one that matters for this skill - it tells you whether the weight is
in tool definitions (fix: disable unused MCP servers), in the system prompt
(fix: trim CLAUDE.md), or in the conversation itself (fix: everything in SKILL.md).

## Common findings and their fixes

**Tool definitions are huge.** Connected MCP servers load every tool schema up front.
Disable servers you are not using in this project. Each unused server can cost
thousands of tokens on every single turn.

**CLAUDE.md is huge.** It is prepended to every session. Move rarely-needed detail into
files that Claude reads on demand and reference them by path instead of inlining them.

**Messages dominate.** This is the case the skill body addresses: tool output that was
read once and never needed again. Grep harder, Read narrower, pipe through `head`.

**Auto-compaction fires often.** Compaction is not free - it costs a full summarization
pass and loses detail. Frequent compaction is a symptom, not the problem. Find the
line item above that is filling the window.

## A rough sense of scale

- A 500-line source file: roughly 5,000-7,000 tokens
- `git diff` on a medium feature branch: easily 10,000+ tokens
- `ls -R` on a `node_modules`-containing tree: enough to end the session
- A targeted `Grep -n -C 5`: usually under 500 tokens

The ratio between the last two lines is the whole point of this skill.
