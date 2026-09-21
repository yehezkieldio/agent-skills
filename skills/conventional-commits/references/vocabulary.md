# Vocabulary

Every description starts with a strong verb and names a concrete artifact.

## Verb Tiers

Prefer the highest tier that fits.

- Tier 1, precise and preferred: add, remove, extract, split, merge, replace, rename, inline, implement, introduce, enforce, migrate, drop, deprecate, wire, unwrap, hoist, flatten, narrow, widen, gate, guard.
- Tier 2, when tier 1 does not fit: fix, resolve, correct, handle, validate, normalize, convert, optimize, simplify, consolidate, decouple, isolate, swap, align, reorder, restructure, rework, parallelize, batch, cache, index, deduplicate, throttle, debounce, retry.
- Tier 3, only when tiers 1 and 2 do not apply: update, change, modify, adjust, improve, clean, move, set.

## Banned Vocabulary

Never use these in a description. If you catch one, stop and rewrite with a concrete alternative.

### Verbs

ensure, enhance, leverage, utilize, streamline, facilitate, address, employ, revamp, overhaul, bolster, augment, elevate, empower, foster, harness.

Three have limited exceptions:

- `optimize`: allowed only if the change is measurably faster. Otherwise use `perf` with a concrete verb, or `simplify`.
- `refine`: use "simplify" or "restructure".
- `tweak`: use "adjust" or "fix".

### Adjectives

robust, seamless, comprehensive, cutting-edge, state-of-the-art, holistic, synergistic, elegant, performant, better, improved, enhanced.

Say what is better, what improved, or how. Replace "performant" with "faster" or "reduce allocations".

### Phrases

"in order to", "as needed", "going forward", "with respect to", "a number of", "in terms of", "make sure", "take care of", "deal with", "properly handle", "various improvements", "minor changes", "some fixes", "general cleanup", "miscellaneous updates".

For "properly handle", say what the handling does.

## Banned Patterns

| Pattern | Do this instead |
|---|---|
| Ending with "for better X" | Describe the change and stop |
| "update X to Y" when the change adds a feature | Use `feat` and "add" |
| "fix X" with no named bug | Name the specific defect |
| "refactor X for clarity" | Name the structural change |
| "clean up X" | Say what was removed or restructured |
| "improve X" | Say the specific improvement |

## Rewrite Examples

| Weak | Strong |
|---|---|
| `fix: ensure the pool is properly handled` | `fix(db): resolve race condition in connection pool` |
| `refactor: improve auth code for clarity` | `refactor(auth): extract token parsing into its own module` |
| `chore: various improvements` | `chore(deps): bump tokio to 1.49` |
| `feat: enhance the parser` | `feat(parser): add expression parsing` |
| `perf: optimize lookup` | `perf(parser): replace HashMap with Vec in hot-path lookup` |
| `fix: address error handling` | `fix(api): return 404 for missing user id` |
