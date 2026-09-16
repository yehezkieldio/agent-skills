---
name: content-writing-composition
description: This skill should be used for any substantial piece of writing meant to read as authored, not generated — drafting a technical article ("write an article about", "draft a Medium post", "write it up in my style"), a conceptual or opinion essay, or a formal academic manuscript/thesis chapter, AND reviewing, auditing, or revising an existing piece of this kind ("review this article", "audit this manuscript for AI-writing tells", "apply this feedback to my draft", "check this piece against the checklist", "fix these issues without asking me first"). Applies to any codebase, subject matter, or language, and to pieces this skill didn't originally draft — grounds technical pieces in real code and git history, calibrates voice against a real author's corpus where one exists, follows an institution's own guideline where one governs, and screens every draft or existing piece against a running checklist of formulaic-writing tells.
version: 0.4.0
---

# Content Writing & Composition

Turn a real subject (an engineering decision found in a codebase, an idea worth arguing, a body of research) into a finished piece of writing that reads as authored by a specific person or bound by a specific institutional register, not produced by a model executing a generic outline. Two failure modes recur across every composition type this skill covers: inventing detail that isn't grounded in real source material, and defaulting to generic "well-written" prose instead of the voice or register the piece actually needs.

This skill is decomposed by **composition type**, and each type lives in its own file under `references/` so that picking one never pulls another type's content into context — asking for a conceptual essay should never load academic-thesis-specific guidance, and vice versa. `references/type-index.md` is the dispatcher: read it first, pick exactly one type (or, for a genuine cross-mix request, the small set the index says to combine), then read only that type's file. The workflow below is universal across every type; each type file fills in the parts that differ (structure, evidence policy, sanitization, closing convention).

## Two entry points: drafting or reviewing

This skill covers two distinct jobs that share the same type files and the same checklist, but take a different path through this document:

- **Drafting a new piece.** Follow the Workflow below in order, Step 0 through Step 6.
- **Reviewing, auditing, or revising a piece that already exists** — including one this skill didn't originally draft. Still do Step 0 (identify the type, since it governs which checklist calibration applies), then go straight to `references/review-and-audit.md`, which covers deciding whether the task is report-only or fix-authorized, respecting a project's own existing style guide, delegating a large audit to a subagent, applying someone else's written critique, and running a holistic pass distinct from a mechanical checklist pass.

If it's unclear which entry point a request wants, ask — the two modes carry very different risk profiles, especially for a piece with real external stakes.

## Workflow

Follow these steps in order for a new piece. Do not skip Step 2 for a type that has it — voice calibration is the step most likely to be skipped and the one that most determines whether a result feels authored or generated.

### Step 0: Pick the composition type

Read `references/type-index.md` and pick a type before doing anything else. It is a registry, not a fixed list — a request that clearly wants a shape no current type covers is a signal to add a new type there (see `references/type-template.md`) rather than force-fitting the closest existing one. Guessing wrong here means redoing a full draft, not a paragraph, so ask if the signals are ambiguous.

Once picked, read only that one type file (e.g. `references/type-conceptual-essay.md`). It governs the macro-structure, the evidence/citation policy, the sanitization level, and the closing convention for the rest of this workflow.

### Step 1: Ground the content in real source material

Before writing a single sentence, establish what actually happened or what actually exists, using whatever counts as real evidence for the chosen type (see that type's own **Grounding** section — git history and diffs for a codebase-grounded piece, a verified citation or dataset for an academic one). For a codebase-grounded piece specifically:

- Read the real source files involved, not a paraphrase from memory.
- Run `git log --reverse --format='%ad %h %s' --date=short -- <paths>` for the true chronological order — a plain `git log` is newest-first and easy to misread as a narrative in the wrong direction.
- Pull the actual diffs of commits that matter (`git show <sha> -- <path>`) so quoted code and described bugs are the real thing.

Never fabricate a bug, a metric, a timeline, or a citation, for any type. If a piece needs more grounding material than what's already established (e.g. a long piece's length needs to grow with a genuinely new section, not padding), go find more real material — a subagent search is often the right tool once the source is large; brief it with what's already been used so it doesn't rediscover the same ground.

### Step 2: Calibrate voice against a real corpus, or skip it where there isn't one

