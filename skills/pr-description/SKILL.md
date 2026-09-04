---
name: pr-description
description: Write a bilingual English + Thai pull request description, classified as Patch Note, Minor Update, or Major Update, containing only the sections that actually apply - What's new, Changed, and Bug fix. Use whenever the user wants a PR description, PR body, PR summary, release note, patch note, or changelog entry, including phrasings like "เขียน PR ให้หน่อย", "สรุป PR", "ทำ release note", "เปิด PR", or when they are about to run gh pr create. Also covers cutting the matching GitHub release, deriving the version bump from the tier. Use it when they ask to create a release, tag a version, or say "สร้าง release" or "ออกเวอร์ชันใหม่", and when updating or rewriting an existing PR description.
license: MIT
metadata:
  author: EARTH157
  version: "1.5"
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

**If the commits carry Conventional Commits types, they have already done most of this
work.** `feat:`, `fix:` and a `!` or `BREAKING CHANGE:` footer give you the section and
the tier without opening a single diff - which is the whole point of committing as you
go and deciding about the release later. Read the log first, and fall back to diffs only
for commits with no type, or where the subject line is too vague to place. See the
`commit-message` skill for the mapping.

## Step 2 - Classify the tier

Work top-down and stop at the first match:

| Tier | Match when | Examples |
|---|---|---|
| **Major Update** | Anything breaks, or anyone must do something to keep working | Removed or renamed an API/prop/env var, DB migration, changed default behavior, dropped support |
| **Minor Update** | Something new that is backward compatible | New feature, new page, new option, new endpoint |
| **Patch Note** | Neither of the above | Bug fixes, copy, styling, perf, refactor, dependency bumps |

Deciding rule: **does anyone have to change what they do?** Yes → Major.
No, but there is something new → Minor. Otherwise → Patch Note.

With typed commits this is arithmetic, not judgement: any `!` or `BREAKING CHANGE:` in
the range → Major. Otherwise any `feat:` → Minor. Otherwise → Patch Note. Verify the
result against the diff before trusting it - a mistyped commit is common, and a `feat:`
that only touched tests is not a Minor Update.

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

## Step 5 - Cut the release (only when asked)

A release publishes a tag and notes that other people and tooling will fetch, and a
pulled tag is awkward to undo. **Never create one unprompted.** Do it only when the user
asks, and only after showing them the version number and the body you intend to publish.

### The tier already chose the bump

| Tier | Bump | `1.4.2` becomes |
|---|---|---|
| Patch Note | patch | `1.4.3` |
| Minor Update | minor | `1.5.0` |
| Major Update | major | `2.0.0` |

**Below 1.0, shift every bump down one place**: a Major Update takes `0.4.2` to `0.5.0`,
a Minor Update takes it to `0.4.3`. This keeps a pre-1.0 project from spending its minor
numbers before the API is stable. Moving to `1.0.0` is the user's decision, never one you
infer from the diff.

**Propose the computed version, do not announce it.** If the user names a different one,
use theirs without arguing - state once what the rule would have given, then carry on.
The next release computes from whatever was actually published, not from what the rule
would have produced.

Read the current version, do not assume it:

```bash
gh release list --limit 1
git tag --sort=-v:refname | head -1
```

Match the existing tag format exactly - if the repo tags `1.4.2`, do not switch to
`v1.4.2`. If there are no tags at all, ask what the first version should be.

### Bump the manifest first

A tag points at a commit. If the version manifest still says the old number when the tag
is cut, the released commit contradicts its own release - and fixing that means moving a
tag other people have already fetched. Bump, commit, and push **before**
`gh release create`.

Find the manifest the repo actually uses. Never create one that does not exist:

| Ecosystem | File | Field |
|---|---|---|
| Node | `package.json` | `version` |
| Python | `pyproject.toml` | `project.version` |
| Rust | `Cargo.toml` | `package.version` |
| Claude Code plugin | `.claude-plugin/plugin.json` | `version` |
| Go | none - the tag *is* the version | skip this step |

Rules:

- Write the bare version, no `v` prefix. The `v` belongs to the tag, not the manifest.
- If several files declare a version, bump them all in one commit. If they disagree with
  each other before you start, stop and say so - that is a pre-existing bug, not yours to
  silently resolve.
- Never hand-edit a lockfile. Use the ecosystem's own command when there is one
  (`npm version <x> --no-git-tag-version`, `cargo set-version <x>`).
- Commit the bump on its own, message `Release v<x>`, and push it.

Then confirm the tag landed on the bumped commit:

```bash
git show <tag>:<manifest> | grep -i version
```

### Create it

Write the bilingual body to a temp file, then:

```bash
gh release create v1.5.0 --title "v1.5.0" --notes-file <temp-file>
```

- `--draft` when the user wants to review it on GitHub before it goes public.
- `--prerelease` for anything not meant for general use.
- Drop the tier label line from the release body. The version number already says it.

The same file serves the PR: `gh pr create --body-file <temp-file>`.

## Do not

- Guess at a change you did not read in the diff.
- Claim a fix works when the PR has no test or verification for it.
- Upgrade the tier to make the PR sound bigger, or downgrade it to avoid a migration note.
- Create, tag, or push a release the user did not ask for.
- Cut a tag before the version bump is committed and pushed.
- Invent a version number instead of reading the current one.

Worked examples for all three tiers: [references/examples.md](references/examples.md).
