# Hidden Write Checklist

A hidden write is any mutation or outbound request that no user action or explicit command handler asked for. Treat each one as a suspect until it is shown to be intended.

Map each item below onto the equivalent construct in the framework at hand. Do not assume that automatic framework behavior is correct.

## Where to Look

- Lifecycle and startup code: mount hooks, init methods, constructors, module top-level code, and application boot scripts.
- Observers: watchers, subscribers, effects, signals, computed values with side effects, event listeners, and store subscriptions.
- Interception layers: middleware, interceptors, decorators, ORM hooks, model callbacks, and triggers.
- Timing and repetition: retries, backoff loops, schedulers, cron jobs, background workers, polling, and cache refreshers.
- Persistence: restore or hydration steps that write back what they read, migrations that run on startup, autosave, and draft storage.
- Mirroring: helpers that copy derived data into another store, cache, file, queue, session, or database.

## Questions for Each Suspect

1. Which event triggers it? Does that event include a user or system decision to write?
2. Does it run on startup, restore, focus, reconnect, or retry, where nobody asked for a write?
3. Does it read state and write the same state back?
4. Does it write derived data that another layer already owns?
5. Remove this code in a test. Does the observed error still occur?

## Preferred Design

- Writers are explicit: command handlers, request handlers, job runners, and user actions.
- Startup-time and background writes need a written reason.
- Each piece of state has one owner. Every other holder is a cache with a named refresh rule.

## Tracing Aids

If a tool is available, use it. Then read the source to make sure that the result is right.

- A call-graph tool: list every caller of the write function, and so every path that reaches it.
- A structural search: find all sites that call the write, or all watchers on the state.
- A text search: search for the store key, table name, or endpoint path, to find writers that bypass the main helper.
