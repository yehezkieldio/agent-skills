# Article types

This skill supports more than one shape of finished piece. Voice calibration (`style-corpus.md`) and the AI-tell screen (`anti-formulaic-writing.md`) apply to every type equally — what differs by type is the macro-structure, the code/evidence policy, the sanitization level, and the closing convention. Pick a type in Step 0 before outlining anything; drafting against the wrong type's shape is the most common way a piece has to be torn down and rebuilt.

This file is a registry, not a fixed list. Adding a third, fourth, or fifth type means appending a new `## Type: <Name>` section below, following the template at the bottom — nothing in SKILL.md needs to change to support a new type beyond pointing here.

## How to pick a type

Default to **Narrative Feature Writeup** — it's what most "write an article about this bug/feature/commit" requests want, and it's the shape the author's existing Medium corpus is written in.

Switch to **Conceptual Essay** when the request explicitly rules out a story/tutorial/case-study shape (e.g. "not a tutorial, not a case study, not a postmortem, not autobiographical," "opinionated infodump," "structured conceptual essay," "I want to discuss ideas, not narrate how I found them"), or asks for a piece organized around ideas/opinions rather than a chronological or narrative arc.

If the request doesn't clearly signal either, or seems to want something neither type quite covers, ask rather than guessing — the two types diverge early (code vs. no code, real names vs. generalized evidence, chronological vs. concept-by-concept), and guessing wrong wastes a full draft.

---

## Type: Narrative Feature Writeup

**Signals:** "write an article about this bug/feature/refactor," "turn this commit into a post," "write it up in my style" with no further qualification. This is the default.

**Grounding:** real commits, real diffs, real bug behavior, pulled via git history (Step 1). The system's real name and identifying details generally stay in, matching how the author's own Medium pieces name their projects (Azalea, cubic) — only anonymize if the user asks to.

**Structure:**
1. A short, blunt 1–2 sentence hook stating the problem starkly.
2. A context paragraph naming the project/domain, folding any secondary comparison into a single clause rather than a dedicated section.
3. A thesis paragraph stating the one-sentence reframe (see below) and the tension the rest of the piece resolves.
4. Sections that each read as a *consequence* of the reframe, not a flat "first we did X, then Y" chronological list — each addition should answer a genuinely different question than the last one did.
5. Real code snippets are expected and central: they're the evidence, quoted and discussed, not just described.
6. Closing states what the design explicitly does *not* guarantee (or an equivalent non-recap move), landing on one short, quotable line. No generic "in summary, we built..." recap.

**The one-sentence reframe:** check whether the author's other pieces open by reframing the mundane problem as a sharper abstraction early (e.g. "SSE here is cache invalidation with a socket attached to it"). Find this sentence before outlining sections — it determines section order, since the sentence that unlocks the rest of the argument goes near the front, not wherever it was chronologically discovered.

**Code and evidence policy:** code snippets, real function/variable names, and real bug descriptions are all in scope and expected. Quote the actual diff or the actual broken behavior rather than a plausible reconstruction.

**Sanitization:** light. Keep the real project name and real technical stack unless the user says otherwise. Still never expose secrets, credentials, or genuinely private operational detail (internal URLs, customer data, etc.).

**Examples in the corpus:** "One EventSource to Rule Them All," "When Drop is Your Last Line of Defense," "Fail-Open Cache with Batched Writes and Exponential Backoff."

---

## Type: Conceptual Essay

**Signals:** explicit exclusion of narrative/tutorial/case-study/postmortem/autobiographical framing; a request to discuss a *style* or *philosophy* of engineering rather than one specific fix; "opinionated," "infodump," "structured essay," "present and develop ideas" rather than "tell the story of."

**Grounding:** the current codebase is evidence used to answer one question only — "does this concept actually exist in the author's engineering?" — never "what does this application do?" Investigate real code and real mechanisms the same way as the narrative type (Step 1 still applies), but the write-up generalizes every finding into an abstract engineering concept before it reaches the page.

**Structure**, per concept, repeated as its own section:
1. Name the concept.
2. Explain it.
3. Examine its implications.
4. Connect it to related engineering ideas.
5. State the author's opinion or implementation preference on it, directly and declaratively — not hedged with "I prefer" / "I tend to" / "I consider," used only sparingly if at all.
6. Move to the next concept.

The piece as a whole opens with a short, personal-but-not-autobiographical grounding paragraph (what kind of work produced this obsession, in general terms — not a life story), then states the central tension directly rather than announcing the piece ("this is an examination of..." is a throat-clearing tell to avoid here specifically, see `anti-formulaic-writing.md`). It does not open by listing the sections to come.

