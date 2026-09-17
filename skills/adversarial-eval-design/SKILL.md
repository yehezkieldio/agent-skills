---
name: adversarial-eval-design
description: This skill should be used when the user asks to "design test cases", "build an eval set", "audit test coverage", "check for edge cases", "review for adversarial scenarios", "stress test this", "harden the test suite", "convert this incident into a test", "weight failures by severity", "avoid happy-path testing", or otherwise wants to determine whether a system, subsystem, module, function, or piece of code behaves correctly under realistic, adversarial, or production-shaped conditions rather than only the intended/expected path. Applies to any codebase or component — not specific to AI/LLM model evaluation.
---

# Adversarial Eval Design

Design and audit test/eval sets that answer one question: does this system behave
correctly under the conditions it will actually face, not just the conditions it was
written to handle? A test suite that only exercises the happy path measures that the
code does what its author imagined — not that it survives contact with real usage,
malformed input, concurrent access, partial failure, or an adversarial user.

Evaluation exists to inform a decision (ship, don't ship, this is safe, this is broken).
A pile of passing tests that never touched a hard case is not evidence of correctness —
it is evidence of untested correctness. Treat every eval/test set the same way: as a
claim about coverage that must be checked, not assumed.

## When to apply this

Use this skill whenever the task is to design new tests for a system/subsystem/function,
or to audit whether an existing test suite is actually sufficient — not just whether it
passes. It applies at any granularity: a single function, an API endpoint, a subsystem
(e.g. an inventory ledger, an auth flow, a payment path), or a whole service.

It does not apply to writing implementation code itself, and it is not an AI/LLM-grading
framework — the "eval set" here is an ordinary test suite, fuzz corpus, or QA checklist;
"grading" is ordinary assertions, not a judge model.

## Core procedure

Work through these steps in order. Skip a step only when it is clearly inapplicable
(e.g. no production history exists yet for a brand-new system) and say so explicitly.

### 1. Scope to what matters to the business/system, not what's easy to test

Before writing a single case, identify the workflows whose failure would actually hurt:
high-volume paths (run constantly, so any bug compounds), high-consequence paths
(money, data integrity, security, safety), and high-risk paths (complex, recently
changed, or historically fragile). Concentrate eval effort there first. Do not spend
equal effort on a rarely-used admin toggle and the core write path just because both
are equally easy to unit test.

Ask: "If this broke in production, who would notice, how fast, and how bad would it
be?" Rank candidate test targets by that answer before writing cases.

### 2. Structure each case so it stands on its own

Every eval/test case should carry enough information to be understood and re-run
without the original author present:

- **Input / trigger** — the exact request, call, or event that starts the scenario
- **Preconditions / state** — what the system, database, or environment looks like
  going in (this is often the part happy-path tests skip and where real bugs hide)
- **Expected outcome** — the specific, checkable result (not "it should work")
- **Assertion / grading rule** — how a pass/fail is mechanically determined
- **Metadata** — category (edge case, adversarial, regression-from-incident, etc.) and
  severity (see step 5), so the suite can be triaged, not just counted

A test with an unstated precondition or a vague expected outcome ("handles it
gracefully") is not a real eval case — tighten it before counting it as coverage.

### 3. Check representativeness before trusting the suite

A green test suite only means something if its distribution matches reality. Check:

- Are difficulty levels represented (trivial, typical, hard, pathological), or does the
  suite cluster entirely around the easy end?
- Are known failure modes from this codebase's history represented?
- Are rare-but-severe scenarios present even though they're rare? A once-a-year case
  that would cause financial, legal, safety, or irreversible-data damage deserves a
  test even at low frequency — frequency and impact are independent axes, weight by
  impact, not just how often it happens.

If a category of real usage has zero cases, that is a coverage gap to name explicitly,
not something to infer is "probably fine."

### 4. Actively work against happy-path bias

Do not wait for edge cases to occur to you — enumerate them systematically. For any
target, walk the categories in `references/scenario-taxonomy.md` (boundary values,
malformed/missing/oversized input, concurrency and ordering, partial/interrupted
failure, resource exhaustion, stale or inconsistent state, adversarial/malicious input,
upstream/downstream dependency failure) and check each one against the target instead
of relying on whatever cases come to mind first. Most under-tested systems fail not
because edge cases are unknown in the abstract, but because nobody walked the checklist
against this specific target.

### 5. Turn production failures into permanent cases

Every real incident, bug report, or production failure is a free, pre-validated eval
case — it already proves the scenario occurs and the current behavior is wrong. When a
production failure exists (a bug report, an incident writeup, a postmortem, a support
ticket), convert it into a regression case using the process in
`references/production-failure-conversion.md` before considering the fix complete. A
fix without a corresponding permanent test is a fix that can silently regress.

If no production history exists yet (new system, new feature), say so and rely on
steps 1–4 instead — do not fabricate incidents that didn't happen.

### 6. Weight failures, don't just count them

Not every failing case matters equally. Classify each case's severity before rolling
results into a decision — see `references/severity-weighting.md` for a concrete
severity rubric (critical / major / minor / cosmetic) and how to use it. A suite with
"98% pass rate" is meaningless without knowing whether the 2% failing are cosmetic
issues or the two cases that corrupt financial totals. Report failures by weighted
severity, not raw pass percentage, when the result will drive a ship/no-ship decision.

### 7. Guard against overfitting the suite

If the same people writing the implementation also write and see every test case,
tests can drift into checking "does the code do what the code does" rather than "does
the code do what it should." Counter this:

- Keep some cases intentionally unseen by whoever is implementing the fix, when
  feasible (a reviewer or separate pass writes/holds them)
- Rotate or refresh cases over time instead of letting the same fixed set calcify
- Watch production behavior separately from the test suite — if production diverges
  from what the suite predicts, that is a signal the suite has drifted from reality,
  not that production is wrong

### 8. Confirm decision-readiness before acting on results

Before treating "the suite passed" as "the system is correct," confirm:

- Coverage actually includes the business-critical paths (step 1), not just what was
  convenient to test
- Cases are well-formed enough to be trusted (step 2)
- Known failure modes and edge/adversarial categories are represented (steps 3–4)
- Any failures are triaged by severity, not just counted (step 6)

If any of these is missing, say so explicitly rather than presenting a pass/fail number
as a finished verdict.

## Output format when auditing an existing suite

When asked to audit rather than design from scratch, report findings as a gap list, not
a narrative: for each business-critical workflow, state what's covered, what's missing
(by taxonomy category from `references/scenario-taxonomy.md`), and what severity of
risk the gap represents. Prioritize closing high-severity, high-likelihood gaps first.

## Additional resources

- `references/scenario-taxonomy.md` — the checklist of adversarial/edge-case categories
  to walk against any target (boundary, malformed input, concurrency, partial failure,
  resource exhaustion, stale state, adversarial input, dependency failure)
- `references/production-failure-conversion.md` — the process for turning an incident,
  bug report, or postmortem into a permanent regression case
- `references/severity-weighting.md` — the severity rubric and how to use weighted
  failure counts instead of raw pass rate in a ship/no-ship decision
- `examples/eval-case-template.md` — a fill-in-the-blank template matching the case
  structure in step 2
