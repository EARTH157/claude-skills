# Claude Code specifics

Applies only inside Claude Code. Other harnesses should ignore this file and map the
surfaces onto whatever they provide.

## Surfaces to tools

| Surface | Tool |
|---|---|
| 1 Read only | `Grep` / `Read` with `offset`+`limit` |
| 2 One-shot command | `Bash` |
| 3 Instrumented re-run | `Edit` to add logging, then `Bash` |
| 4 Long-running process | `Bash` with `run_in_background`, or `Monitor` |
| 5 Live UI | the browser tools - navigate, `read_page`, `read_console_messages`, `read_network_requests` |
| 6 Isolated repro | a file in the scratchpad directory, run with `Bash` |

## Choosing between background Bash and Monitor

They answer different questions.

- **`Bash` with `run_in_background`** - one notification when the command exits. Use it
  for "tell me when the build finishes" or "wait until the server is up". Give it a
  command that terminates, such as an `until` loop that ends once the condition holds.
- **`Monitor`** - one notification per matching line, for as long as it runs. Use it for
  "tell me every time an ERROR appears". A `tail -f` or `while true` never exits, so it
  belongs here and not in a background Bash call.

Picking the wrong one is the common mistake: an unbounded `tail -f` in background Bash
stays armed until timeout long after the event you wanted has passed.

## Filtering that actually flushes

Every stage of a pipe must flush per line or matches sit in a buffer unseen:

```bash
tail -f dev.log | grep -E --line-buffered "ready|Error|Traceback|FAILED|Killed|OOM"
```

- `grep` needs `--line-buffered`; `awk` needs `fflush()`.
- `head` cannot flush at all - `| head -5` delivers nothing until five matches exist.
- Only stdout becomes an event. Merge stderr with `2>&1` when watching a command you
  run yourself, or its crash never reaches your filter.

## Browser surface notes

- `read_page` and `get_page_text` beat screenshots for checking text and structure, and
  cost far less.
- `read_console_messages` with `onlyErrors: true` is usually the first thing to check on
  a UI bug, before any screenshot.
- `resize_window` with the mobile preset reproduces layout bugs that only appear on a
  phone. Reload after switching so load-time device checks re-run.
