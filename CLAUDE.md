# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of Agent Skills written to the [Agent Skills open standard](https://agentskills.io).
There is no application code, no build step, and no test suite — the deliverable is the
prose inside each `SKILL.md`.

## Commands

```bash
npx skills-ref validate ./skills/<name>    # validate one skill against the spec
```

```powershell
.\install.ps1 -WhatIf    # preview cross-agent linking
.\install.ps1            # junction skills/ into other agents' skills directories
```

To try a change without committing, add this repo as a local marketplace. It reads from
disk, so the next session picks up edits with no commit and no reinstall:

```
/plugin marketplace add /path/to/claude-skills
```

## Two distribution paths, one source

`skills/` is the single source of truth. It reaches agents two different ways, and both
must keep working:

- **Claude Code** loads it as a plugin through `.claude-plugin/marketplace.json` — this
  repo is its own marketplace, with `source: "./"`.
- **Every other agent** gets it through `install.ps1`, which creates directory junctions
  from each tool's own skills directory into `skills/`.

`.claude-plugin/` is invisible to non-Claude tools, so it costs them nothing. The
consequence that matters: any edit under `skills/` ships down both paths at once.

The path table in `install.ps1` is only confirmed for `.claude/skills`. The rest came
from third-party write-ups, so each entry carries a docs link — verify before trusting one.

## Naming is load-bearing

Three names appear in commands users type. Renaming any of them breaks existing installs,
so treat a rename as a breaking change.

| Name | Defined in | What breaks |
|---|---|---|
| marketplace `name` | `.claude-plugin/marketplace.json` | `/plugin marketplace update <name>` |
| plugin `name` | `.claude-plugin/plugin.json` | `/plugin install <plugin>@<marketplace>` |
| skill `name` | `skills/<dir>/SKILL.md` | must equal its directory name — spec requirement |

## Writing a skill

- `description` is the **only** text an agent sees before deciding whether to load the
  skill. State what it does, when to use it, and the words a user would actually type —
  including Thai phrasings, since this user works in Thai.
- Keep `SKILL.md` under 500 lines. Detail belongs in `references/`, loaded only on demand.
- **Stay harness-agnostic.** Name operations ("content search"), not one tool's API
  (`Grep`). Tool-specific material goes in `references/<tool>.md`, the way `lean-context`
  splits out `claude-code.md`.
- `SKILL.md` is written in English on purpose: it is model-facing instruction, and it
  costs roughly half the tokens of equivalent Thai. User-facing docs stay in Thai.
- Two skills must never compete for the same trigger. Before adding one, check that its
  `description` does not overlap an existing skill's.
