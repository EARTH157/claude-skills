# Measuring before optimizing

Do not guess where tokens went. Find the biggest line item, then cut that.
This file is harness-agnostic. For Claude Code's built-in commands see
[claude-code.md](claude-code.md).

## The four line items

Every context window is some mix of these. Each has a different fix.

**1. Tool / MCP definitions.** Loaded up front, on every single turn. A connected MCP
server you are not using in this project can cost thousands of tokens per turn forever.
Fix: disconnect servers this project does not need.

**2. System prompt and always-on instruction files.** `CLAUDE.md`, `AGENTS.md`,
`.cursor/rules`, or the equivalent. Prepended to everything.
Fix: move rarely-needed detail into files referenced by path, loaded on demand.

**3. Skill metadata.** Every installed skill contributes its `name` + `description`
at startup - roughly 100 tokens each. Cheap individually, not free at 50 skills.
Fix: uninstall skills you never trigger.

**4. Conversation messages.** Usually the largest and the most fixable. This is tool
output that was read once and never needed again.
Fix: everything in the main skill body.

## Compaction is a symptom

Frequent auto-compaction is not the problem, it is the alarm. Compaction costs a full
summarization pass and silently loses detail. If it fires often, one of the four items
above is filling the window - find which before changing how you work.

## A rough sense of scale

- A 500-line source file: roughly 5,000-7,000 tokens
- `git diff` on a medium feature branch: easily 10,000+
- `ls -R` on a tree containing `node_modules`: enough to end the session
- A targeted search with 5 lines of context: usually under 500

The ratio between the last two lines is the entire point of this skill.
