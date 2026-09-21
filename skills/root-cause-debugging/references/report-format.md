# Root-Cause Report Format

Use this structure for a full review, for a bug that spans layers, or on request. For a short bug, use the compact order in `SKILL.md`.

## Fields

1. Expected behavior: what must happen, in plain language.
2. Invariant: the rule that always holds, in one sentence.
3. What definitely did not happen: facts that the evidence rules out.
4. Bug class: for example hidden write, stale state, contract mismatch, race, or environment drift.
5. Causal chain: the steps from the intended action or event to the observed system effect.
6. First unintended side effect: the earliest write or request that must not happen.
7. Canonical source of truth: the one owner of the state.
8. Competing sources of truth: every other place that holds or mirrors the state.
9. Symptom: what the user or test saw.
10. Trigger: the condition that makes the symptom appear.
11. Root cause: one sentence.
12. Correct layer to fix first: and why lower or higher layers are not the right first fix.
13. Minimal safe fix: the smallest change that removes the root cause.
14. Architectural follow-up: larger changes for later, kept separate from the fix.
15. Proposed patch: the code change.

## Rules for Filling It In

- Separate symptom, trigger, and root cause. They are three different facts.
- Name the first visible wrong behavior, not only the final error.
- If a low-level fix is still needed, explain why the upstream fix is not enough, or why both are required.
- Do not make a contract more permissive unless the final design intends the observed payload.

## Example

A settings page shows "invalid payload" from the API on every load.

1. Expected behavior: opening the page reads settings and writes nothing.
2. Invariant: a page load never sends a write request.
3. Did not happen: the user did not press save.
4. Bug class: hidden write from a lifecycle hook.
5. Causal chain: the page mounts. A watcher on the form state fires during initial hydration. The watcher calls the save handler with an empty form. The API rejects the empty payload.
6. First unintended side effect: the save request sent at mount.
7. Canonical source of truth: the server record.
8. Competing sources: the local form state and a persisted draft in local storage.
9. Symptom: an "invalid payload" error toast.
10. Trigger: any page load with no saved draft.
11. Root cause: the watcher treats hydration as a user edit and autosaves.
12. Correct layer: the watcher, not the API validation.
13. Minimal safe fix: ignore changes during hydration. Save only from the explicit save handler.
14. Follow-up: remove the draft store, or give it a single owner.
15. Patch: the change to the watcher, plus a test that mounting the page sends no request.
