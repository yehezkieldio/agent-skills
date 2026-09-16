# Type: Narrative Feature Writeup

**Signals:** "write an article about this bug/feature/refactor," "turn this commit into a post," "write it up in my style" with no further qualification. This is the default type when signals are ambiguous.

**Grounding:** real commits, real diffs, real bug behavior, pulled via git history (Step 1 in `SKILL.md`). The system's real name and identifying details generally stay in, matching how a technical author's own published pieces typically name their projects — only anonymize if asked to.

**Structure:**

1. A short, blunt 1–2 sentence hook stating the problem starkly.
2. A context paragraph naming the project/domain, folding any secondary comparison into a single clause rather than a dedicated section.
3. A thesis paragraph stating the one-sentence reframe (see below) and the tension the rest of the piece resolves.
4. Sections that each read as a *consequence* of the reframe, not a flat "first we did X, then Y" chronological list — each addition should answer a genuinely different question than the last one did.
5. Real code snippets are expected and central: they're the evidence, quoted and discussed, not just described.
6. Closing states what the design explicitly does *not* guarantee (or an equivalent non-recap move), landing on one short, quotable line. No generic "in summary, we built..." recap.

**The one-sentence reframe:** check whether the target corpus opens pieces by reframing the mundane problem as a sharper abstraction early (e.g. "SSE here is cache invalidation with a socket attached to it"). Find this sentence before outlining sections — it determines section order, since the sentence that unlocks the rest of the argument goes near the front, not wherever it was chronologically discovered.

**Code and evidence policy:** code snippets, real function/variable names, and real bug descriptions are all in scope and expected. Quote the actual diff or the actual broken behavior rather than a plausible reconstruction.

**Sanitization:** light. Keep the real project name and real technical stack unless told otherwise. Still never expose secrets, credentials, or genuinely private operational detail (internal URLs, customer data, etc.).

**Closing convention:** state what the design explicitly does *not* guarantee, or an equivalent non-recap move — never a generic "in summary, we built..." wrap-up.

## Common mistakes specific to this type

- Presenting a sequence of changes as a flat list ("first we added X, then Y, then Z") when each addition should answer a genuinely different question than the last — make that difference explicit instead of just sequencing them.
- Hopeful/toiling clichés framing effort as a triumph ("it took an afternoon to get right, it took two months to get wrong"). Reads as performative struggle rather than genuine voice unless the target corpus actually writes this way.
- Assuming headings should be either purely descriptive or all playful without checking the real ratio in a corpus sample first.

## Example signals from a real corpus

Real piece titles that exemplify this type: "One EventSource to Rule Them All," "When Drop is Your Last Line of Defense," "Fail-Open Cache with Batched Writes and Exponential Backoff." These are technical-noun-with-thesis headlines, not generic feature descriptions — see `style-corpus.md` for how to extract this pattern from a specific author's corpus rather than assuming it.
