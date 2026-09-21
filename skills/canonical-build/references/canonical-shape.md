# Canonical Shape Reference

This file holds the details of Policy A. The rules and the environment table are in `SKILL.md`.

## Review Checklist

Reject a change that does any of these:

- Keeps old-shape behavior behind a conditional.
- Adds a translation layer between the old shape and the new shape.
- Adds validation that exists only to reject legacy input.
- Adds a test that exists only to memorialize an abandoned draft format.

Remove any of these that remain:

- Dead helpers.
- Dead conditionals.
- Comments that describe removed draft formats.

Make sure that one owner holds the canonical contract.

## Deliverables

A hard-cut change delivers only:

- A minimal implementation that supports the canonical shape.
- Updated tests for the canonical shape only.
- Removal of obsolete legacy-shape tests.
- No new rejection tests for old shapes.
- No runtime logic that exists to recognize legacy formats.

## Validation Boundaries

Validation can reject malformed input of the current canonical shape. Validation must not branch on legacy discriminators, old field names, aliases, old enum members, or draft formats.

## Production Migration Sequence

If Step 0 finds live data and the shape must change, use this sequence. Each step ships as its own change with a rollback path.

1. Add the new shape next to the old shape. Write a migration that is safe to run twice and safe on live data.
2. Back up or snapshot the affected data. Name the rollback step before you run anything.
3. Move producers to write only the new shape.
4. Run the data migration. Make sure that counts match before and after, and read a sample of rows.
5. Move consumers to read only the new shape.
6. In a later change, delete the old shape and its migration code.

The old shape exists only between steps 1 and 6. Name each piece of temporary compatibility code and the step that removes it.

## Naming an Exception

When a real boundary blocks the hard cut, write down:

- The exact file and function.
- The persisted or public dependency, in concrete terms.
- The condition under which the boundary can go away.
