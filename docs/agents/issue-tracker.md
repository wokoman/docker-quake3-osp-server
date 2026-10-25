# Issue tracker: Forgejo

Issues and specs for this repo live as Forgejo issues on `git.michalkozak.cz` (the `origin` remote). Use the `fj` CLI for all operations; it infers the repo from the git remote when run inside a clone.

## Conventions

- **Create an issue**: `fj issue create "<title>" --body "..."`, or `--body-file <path>` for multi-line bodies.
- **Read an issue**: `fj issue view <number>` (title + body); `fj issue view <number> comments` lists comments.
- **List issues**: `fj issue search --state open --labels "..."` (also `--assignee`, `--creator`; `--state` accepts `open`/`closed`/`all`).
- **Comment on an issue**: `fj issue comment <number> "..."`
- **Apply / remove labels**: `fj issue edit <number> labels --add "..." --rm "..."`
- **Assign**: `fj issue assign <number> <username>`
- **Close**: `fj issue close <number> --with-msg "..."`

Forgejo has no sub-issues or native issue dependencies. Use body lines instead: `Part of #<parent>` at the top of a child body, `Blocked by: #<n>, #<n>` for dependencies.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; `/triage` reads this flag.)_

When set to `yes`, PRs run through the same labels and states as issues, using the `fj pr` equivalents (`fj pr view`, `fj pr comment`, `fj pr close`).

## When a skill says "publish to the issue tracker"

Create a Forgejo issue.

## When a skill says "fetch the relevant ticket"

Read it as in **Read an issue** above.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with child issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body.
- **Child ticket**: an issue with `Part of #<map>` at the top of its body. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: a `Blocked by: #<n>, #<n>` line at the top of the child body. A ticket is unblocked when every blocker is closed.
- **Frontier query**: list the map's open children (`fj issue search --state open`), drop any with an open blocker in its `Blocked by` line or an assignee; first in map order wins.
- **Claim**: `fj issue assign <n> <you>`, the session's first write.
- **Resolve**: `fj issue comment <n> "<answer>"`, then `fj issue close <n>`, then append a context pointer to the map's Decisions-so-far.
