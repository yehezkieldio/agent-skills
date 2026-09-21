# Worked Examples

Each example shows the input, the reasoning, and the header.

## Features and Fixes

**Feature in a workspace crate**
Input: added a `Token` struct with validation in `christina-core/src/auth/token.rs`.
Reasoning: new capability gives `feat`. The crate `christina-core` gives `core`, but the inner module `auth` is more precise.
Header: `feat(auth): add token validation with expiry checking`

**Bug fix across several files**
Input: fixed a race condition in the database connection pool, and removed an unused mutex in the cache.
Reasoning: bug fix gives `fix`. The primary module is the database, so the scope is `db`.
Header: `fix(db): resolve race condition in connection pool`

**Fix with a named defect**
Input: `let x = vec![]` replaced by `Vec::new()` in `src/memory/alloc.rs`, correcting an allocation.
Reasoning: corrects incorrect behavior, so `fix`. Module `memory`.
Header: `fix(memory): replace vec![] with Vec::new for correct allocation`

## Maintenance

**Dependency bump**
Input: bumped tokio from 1.38 to 1.49 in `Cargo.toml`, then ran `cargo update`.
Reasoning: a dependency change gives `chore`. The file is `Cargo.toml`, so the scope is `deps`.
Header: `chore(deps): bump tokio to 1.49`

**Configuration files**
Input: changed `max_width` in `rustfmt.toml` and the indent in `.editorconfig`.
Reasoning: tooling configuration gives `chore` with scope `config`.
Header: `chore(config): set max_width in rustfmt and indent in editorconfig`

**Build tooling**
Input: `justfile` gained a new test command. No source change.
Reasoning: build tooling gives `build`.
Header: `build: add nextest run command to justfile`

## Pipelines

**Release workflow**
Input: added `.github/workflows/release.yml`.
Reasoning: pipeline configuration gives `ci`. Do not repeat `ci` as the scope.
Header: `ci: add release workflow`

**New lint job**
Input: `.github/workflows/ci.yml` gained a clippy job.
Reasoning: `ci`, with no scope.
Header: `ci: add clippy lint job`

## Other Types

**Measured performance gain**
Input: replaced a `HashMap` with a `Vec` lookup in a hot path, cutting p99 latency by 40 percent.
Reasoning: a measured gain gives `perf`. Module `parser`.
Header: `perf(parser): replace HashMap with Vec in hot-path lookup`

**Test-only change**
Input: added integration tests for the token refresh flow.
Reasoning: tests only give `test`. Module `auth`.
Header: `test(auth): add integration tests for token refresh`

**Security hardening**
Input: added input sanitization for user-supplied commit context, to block prompt injection.
Reasoning: a security measure gives `security`. Module `prompt`.
Header: `security(prompt): sanitize user context input`

**Restructure with a name**
Input: `christina-core/src/prompt.rs` rewritten with new prompt templates.
Reasoning: no external behavior change gives `refactor`. The inner module `prompt` is more precise than the crate `core`.
Header: `refactor(prompt): rewrite commit message prompt templates`

## Breaking Change

Input: removed the v1 routes from the API.
Reasoning: removes public behavior, so add `!`.
Header: `feat(api)!: drop v1 routes`

## With Issue Context

Input: the user says "this fixes #482", and the change resolves the token refresh loop.
Reasoning: `fix` type, real issue number, so add a `Fixes` footer.

```
fix(auth): resolve token refresh loop on expired session

Fixes #482
```

## Multi-Theme Diff

Input: six files in a user roles system, four files in a database migration, two files in test utilities.
Reasoning: the roles theme has the most files. Its type is `feat`. The themes do not share a scope, so omit it.
Header: `feat: implement user roles system`
