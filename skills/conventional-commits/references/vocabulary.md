# Vocabulary and AI Tells

Every description starts with a strong verb and names a concrete artifact. This file holds the verb tiers, the banned words, and the patterns that make a commit message read as generated.

## Verb Tiers

Prefer the highest tier that fits.

### Tier 1: precise and preferred

By purpose:

- Create: add, introduce, implement, support, allow, expose, emit, log, report, seed, vendor.
- Remove: remove, drop, delete, strip, prune, purge, deprecate, disable.
- Restructure: extract, split, merge, inline, hoist, flatten, collapse, unify, relocate, rename, reorder, unwrap, decouple, isolate.
- Replace: replace, swap, migrate, switch, convert, port, pin, unpin, bump.
- Constrain: enforce, require, reject, forbid, cap, clamp, narrow, widen, gate, guard, escape, sanitize, redact.
- Connect: wire, rewire, bind, forward, propagate, thread, delegate, defer.
- Restore: restore, revert, reinstate.

### Tier 2: acceptable when tier 1 does not fit

fix, resolve, correct, handle, validate, normalize, stop, skip, default, fall back, retry, simplify, consolidate, align, restructure, rework, tighten, loosen, relax, parallelize, batch, cache, memoize, precompute, index, deduplicate, throttle, debounce, coalesce, truncate, reuse, avoid.

Two uses need care. Write `fix` only with the defect named. Write `handle` only with what the handling does.

### Tier 3: only when tiers 1 and 2 do not apply

update, change, modify, adjust, set, use, make.

Never write a bare tier 3 verb with a vague object ("update logic", "change handling", "set values").

## Banned Vocabulary

Never use these in a header or a body. If one appears, rewrite the sentence around a concrete artifact.

### Verbs

ensure, enhance, leverage, utilize, streamline, facilitate, address, employ, revamp, overhaul, bolster, augment, elevate, empower, foster, harness, delve, unlock, unleash, showcase, spearhead, orchestrate, navigate, embrace, amplify, supercharge, reimagine, modernize, polish, tidy, boost.

Limited exceptions:

- `optimize`: only if the change is measurably faster. Otherwise pick a concrete verb.
- `refine`: use "simplify" or "restructure".
- `tweak`: use "adjust" or "fix".
- `enable`: allowed only for switching on a named flag or feature. Never as a vague verb ("enable better X").

### Adjectives and adverbs

robust, seamless, seamlessly, comprehensive, cutting-edge, state-of-the-art, holistic, synergistic, elegant, performant, powerful, sophisticated, intelligent, smart, advanced, proper, properly, appropriate, appropriately, significant, significantly, substantial, critical, crucial, vital, pivotal, key, efficient, efficiently, effective, effectively, generic, better, improved, enhanced, cleaner, various, numerous, minor, major, some, misc.

Filler adverbs and intensifiers: essentially, basically, simply, just, merely, purely, actually, really, truly, fully, quite, very, incredibly, fundamentally, honestly, finally.

Say what is better, what improved, or how.

### Nouns

improvements, enhancements, tweaks, refinements, cleanup, polish, stuff, things, issues, functionality, capabilities, mechanism, framework, ecosystem, landscape, paradigm, synergy, best practices, edge cases, wip.

Name the actual thing instead. A noun such as "logic" or "handling" is vague unless the header says which one.

### Phrases

- Old list: "in order to", "as needed", "going forward", "with respect to", "a number of", "in terms of", "make sure", "take care of", "deal with", "properly handle", "various improvements", "minor changes", "some fixes", "general cleanup", "miscellaneous updates".
- Self-reference: "this commit", "this change", "this PR", "in this commit", "the purpose of this".
- Filler: "it is worth noting", "it is important to", "a variety of", "a range of", "and more", "etc.", "and so on", "in a way that", "under the hood", "behind the scenes", "at the end of the day", "moving forward", "once and for all".
- Purpose tails: "for consistency", "for clarity", "for readability", "for maintainability", "for better X", "to improve X", "to make it more X", "to allow for".
- Hedges: "should now", "should fix", "hopefully", "potentially", "possibly", "might", "somewhat".

