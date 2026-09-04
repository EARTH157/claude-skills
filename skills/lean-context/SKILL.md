---
name: lean-context
description: Cut token usage on large-codebase tasks without losing accuracy - targeted search instead of whole-file reads, filtered command output, subagent fan-out for wide sweeps, and cache-friendly habits. Use when the user mentions token cost, budget, context filling up, frequent auto-compaction, a session feeling slow or expensive, or asks Claude to work more cheaply or efficiently. Also apply proactively before any task that will touch many files or generate large tool output.
---

# Lean Context

Token cost is dominated by what enters the context window, not by what you write.
Nearly all waste is tool output you did not need. Optimize the input side.
Never buy savings with shorter reasoning or skipped verification.

## The rule

**Never read more than you need to answer the question in front of you.**
Every read should survive the sentence: "I need lines X-Y of this file because Z."

## Before starting

1. Estimate blast radius. More than ~5 files, or more than ~200 lines of output? Apply this skill deliberately.
2. Pick the cheapest tool that answers the question (table below).
3. If the sweep is wide and only the conclusion matters, delegate it. See **Fan-out**.

## Cheapest tool for the question

| Question | Cheap | Expensive - avoid |
|---|---|---|
| Does X exist, and where? | `Grep` with `files_with_matches` | reading each candidate file |
| What does this function do? | `Grep -n -C 5` on its name | `Read` on the whole file |
| What changed? | `git diff --stat`, then diff one path | `git diff` across everything |
| What is in this directory? | `Glob` with a pattern | `ls -R` or bare `find .` |
| What is the shape of this file? | `Read` with `offset` / `limit` | full `Read` of a 2000-line file |
| Which of 40 files follow convention Y? | `Explore` subagent | reading all 40 yourself |

## Reading files

- Grep first, Read second. `Grep -n -C 5` frequently answers the question outright.
- Once you know the line number, `Read` with `offset`/`limit` instead of the whole file.
- Do not re-read a file you already read this session unless it changed outside your edits.
- Do not read a file back to "verify" an `Edit` that returned success. Edit failures are loud.

## Command output

Cap output at the source. A pipe is cheaper than a large result you then ignore.

- `| head -50`, `| tail -50`, or `rg -n <pattern>` instead of dumping.
- Reach for `--stat`, `--name-only`, `-q`, `--quiet` on git and build tools.
- After a test run identifies a failure, re-run only that test, not the suite.
- For genuinely huge output: redirect to a scratchpad file, then grep the file.

## Fan-out

When a question requires sweeping many files but you only need the conclusion,
spawn a read-only search subagent. The file dumps land in its context, not yours,
and you get back a paragraph.

Worth it when: more than ~10 files to inspect, or the search needs several naming guesses.
Not worth it when: you already know the file, or one Grep answers it. A subagent starts
cold and re-derives context, which has its own cost.

## Cache-friendly habits

The conversation prefix is cached; keeping it stable is free money.

- Batch independent tool calls into a single message - fewer round trips over the same prefix.
- Finish one thread before starting another; interleaving unrelated tasks bloats the prefix
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

To find out where tokens actually went before optimizing, see
[references/measuring.md](references/measuring.md).