**Code and evidence policy:** no code, no pseudocode, no SQL, no config listings, no API examples, no source excerpts, anywhere in the piece. Findings from the codebase get generalized into the underlying engineering concept (materialized state, authoritative state, reconciliation, constraint-driven design, causal compression, etc.) rather than described as the specific mechanism that produced them. If a finding can't be generalized without losing what makes it true, verify it thoroughly (a dedicated research pass over the codebase, checking each candidate concept against real evidence, is worth doing before drafting) but still describe it in the abstract vocabulary, not the concrete implementation.

**Sanitization:** heavy, but sanitization is about identity, not about specificity. No system name, business/client name, personal names, identifiable users, private operational detail, proprietary identifiers, secrets, credentials, or identifying URLs — generalize domain-specific entities into their engineering category (e.g. "an order-and-fulfillment domain" instead of the real business entity). What's still fine, and worth keeping in: a real, generalized number that doesn't identify the system (a timeout measured in minutes, a cap on a queue size, a percentage). A piece built entirely out of hypothetical-sounding generalities reads as invented even when it's grounded in real findings; a few real numbers, kept generic enough not to fingerprint the deployment, are what let a reader trust that the abstractions describe something that actually happened rather than something that sounds plausible.

**Tone:** can be more academic in vocabulary and precision than the narrative type, but should still read naturally, not too dense with jargon for a technical-but-not-expert reader (see "Long-form pacing and accessibility" in SKILL.md — this type is the one most likely to need it, since it tends to run long and abstract).

**Claims and pushback:** this type makes strong, opinionated claims by design, and that's the point — but a claim phrased as an absolute about a whole category of technology or practice ("brokers are opaque," "none of it is available to read") hands a senior reader a free counterexample (an open-source broker, a managed service that exposes internals, a database with its own opaque internals) and an excuse to dismiss the whole section on the strength of it. Before finalizing a strong claim, ask what a senior engineer with direct experience in that specific area would object to, then check whether the claim is really about something narrower and more defensible than what it's currently stated as. "External infrastructure is opaque" isn't that narrower claim; "the complexity exists outside your modification boundary — you can configure it, observe it, and work around it, but you don't own the assumptions that produced it" is, because it survives the counterexample instead of needing to outrun it. The reframed version should be *harder* to argue against than the original, not just softer or more hedged.

**If the title uses a technical word in a stretched sense, justify it once, early.** A title chosen for its rhythm or punch (e.g. pairing "infrastructure" with "algorithmic" as a matched contrast) can use a word in a broader sense than its precise technical meaning — nothing wrong with that, but a reader with the technical background will notice the gap if it's never addressed. One short, direct beat early in the piece ("'algorithmic' here isn't about complexity classes, it's about...") closes the gap without having to change the title or pretend the gap doesn't exist.

**Avoid naming the subject as "a style" or "this style."** It's tempting to write about the collection of preferences this type describes as if it were a labeled object ("this style optimizes for...", "this style treats X as permanent"), especially once the piece has explicitly called it a style once. Repeated after that, it reads like the essay is describing itself from the outside rather than just describing the engineering directly, closer to journal meta-commentary than to argument. Name the concept once if the piece needs to (e.g. in an opening or closing classification), then go back to describing what's actually happening — "the difficulty sits inside a boundary that can be modified" instead of "this style can modify the difficulty," "this inverts that order on purpose" instead of "this style inverts that order on purpose."

**Closing:** no recap, and no meta-move that lists everything covered and tells the reader how to receive it — a "here are the recurring fingerprints" section or a "here's which ideas are doctrine vs. quirk vs. technique" taxonomy both feel like a satisfying way to land the piece while drafting, but on a re-read they're the same throat-clearing problem the opening avoids, just moved to the end: the essay stepping outside itself to summarize and categorize its own content instead of just being the content.