Some types have no personal voice to calibrate (check the type file's **Tone** section — an Academic/Thesis Writeup targets an institution's formal register, not an author's corpus, and skips this step entirely). For every type that does calibrate against a corpus:

Fetch the target author's own published work and request **verbatim quotes**, not a summary: the exact paragraphs before the first heading, a handful of section headings, a few full mid-piece paragraphs, and the closing. By default, when no other author is specified, the target is this skill's own author, whose corpus lives on Medium at the RSS feed `https://medium.com/feed/@yehezkieldio`. This is a default, not a hard-coded assumption — when a piece is being written for or as someone else, calibrate against that person's own published corpus instead, fetched from wherever it actually lives (their own Medium feed, a personal blog, a different platform entirely). Extract concrete, falsifiable patterns from whichever corpus applies (see `references/style-corpus.md` for the structure). Drafting from a vibe-based impression of "technical and punchy" produces generic prose that merely sounds like the target voice.

### Step 3: Find the type's central sentence

Most types need one sentence, found before outlining sections, that the rest of the piece becomes a *consequence* of rather than a separate topic (a reframe for a narrative piece, a central tension for an essay, a precisely-stated problem statement for an academic piece with no single "reframe" to find). See the type file's own guidance for what this looks like for the chosen type — the exact shape differs enough between types that it isn't a universal step.

### Step 4: Draft to a local file, never publish directly

Write the draft to a local file (e.g. `ARTICLE.md`), not to any publishing tool, unless explicitly asked to post it. Structure the piece exactly per the chosen type's spec — don't default to one type's shape when another was picked. Read `references/anti-formulaic-writing.md` before writing a single paragraph, and re-check the finished draft against it before presenting; a type file may narrow how that checklist applies (an Academic/Thesis Writeup treats certain "formulaic-looking" structures as required genre convention, not tells — see that type file).

Sanitize identifying details per the chosen type's own sanitization policy. Never mention unrelated private material (internal docs, other codebases, someone else's academic work) even in passing, regardless of type.

### Step 5: Apply revisions surgically

Distinguish "fix this specific thing" from "rewrite it all." If revision feedback quotes exact lines and says what's wrong, treat that as the scope — fix those lines and anything structurally downstream, not license to re-architect the whole piece. Only do a full rewrite when explicitly asked. When feedback is a long analytical critique, extract the *concrete, actionable* instructions inside it rather than imitating the critique's own prose style. For a revision pass involved enough to need deciding audit scope, delegating a large read, or reconciling a critique against an earlier stated requirement, see `references/review-and-audit.md` — the same file that governs reviewing a piece that wasn't freshly drafted in this session.

### Step 6: Deliver platform metadata separately from the body

If asked for a subtitle, tags, or cover-image placement, answer separately from the article file unless asked to fold them in. See `references/platform-metadata.md` for the subtitle shape, tag conventions, and image-placement rules, and `examples/subtitle-patterns.md` for verbatim confirmed examples.

## Common mistakes to avoid

- Skipping Step 0, or picking a type from habit instead of the actual signals in `references/type-index.md` — including code and real names in a piece that asked for heavy sanitization, or the reverse.
- Drafting from a generic outline before doing Step 1 and Step 2. Outline-first produces structure that has to be torn down once real grounding and real voice are checked.
- Meta-narrative throat-clearing about the piece itself ("what follows is...", "this is an examination of..."). Jump into the subject; let the reader infer the shape from how it reads.
- Ending with a generic recap. Each type file states its own non-recap closing convention — use that instead.
- Inflating a long piece's length with a restated aphorism or a repeated re-explanation of the same point/mechanism, instead of finding genuinely new grounding material and giving it its own section. Length from repetition reads as padding regardless of how well the sentences are polished; length from a new real example reads as depth.

Type-specific common mistakes (e.g. the Conceptual Essay's absolute-claim trap, or the Academic type's genre-convention-vs-tell distinction) live in each type's own file, not here — check the chosen type file's guidance directly rather than assuming this list is exhaustive.

## Long-form pacing and accessibility

For a piece long enough to be a 20+ minute read, dense argument paragraphs need occasional breathing room, regardless of type. Insert short (1–2 sentence) standalone interludes between heavier sections — plain paragraphs, not a device that turns into its own tic if overused — spaced roughly every 3–4 sections. An interlude is a beat, not a summary and not a transition sentence dressed up as one.

If the piece is meant to be readable by someone technical-but-not-expert, gloss unfamiliar jargon inline the first time it appears (a short parenthetical, not a footnote), and anchor-link a concept that has a well-known name or origin to its canonical source rather than re-explaining it from scratch.

## Additional resources

**Type files** (`references/`) — read `type-index.md` first, then exactly the one (or few, for a cross-mix) type file the request needs:

- `type-index.md` — the dispatcher: signals for each registered type, and guidance for a request that genuinely wants a blend of two types.
- `type-narrative-feature.md` — a technical story with a chronological arc, code included, light sanitization.
- `type-conceptual-essay.md` — an opinionated, concept-by-concept infodump with no chronological arc, no code, heavy sanitization.
- `type-academic-thesis.md` — a formal manuscript chapter governed by an institutional guideline, in any language, with no author voice to calibrate.
- `type-template.md` — copy-paste template for registering a new type.

**Shared references** (apply regardless of chosen type):

- `anti-formulaic-writing.md` — the concrete, ever-growing checklist of formulaic and AI-typical writing patterns to screen every draft against.
- `style-corpus.md` — how to structure a voice-calibration analysis once source pieces are fetched.
- `platform-metadata.md` — subtitle shape, tag conventions, and cover/inline image placement rules for publishing.
- `review-and-audit.md` — the second entry point: reviewing, auditing, or revising a piece that already exists, including one this skill didn't draft. Covers report-only vs. fix-authorized scope, respecting an existing project style guide, delegating a large audit, applying an external critique, and running a holistic pass distinct from a checklist pass.

**Examples** (`examples/`) — illustrative material fetched on demand, not loaded by default:

- `subtitle-patterns.md` — verbatim confirmed subtitle examples and their shape breakdown.
