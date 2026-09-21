# Footers

The default commit has no footer. Add one only if the session shows a reason: an issue, a pull request, a breaking change, a required trailer, or a co-author.

## Where the Facts Come From

- The user names an issue or pull request.
- The branch name contains a number, such as `fix/482-token-loop`.
- The task came from an issue or pull request that the session read.
- The user says the change breaks callers.

Never invent a number. If the context is unclear, leave the footer out, or ask.

## Syntax

A footer is one line of the form `Key: value` or `Key #value`.

- The key joins words with hyphens: `Related-PR`, `Co-authored-by`. The exception is `BREAKING CHANGE`, which has a space.
- The value is a number, a hash, a URL, a name, or a short sentence.
- Prefer one line per footer. For a long value, indent each continuation line with a space or a tab. Git folds indented lines into the value. Shorter is better.

## Placement

The footer block is the last paragraph of the message.

- With a body: one blank line after the body, then the footer lines.
- Without a body: one blank line after the header, then the footer lines. The footer block then works as the body.
- Footer lines stay together in one block, with no blank lines between them.

One-line views such as `git log --oneline` and the commit list on GitHub show only the header. The body and the footer block stay out of that view.

## Keys

- `Fixes #123`
  - A `fix` commit that closes a bug report
- `Closes #123`
  - A `feat` commit, or other work that completes an issue
- `Resolves #123`
  - The user, the repository, or the tracker uses this word
- `Refs #123`
  - The commit relates to an issue but does not finish it
- `Related-PR: #45`
  - A pull request that this commit connects to, with no closing effect
- `BREAKING CHANGE: <what breaks and how to migrate>`
  - A breaking change that needs a migration note
- `Co-authored-by: Name <email>`
  - A co-author that the user named
- `Signed-off-by: Name <email>`
  - The repository requires sign-off

Rules:

- Use one closing keyword per issue. Do not mix `Fixes` and `Closes` for the same issue.
- For another repository, write `Closes owner/repo#123`.
- For several issues, write one footer per line. GitHub closes each issue when the commit reaches the default branch.
- Keep trailers that the repository or the harness requires, such as `Co-Authored-By`. Place them last.
- Other trailers such as `Link`, `Reported-by`, and `Reviewed-by` need a real session fact behind them.

## Breaking Changes

The `!` after the type or scope marks a breaking change. That alone is enough by default. Add a `BREAKING CHANGE:` footer only if the user asks, or if callers need a migration note. Keep the note to one line, or indent the continuation lines.

```
feat(api)!: drop v1 routes

BREAKING CHANGE: clients must call /v2/*. The /v1/* routes return 410.
```

## Reverts

Write `revert: <description of the reverted change>` and add `Refs: <short sha>` as a footer.

## How Git Reads Footers

Tested with git 2.55.

- A block of `Key: value` lines is a trailer block. `git log --format='%(trailers)'` and `git interpret-trailers` read it.
- `Fixes #123` is a valid Conventional Commits footer, and GitHub closes the issue from it. Git does not parse it as a trailer. One such line in a block makes git ignore the whole block for trailer tools. This is harmless unless a tool reads trailers.
- `BREAKING CHANGE:` has a space in the key. Git does not parse it as a trailer. The spec allows `BREAKING-CHANGE:` as a synonym, and git parses that one. Use the hyphen form only if a trailer tool must read it.
- A continuation line that starts with whitespace folds into the value above it.

## Passing the Message to Git

Never open an editor. Build the message from arguments.

- Pass each paragraph as its own `-m` flag. Git joins them with one blank line: header, then body, then footer block.
- Put all footer lines in one `-m` argument, separated by newlines, so they form a single block.

```sh
git commit -m "fix(db): stop pool race" -m "Fixes #482
Related-PR: #490"
```

- `--trailer "Key: value"` appends a trailer block. It needs the colon form. `--trailer "Fixes #7"` produces `Fixes #7:` with a stray colon. A key with a space, such as `BREAKING CHANGE`, breaks in the same way, so use `BREAKING-CHANGE` there. Use `--trailer` for `Co-authored-by`, `Signed-off-by`, and other `Key: value` lines.
- When a message mixes `Fixes #N` with other footers, put every footer line in one `-m` block.
