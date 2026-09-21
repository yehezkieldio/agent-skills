# Types and Scopes

## Type Table

Each type has one meaning. Do not mix them.

| Type | Meaning |
|---|---|
| `feat` | New user-facing capability, endpoint, flag, command, or behavior |
| `fix` | Corrects a bug, regression, or incorrect behavior |
| `refactor` | Restructures code without changing external behavior |
| `perf` | Measurable gain in latency, throughput, or memory |
| `chore` | Maintenance that fits no other type: version bumps, tooling, configuration |
| `docs` | Documentation only: README, doc comments, guides, man pages |
| `test` | Adds or changes tests only, with no production code change |
| `build` | Build system, compilation, linking, packaging |
| `ci` | CI/CD pipeline configuration |
| `style` | Formatting, whitespace, semicolons, import order, with no logic change |
| `security` | Hardens security: input validation, auth checks, CVE patches |
| `compat` | Backward-compatibility shim or migration |
| `i18n` | Internationalization or localization |

## Decision Priority

If several types fit, choose the dominant type by file count. Break ties with this order:

`feat` > `fix` > `security` > `perf` > `refactor` > `build` > `ci` > `test` > `docs` > `style` > `chore`

When in doubt between the top types, prefer `feat`, then `fix`, then `refactor`, then `chore`.

## Scope Rules

The scope names the module or component. It never names the kind of change.

### Workspace or monorepo

- If the change stays inside one package, use the package name.
- Strip the common project prefix. `christina-core` becomes `core`. `christina-cli` becomes `cli`.
- If the change spans several packages, use the primary package, or omit the scope.

### Inside one package

- Use the nearest meaningful module directory. `src/auth/token.rs` gives `auth`. `src/parser/lexer.rs` gives `parser`.
- For a deep path, use the most meaningful ancestor. `src/api/v2/handlers/users.rs` gives `api`.
- If both a package name and an inner module fit, use the inner module. It is more precise. A rewrite of prompt templates in `christina-core/src/prompt.rs` gets `prompt`, not `core`.

### Format

- No spaces. Use kebab-case or snake_case.
- Omit the scope if it is ambiguous, or if the change spans three or more unrelated modules.
- Never use these as a scope: `feature`, `fix`, `update`, `change`, `src`, `code`, `misc`, `chore`, `refactor`, `improvement`, `cleanup`.
- Never repeat the type as the scope. Write `ci: add release workflow`, not `ci(ci): ...` or `chore(ci): ...`. Never write `deps(deps)`.

## Non-Source Files

| Files | Type and scope |
|---|---|
| `Cargo.toml`, `Cargo.lock`, `package.json`, lockfiles, `go.mod` | `chore(deps)` |
| `.github/workflows/*`, `.gitlab-ci.yml`, `Jenkinsfile` | `ci`, with no scope |
| `justfile`, `Makefile`, `build.rs`, build scripts | `build` |
| `config.toml`, `.env`, settings files | `chore(config)` |
| `.gitignore`, `.editorconfig`, `rustfmt.toml` | `chore(config)` |
| `README.md`, `docs/*`, `CHANGELOG.md` | `docs(<file name without extension>)` |
| `Dockerfile`, `docker-compose.yml`, Kubernetes manifests | `build(docker)` or `build(k8s)` |

A dependency change that adds a feature is still a `feat`. The table applies to changes that only touch these files.

## Scope for Several Areas

Use these tiers when the diff spans several modules.

1. Package tier: if more than 70 percent of the changed files share one package prefix, use that package's short name.
2. Module tier: if more than 70 percent of the files sit in one module inside a package, use the module directory name.
3. Infrastructure tier: match the non-source table above.
4. Two areas: if two distinct modules each hold 40 percent or more of the files, combine them with a slash: `api/ui` or `auth/core`. Never combine more than two.
5. Ambiguous: with three or more distinct areas and no clear majority, omit the scope.
