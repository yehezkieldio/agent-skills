# Composition type index

This file is a dispatcher, not a spec. Read it, pick the one type file the request actually needs, then go read only that file — do not read multiple type files "to be safe" for an ordinary single-type request. This is the entire point of splitting types into separate files: picking Conceptual Essay should never pull Academic/Thesis Writeup content into context, or vice versa.

Registered types, in default-first order:

| Type | File | Pick this when the request... |
|---|---|---|
| Narrative Feature Writeup | `type-narrative-feature.md` | asks to write up a bug/feature/refactor/commit as a story, with no further qualification. This is the default. |
| Conceptual Essay | `type-conceptual-essay.md` | explicitly rules out a story/tutorial/case-study/postmortem/autobiographical shape, or asks for an opinionated, idea-organized piece rather than a chronological one. |
| Academic/Thesis Writeup | `type-academic-thesis.md` | is a formal academic manuscript governed by an institutional guideline — a thesis/dissertation chapter, a research proposal, or anything judged by an advisor/examiner against a written program template, in any language. |

## How to pick

Default to **Narrative Feature Writeup** — it's what most "write an article about this" requests want, and it's the shape most published technical-writing corpora already use.

Switch to **Conceptual Essay** on signals like "not a tutorial, not a case study, not a postmortem, not autobiographical," "opinionated infodump," "structured conceptual essay," or "I want to discuss ideas, not narrate how I found them."

Switch to **Academic/Thesis Writeup** on signals like "thesis," "dissertation," "academic manuscript," "research proposal," or a request to draft/edit an introduction, literature-review, methodology, results, or conclusion chapter against an institutional guideline.

If the request doesn't clearly signal any of these, or wants something no type quite covers, ask rather than guessing — the types diverge early (code vs. no code, real names vs. generalized evidence, chronological vs. concept-by-concept vs. institutionally-mandated), and guessing wrong wastes a full draft.

## Cross-mix requests

A request can genuinely want elements of two types at once — a thesis-adjacent conceptual essay written for a general audience but held to citation standards, or a narrative case-study writeup that also needs a formal evidentiary register. Don't force a single type onto a piece that's actually asking for a blend: read the type files for each type actually needed (usually two, rarely more), and before drafting, state out loud which one is the *primary* structural shape (the one governing macro-structure and closing convention) and which is contributing a secondary constraint (usually the evidence/citation policy or the sanitization level). Drafting without naming the primary shape first tends to produce a piece that structurally belongs to neither type.

This is a judgment call, not a formula — most requests are a clean single-type match, and reading two type files "just in case" defeats the purpose of the split. Only go to two files when the request's own wording genuinely asks for both a shape and a constraint that belong to different types.

## Adding a new type

This is a registry, not a fixed list. A request that clearly wants a shape no current type covers (a tutorial, a postmortem, a manifesto, a formal proposal) is a signal to register a new type rather than force-fitting the closest existing one — copy `type-template.md` into a new `type-<name>.md` file, fill it in, and add a row to the table above. Check with whoever is asking before treating a genuinely new type as in-scope; this skill's default charter doesn't cover every shape of writing that exists.
