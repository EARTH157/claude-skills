---
name: lean-context
description: Cut token usage on large-codebase tasks without losing accuracy - targeted search instead of whole-file reads, filtered command output, subagent fan-out for wide sweeps, and cache-friendly habits. Use when the user mentions token cost, budget, context filling up, frequent auto-compaction, a session feeling slow or expensive, or asks the agent to work more cheaply or efficiently. Also apply proactively before any task that will touch many files or generate large tool output.
license: MIT
metadata:
  author: EARTH157
  version: "0.3"
---

# Lean Context

Token cost is dominated by what enters the context window, not by what you write.
Nearly all waste is tool output you did not need. Optimize the input side.
Never buy savings with shorter reasoning or skipped verification.

Tool names differ between agents. This skill names *operations*; use whatever your
harness calls them. Common mappings:

| Operation | Typical tool names |
|---|---|
| content search | `Grep`, `search`, `ripgrep`, `rg` |
| filename search | `Glob`, `find`, `file_search` |
| partial file read | `Read` with offset/limit, `view` with a line range |
| delegated search | subagent / task / `Explore` |

If your harness lacks one, fall back to a shell command that does the same job.

## The rule

**Never read more than you need to answer the question in front of you.**
Every read should survive the sentence: "I need lines X-Y of this file because Z."

## Before starting

1. Estimate blast radius. More than ~5 files, or more than ~200 lines of output? Apply this skill deliberately.
2. Pick the cheapest operation that answers the question (table below).
3. If the sweep is wide and only the conclusion matters, delegate it. See **Fan-out**.

## Cheapest operation for the question

| Question | Cheap | Expensive - avoid |
|---|---|---|
| Does X exist, and where? | content search, filenames only | reading each candidate file |
| What does this function do? | content search on its name, 5 lines of context | reading the whole file |
| What changed? | `git diff --stat`, then diff one path | `git diff` across everything |
| What is in this directory? | filename search with a pattern | `ls -R` or bare `find .` |
| What is the shape of this file? | partial read around a known line | full read of a 2000-line file |
| Which of 40 files follow convention Y? | delegated search | reading all 40 yourself |

## Reading files

- Search first, read second. A search with line numbers and a few lines of context
  frequently answers the question outright.
- Once you know the line number, read a window around it instead of the whole file.
- Do not re-read a file you already read this session unless it changed outside your edits.
- Do not read a file back to "verify" an edit that returned success. Edit failures are loud.

### When a search comes back empty

An empty result is information: your guess at this codebase's vocabulary was wrong.
Do not answer it by reading the whole file, and do not fire off three more guesses.

Probe the file's structure first - one cheap search for the anchors every file has:

```bash
grep -nE '^(import|export|from|func |class |def |const [A-Z])' <file>
```

That returns the file's own vocabulary - what it pulls in, what it hands out - in a few
hundred bytes. Draw your next search term from that, not from memory.

Measured on a 1350-line React component: a wrong search, a structural probe, then a
correct search cost 6.2 KB over three round trips. Reading the file cost 49.6 KB in one.
Guessing wrong and recovering is still eight times cheaper than not searching.

Two probes with no hits means the thing may not be in this file. Widen to the directory
before concluding anything about it.

## Command output

Cap output at the source. A pipe is cheaper than a large result you then ignore.

- `| head -50`, `| tail -50`, or `rg -n <pattern>` instead of dumping.
- Reach for `--stat`, `--name-only`, `-q`, `--quiet` on git and build tools.
- After a test run identifies a failure, re-run only that test, not the suite.
- For genuinely huge output: redirect to a temp file, then search the file.

## Fan-out

When a question requires sweeping many files but you only need the conclusion,
delegate it to a read-only search subagent if your harness has one. The file dumps
land in its context, not yours, and you get back a paragraph.

Worth it when: more than ~10 files to inspect, or the search needs several naming guesses.
Not worth it when: you already know the file, or one search answers it. A subagent starts
cold and re-derives context, which has its own cost.

## Cache-friendly habits

The conversation prefix is usually cached; keeping it stable is free money.

- Batch independent tool calls into a single message - fewer round trips over the same prefix.
- Finish one thread before starting another. Interleaving unrelated tasks bloats the prefix
  that every later turn pays for.
- Do not edit files early in a session that you only needed to read.

## Output hygiene

- Do not echo file contents back to the user. Reference `path:line` instead.
- Do not restate a plan you already stated.
- Do not narrate what you are about to do and then do it. Do it, then report.
- Report changes by intent, not by pasting back the code you just wrote.

## What is NOT a token saving

These are quality regressions wearing an efficiency costume:

- Skipping verification that a change actually works.
- Guessing at an API signature instead of checking it.
- Cutting reasoning short on a genuinely hard problem.
- Truncating output the user explicitly asked to see.
- Declaring a task done while part of the scope is untouched.

If a task genuinely needs a lot of context, spend it and say so.

## Measuring

Diagnose before optimizing: [references/measuring.md](references/measuring.md).
Claude Code has built-in commands for this: [references/claude-code.md](references/claude-code.md).
