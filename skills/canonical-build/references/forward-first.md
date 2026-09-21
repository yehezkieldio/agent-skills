# Forward-First Reference

This file holds the details of Policy B. The rules and the decision rule are in `SKILL.md`.

## Required Validation

Choose the checks that match the change:

- Runtime behavior and exit status.
- Schema and type validity.
- Exact input, output, accepted, rejected, and unknown counts.
- Deterministic first, middle, and last samples.
- Identity and partition conservation: nothing lost, nothing counted twice.
- Join consistency and flag polarity.
- Nontruncation and bounded diagnostic output.
- Wall-clock time and peak memory for material stages.

A hash can identify an input or a revision. A hash never grants correctness, execution, or roadmap credit.

## Forward Cursor Rules

The forward cursor marks the next stage to build or run.

- Move it backward only for a replay condition listed in `SKILL.md`.
- When one producer changes, replay only that producer's dependency cone. Do not invalidate a wide range of stages.
- When a run exposes a defect in a stage, fix that stage before you rerun its dependency cone.
- If the next proposed action is bookkeeping only, select the next unresolved producer, consumer, adapter, or output instead.

## Manual Stage Runs

A manual run of an authorized stage follows the same contract as a full pipeline run.

1. Run the exact stage.
2. Test the output against the list above.
3. Publish the output atomically: write to a temporary path, then rename.
4. Record the command, the input, the result, and the expectation, in the report to the user.

If an execution record carries the command, the input, the result, and the expectation, it is substantive. A missing record blocks that one claim. It does not invalidate unrelated earlier stages.

## Parallel Work Invariants

These invariants are behavior contracts. They are not a scheduler. The runtime owns scheduling, concurrency, and worker topology.

- One writer owns publication, cursor movement, acceptance, and conclusions.
- Workers never become competing sources of truth.
- Inspect a worker output locally before you use it. A report states intent, not result.
- Forward progress does not wait for every worker. When the dependency is reached, use the completed output.
- An idle worker slot costs less than fake work.
