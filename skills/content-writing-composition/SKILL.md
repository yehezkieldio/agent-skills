---
name: content-writing-composition
description: This skill should be used for any substantial piece of writing meant to read as authored, not generated — a technical article ("write an article about", "draft a Medium/dev.to post", "turn this feature into an article", "write it up in my style"), a conceptual or opinion essay, an academic or research-adjacent writeup, or any other long-form composition where matching a real voice and avoiding formulaic AI prose patterns matters more than just conveying information. Applies to any codebase or subject matter — grounds technical pieces in real code and git history from the current project, calibrates voice against the author's own published corpus, and screens every draft against a running checklist of formulaic-writing tells.
version: 0.2.0
---

# Content Writing & Composition

Turn a real subject (an engineering decision found in a codebase, an idea worth arguing, a body of research) into a finished piece of writing that reads as authored by this specific person, not by a model executing an outline. The two failure modes this skill exists to prevent, regardless of what kind of piece is being written: inventing detail that isn't grounded in the real source material, and defaulting to generic "well-written" prose instead of the author's actual voice.

This skill is decomposed by **composition type** (technical article, conceptual essay, academic writeup, and whatever else gets added later) because the types diverge early and structurally — whether code or citations appear at all, whether real names stay in or get generalized away, whether sections follow a chronological arc, a concept-by-concept structure, or a formal argument structure. The workflow below is universal; the type-specific spec in `references/writing-types.md` fills in the parts that differ.

## Workflow

Follow these steps in order. Do not skip step 2 even when the subject matter is already well understood — voice calibration is the part most likely to be skipped and it is the part that most determines whether the result feels authored or generated.

### Step 0: Pick the composition type

Read `references/writing-types.md` and pick a type before doing anything else — it's a registry, not a fixed list, so a request that clearly wants a shape no current type covers is a signal to add a new type there (see its template) rather than force-fitting the closest existing one. Currently registered: **Narrative Feature Writeup** (a technical story with a chronological arc), **Conceptual Essay** (an opinionated, concept-by-concept infodump with no chronological arc), and any further types appended over time (e.g. an academic/research writeup would need its own entry for citation policy, formal argument structure, and register — add it there rather than improvising inline the first time it's actually requested).

Default to **Narrative Feature Writeup** unless the request explicitly rules out a story/tutorial/case-study/postmortem/autobiographical shape, or asks for something organized around ideas and opinions rather than a chronological arc, in which case use **Conceptual Essay**. If neither reading is clearly right, ask — guessing wrong here means redoing the whole draft, not just a paragraph.

Once picked, the type governs: the macro-structure in place of a generic outline, the evidence/citation policy, the sanitization level, and the closing convention. Steps 1 and 2 below apply to every type; steps 3 and 4 point back to the type's own spec for anything that differs.

### Step 1: Ground the content in real source material

Before writing a single sentence, establish what actually happened or what actually exists. For a codebase-grounded piece (technical article or conceptual essay):

- Read the real source files involved, not a paraphrase from memory.
- Run `git log --reverse --format='%ad %h %s' --date=short -- <paths>` to get the true chronological order of changes. Do not trust a plain `git log` (newest-first) without checking direction, and filter out unrelated noise (checkpoint commits, unrelated refactors) before treating the order as a narrative.
- Pull the actual diffs of the commits that matter (`git show <sha> -- <path>`) so quoted code and described bugs are the real thing, not a plausible reconstruction.
- If a piece needs more grounding material than what's already been established in conversation (e.g. pushing a conceptual essay's word count up with a genuinely new section rather than padding existing ones), read further into the codebase specifically looking for mechanisms not already used, rather than stretching one mechanism across multiple sections. A subagent search is often the right tool for this when the codebase is large — brief it with the mechanisms already used so it doesn't rediscover the same ones.
- Never fabricate a bug, a metric, a timeline, or a citation. If a detail isn't recoverable from the code, the history, or a real source, leave it out or ask.

For an academic or research-adjacent piece, the equivalent grounding is real citations and verified claims — never invent a source, a study result, or a statistic that can't be traced back to something real.

### Step 2: Calibrate voice against the author's own corpus, not a generic standard

The author's corpus lives on Medium, fetched via the RSS feed at `https://medium.com/feed/@yehezkieldio` (dev.to is a rare mirror, not the primary source — don't default to it). Fetch the feed first to see the current list of published pieces, then fetch 1–3 of the actual stories (prioritize ones closest in subject matter to the new article, e.g. a systems/Rust piece for another systems piece). Request **verbatim quotes**, not a summary — a summary of "the tone is conversational yet technically authoritative" is useless for imitation; the actual sentences are not. Specifically request:

