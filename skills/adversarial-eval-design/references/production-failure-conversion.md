# Converting a Production Failure into a Permanent Test Case

A production failure is a pre-validated eval case: it already proves the scenario
occurs in reality and that current behavior is wrong. Treat "fixed the bug" and "added
the regression case" as two separate, both-required steps — a fix without a
corresponding test is a fix that can silently regress.

## Process

1. **Reconstruct the exact trigger.** Pin down the precise input, sequence of events,
   and system/data state that produced the failure — not an approximation of it. Pull
   from logs, error ids, request ids, or incident timestamps where available rather
   than reconstructing from memory. A vague reproduction ("something like a large
   order") is not enough to prevent a narrower recurrence of the same root cause.

2. **Separate the trigger from the root cause.** The trigger is what a test needs to
   reproduce; the root cause is what the fix needs to address. Write the case around
   the trigger, and confirm the fix actually addresses the root cause rather than only
   the specific symptom observed — otherwise a slightly different trigger with the same
   root cause will slip through un-caught.

3. **Write the case at the right layer.** Reproduce the failure as close to where it
   actually occurred as possible (unit-level if it's a pure logic bug, integration- or
   API-level if it involves multiple components or real I/O). A case that only
   reproduces the symptom at a much higher level is more brittle and slower to run.

4. **Mark provenance and severity in the case metadata.** Tag the case as
   incident-derived and record its severity (see `severity-weighting.md`) so future
   triage understands why this specific, possibly-obscure case exists. An unexplained
   odd test case tends to get deleted by someone who doesn't know its history.

5. **Generalize one step, but not further.** If the incident reveals a category of bug
   (e.g. "any time zone offset is unhandled," not just "this one offset"), add
   coverage for the class of input the taxonomy category implies — but don't invent
   speculative scenarios that didn't actually occur and aren't clearly implied by the
   root cause; that drifts back into guessing rather than evidence-based coverage.

6. **Verify the case fails against the pre-fix code and passes against the fix.**
   Confirm the case actually catches the original bug (run it against a checkout
   before the fix, or temporarily revert the fix) before trusting it as a real
   regression guard — a case that passes even without the fix protects nothing.

## When no production history exists yet

For a new system or a feature with no incident history, this step doesn't apply yet —
rely on the scenario taxonomy and business-workflow scoping instead. Don't fabricate
plausible-sounding "incidents" to fill this category; an invented scenario belongs
under the adversarial/edge-case taxonomy, labeled as such, not misrepresented as
incident-derived.
