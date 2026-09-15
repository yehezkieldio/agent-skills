---
name: technical-article-writing
description: This skill should be used when the user asks to "write an article about", "draft a Medium/dev.to post", "turn this feature into an article", "write it up in my style", "make an article out of this commit/bug/design decision", or wants a technical engineering writeup authored in their own established voice rather than generic AI prose. Applies to any codebase — grounds the article in real code and git history from the current project and calibrates voice against the author's own published corpus.
version: 0.1.0
---

# Technical Article Writing

Turn a real engineering decision (a bug, a refactor, a design tradeoff) found in the current codebase into a publishable technical article that reads as authored by this specific person, not by a model executing an outline. The two failure modes this skill exists to prevent: inventing implementation detail that isn't in the code, and defaulting to generic "well-written engineering blog" prose instead of the author's actual voice.

## Workflow

Follow these steps in order. Do not skip step 2 even when the technical content is already well understood — voice calibration is the part most likely to be skipped and it is the part that most determines whether the result feels authored or generated.

### Step 1: Ground the content in the real system

Before writing a single sentence, establish what actually happened:

- Read the real source files involved, not a paraphrase from memory.
- Run `git log --reverse --format='%ad %h %s' --date=short -- <paths>` to get the true chronological order of changes. Do not trust a plain `git log` (newest-first) without checking direction, and filter out unrelated noise (checkpoint commits, unrelated refactors) before treating the order as a narrative.
- Pull the actual diffs of the commits that matter (`git show <sha> -- <path>`) so quoted code and described bugs are the real thing, not a plausible reconstruction.
- Never fabricate a bug, a metric, or a timeline. If a detail isn't recoverable from the code or history, leave it out or ask.

### Step 2: Calibrate voice against the author's own corpus, not a generic standard

The author's corpus lives on Medium, fetched via the RSS feed at `https://medium.com/feed/@yehezkieldio` (dev.to is a rare mirror, not the primary source — don't default to it). Fetch the feed first to see the current list of published pieces, then fetch 1–3 of the actual stories (prioritize ones closest in subject matter to the new article, e.g. a systems/Rust piece for another systems piece). Request **verbatim quotes**, not a summary — a summary of "the tone is conversational yet technically authoritative" is useless for imitation; the actual sentences are not. Specifically request:

- The exact paragraphs before the first section heading, in full and in order (this reveals the intro shape: how many paragraphs, what each one does).
- A handful of section headings verbatim, to see the real ratio of descriptive-technical vs. playful/irreverent headings — don't assume it's "make every heading a joke" or "make every heading descriptive" without checking.
- A few full paragraphs mid-article, to see actual sentence rhythm and paragraph shape.
- The closing paragraph(s).

Extract concrete, falsifiable patterns from this (see `references/style-corpus.md` for how to structure the analysis and what to look for). Do not proceed to drafting on a vibe-based impression of "technical and punchy" — that produces generic prose that merely sounds technical.

### Step 3: Find the one-sentence reframe

Check whether the author's other pieces open by reframing the mundane problem as a sharper abstraction early (e.g., "this is fundamentally a compression problem," "a distributed systems problem masquerading as a chat bot"). If that's a pattern in the corpus, the new article needs its own version: one sentence, stated early, that every subsequent section becomes a *consequence* of rather than a separate topic. Find this before outlining sections — it determines the order sections should appear in (the sentence that unlocks the rest of the argument goes near the front, not wherever it was chronologically discovered).

### Step 4: Draft to a local file, never publish directly

Write the draft to a local file in the working directory (e.g. `ARTICLE.md`), not to any publishing tool, unless the user explicitly asks to post it. Structure the opening as the corpus dictates (often: hook → domain context with secondary comparisons folded into a single clause, not a dedicated section → thesis paragraph naming the reframe), then let remaining sections each read as a consequence of that reframe rather than a flat chronological "then we did X" list. See `references/anti-ai-isms.md` before writing a single paragraph, and re-check the draft against it before presenting.

Sanitize identifying details: replace the real project/company/private codename with a generic domain description unless the user says otherwise. Never mention unrelated private material (internal docs, other codebases, academic work) even in passing — this is a public-facing artifact.

### Step 5: Apply revisions surgically

When given revision feedback, distinguish between "fix this specific thing" and "rewrite it all." If the user quotes exact lines and says what's wrong with them, treat that as the scope — fix those lines and anything structurally downstream of them, don't take it as license to re-architect the whole piece. Only do a full rewrite when explicitly asked for one. When the user provides a long analytical critique (e.g., comparing against their other published work), read it for the *concrete, actionable* instructions inside it and apply those; don't treat the analysis prose itself as something to imitate or echo back.

### Step 6: Deliver platform metadata separately from the body

If asked for a subtitle and/or tags, give them as a short separate answer, not folded into the article file itself unless the user asks for them in the file.

**Subtitle (Medium dek):** this is not the article's opening line and not a marketing-style summary — it's a distinct, deliberately crafted one-liner shown under the title on the profile/feed view. The real pattern, confirmed from the author's own Medium home:

> "When async tasks panic and runtimes die, your subprocess guard is the last code that runs. Make it count. (And watch out for ^C.)"
> "Building a fail-open deduplication cache in Rust with batched writes, exponential backoff, and graceful degradation."
> "Recursive diff chunking, token-aware compression, and why solving your own friction beats general-purpose mediocrity."

The shape is usually one of two things: (a) a comma-separated list of the concrete techniques/mechanisms in the piece, closed with a wry "why X beats/is Y" thesis clause, or (b) a short two-sentence beat — a plain statement of what happened, then an imperative or a parenthetical aside that undercuts it slightly. Don't reuse the article's actual first sentence as the subtitle — draft a new, tighter line in one of these two shapes, anchored on the piece's central reframe (the one-sentence claim from Step 3), not a generic feature list.

**Tags:** 5 tags, ordinary lowercase topic/technology words (language, protocol/concept, platform, discipline) — not hashtags, not marketing phrases. Base them on what the piece is actually about (a systems piece gets the language + the specific mechanism + the broader discipline, e.g. `typescript`, `sse`, `webdev`, `softwaredesign`, `nextjs`), not a generic SEO list.

## Common mistakes to avoid

- Drafting from a generic outline (even a good one) before fetching and studying the author's real corpus. Outline-first produces structure that has to be torn down and rebuilt once the real voice is checked. Study first.
- Meta-narrative throat-clearing about the article itself ("what follows is...", "this piece will cover..."). The author's real writing drops straight into the problem.
- Hopeful/toiling clichés framing effort as a triumph ("it took an afternoon to get right, it took two months to get wrong" — style constructions like this read as performative struggle, not genuine voice, unless the corpus actually does this).
- Presenting a sequence of changes as a flat list ("first we added X, then Y, then Z") when the corpus's actual pattern is each addition answering a *distinctly different question* than the last — make that difference explicit instead of just sequencing them.
- Assuming headings should all be either purely descriptive or all playful without checking the real ratio in the corpus.
- Ending with a generic recap ("in summary, we built..."). Check whether the corpus instead ends by stating what the design explicitly does *not* guarantee, or some other non-recap closing move, and match that.

## Additional resources

- `references/style-corpus.md` — how to structure the voice-calibration analysis once source articles are fetched, and the categories of pattern to extract.
- `references/anti-ai-isms.md` — the concrete list of AI-writing tells to screen every draft against before presenting it.
