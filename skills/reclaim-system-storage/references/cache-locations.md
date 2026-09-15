# Cache locations and clean commands

Distilled from real cleanups on a CachyOS/Arch machine with a heavy dev toolchain
(Rust, Node/Bun, Python, Java, AI coding tools). Sizes are examples from one
real run, not guarantees — always survey the actual machine first.

Every row here is **regenerable**: clearing it costs a slower next build/fetch,
never data loss. Treat anything not in this table as unknown, and hold it out
for user confirmation rather than assuming it's safe.

## Language/package-manager caches

| Tool | Path | Clean command | Notes |
|---|---|---|---|
| uv (Python) | `~/.cache/uv` | `uv cache clean` | Can be 10GB+; grows fast with frequent `uv run`/`uvx`. |
| pip | `~/.cache/pip` | `pip cache purge` | Usually small. |
| npm | `~/.npm/_cacache` | `npm cache clean --force` | `--force` needed; npm warns, that's expected. |
| bun (downloads) | `~/.bun/install/cache` | `rm -rf` contents | Do not touch `~/.bun/install/global` — that's `bun install -g` packages. |
| Gradle | `~/.gradle/caches` | `rm -rf` contents | Java build cache, regenerates on next build. |
| Composer (PHP) | `~/.cache/composer` | `composer clear-cache` or `rm -rf` | |
| node-gyp | `~/.cache/node-gyp` | `rm -rf` | Native addon build cache. |
| Playwright browsers | `~/.cache/ms-playwright*` | `rm -rf` | Re-downloads browser binaries on next `playwright install`/test run — can be slow, mention this before clearing. |

## Rust-specific (see also the hard rule below)

| Path | What it is | Safe to clear |
|---|---|---|
| `~/.cargo/build` or `{cargo-cache-home}/build/<hash>` | Shared build-dir cache (check `~/.cargo/config.toml` for a custom `build.build-dir` — some setups key it per-workspace under a hash, shared across ALL cargo projects on the machine) | Yes, fully. Regenerates on next `cargo build`. If keyed per-workspace, can target just one project's hash subdirectory instead of the whole thing. |
| `~/.cache/sccache` | sccache compiler object cache | Yes, fully. |
| `~/.cargo/registry` | Downloaded crate sources/index | Yes, but lower priority — usually smaller (hundreds of MB) and costs a network re-fetch. |
| `~/.rustup/toolchains/*` | Installed compiler toolchains | **No** — this is the active toolchain, not cache. Only remove a specific toolchain the user explicitly names as unused (`rustup toolchain uninstall <name>`), never as part of a general cleanup pass. |
| `~/.cargo/bin` | `cargo install`/`cargo binstall` global binaries | **Never touch.** This is the one thing users most often explicitly ask to be spared — see hard rule below. |

## AUR/pacman (Arch-based systems)

| Path | Clean command | Notes |
|---|---|---|
| `~/.cache/paru/clone`, `~/.cache/paru/diff` | `paru -Sccc` (interactive; see gotcha below) | AUR package build/git-clone cache. |
| `/var/cache/pacman/pkg` | `sudo pacman -Sc` (keeps currently-installed versions) or `sudo pacman -Scc` (removes all, more aggressive) | Needs sudo. Prefer `-Sc` unless the user wants maximum reclaim. |
| Orphaned packages | `pacman -Qtdq` to list, `sudo pacman -Rns $(pacman -Qtdq)` to remove | Only remove after showing the user the list — these are real installed packages, not cache. |

**Gotcha**: `paru -Sccc --noconfirm` does not suppress paru's *own* interactive
prompts (only pacman's); `--noconfirm` alone can leave the command hanging on a
`[y/N]` prompt. Pipe answers instead: `yes | paru -Sccc`. If that still leaves
stray `download-*` partial-download directories in `/var/cache/pacman/pkg/`,
remove those directly with `sudo rm -rf /var/cache/pacman/pkg/download-*`.

## Browser and app caches

| Path | Notes |
|---|---|
| `~/.cache/<browser>` (zen, google-chrome, BraveSoftware, etc.) | Safe to clear even while the browser is running — it just recreates entries. A first `rm -rf` attempt can fail with "Directory not empty" on files the running browser has open; retry once and it succeeds (the browser releases the handle between writes). |
| `~/.config/google-chrome-backup*`, `~/.config/*-crashrecovery-*` | Stale crash-recovery snapshots from a past crash, not live profile data. Confirm with the user before removing — flag as ambiguous, not auto-clean. |
| `~/.local/share/Trash` | Already user-deleted files. Still confirm before emptying — "cleanup" doesn't automatically imply "also permanently delete my trash." |

## AI coding tool caches

Tools like opencode, GitHub Copilot, and similar coding assistants keep their
own `~/.cache/<tool>` and sometimes `~/.local/share/<tool>` directories for
model/index caches. These regenerate on next use. Treat unfamiliar tool names
the same way: check size with `du -sh`, and if the directory name clearly maps
to a known dev tool and looks like a cache (not config/state), it's a
reasonable candidate — but group these together and confirm as a batch rather
than assuming silently, since a wrong guess here is more likely than in the
well-established caches above.

## System-level (not project-specific)

| What | Command | Notes |
|---|---|---|
| systemd journal | `journalctl --disk-usage` to check, `sudo journalctl --vacuum-time=2weeks` to trim | Usually small (tens of MB); rarely worth it unless explicitly large. |