## Banned Patterns

- Ending with "for better X"
  - Instead: describe the change and stop
- "update X to Y" when the change adds a feature
  - Instead: use `feat` and "add"
- "fix X" with no named bug
  - Instead: name the specific defect
- "refactor X for clarity"
  - Instead: name the structural change
- "clean up X"
  - Instead: say what was removed or restructured
- "improve X"
  - Instead: say the specific improvement
- Naming a file as the content ("update user.ts")
  - Instead: name the behavior or artifact that changed
- Two unrelated actions joined by "and"
  - Instead: one header for the dominant change

## AI Tells

These patterns come from the anti-formulaic screen. They show up in generated commit messages more than in human ones. Screen the header and the body for each.

- **Em dash** in place of a real sentence break. Use a period, a comma, or a rewrite.
- **Colon elaboration** inside a description or body sentence ("fix: resolve crash: null user"). One colon after the type is enough. Elsewhere, use a conjunction or a period.
- **Negation pivot** ("not X, but Y", "rather than X", "instead of X"). State the affirmative: "replace X with Y" already says it.
- **Exact triples** ("add A, B, and C") when three is a habit and not the count.
- **Fragment triplets** and **staccato runs** of short sentences in a body. Merge them into sentences that carry the reasoning.
- **Connector chains**: Additionally, Furthermore, Moreover.
- **Throat-clearing openers**: "This commit adds...", "In this change we...", "What follows is...".
- **Closing morals and aphorisms**: "This keeps the code simple." "Simplicity wins." End on the last fact.
- **Restating the header** as the first line of the body, or restating the body as a last line.
- **Hedge stacking**: "might potentially help". State what the change does, or leave it out.
- **Dramatic verbs on mundane facts**: "eliminates", "transforms", "unlocks" for a small rename or a bump.
- **Grandiose stakes**: "critical fix", "major improvement" for an internal change.
- **Borrowed authority**: "best practice", "as recommended", "industry standard" with no source. Cite the doc or leave it out.
- **Avoiding plain verbs**: "serves as", "acts as", "features", "boasts", "functions as". Write "is" or "has".
- **Same word twice**: one root word repeated inside a single sentence.
- **Rhetorical questions** and **staged vulnerability** ("finally got this working"). Facts only.
- **Formatting habits**: bold, markdown headings, emoji, and bullet lists with bold lead-ins. Git shows plain text.

### Do not chase the count

A word on these lists is filler in one sentence and load-bearing in another. Before you cut a hit, ask what the sentence loses. Do not swap a specific phrase for a vague one to clear a scan. A header such as `fix(parser): stop panic on empty input` is right even though "stop" is short. The fix for a hit is a more concrete sentence, and not a shorter one.

## Rewrites

- Weak: `fix: ensure the pool is properly handled`
  - Strong: `fix(db): resolve race in connection pool`
- Weak: `refactor: improve auth code for clarity`
  - Strong: `refactor(auth): extract token parsing into its own module`
- Weak: `chore: various improvements`
  - Strong: `chore(deps): bump tokio to 1.49`
- Weak: `feat: enhance the parser`
  - Strong: `feat(parser): add expression parsing`
- Weak: `perf: optimize lookup`
  - Strong: `perf(parser): replace HashMap with Vec in hot path`
- Weak: `fix: address error handling`
  - Strong: `fix(api): return 404 for missing user id`
- Weak: `feat: add robust and seamless retry logic`
  - Strong: `feat(client): retry failed uploads three times`
- Weak: `fix: update user.ts to handle null`
  - Strong: `fix(users): skip rows with a null email`

Body rewrite:

```
Weak:
This commit addresses an issue where the cache was not being properly
invalidated. Additionally, it streamlines the eviction logic. This
ensures better performance and improved reliability.

Strong:
The cache kept entries after a write to the same key, so readers saw
stale values for up to the 5 minute TTL. Delete the entry on write.
The extra delete adds one round trip per write.
```