- The exact paragraphs before the first section heading, in full and in order (this reveals the intro shape: how many paragraphs, what each one does).
- A handful of section headings verbatim, to see the real ratio of descriptive-technical vs. playful/irreverent headings — don't assume it's "make every heading a joke" or "make every heading descriptive" without checking.
- A few full paragraphs mid-article, to see actual sentence rhythm and paragraph shape.
- The closing paragraph(s).

Extract concrete, falsifiable patterns from this (see `references/style-corpus.md` for how to structure the analysis and what to look for). Do not proceed to drafting on a vibe-based impression of "technical and punchy" — that produces generic prose that merely sounds technical.

### Step 3: Find the type's central sentence

For **Narrative Feature Writeup**: check whether the author's other pieces open by reframing the mundane problem as a sharper abstraction early (e.g., "this is fundamentally a compression problem," "a distributed systems problem masquerading as a chat bot"). If that's a pattern in the corpus, the new article needs its own version: one sentence, stated early, that every subsequent section becomes a *consequence* of rather than a separate topic. Find this before outlining sections — it determines the order sections should appear in (the sentence that unlocks the rest of the argument goes near the front, not wherever it was chronologically discovered).

For **Conceptual Essay**: find the central tension the whole piece orbits (e.g. "small infrastructure does not produce small software") the same way — before outlining the per-concept sections in `references/writing-types.md`, since it determines which concept opens the piece and which reads as a consequence of which.

For a future academic/research type: the equivalent is the thesis or research question stated early enough that every section reads as evidence toward it, not a separate topic.

### Step 4: Draft to a local file, never publish directly

Write the draft to a local file in the working directory (e.g. `ARTICLE.md`), not to any publishing tool, unless the user explicitly asks to post it. Structure the piece according to the chosen type's spec in `references/writing-types.md` (opening shape, section pattern, evidence/code/citation policy, closing convention) — don't default to the narrative hook → reframe → consequences shape if the conceptual-essay type was chosen, or vice versa. See `references/anti-formulaic-writing.md` before writing a single paragraph, and re-check the draft against it before presenting.

Sanitize identifying details per the chosen type's sanitization policy (light for Narrative Feature Writeup, heavy for Conceptual Essay — see `references/writing-types.md`). Never mention unrelated private material (internal docs, other codebases, academic work) even in passing, regardless of type — this is a public-facing artifact.

### Step 5: Apply revisions surgically

When given revision feedback, distinguish between "fix this specific thing" and "rewrite it all." If the user quotes exact lines and says what's wrong with them, treat that as the scope — fix those lines and anything structurally downstream of them, don't take it as license to re-architect the whole piece. Only do a full rewrite when explicitly asked for one. When the user provides a long analytical critique (e.g., comparing against their other published work), read it for the *concrete, actionable* instructions inside it and apply those; don't treat the analysis prose itself as something to imitate or echo back.

### Step 6: Deliver platform metadata separately from the body

If asked for a subtitle and/or tags, give them as a short separate answer, not folded into the article file itself unless the user asks for them in the file.

**Cover/inline images:** if an image is going in at all, it belongs before the title/subtitle block (classic Medium pattern: title → subtitle → image → opening paragraph), never dropped mid-opening — an image between the hook and its continuation breaks the momentum the opening was built to have. For a Conceptual Essay especially, ask whether a generic stock photo is worth including at all; an abstract systems piece often reads better with no image than with a mismatched one chosen just to satisfy a template.

**Subtitle (Medium dek):** this is not the article's opening line and not a marketing-style summary — it's a distinct, deliberately crafted one-liner shown under the title on the profile/feed view. The real pattern, confirmed from the author's own Medium home:

> "When async tasks panic and runtimes die, your subprocess guard is the last code that runs. Make it count. (And watch out for ^C.)"
> "Building a fail-open deduplication cache in Rust with batched writes, exponential backoff, and graceful degradation."
> "Recursive diff chunking, token-aware compression, and why solving your own friction beats general-purpose mediocrity."

The shape is usually one of two things: (a) a comma-separated list of the concrete techniques/mechanisms in the piece, closed with a wry "why X beats/is Y" thesis clause, or (b) a short two-sentence beat — a plain statement of what happened, then an imperative or a parenthetical aside that undercuts it slightly. Don't reuse the article's actual first sentence as the subtitle — draft a new, tighter line in one of these two shapes, anchored on the piece's central reframe (the one-sentence claim from Step 3), not a generic feature list.