The strongest closing move for this type is naming the boundary condition: state plainly, in real paragraphs, where the whole preference stops being the right call and the tradeoff actually reverses (a change in team shape, a change in scale, a change in who's still around to own the assumptions). This does real work a recap can't — it shows the claims were never meant as universal, which is what keeps the piece from reading as dogma. Don't manufacture this if the piece hasn't actually earned it; the boundary condition has to be a real, specific limit, not a hedge tacked on for balance.

Avoid, especially here: returning to the opening's personal image just to bookend it (it reads as a forced callback more often than an earned one); a fragment-pair "quotable" ending manufactured because it sounds like a mic drop rather than because the actual final thought is that compressed (see `anti-formulaic-writing.md`); introducing a genuinely new argument in the last section; and apologizing for or hedging the piece's own claims on the way out. One real, complete closing paragraph that says something specific beats a short punchy one that says something vague.

**Paragraph rhythm:** this type is essayistic, not a wall of text, but that doesn't mean short paragraphs everywhere — it means paragraphs have different jobs and the reader gets visual landmarks between them. A workable default inside a section: one short paragraph stating the claim, two to four longer paragraphs doing the actual explanatory work (complication, mechanism, consequence, qualification), then a short transitional beat before the next section. Three good moves inside that rhythm:

- *Hinge sentences.* A one-line standalone paragraph that rotates the reader from one idea to the next, placed where a section's argument turns rather than at a fixed interval — not a summary of what came before, and not a preview of what's coming, just the pivot itself ("Complexity never disappears. It only changes owners." / "The trigger count was never the real problem. The consequence count was."). A handful across a long piece is right; one per section is too many and starts reading as a tic.
- *Density relief.* When several consecutive sentences are all carrying real argumentative weight (the kind of sentence that took real effort to compress), let one plain, short sentence sit among them with no new content of its own ("That's the trade." / "The cost doesn't go away. It waits."). It gives the dense sentences around it room to land instead of blurring together.
- *Splitting for function, not length.* Break a paragraph in two when the two halves are doing genuinely different rhetorical work (context vs. extraction, claim vs. qualification), not on a word-count trigger. Don't over-split into one-sentence paragraphs as a reflex — that reads as manufactured profundity rather than rhythm, and the paragraphs in this type are allowed to still carry a real argument inside them.

**Example in the corpus:** "Infrastructure Minimalism and Algorithmic Maximalism."

---

**Length and section overlap:** the per-concept structure makes it easy to generate more sections than the piece actually needs, because a real mechanism found during research is often relevant to several different concepts at once (a query-cost registry is evidence for constraint-driven design, for performance-as-shape, and for mechanical sympathy, all at once). Writing a full section for each angle, each one re-explaining the same mechanism from scratch, produces a piece that's a third longer than it needs to be and reads as the same point made three times rather than three points. Before finalizing the section list, check: does more than one section re-describe the same underlying mechanism before making its point? If so, merge them — introduce the mechanism in full once, in whichever section is the best fit, and let the other angles show up as a paragraph inside that section or a brief callback elsewhere, not a full separate heading. A piece with real length pressure from distinct ideas is fine; a piece that's long because three sections independently re-explain the same registry is not.

**Own real inconsistencies instead of writing around them.** A close technical reader will notice when a claim and its evidence don't quite line up (a "strict by default" argument whose own example defaults to permissive; an "enforced" contract that turns out to be enforced by nothing but convention). Resist the instinct to write a paragraph that reframes the inconsistency until it sounds resolved — a sharp reader sees through the reframing and now also doubts the parts that were actually solid. State the inconsistency plainly, in one or two sentences, and say what survives around it. This is a smaller, more honest unit than a paragraph trying to argue the tension away, and it's consistent with the "Where This Breaks Down" style of closing.

**Real terminology, cited, beats reinventing the idea from scratch.** When a mechanism found in the codebase matches a named pattern in the wider field (event sourcing, CQRS, Tesler's Law, the transactional outbox pattern, mechanical sympathy), name it and link it rather than describing the idea in entirely original vocabulary as if no one had noticed it before. This does two things at once: it grounds an otherwise abstract essay in real prior art (which a technical reader checks for), and it's a natural, low-effort way to add an anchor link (see "Long-form pacing and accessibility" in SKILL.md). Get the term right, though — reaching for the closest-sounding pattern instead of the actually-correct one (CQRS when the mechanism is really event sourcing, for instance) reads as name-dropping rather than grounding.

**State the central tension early, not two sections in.** The per-concept structure can bury the piece's actual thesis under a section or two of table-setting about preferences and obsessions in general. Say the one-sentence central claim (see Step 3) directly in the opening, before the first heading, the same way the Narrative type states its reframe before its first heading. Sections after that then read as consequences of a claim the reader already has, not a claim the reader is still waiting for.

## Template for a new type

Copy this when adding a type this skill doesn't cover yet (a tutorial, a postmortem, a manifesto, an academic writeup, etc. — note that this skill's default charter currently excludes some of these from the two registered types; check with the user before treating a genuinely new type as in-scope):

```markdown
## Type: <Name>

**Signals:** <phrases or requests that indicate this type>

**Grounding:** <what gets pulled from the codebase/git history, and how directly it's used>

**Structure:** <the macro-shape: opening, section pattern, closing>

**Code and evidence policy:** <is code shown verbatim, described, or excluded entirely>

**Sanitization:** <how much identifying detail gets kept vs. generalized>

**Tone:** <anything type-specific beyond the shared voice calibration>

**Closing:** <the type's non-recap closing convention>

**Example in the corpus:** <a real piece, once one exists, that exemplifies this type>
```
