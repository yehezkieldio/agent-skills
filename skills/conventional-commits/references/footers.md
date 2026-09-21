# Footers

The default commit has a header line and nothing else. Add a footer only in the cases below. A footer needs one blank line between it and the header.

## Issue and Pull Request References

Add a closing footer when the session has real context. Sources of context:

- The user names an issue or pull request.
- The branch name contains a number, such as `fix/482-token-loop`.
- The task came from an issue or pull request that the session read.

Never invent a number. If the context is unclear, ask, or leave the footer out.

| Keyword | Use for |
|---|---|
| `Fixes #123` | A `fix` commit that closes a bug report |
| `Closes #123` | A `feat` commit, or most other completed work |
| `Resolves #123` | The user, the repository, or the tracker uses this word |
| `Refs #123` | The commit relates to an issue but does not finish it |

Rules:

- Use one keyword style per commit. Do not mix `Fixes` and `Closes` for the same issue.
- For another repository, write `Closes owner/repo#123`.
- For several issues, write one footer per line.

```
fix(auth): resolve token refresh loop on expired session

Fixes #482
Closes #490
```

- GitHub closes the issue when the commit reaches the default branch. A pull request that squashes commits uses its own title and body, so tell the user if the closing keyword must also go in the pull request description.

## Breaking Changes

The `!` after the type or scope marks a breaking change. That is enough by default.

Add a `BREAKING CHANGE: <what breaks and how to migrate>` footer only if the user asks, or if the break needs a migration note.

```
feat(api)!: drop v1 routes

BREAKING CHANGE: clients must call /v2/* routes. The /v1/* routes now return 410.
```

## Required Trailers

Keep trailers that the repository or the harness requires, such as `Co-Authored-By` or `Signed-off-by`. Place them last, after any issue footers, separated from the rest by one blank line.

## Reverts

Write `revert: <description of the reverted change>` and add the short SHA as a footer.

```
revert: drop v1 routes

Refs: a1b2c3d
```

## Passing Footers to Git

Pass the header and each footer group as separate `-m` flags. Git joins them with blank lines.

```sh
git commit -m "fix(auth): resolve token refresh loop on expired session" -m "Fixes #482"
```

For a header, an issue footer, and a trailer, use three `-m` flags.
