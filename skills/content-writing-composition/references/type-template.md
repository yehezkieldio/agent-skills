# Template for a new composition type

Copy this into a new `type-<name>.md` file when a request clearly wants a shape no current type covers (a tutorial, a postmortem, a manifesto, a formal proposal, etc.). Check with whoever is asking before treating a genuinely new type as in-scope — this skill's default charter doesn't cover every shape of writing that exists. After creating the file, add a row for it to the table in `type-index.md` so the dispatcher can route to it.

```markdown
# Type: <Name>

**Signals:** <phrases or requests that indicate this type>

**Grounding:** <what gets pulled from source material — code/git history, citations/data, or something else — and how directly it's used>

**Structure:** <the macro-shape: opening, section pattern, closing>

**Code and evidence policy:** <is code shown verbatim, described, or excluded entirely; what counts as evidence for a claim>

**Sanitization:** <how much identifying detail gets kept vs. generalized, and why (confidentiality, genre register, or something else)>

**Tone:** <anything type-specific beyond the shared voice calibration — including whether this type calibrates against a personal corpus at all>

**Closing:** <the type's non-recap closing convention>

**Example:** <a real piece, once one exists, that exemplifies this type>
```

Keep each new type file self-contained and roughly the same size as the existing ones (a few hundred to a couple thousand words) — if a type accumulates enough type-specific sub-guidance to feel unwieldy, that's a signal some of it might belong in a shared reference instead (if it turns out to actually be universal) or in an `examples/` file (if it's illustrative material rather than a rule).
