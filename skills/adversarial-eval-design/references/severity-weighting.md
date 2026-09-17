# Failure Severity Weighting

A raw pass rate ("47/50 tests passing") hides the only question that actually matters
for a ship/no-ship decision: what do the 3 failures cost if they happen in production?
Classify every case's severity up front, and report failures by weighted severity, not
by count, whenever the result will drive a real decision.

## Severity rubric

Use a rubric like this (adjust labels/categories to the domain, keep the ordering):

- **Critical** — data corruption or loss, financial miscalculation, security/auth
  bypass, safety impact, or an irreversible action taken incorrectly. Any single
  critical failure should block a ship decision regardless of how many other tests
  pass.
- **Major** — a core workflow breaks or produces wrong results, but the damage is
  visible, bounded, and recoverable (e.g. an operation fails loudly instead of
  silently, or requires manual correction afterward).
- **Minor** — a secondary or rarely-used path misbehaves, with limited blast radius
  and an easy workaround.
- **Cosmetic** — presentation-only issues with no functional or data impact.

## How to use it

- Tag every case with its severity at design time (step 2 of the core procedure), not
  after the fact when triaging failures — assigning severity retroactively tends to be
  biased by whether the case happens to be passing.
- When summarizing results, lead with critical/major failures explicitly, even if
  there's only one, rather than leading with an aggregate percentage. "1 critical
  failure (double-charges on retried payment), 46/49 other cases passing" is a decision
  makers can act on; "94% pass rate" is not.
- Frequency and severity are independent axes — weight by potential impact, not by how
  often the scenario is expected to occur. A once-a-year case that corrupts financial
  records outweighs a common case that produces a slightly suboptimal but harmless
  result.
- When comparing two versions/implementations, compare weighted severity profiles, not
  just pass-count deltas — a change that fixes five cosmetic cases while introducing
  one critical regression is a net loss even though the raw pass count went up.
- Escalate ambiguous severity by asking: "if this happened in production right now,
  who would need to be paged, and how fast?" If the honest answer is "someone gets
  paged immediately," it's critical regardless of how rare the trigger is.
