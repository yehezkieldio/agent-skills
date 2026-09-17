# Eval / Test Case Template

Copy this structure for each case when designing or auditing a suite. Fill every
field — an unfilled field is usually where the real ambiguity was hiding.

```
Case ID:        <short stable identifier, e.g. ORD-EDGE-014>
Target:         <function / endpoint / subsystem under test>
Category:       <one of: happy-path | boundary | malformed-input | concurrency |
                  partial-failure | resource-exhaustion | stale-state |
                  adversarial-input | dependency-failure | incident-derived>
Severity:        <critical | major | minor | cosmetic>
Provenance:      <business-workflow scoping | taxonomy walk | production incident
                  <link/id if incident-derived> | other, specify>

Preconditions:   <exact system/data state before the trigger — what exists, what
                  doesn't, what state flags/config are set>
Trigger:         <exact input, call, or event sequence that starts the scenario>
Expected result: <specific, mechanically checkable outcome — not "works correctly">
Assertion:       <how pass/fail is determined — the concrete check(s)>

Notes:           <anything a future maintainer needs to not accidentally delete
                  this case, e.g. "looks redundant with CASE-009 but covers the
                  boundary instant, not the interior">
```

## Example (filled in)

```
Case ID:        STOCK-EDGE-003
Target:         stock-ledger completion handler
Category:       incident-derived
Severity:        critical
Provenance:      production incident 2026-03-11: double stock deduction when a
                  kitchen "done" action was retried after a timeout

Preconditions:   Order item in "pending" status; stock_balances row exists with
                  current_stock = 10; client sends the same completion request
                  twice within 500ms (simulating a retried request after a
                  perceived timeout)
Trigger:         Two concurrent POST requests marking the same order item "done"
Expected result: Exactly one "penjualan" stok_log row is appended; current_stock
                  decreases by exactly 1, not 2
Assertion:       Query stok_logs for the item/order pair after both requests
                  resolve; assert count == 1 and stock_balances.current_stock == 9

Notes:           Do not weaken this to a single-request test — the bug only
                  reproduces under the concurrent/retried trigger.
```
