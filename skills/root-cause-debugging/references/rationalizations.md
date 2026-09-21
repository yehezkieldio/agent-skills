# Common Rationalizations

Each excuse below is a reason agents give for skipping a phase. Each one fails for the reason shown.

## Observe

| Excuse | Reality |
|---|---|
| "I already know what is wrong" | Write it as a hypothesis and test it. If it is right, this takes two minutes. |
| "Let me try a quick fix first" | This is how a session reaches six failed attempts and 45 minutes lost. |
| "The error message is clear" | Error messages describe symptoms. A null error says what failed, not why the value was null. |
| "I can see the bug in the code" | Then reproduce it. If the bug is that visible, reproduction is cheap. |

## Trace

| Excuse | Reality |
|---|---|
| "The contract is obviously too strict" | Prove that the payload is intended before loosening the contract. |
| "The request happens, so it is needed" | Make sure that the request was meant to happen at all. |
| "Only one place writes this" | Search for the store key and the endpoint. Hidden writers are the usual cause. |

## Hypothesize

| Excuse | Reality |
|---|---|
| "I only have one theory" | That is one favorite theory. Think across data, logic, state, environment, and hidden writes. |
| "Writing it down is slow" | Debugging without notes is slower. Compaction erases hypothesis two. |
| "There is no conflicting evidence" | Either the search was shallow or the theory is right. Test it either way. |

## Experiment

| Excuse | Reality |
|---|---|
| "I will test two things at once" | If the bug disappears, which change fixed it? The test must run again. |
| "Five lines is not enough" | Five lines is enough for a log, an assertion, a hardcoded value, or a short-circuit. If it is not, the hypothesis is vague. |
| "The experiment is basically the fix" | The experiment is diagnostic. The fix meets a higher quality bar. Revert the experiment. |

## Conclude

| Excuse | Reply |
|---|---|
| "A regression test is overkill" | Simple bugs do not need this skill. This one was not simple. Add the test. |
| "All hypotheses failed, I am stuck" | Return to Observe. A bug exists, so a cause exists, and something was missed. |
