---
name: pr-description
description: Write a bilingual English + Thai pull request description, classified as Patch Note, Minor Update, or Major Update, containing only the sections that actually apply - What's new, Changed, and Bug fix. Use whenever the user wants a PR description, PR body, PR summary, release note, patch note, or changelog entry, including phrasings like "เขียน PR ให้หน่อย", "สรุป PR", "ทำ release note", "เปิด PR", or when they are about to run gh pr create. Also use when updating or rewriting an existing PR description.
license: MIT
metadata:
  author: EARTH157
  version: "1.1"
---

# PR Description

Two decisions, in order: **which tier**, then **which sections**. Get those right and
the writing is mechanical.

## Step 1 - Gather, cheaply

Read the change, not every file:

```bash
git log --oneline <base>..HEAD
git diff --stat <base>..HEAD
```

Read full diffs only for files whose user-visible effect you cannot infer from the
stat line. Commit messages describe intent; the diff confirms it. Trust neither alone.

## Step 2 - Classify the tier

Work top-down and stop at the first match:

| Tier | Match when | Examples |
|---|---|---|
| **Major Update** | Anything breaks, or anyone must do something to keep working | Removed or renamed an API/prop/env var, DB migration, changed default behavior, dropped support |
| **Minor Update** | Something new that is backward compatible | New feature, new page, new option, new endpoint |
| **Patch Note** | Neither of the above | Bug fixes, copy, styling, perf, refactor, dependency bumps |

Deciding rule: **does anyone have to change what they do?** Yes → Major.
No, but there is something new → Minor. Otherwise → Patch Note.

A PR full of bug fixes is a Patch Note no matter how many files it touches.
Size is not the signal; consequence is.

## Step 3 - Pick sections

Three sections exist: **What's new**, **Changed**, **Bug fix**. Route every bullet with
one question - *was the old behavior wrong?*

| The bullet describes | Section |
|---|---|
| Something that did not exist before | `What's new` |
| Something that existed, works differently now, and the old way was not a defect | `Changed` |
| Something that existed, was wrong, and is now correct | `Bug fix` |

Emit any combination - one section, two, or all three. Order is always
`What's new` → `Changed` → `Bug fix`.

**Never emit an empty section, and never write "N/A" or "None".** Omit it.

`Changed` is the section that rots first. It is not a home for refactors, renamed
internals, or dependency bumps. If a user cannot perceive the difference, it still gets
no bullet.

### Breaking changes

Mark them `**Breaking**` and put them in whichever section the change belongs to - usually
`Changed`, since breaking something almost always means altering what already existed.
List `**Breaking**` bullets first within their section, and lead with what the reader
must do:

```
- **Breaking** — `POST /report/export` now requires `format`. Existing callers must pass `format: "csv"`.
```

## Step 4 - Write it

Format:

```markdown
**<Tier>**

## What's new
- ...

## Changed
- ...

## Bug fix
- ...

---

## มีอะไรใหม่
- ...

## ปรับปรุง
- ...

## แก้บั๊ก
- ...
```

English block first: GitHub previews, notifications, and release-note tooling read
from the top. The Thai block is the same content in full, not a summary.

### Content rules

- One bullet per **user-visible change**, not per commit. Squash related commits into one line.
- Lead with the effect, not the file. "Export now includes refunds", not "Updated `exportService.ts`".
- Omit invisible work - refactors, tests, lint, formatting. If the whole PR is invisible,
  say so in one Patch Note line: `- Refactored the report pipeline; no behavior change.`
- Cap each section at ~5 bullets. If it needs more, say so and suggest splitting the PR.
- No preamble, no "This PR ...", no closing summary. Bullets only.
- Keep issue and PR links if the user gave them; do not invent them.

### Bilingual rules

- Both blocks state the **same facts**. Not a loose paraphrase, not a shortened Thai version.
- Translate the meaning, not the words. Thai that reads like machine translation is a defect.
- Keep technical terms in English inside the Thai block - `deploy`, `endpoint`, `cache`,
  `migration`, API names, file paths. That is how Thai developers actually write.
- Tier label and section headings are fixed strings. Do not translate the tier label.

## Do not

- Guess at a change you did not read in the diff.
- Claim a fix works when the PR has no test or verification for it.
- Upgrade the tier to make the PR sound bigger, or downgrade it to avoid a migration note.

Worked examples for all three tiers: [references/examples.md](references/examples.md).
