# Commit Body

The default commit has no body. Write one only if the user asks for it, for example "with a body", "explain why", or "add details".

## Layout

The layout follows the 50/72 convention from the Linux kernel.

- Header: aim for 50 characters or fewer, with a hard limit of 72. The header keeps the Conventional Commits form, so the description stays lowercase.
- One blank line between the header and the body. Tools such as `git log --oneline` and `git shortlog` depend on it.
- Body lines: hard wrap at 72 characters. A URL, a stack trace line, or an error message can run over.
- Plain text. Write no markdown headings, no bold, no emoji, and no markdown tables. Git does not render them.
- Paragraphs by default. Use a `- ` list only for three or more discrete facts, and indent wrapped lines by two spaces.
- Footers go after the body, separated by one blank line. See `footers.md`.

## Content

Explain why and what. The diff already shows how.

A good body has up to four parts, in this order. Leave out any part that adds nothing, and write no labels for them.

1. Problem and context: what was wrong or missing, and who felt it.
2. Root cause: why it happened. Include this only if the session established it.
3. Solution: what the change does, in terms of behavior.
4. Trade-offs and side effects: anything a reader of the diff would not see. Examples are a behavior change for callers, a limit, a cost, or a follow-up that this change does not cover.

Most bodies run 3 to 10 lines. A body that is longer than the diff it describes needs a cut.

## Voice

- Technical and direct. State facts, numbers, error text, and versions.
- Imperative where it fits: "Clear the session on the first 401."
- Plain present or past tense for the problem: "The client retried without limit."
- The header and the body say different things. The body never restates the header.

## Grounding

Take every fact from the session or the diff: the error text the user pasted, the measurement they reported, the cause they found, the issue they named. Do not invent a root cause, a benchmark, or a user impact. If the session does not establish a fact, leave the sentence out. A short honest body beats a full body with a guess in it.

## Screening

Run the AI-tell list in `vocabulary.md` on the body as well as the header. The tells that show up most in bodies:

- An opener such as "This commit", "This change", or "In this PR".
- A closing line that summarizes or states a moral ("This keeps things simple.").
- Connectors such as Additionally, Furthermore, and Moreover.
- A line-by-line narration of the diff.
- Hedges such as "should now", "hopefully", and "potentially".

## Example

```
fix(auth): stop token refresh retry loop on 401

An expired session made the client call /refresh, get a 401, and call
/refresh again with no limit. Each retry reset the backoff timer, so
the client sent one request every 200 ms until the tab closed.

Clear the session on the first 401 and return to the sign-in screen.
Callers that relied on the silent retry now see a sign-in prompt.

Fixes #482
```

The first paragraph gives the problem and the cause. The second gives the solution and the side effect. The footer closes the issue.
