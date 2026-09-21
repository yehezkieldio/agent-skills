---
name: root-cause-debugging
description: This skill should be used when the user asks to "debug this", "why is this failing", "find the root cause", "this test is flaky", "it works locally but not in CI", "the fix did not work", "the same bug came back", "why is this request being sent", "why is this null", "state is wrong after restore", "track down this regression", or reports a crash, wrong output, performance regression, deserialization error, missing field, hydration bug, or unexpected background write with an unclear cause. Also use after a failed first fix attempt, and when reviewing code where the visible error is downstream of an unintended side effect. Skip typos, missing imports, and errors that name the exact line and cause.
---

# Root-Cause Debugging

Find the first wrong event, prove it, and then write the fix. A visible error is a symptom until evidence shows otherwise. Often the contract, type, or parser that rejected the data is correct. The bug is the earlier code that produced bad data, or that sent a request that must not exist.

Core rule: write no fix code until a hypothesis survives a test that can disprove it.

## When to Use

Use this skill for any bug with a cause that is not obvious from the error message. If one fix attempt failed, switch to this skill at once.

Skip typos, syntax errors, missing imports, and linter or compiler messages that state the cause and location. Fix those directly.

## The Loop

The loop has five phases. Do not skip a phase. Write no fix code before phase 5.

### 1. Observe

Collect facts. Separate known facts from assumptions.

1. Reproduce the bug. Record the exact error text, stack trace, or wrong output.
2. If the bug does not reproduce, record that as the first finding, with the conditions.
3. Shrink the reproduction until one more removal hides the bug.
4. Record the environment: OS, runtime, dependency versions, and relevant configuration.
5. Note what works. The bug lives at the boundary between working and broken.

### 2. Trace

Answer these questions in order before forming a theory. The full write-up is in `references/report-format.md`.

1. Which user action or system event was meant to happen?
2. Which call path produced the observed request, write, or error? If a call-graph tool is available, use it. Then read the source.
3. Under the intended behavior, was this request, mutation, or side effect meant to happen at all?
4. Which layer owns the state? Which other sources compete with it?
5. What is the first visible wrong behavior? Do not stop at the final error.

Name the invariant in one sentence, for example "a page load never writes to the database". Name at least one thing that definitely did not happen.

### 3. Hypothesize

Write 3 to 5 candidate causes. One favorite theory is not enough. Cover several categories:

- Data: wrong input, missing field, type mismatch, encoding.
- Logic: wrong condition, off-by-one, race, wrong order.
- State: stale cache, leaked state, initialization order, two sources of truth.
- Environment: configuration, version, dependency, permissions.
- Hidden write: observer, lifecycle hook, retry, background job, restore step.

For each cause, record the supporting evidence, the conflicting evidence, and the smallest test that can disprove it. Mark the best-supported cause as the root hypothesis. If several qualify, pick the cheapest to test.

### 4. Experiment

Try to disprove the root hypothesis. Do not try to prove it.

1. Before you run anything, write down which result confirms the hypothesis and which result rejects it.
2. Change one variable. Use diagnostic code only: a log line, an assertion, a hardcoded value, or a short-circuit. Keep the change near 5 lines. If the experiment needs more, the hypothesis is too vague, so split it.
3. Run the reproduction. Record the result as confirmed, rejected, or inconclusive.
4. Revert the experiment code.

A rejected hypothesis is progress. Promote the next hypothesis. If all are rejected, return to phase 1 with the new observations.

### 5. Conclude

1. State the root cause in one sentence.
2. Choose the correct layer to fix first. Prefer the upstream logic fix over loosening a downstream contract. If the final design does not intend the observed payload, do not loosen the contract.
3. Write the minimal fix. Add a regression test that fails without the fix and passes with it.
4. Run the original reproduction. Make sure that it now passes.
5. List architectural follow-up work separately. Do not fold it into the fix.

## Hidden Write Checks

Treat every non-explicit write as a suspect until it is shown to be intended. Audit lifecycle hooks, watchers, subscribers, middleware, interceptors, retries, background jobs, cache refreshers, persistence restore, scheduled tasks, and startup code.

Look for derived data that an observer or helper mirrors into another store, cache, file, queue, or session. Prefer explicit command handlers and user actions as the only writers. The expanded list is in `references/hidden-writes.md`.

## Stop Conditions

If any of these happen, stop and return to phase 3:

- You write more than about 5 lines before a hypothesis is confirmed.
- You try the same approach a second time. The hypothesis behind it is rejected.
- You ignore conflicting evidence. Write it down and re-rank the hypotheses.
- The work feels nearly done after three failed attempts. This is a sign of pushing a wrong theory deeper.

## Investigation Notes

For a short bug, keep notes in the conversation. For a long investigation, write the observations, hypotheses, experiment results, and conclusion to `DEBUG.md` in the project root. A long investigation spans many experiments, and compaction can erase its context. Keep that file out of commits unless the user asks to keep it.

## Reporting

Report in this order: symptom, trigger, first unintended side effect, root cause, correct layer to fix first, minimal safe fix, and follow-up. For a full review, or a bug that spans several layers, use the long format in `references/report-format.md`.

## Additional Resources

- `references/report-format.md`: the full 15-field report structure with a filled example.
- `references/hidden-writes.md`: the expanded list of lifecycle, observer, and background writes.
- `references/rationalizations.md`: common excuses for skipping a phase, and why each one fails.
