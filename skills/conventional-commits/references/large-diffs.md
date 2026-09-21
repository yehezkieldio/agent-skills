# Large and Mixed Diffs

Use this procedure when the diff spans many files, or when one read of the diff does not fit in context. It has three stages. A small diff needs only stage 3.

Route large `git diff` output through a sandbox tool such as context-mode, or read it with `git diff --staged --stat` first and then one file group at a time.

## Stage 1: Summarize Each File Group

For each group of related files, write one sentence.

- One sentence only. No lists, no markdown.
- Describe the main change at a high level. Write no commit type prefix and no commit message.
- Past tense: "Added", "Fixed", "Removed".
- Name the struct, function, module, or file that changed.
- Prefix the sentence with the file path in brackets.
- Use no vague words. Name concrete artifacts.

```
[src/auth/token.rs] Added Token struct with expiry validation and JWT parsing
[src/db/pool.rs] Fixed race condition in connection pool by reordering mutex acquisition
[Cargo.toml] Bumped tokio dependency from 1.38 to 1.49
```

## Stage 2: Extract Themes

From the summaries and their file counts, extract 1 to 3 themes that describe the intent of the whole commit.

- Group by cross-file pattern and architectural intent.
- Use precise verbs: introduce, extract, migrate, replace, split, merge, wire, gate, enforce.
- Rank themes by file count, highest first.
- Use no commit type prefix in titles or descriptions.
- Avoid file names unless a name is needed to tell two themes apart.
- Each title has 8 words or fewer. Each description is exactly one sentence.
- Set the scope with the scope tiers in `types-and-scopes.md`. Use `null` for an ambiguous scope.

Theme shape:

```json
{
  "themes": [
    {
      "title": "JWT token validation",
      "description": "Introduced JWT validation with session management in auth middleware",
      "fileCount": 3,
      "scope": "auth"
    }
  ]
}
```

## Stage 3: Synthesize the Header

1. Choose the theme with the most files.
2. If two themes tie, break the tie with the type priority order.
3. Take the scope from the theme. Omit it if the scope is `null`.
4. Start the description with a tier 1 verb when possible.
5. Write one header of 72 characters or fewer. Scan it against `vocabulary.md`.

Example:

```
Themes:
- Database migration (refactor): 4 files
- User roles system (feat): 6 files
- Test utilities (chore): 2 files

Choice: "User roles system" has the most files.
Header: feat: implement user roles system
```

Tie example:

```
Themes:
- Error handling rework (refactor): 3 files
- Security patches (fix): 3 files

Choice: both have 3 files. fix ranks above refactor.
Header: fix: resolve security vulnerabilities in error paths
```

## Mixed Concerns

If the staged changes hold unrelated concerns, still write one header for the dominant change. Tell the user once that the changes could split into separate commits. Do not split unless the user asks.
