---
name: debug
description: Investigate a bug by first picking the cheapest surface that can actually observe the failure - reading alone, a one-shot command, an instrumented re-run, a long-running process watched in the background, a live UI, or a minimal isolated repro - then narrowing by one hypothesis per experiment. Use when the user reports something broken, failing, crashing, hanging, erroring, or behaving unexpectedly, including phrasings like "แก้บั๊กให้หน่อย", "ทำไมมันไม่ทำงาน", "หาสาเหตุ", "it crashes", "this test fails", and when a stack trace or error message is pasted in.
license: MIT
metadata:
  author: EARTH157
  version: "1.0"
---

# Debug

Most wasted debugging effort goes to the wrong surface: theorising about a failure one
command would have shown, or staring at a static file at a bug that only exists while
the system is running.

Pick the surface first. Then narrow.

## Step 1 - Say what you need to see

Before choosing anything, finish this sentence:

> I will know the cause when I see ___.

If you cannot finish it, you have a guess, not a hypothesis. Read the error and the code
around it until you can. A surface chosen without this sentence is chosen at random.

## Step 2 - Pick the cheapest surface that can show it

Work down the list. Stop at the first surface that can actually observe your sentence.

| # | Surface | Use when |
|---|---|---|
| 1 | Read only | The failure is visible in the code or the diff - wrong operator, off-by-one, typo, obvious contract mismatch |
| 2 | One-shot command | Something already reproduces it: a failing test, a build error, a CLI invocation |
| 3 | Instrumented re-run | You need a value the program does not print. Add logging, run it again |
| 4 | Long-running process, watched in the background | The failure needs the system up: server, watcher, queue, reconnect, anything timing- or state-dependent |
| 5 | Live UI | Rendering, layout, client state - anything only a browser shows |
| 6 | Minimal isolated repro | The real system is too noisy, or you must prove which layer owns the bug |

Two rules about that table:

- **Never escalate without a reason you can state out loud.** Starting a dev server to
  diagnose a typecheck error is pure waste.
- **Never stay too low either.** A race, a leak, or a reconnect bug will not resolve at
  surface 1 or 2 however long you look. If two experiments at the current surface taught
  you nothing new, escalate.

Complexity is not the size of the codebase. It is whether the failure needs *state* or
*time* to appear. A one-line bug in a 200k-line repo is still surface 1. A five-line
bug that only shows after two reconnects is surface 4.

### On the background surface

A process you have to watch belongs in the background, never in a blocking call that
holds up everything else. Start it, filter its output down to the lines that would
change your mind, and keep working while it runs.

Filter for the **failure** signatures too, not only the success line. A watcher grepping
only for `ready` stays silent through a crash loop - and silence looks exactly like
"still starting". If you cannot list the failure signatures, widen the pattern rather
than narrow it.

## Step 3 - One hypothesis, one experiment

- Change one thing per run. Two changes and a green result tells you nothing about which
  one mattered.
- After each run, state what it rules **out**. Debugging converges by elimination, not by
  accumulating theories.
- The error's location is not the bug's location. A null at line 40 is usually a contract
  broken at line 12.
- If three experiments have not narrowed it, your model of the system is wrong. Stop
  experimenting, read the path end to end, or ask.

## Step 4 - Prove it, then clean up

- **Reproduce, fix, reproduce again.** A fix you never watched fail is not verified.
- Say which of those you actually did. "This should fix it" is a hypothesis reported as
  a result.
- Strip the instrumentation: added logging, hardcoded values, disabled checks, a test
  narrowed to one case.
- If the root cause sits outside the current scope, report it. Do not quietly patch the
  symptom.

## Reading the evidence

Logs and traces are tool output, and tool output is where a context window goes to die.
Filter at the source instead of pasting a whole run:

- Search the log for the failure signature rather than dumping it.
- Read the top and the bottom of a stack trace first. The middle is usually framework.
- Cap every tail and follow, so a firehose cannot flood the session.

The `lean-context` skill covers the general rule.

## Do not

- Propose a fix for a failure you have not observed.
- "Fix" a flaky failure by re-running until it passes.
- Change unrelated code while you happen to be in the file.
- Call a bug fixed on the strength of a passing typecheck alone.
