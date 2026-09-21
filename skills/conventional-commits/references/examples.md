# Worked Examples

Each example shows the input, the reasoning, and the result. Headers aim for 50 characters or fewer.

## Headers

**Feature in a workspace crate**
Input: added a `Token` struct with validation in `christina-core/src/auth/token.rs`.
Reasoning: new capability gives `feat`. The crate gives `core`, but the inner module `auth` is more precise.
Header: `feat(auth): add token expiry validation`

**Bug fix across several files**
Input: fixed a race in the connection pool, and removed an unused mutex in the cache.
Reasoning: bug fix gives `fix`. The primary module is the database.
Header: `fix(db): resolve race in connection pool`

**Dependency bump**
Input: bumped tokio from 1.38 to 1.49 in `Cargo.toml`, then ran `cargo update`.
Reasoning: a dependency change gives `chore` with scope `deps`.
Header: `chore(deps): bump tokio to 1.49`

**Configuration files**
Input: changed `max_width` in `rustfmt.toml` and the indent in `.editorconfig`.
Reasoning: tooling configuration gives `chore` with scope `config`.
Header: `chore(config): align rustfmt and editorconfig`

**Build tooling**
Input: `justfile` gained a nextest command. No source change.
Header: `build: add nextest run command to justfile`

**Pipeline**
Input: added `.github/workflows/release.yml`.
Reasoning: pipeline configuration gives `ci`. The type is not repeated as the scope.
Header: `ci: add release workflow`

**Measured performance gain**
Input: replaced a `HashMap` with a `Vec` lookup in a hot path, cutting p99 latency by 40 percent.
Header: `perf(parser): replace HashMap with Vec in hot path`

**Test-only change**
Header: `test(auth): add token refresh integration tests`

**Security hardening**
Input: sanitized user-supplied commit context to block prompt injection.
Header: `security(prompt): sanitize user context input`

**Restructure**
Input: `christina-core/src/prompt.rs` rewritten with new templates.
Reasoning: no external behavior change gives `refactor`. The inner module `prompt` beats the crate `core`.
Header: `refactor(prompt): rewrite commit prompt templates`

**Breaking change**
Input: removed the v1 routes from the API.
Header: `feat(api)!: drop v1 routes`

## History Shaped the Result

Input: `git log --no-merges -5 --format=%s` shows five subjects such as `fix(web): ...`, `feat(web): ...`, and `chore(api): ...`. The change touches `apps/web/src/cart/`.
Reasoning: history is consistently conventional, and it uses app names as scopes, not module names. Use `web`.
Header: `fix(web): stop cart total rounding at checkout`

Input: the last five subjects are "wip", "fix stuff", "Update README", "more changes", and "merge fixes".
Reasoning: history is mixed and not conventional. Ignore it and apply the skill rules.

## Header With a Footer

Input: the branch is `fix/482-token-loop`, and the user said the change closes the bug.
Reasoning: `fix` type, a real issue number from the branch and the user, so add a `Fixes` footer. No body, so the footer follows the header after one blank line.

```
fix(auth): stop token refresh retry loop on 401

Fixes #482
```

Input: the session implemented an issue and referenced a related pull request.

```
feat(export): add CSV export for orders

Closes #311
Related-PR: #318
```

## Header With a Body

The user asked for a body. Take the facts from the session.

```
fix(auth): stop token refresh retry loop on 401

An expired session made the client call /refresh, get a 401, and call
/refresh again with no limit. Each retry reset the backoff timer, so
the client sent one request every 200 ms until the tab closed.

Clear the session on the first 401 and return to the sign-in screen.
Callers that relied on the silent retry now see a sign-in prompt.

Fixes #482
```

A feature with a stated limit:

```
feat(export): add CSV export for orders

Support asked for a way to pull a month of orders into a spreadsheet.
The export streams rows from a database cursor, so memory stays flat
for large ranges.

Exports over 100000 rows return 413. A background job for those is a
follow-up.

Closes #311
```

A refactor with a trade-off and no footer:

```
refactor(cache): extract eviction module

The cache file mixed lookup, expiry, and eviction, and every edit to
the eviction rules touched the lookup path. Move eviction behind one
evict() call so the rules change in one place.

The extra call adds one function hop per write. Benchmarks show no
change beyond noise.
```

## Breaking Change With a Note

```
feat(api)!: drop v1 routes

BREAKING CHANGE: clients must call /v2/*. The /v1/* routes return 410.
```

## Message Only

The user said "just give me the message". Present the message in a code block and add nothing else. Do not run `git commit`.

```
chore(deps): bump tokio to 1.49
```

## After Committing

Report one line and stop.

```
a1b2c3d fix(auth): stop token refresh retry loop on 401
```