**Tags:** 5 tags, ordinary lowercase topic/technology words (language, protocol/concept, platform, discipline) — not hashtags, not marketing phrases. Base them on what the piece is actually about (a systems piece gets the language + the specific mechanism + the broader discipline, e.g. `typescript`, `sse`, `webdev`, `softwaredesign`, `nextjs`), not a generic SEO list.

## Common mistakes to avoid

- Skipping Step 0 and defaulting to the Narrative Feature Writeup shape out of habit, including code and real names in a piece that asked to be a Conceptual Essay (or the reverse: writing a code-free abstract essay when the request wanted a concrete, code-backed writeup). Check the signals in `references/writing-types.md` before outlining.
- Stating a strong claim as an absolute about a whole category of technology or practice ("none of it is available to read," "external infrastructure is opaque") when the real claim only holds along a narrower line. A senior reader will have the one counterexample ready (an open-source broker, a managed service that exposes internals, a database with its own opaque internals) and use it to dismiss the entire point, not just the overstated part. Find what the claim is actually about before finalizing it — see "Claims and pushback" under the Conceptual Essay type in `references/writing-types.md`.
- For a Conceptual Essay specifically: naming the subject "a style" once is fine, but repeatedly writing "this style does X" / "this style treats Y as Z" turns the piece into commentary about itself instead of a direct description of the engineering. See "Avoid naming the subject as 'a style'" under the Conceptual Essay type in `references/writing-types.md`.
- Drafting from a generic outline (even a good one) before fetching and studying the author's real corpus. Outline-first produces structure that has to be torn down and rebuilt once the real voice is checked. Study first.
- Meta-narrative throat-clearing about the article itself ("what follows is...", "this piece will cover...", "this is an examination of...", "this is a story about..."). Don't announce the piece before writing it — jump straight into the subject matter, and let the reader infer what kind of piece it is from how it reads.
- Hopeful/toiling clichés framing effort as a triumph ("it took an afternoon to get right, it took two months to get wrong" — style constructions like this read as performative struggle, not genuine voice, unless the corpus actually does this).
- Presenting a sequence of changes as a flat list ("first we added X, then Y, then Z") when the corpus's actual pattern is each addition answering a *distinctly different question* than the last — make that difference explicit instead of just sequencing them.
- Assuming headings should all be either purely descriptive or all playful without checking the real ratio in the corpus.
- Ending with a generic recap ("in summary, we built..."). Match the chosen type's non-recap closing convention instead (what the design explicitly does *not* guarantee for Narrative Feature Writeup; a real boundary condition for Conceptual Essay, not a taxonomy of the piece's own doctrine — see `references/writing-types.md`).
- Adding real length to a long piece by padding existing sections with restated aphorisms or a fourth re-explanation of the same mechanism, instead of finding a genuinely new piece of grounding material (a distinct mechanism in the codebase, a distinct citation) and giving it its own section. Length that comes from repetition reads as padding no matter how well the sentences are polished; length that comes from a new real example reads as depth.

## Long-form pacing and accessibility

For a piece long enough to be a 20+ minute read, dense argument paragraphs need occasional breathing room. Insert short (1–2 sentence) standalone interludes between heavier sections — set off as a blockquote, not a heading — that reset the reader without restating what was just covered or previewing what's next in detail. Space them roughly every 3–4 sections, not every section; overuse turns the device into its own tic and defeats the purpose. An interlude is a beat, not a summary and not a transition sentence dressed up as one.

If the piece is meant to be readable by someone technical-but-not-expert (ask if unclear), gloss unfamiliar jargon inline the first time it appears — a short parenthetical, not a footnote or a dedicated sentence — rather than assuming the term is already known. Where a concept has a well-known name or origin (a named pattern, a coined term, a classic essay), anchor-link it to its canonical source (Wikipedia, the original post that coined it, official docs) rather than re-explaining it from scratch; this matches the corpus's own habit of linking out to primary references instead of restating them.

## Additional resources

- `references/writing-types.md` — the registry of supported composition types (currently Narrative Feature Writeup and Conceptual Essay), each with its own structure, evidence/code/citation policy, sanitization level, and closing convention. Append a new type here rather than improvising a third shape inline — an academic writeup, a formal proposal, or any other recurring shape belongs here once it's actually needed, not before.
- `references/style-corpus.md` — how to structure the voice-calibration analysis once source pieces are fetched, and the categories of pattern to extract. Applies regardless of chosen type.
- `references/anti-formulaic-writing.md` — the concrete, ever-growing list of formulaic and AI-typical writing patterns to screen every draft against before presenting it. Applies regardless of chosen type or subject matter — the patterns it names (reflexive negation pivots, mic-drop paragraph endings, "most systems/most people" contrast openers, symmetrical binary comparisons, and more) are generic tells, not technical-writing-specific ones.
