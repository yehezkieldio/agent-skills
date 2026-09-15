---
name: reclaim-system-storage
description: This skill should be used when the user asks to "clean up my system", "free up disk space", "reclaim storage", "clean up cache", "running out of space", "find what's using disk space", "clean up rust/cargo/node/bun stuff", or wants a general system-wide cleanup rather than deleting one specific project or file.
---

# Reclaim System Storage

Survey disk usage before deleting anything, separate what's safely
regenerable from what needs a judgment call, confirm the judgment calls, then
execute and verify. Never guess at what's safe — every byte reclaimed here
should be traceable to a specific, known-regenerable cache.

## Workflow

1. **Survey first, always.** Run `scripts/survey.sh` (or the equivalent
   `dust`/`du`/`df` commands by hand if `dust` isn't installed) before
   proposing or running any deletion. Never delete based on assumption alone.

2. **Categorize every candidate into exactly one bucket:**
   - **High-confidence, regenerable cache** — a known package-manager or
     build-tool cache (see `references/cache-locations.md` for the full
     table: uv, pip, npm, bun, cargo/sccache, gradle, pacman/paru, browser
     caches, Playwright, AI tool caches, etc.). Safe to clear without
     per-item confirmation once the overall plan is approved.
   - **Needs confirmation** — trash, crash-recovery backups, orphaned
     packages, anything whose name/purpose isn't immediately obvious, or
     anything that represents user data rather than a tool's own cache.
     Never delete these without asking first, even if they look large and
     tempting.
   - **Never touch** — see the hard rule below. Exclude these from the plan
     entirely; don't even list them as candidates.

3. **Present the plan before executing.** Show a table: what, where, size,
   how it's cleared, which bucket. Get one confirmation for the
   high-confidence batch as a whole (no need to ask item-by-item within that
   bucket) and explicit answers for each needs-confirmation item. Use
   `AskUserQuestion` for the needs-confirmation items — don't bury a real
   choice in prose the user might skim past.

4. **Execute in dependency order**: user-space caches first (no sudo), then
   sudo-requiring system caches (pacman, journal), since sudo prompts and
   package-manager transactions are the most likely to need a retry or hit
   an interactive prompt.

5. **Verify.** Compare `df -h /` before and after. Spot-check that anything
   explicitly meant to survive (see hard rule) is still present and
   functional — for global CLI installs, confirm the binary is still on
   `PATH` and the package manager still lists it as installed, not just that
   the directory exists.

## Hard rule: never delete global tool installs

A "clean up cache" request is about *cache*, never about installed software,
even when the user's phrasing is broad ("clean up rust stuff", "generally
cleanup my system"). Unless the user explicitly names a specific package or
binary for removal, always exclude:

- Global package-manager installs: `~/.cargo/bin` (`cargo install`/`cargo
  binstall`), `~/.bun/install/global` (`bun install -g`), and the equivalent
  global-bin directory for any other language's package manager present on
  the machine (npm global, pipx venvs, go install, etc.).
- Active toolchains: `~/.rustup/toolchains/*`, language runtime installs,
  and anything a build depends on to function tomorrow.
- Anything holding source-of-truth data: SSH/GPG keys, actual project
  source directories, documents — this skill is about caches, not about
  auditing what files exist on the machine.

When in doubt whether something is a cache or an install, check: does
deleting it just cost a slower next build/fetch (cache), or does it remove
functionality the user relies on right now (install)? If unsure which, ask
rather than assume either way.

## Known gotchas

`paru -Sccc --noconfirm` doesn't suppress paru's own interactive prompts —
pipe `yes |` instead, or answer them directly. Browser cache deletion can
fail with "Directory not empty" on the first attempt while the browser is
running (open file handles); retry once before treating it as a real
failure. Both are detailed in `references/cache-locations.md`, alongside the
full path/command table for every cache category.

## Additional resources

- **`references/cache-locations.md`** — full table of cache paths and clean
  commands per tool, plus the two gotchas above in detail.
- **`scripts/survey.sh`** — read-only survey script; run this first every
  time rather than re-deriving the same `du`/`dust` invocations.
