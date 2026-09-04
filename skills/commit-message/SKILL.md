---
name: commit-message
description: Write a commit message another developer can act on - a Conventional Commits subject, a body that explains why rather than what, and one commit per logical change - so that a release can later be assembled from git log instead of by re-reading diffs. Also covers splitting a mixed working tree into separate commits. Use whenever a commit is about to be made or a message needs rewriting, including "commit ให้หน่อย", "เขียน commit message", "git commit", "reword this commit", or when changes are staged and the user asks what to write.
license: MIT
metadata:
  author: EARTH157
  version: "1.0"
---

# Commit Message

A commit message is read later, by someone with no memory of today - usually you. The
diff already says *what* changed. The message exists to say *why*, and to let a release
be assembled months later without reopening every diff.

Committing and releasing are separate decisions. Commit freely; decide about releasing
later. That only works if the messages carry enough structure to group afterwards.

## Format

```
<type>: <subject>

<body - why, not what>

<footers>
```

### Subject

- Imperative mood: `add`, never `added` or `adds`.
- Lowercase after the colon, no trailing period, under ~72 characters.
- Name the effect, not the file. `fix: stop the export double-counting refunds`,
  not `fix: update exportService.ts`.

### Type

The type is not decoration. It decides where the change lands in the release notes and
which digit moves, so choosing it carelessly corrupts the next release.

| Type | Release section | Bump |
|---|---|---|
| `feat` | What's new | minor |
| `fix` | Bug fix | patch |
| `perf`, `refactor`, `style` | Changed - and only if a user can perceive it | patch |
| `docs`, `test`, `build`, `ci`, `chore` | omitted from release notes entirely | none |
| any type with `!`, or a `BREAKING CHANGE:` footer | Changed, marked Breaking | major |

A change that should not appear in release notes is `chore`, `docs` or `test`. Reaching
for `feat` to make a change sound significant is how a changelog stops being trusted.

### Body

Write one when the subject is not self-explanatory. Skip it when it is - a padded body
is worse than none.

Answer, in this order:

1. What was wrong or missing before.
2. Why this approach, if another one was the obvious choice.
3. Anything the next reader would otherwise have to rediscover.

Never restate the diff. "Changed `x` to `y`" is already visible in `git show`.

### Footers

- `BREAKING CHANGE: <what the reader must now do>` - the consequence, not just the fact.
- `Refs: #123`, `Closes: #123`.

## One commit, one logical change

A commit that does two things cannot be reverted, reviewed, or released cleanly.

Split when the working tree mixes:

- a fix and a feature
- a behaviour change and a formatting sweep
- product code and an unrelated dependency bump

Stage by path or by hunk and commit separately. If a change genuinely cannot be split,
say why in the body rather than pretending it is one thing.

## Language

Write commits in English even when the product's users are not English speakers. They
are read in `git log`, `git blame` and compare views, and by tooling that assumes a
single language. The bilingual, reader-facing version belongs in the pull request and
the release notes - see the `pr-description` skill.

## Do not

- Write `update`, `fix stuff`, `wip`, `misc`, or a bare file name.
- Describe the file touched instead of the behaviour changed.
- Mention releasing or a version number. That decision happens later, separately.
- Reword or amend a commit that is already pushed and shared.
