---
name: canonical-build
description: This skill should be used when the user asks to "refactor to one canonical shape", "remove legacy handling", "delete the fallback", "hard cut", "drop backward compatibility", "remove the compatibility shim", "clean up the old schema", "rename this contract everywhere", "stop regenerating hashes", "the pipeline refuses to run because of a stale receipt", "do not rerun unchanged stages", or changes a schema, contract, persisted state, routing rule, feature flag, or enum. Also use for multi-stage pipelines, migrations, and long build loops where bookkeeping such as hashes, locks, receipts, or progress markers blocks real work. Read the declared project environment first, because compatibility code is deleted freely only in development.
---

# Canonical Build

Build the real thing once, and do not build machinery that is not the product. This skill has two policies that share this idea.

- Policy A, canonical shape: keep one implementation and delete compatibility code.
- Policy B, forward first: build and validate real output before any bookkeeping.

## Step 0: Read the Environment

Before you apply either policy, find the declared environment. Read the project `CLAUDE.md` and its docs for development, pre-production, or production. If the project declares none, treat it as pre-production. Ask the user before you delete anything that touches persisted data.

| Environment | Policy A: canonical shape |
|---|---|
| Development, no persisted data | Full hard cut. Delete old shapes. Add no shims and no rejection tests. |
| Pre-production | Hard cut internal code and fixtures. Keep any shape that stored data or another service still uses, until a planned migration moves it. |
| Production or live data | Do not hard cut stored or wire shapes. Use a planned migration with a rollback step. Add the new shape, move the data, and remove the old shape in a later change. Hard cut still applies to purely internal code. |

Policy B applies in every environment. Locks and records that protect live systems are not bookkeeping. A deploy lock or a migration lock stops two runs from corrupting live data. Keep them.

## Policy A: Canonical Shape

Apply this policy to changes of schemas, contracts, persisted state, routing, configuration, feature flags, enum sets, and architecture.

### Default assumption

Treat an old shape as internal draft code, unless there is concrete evidence that it is one of these:

- persisted external or user data
- on-disk or database state that must still load
- a wire format across process or service boundaries
- a documented or public contract
- something that code outside the refactor boundary depends on

Old code alone is not proof of a compatibility duty. In production, stored data counts as evidence by default.

### Workflow

1. Name the canonical target shape.
2. Trace every producer and consumer of that shape.
3. Update every live code path to emit and consume only the canonical shape.
4. Update fixtures, test data, builders, and snapshots to the canonical shape.
5. Delete legacy handling, branches, comments, and translation helpers.
6. Keep validation only for the current canonical contract.
7. If a real compatibility boundary exists, isolate it. Name the file, the function, the boundary, and the reason it stays.

### Hard rules

- Add no fallback behavior, compatibility branches, shims, adapters, coercions, aliases, or dual-shape support.
- Add no guard that exists to detect or reject an old shape.
- Add no test that exists to assert the rejection of an old shape.
- Prefer deleting old handling over policing it.
- Choose simplification over backward compatibility. Step 0 and the exception rule below override this.

### Exception rule

Make an exception only for a real persisted, wire, or public boundary. Name the exact file and function. Describe the concrete dependency. Limit the compatibility discussion to that boundary. Invent no compatibility layers elsewhere.

The full review list and the migration sequence for production are in `references/canonical-shape.md`.

## Policy B: Forward First

Apply this policy to pipelines, roadmaps, migrations, staged runs, long implementation loops, and manual stage runs.

### Decision rule

Before each action, classify it as one of three kinds:

1. Semantic implementation: build or connect a producer, consumer, adapter, schema, fixture, or final output.
2. Focused validation: test the changed dependency cone with behavior, schema, counts, samples, or measured resources.
3. Administrative bookkeeping: make or repair hashes, locks, receipts, dashboards, certification markers, progress metadata, or presence-only records.

Choose kinds 1 and 2. Skip kind 3 unless the user asks for it, or the artifact is part of the product. If bookkeeping blocks a path and protects no correctness, remove that dependency from the path.

### Hard rules

- Build the producer and the consumer before polishing status or certification surfaces.
- Do not generate, repair, compare, or propagate administrative hashes.
- Do not create or wait on filesystem locks that only track progress.
- Do not rerun an unchanged stage to regenerate a receipt or marker.
- Never invalidate valid output because a receipt, hash, or marker is missing or stale.
- Never move the forward cursor backward for a metadata change.
- If one producer or consumer changed, replay only its dependency cone.
- Do not claim that a capability works because its file exists. Run the smallest changed dependency cone and inspect the output.
- After focused validation, publish valid output. If no defect remains, add no extra review cycle.

### Replay conditions

A stage can move backward or replay only for a real reason:

- Its input meaning changed.
- Its target or pinned revision changed.
- Its output is malformed, truncated, nonconserving, inconsistent, or incompatible with the consumer.
- An observed run disproves the earlier result.
- The declared dependency cone of a changed producer requires it.

Missing or stale administrative metadata is not a reason.

### When the orchestrator refuses a stage

If the orchestrator refuses a stage only because of a receipt, marker, hash, or lock, follow these steps:

1. Run the exact stage manually.
2. Test its output against the list in `references/forward-first.md`.
3. Publish the valid output atomically.
4. Continue from the forward cursor.
5. Remove or downgrade the administrative-only gate.

Do not refuse an authorized manual run because the full pipeline cannot issue a receipt.

### Checks that stay substantive

Bookkeeping is cheap to skip. Evidence is not. Keep these:

- Integrity that belongs to the product, such as a checksum that users compare, or a signature that the format requires.
- Input and revision identity that decides which version you operate on.
- Real measurement: assertions on results, benchmarks, reproductions, and end-to-end runs.
- The difference between coverage and consequence. A run that touches a path does not prove that the path gave the right answer.

### Parallel work

Exactly one writer owns publication, cursor movement, and conclusions. Workers prepare, implement, and test non-overlapping support work. A worker report states intent, not result, so inspect the output locally before you use it. Do not wait for every worker to finish. Do not invent busywork for idle workers.

## Reporting

Report implemented behavior and measured output first. List blockers literally. Keep infrastructure progress separate from evidence about the output. Do not present administrative completion as working capability.

## Additional Resources

- `references/canonical-shape.md`: the review checklist, the deliverables, and the production migration sequence.
- `references/forward-first.md`: the required validation list and the forward cursor rules in full.
