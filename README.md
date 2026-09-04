# claude-skills

Personal Agent Skills, written to the [Agent Skills open standard](https://agentskills.io).
Works with any agent that reads `SKILL.md`, not just Claude Code.

| Skill | Purpose |
|---|---|
| `lean-context` | Cut token usage on large-codebase tasks without losing accuracy |
| `pr-description` | Write a bilingual EN/TH PR description, tiered Patch/Minor/Major, and cut the matching release |
| `debug` | Investigate a bug on the cheapest surface that can observe it, then narrow by elimination |
| `commit-message` | Write typed, readable commits that a release can later be assembled from |

## Install

**Claude Code** — this repo is also its own plugin marketplace:

```
/plugin marketplace add EARTH157/claude-skills
/plugin install toolkit@claude-skills
```

Update later with `/plugin marketplace update claude-skills`.

**Other agents** (Cursor, Codex, Gemini CLI, ...) — the spec defines the file format,
not where clients look for skills, so each tool has its own directory. `install.ps1`
junctions those directories to this repo, keeping one source of truth:

```powershell
.\install.ps1 -WhatIf   # preview
.\install.ps1           # link into tools already installed
```

Junctions need no admin rights. Paths are a table at the top of `install.ps1`;
each line links to that tool's docs, since these paths move.

## Layout

```
.claude-plugin/        # Claude Code only; other tools ignore it
skills/<name>/
  SKILL.md             # required: frontmatter + instructions
  references/          # loaded on demand
install.ps1
```

## Adding a skill

1. Create `skills/<name>/SKILL.md`.
2. Required frontmatter: `name` (must match the directory; lowercase, digits, single
   hyphens) and `description` (≤1024 chars).
3. `description` is all an agent sees before loading the skill. State what it does,
   when to use it, and the words a user would actually type.
4. Keep `SKILL.md` under 500 lines; move detail into `references/`.
5. Validate with `npx skills-ref validate ./skills/<name>`.

**Keep it portable.** Name operations, not one harness's tools — write "content search",
not `Grep`. Put tool-specific detail in `references/<tool>.md`, as `lean-context` does
with `claude-code.md`.

## Testing before push

```
/plugin marketplace add /path/to/claude-skills
```

A local marketplace reads from disk, so edits show up in the next session with no commit.
