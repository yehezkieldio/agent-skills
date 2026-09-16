# Reviewing, auditing, and revising an existing piece

This applies whenever the request is about a piece that already exists — not necessarily one drafted with this skill — rather than starting from a blank file. "Review this article," "audit this manuscript for AI-writing tells," "apply this feedback," "check this draft against the checklist," and "revise based on what the reviewer said" are all this mode, not the drafting workflow in `SKILL.md`.

The composition type still matters here even though nothing is being drafted from scratch: read `type-index.md`, identify which type the existing piece is (or is closest to), and read that type's file before touching anything. The type governs which parts of `anti-formulaic-writing.md` apply at full strength and which get recalibrated (an Academic/Thesis Writeup treats certain formulaic-looking structures as required convention, not tells — see that type file).

## Decide the scope before touching anything

Two shapes of request look similar but aren't:

- **Report-only audit.** Read, find issues, describe them with evidence (quoted lines, file/location references), and stop — no edits. This is the right default for a document with real external stakes (a thesis or manuscript tied to someone's actual graduation, employment, or legal standing; anything the requester didn't personally author in this session; anything explicitly flagged as sensitive). Ask for the scope explicitly if it's ambiguous on a document like this, rather than guessing that editing is welcome.
- **Audit and fix.** Read, find issues, and apply fixes directly. This is appropriate once explicitly authorized ("fix them all," "adjust accordingly without my input"), or for a piece already in an established fast-iteration back-and-forth where the requester has been directing multiple rounds of changes and clearly wants forward progress over confirmation. Once authorized, apply fixes directly without re-confirming line by line — re-asking after authorization is friction, not diligence.

Getting this wrong in either direction is a real cost: auditing-only when direct fixes were wanted stalls progress; editing freely on a high-stakes document nobody asked to have changed is a trust problem, not just an inconvenience.

## Ground in what already exists before critiquing it

Check whether the project already has its own style guide or established conventions (a `WRITING_GUIDE.md`, a documented set of prior decisions in a project context file) before applying this skill's generic checklist. A project-specific guide is authoritative over this skill's generic defaults, the same precedence rule as an Academic/Thesis Writeup's institutional guideline — this skill fills gaps the project's own guide doesn't cover, it doesn't override it. Read the project guide in full first.

## Delegating a large audit

For a document too large to comfortably read and hold in context directly (many chapters, a long manuscript), delegate the read to a subagent rather than skipping sections or working from a partial read. Brief it with:

- The exact checklist to apply, pasted in full — a fresh subagent has no memory of this skill, so paste the relevant reference file's content (or the project's own style guide, if one governs) rather than referring to it by name.
- Explicit scope boundaries: prose/style only, not the underlying subject matter (research methodology, technical correctness, factual claims) unless specifically asked to review those too.
- Whether the task is report-only or fix-authorized, decided per the section above.
- An instruction to separate confident findings from borderline/uncertain ones, and to say explicitly when something might be a legitimate convention rather than a real violation — especially important for genre or language conventions a generic checklist wasn't written with in mind (see the Academic/Thesis type file's own list of language-specific patterns for a worked example of this distinction).
- An instruction not to manufacture findings to have something to report — a file or section with nothing wrong should be reported as clean, briefly.

## Applying an external critique

When handed someone else's written critique (a review, another session's analysis, a collaborator's notes) rather than asked to audit from scratch:

- Extract the concrete, actionable instructions inside it. Don't treat the critique's own prose as something to imitate or echo back — a critique written in an academic or clinical register doesn't mean the piece itself should adopt that register.
- If the critique quotes exact lines and states what's wrong with them, treat that as the fix's scope — don't take a critique of one paragraph as license to rewrite the whole piece.
- Watch for critique items that conflict with a requirement stated earlier in the same project (a critique flagging a specific sentence as formulaic when that exact sentence was originally requested, verbatim, as one of the piece's core stated opinions). When this happens, don't silently pick a side — preserve the substance of the original requirement while adjusting only what the critique specifically objects to (its placement, its surrounding framing), and say explicitly that this tension exists so the requester can override either way.
- After a critique-driven fix pass, re-screen the changed sections against the checklist again, not just the specific items the critique named — a fix applied under pressure to remove one tell can introduce or relocate a different one (a hedge word removed from one sentence often just moves the same hedging reflex to a new word nearby).

## A holistic pass is different from a checklist pass

A pass that mechanically hunts for checklist violations (a specific banned phrase, a specific construction) is not the same operation as a pass that checks whether the piece reads as one coherent whole. After several rounds of targeted fixes — especially ones that trimmed, merged, or reordered sections — do a full top-to-bottom read specifically for:

- Section-to-section and paragraph-to-paragraph transitions that got orphaned by an earlier cut (a callback sentence referencing material that was since moved or removed).
- Adjacent paragraphs that now happen to open with the same word or construction, a rhythm flaw that individual sentence-level fixes don't surface.
- Whether a structural device (a recurring aphorism style, a interlude pattern, a callback motif) is still used consistently now that some instances of it were cut and others weren't.

This pass is worth doing once real editing has stabilized, not after every single small fix — running it too early means redoing it once more fixes land.
