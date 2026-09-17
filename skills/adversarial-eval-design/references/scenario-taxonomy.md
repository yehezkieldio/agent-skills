# Adversarial / Edge-Case Scenario Taxonomy

Walk every category against the target (function, endpoint, subsystem) before
concluding coverage is adequate. Not every category applies to every target — note
which ones were checked and ruled out, rather than silently skipping them.

## Boundary values

- Minimum, maximum, zero, negative, and off-by-one values for every numeric input
- Empty collections, single-element collections, and maximum-size collections
- First/last item in an ordered sequence, and the boundary between two ranges
  (e.g. the instant a time window opens or closes — inclusive vs. exclusive matters)
- Boundaries that exist in the domain even if rarely hit: exact zero balance, exact
  capacity, exact expiry instant

## Malformed, missing, or oversized input

- Required fields missing, present-but-null, present-but-wrong-type
- Unicode, emoji, very long strings, control characters, mixed encodings
- Payloads larger than any size limit that's supposed to be enforced
- Duplicate keys, duplicate submissions/idempotency keys, replayed requests
- Ambiguous or partially-specified input (e.g. a date with no timezone when one is
  required) — confirm it's rejected, not silently guessed

## Concurrency and ordering

- Two callers acting on the same resource at the same time (race condition)
- Actions arriving out of the order the system assumes (e.g. a completion event
  before its corresponding start event)
- Retries and at-least-once delivery producing duplicate effects
- Long-running operations interleaved with a conflicting state change mid-flight

## Partial and interrupted failure

- Process crash or network failure between step N and step N+1 of a multi-step
  operation — confirm the system doesn't end up in a half-committed state
- A downstream write succeeding while an upstream write fails, or vice versa
- Timeouts on slow dependencies — confirm the caller doesn't assume success

## Resource exhaustion

- Disk full, connection pool exhausted, memory pressure, rate limit hit
- Unbounded loops or queries against unexpectedly large datasets
- Queue backlog growing faster than it drains

## Stale or inconsistent state

- Cached or derived data that has drifted from the source of truth
- A read happening against data that a concurrent write is mid-way through changing
- Operating on an entity that was deleted, archived, or changed state after being
  loaded but before being acted on

## Adversarial / malicious input

- Input deliberately shaped to break parsing, injection-style payloads, path
  traversal attempts, oversized recursive structures
- A caller attempting an action outside their authorization
- Input designed to exploit a known weak assumption (e.g. trusting client-supplied
  totals instead of recomputing server-side)

## Upstream/downstream dependency failure

- A called service returns an error, times out, or returns malformed data
- A dependency is slow rather than down (confirm there's a timeout, not an
  indefinite hang)
- A dependency silently returns stale or partial data instead of failing loudly

## Environmental and configuration edge cases

- Feature flag combinations that aren't the default
- Clock skew, timezone differences, daylight-saving transitions where relevant
- Configuration values at their documented min/max instead of the common default
