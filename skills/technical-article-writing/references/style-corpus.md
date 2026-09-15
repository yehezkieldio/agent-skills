# Structuring a voice-calibration pass

Use this after fetching 1–3 of the author's own published articles (verbatim quotes, not summaries — see SKILL.md step 2). Extract patterns into these categories before drafting anything. Cite the actual quoted line next to each pattern; a pattern without a quoted example backing it is a guess, not a finding.

## Categories to extract

**1. The opening reframe.** Does the piece state, early, a one-sentence reframing of the problem into a sharper abstraction ("this is fundamentally a compression problem")? If yes, the new article needs its own version of this sentence, placed at the same relative position (usually end of the intro block, before the first heading).

**2. Intro shape.** How many paragraphs appear before the first section heading, and what does each one do? A common shape is: (1) a short, blunt 1–2 sentence hook stating the problem starkly, (2) a context paragraph naming the project/domain and folding any secondary comparison or alternative-approach discussion into a single clause rather than a dedicated section, (3) a thesis paragraph stating the reframe and the tension the rest of the piece resolves. Confirm the actual count and content against the fetched text — don't assume three just because a prior article had three.

**3. Heading register.** Pull every heading from the source article(s) and classify each as: technical-noun-with-thesis (e.g. "A Problem of Temporal Mismatch"), blunt/irreverent (e.g. "RAII? I barely know her!"), or pure description. Report the actual ratio. The common finding is "mostly technical-thesis headings, with an occasional deliberately irreverent one" — not "every heading is a joke."

**4. Paragraph shape.** Look at 3–5 full paragraphs mid-article. The common shape across dense technical essays is: assertion → complication → concrete mechanism → consequence → opinion. Confirm this isn't simply "claim → code → explanation," which reads as flatter and more generic.

**5. Sentence rhythm.** Note the alternation pattern: a longer sentence chaining observation → mechanism → consequence, followed by a short blunt sentence, followed by a qualification. Pull 2–3 verbatim examples of the blunt-fragment technique (e.g. "The process keeps running." / "Not delayed. Gone.").

**6. Transition vocabulary.** Collect the actual phrases used to pivot from an obvious solution to the real complication: "but here's the subtle part," "that sounds reasonable until," "except," "or rather," "this is mostly true, but 'mostly' is doing a lot of work here." Use these sparingly in the new draft (roughly once every 2–3 paragraphs, not every paragraph — overuse reads as a tic).

**7. The trade-off structure.** Check whether every major design decision in the source articles is explicitly framed as "we knowingly accept cost X because Y matters more," rather than just described and left unjustified. If so, every section of the new article needs this same explicit justification, not just a description of what was built.

**8. The ending.** Does the piece end with a recap, or with an explicit statement of what the design does *not* guarantee, followed by one short, quotable closing line? Match whichever the corpus actually does — don't default to a summary paragraph.

## Applying it

Once these eight categories are filled in with real quoted evidence, draft the new article section by section, checking each section against the extracted patterns rather than against a generic sense of "technical blog voice." If a drafted paragraph doesn't match the paragraph-shape pattern found in the corpus, rewrite it before moving on rather than fixing it in a later pass — later passes tend to polish sentences without fixing structural mismatches.
