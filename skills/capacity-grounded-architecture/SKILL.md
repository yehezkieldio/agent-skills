---
name: capacity-grounded-architecture
description: Use when discussing whether a system's architecture, hosting setup, or tech stack is "good enough," when speculating about a clean-slate/greenfield redesign, when comparing candidate stacks or hosting models, or when asked to reason about capacity, scaling headroom, or cost-effectiveness of an existing setup. Forces every claim to trace to a measured number and every option to carry a named downside, instead of defaulting to trend-driven or spec-sheet architecture opinions.
---

# Capacity-Grounded Architecture

## Core Instruction

Do not evaluate or propose an architecture from priors about what's "modern," "best practice," or "what people use for this." Evaluate it against the actual measured workload of the actual system in front of you. An architecture opinion that isn't traceable to a number is a guess wearing a diagram.

This applies whether the task is "is our current setup good," "help me design this from scratch," or "should we switch from X to Y." All three collapse into the same discipline: characterize the real workload, find the real constraint, model against it, and state what breaks.

## The Eight Moves

Apply these in order. Skip a move only when the data genuinely doesn't exist yet (e.g. true greenfield with no traffic) — in that case, say so explicitly and mark downstream conclusions as provisional rather than silently skipping the step.

**1. Measure before modeling.** Before any architecture claim, pull real numbers: request rate, data size and growth rate, resource utilization (CPU/RAM/disk), error rate, concurrency, uptime history. Prefer live inspection (dashboards, metrics endpoints, `SELECT COUNT`-style read-only queries, log aggregates) over the system's own documentation — docs describe intent, metrics describe reality, and the two drift apart. Never assert a capacity or scale claim that isn't traceable to a specific observed number.

**2. Derive requirements from the workload, not from the candidate toolset.** Once measured, ask what *this* system's actual access patterns, consistency needs, and concurrency profile require — not which tool is generically "better." "Postgres has stronger guarantees" is not a requirement; "this workflow needs row-level locking because two roles can mutate the same ledger row concurrently" is.

**3. Identify the one resource with no slack.** In any system under discussion, most resources have headroom and one doesn't. Name it explicitly before evaluating options — CPU, memory, a connection ceiling, a single point of failure, operator attention/maintenance burden, disk growth rate, whatever it is. Proposals that improve a resource that already has slack are optimizing the wrong axis; call that out rather than treating every proposed improvement as equally valuable.

**4. Quantify utilization before declaring a ceiling reached or safe.** Use the basic queueing intuition: utilization ρ = arrival rate / service rate. If ρ is far below 1 even under a generous burst multiplier, queueing delay is provably negligible — say so with the actual ratio, not a vibe. If ρ is close to 1, that's the finding, and it should be stated as a number, not "this might not scale."

**5. Extrapolate with explicit, falsifiable assumptions — give a range, not a point.** A single-number projection ("will hit the limit in 3 years") is a hidden claim that growth stays exactly linear forever, which is rarely true. State the extrapolation basis (e.g. "linear at the currently observed rate") and give at least a second bound under a named different assumption (e.g. "if volume triples"), so the assumption — not the number — is the thing open to challenge.

**6. Match the design to the real physical/hosting constraints (mechanical sympathy).** Don't design as if resources exist that the actual deployment target doesn't have (e.g. assuming free parallelism from a second CPU core that isn't there). Don't discard, for free, a resource the deployment target does have (e.g. forcing server-side rendering cost onto a constrained host when client devices have idle compute that could absorb it). This cuts both ways: also don't pay for a capability the workload's shape can't use (e.g. globally distributed storage for a system with one user base in one timezone).

**7. State the honest downside of every option, including the one you'd pick.** A design proposal without a named failure mode or breaking point isn't a design proposal, it's advocacy. For each option under discussion, name specifically where it breaks, what redesign it forces elsewhere, or what it silently gives up.

**8. Keep cost, operational burden, and engineering risk as separate axes.** These get conflated constantly — "cheaper" gets used to mean "less operational effort" gets used to mean "lower risk," and they are frequently not correlated. Evaluate each independently: what does this cost in money, what does this cost in ongoing human attention to keep running, and what does this cost in redesign/migration risk to get there. State which axis is actually the scarce one for this conversation before recommending a tradeoff on the others.

## Workflow

1. Gather real, current numbers about the system in question. Use read-only inspection only — this skill is about grounding a discussion, not about mutating a live system to test it. If live inspection isn't possible or appropriate, say explicitly which numbers are assumed versus measured.
2. State the workload characterization in one or two sentences (rate, size, growth, concurrency, criticality) before naming any tool or platform.
3. Name the one resource with no slack.
4. For each option under discussion (including "keep the current setup"), give: what it's good for given the measured workload, the utilization/capacity math where relevant, and its specific breaking point or downside.
5. If projecting forward, give a bounded range with stated assumptions, not a single number.
6. Close by naming which axis (cost / ops burden / engineering risk) is actually driving the decision, since that determines which option is "right" — this is a judgment call for the requester to make, not something to resolve for them by default.

## Anti-Patterns to Avoid

- Recommending a stack because it's popular, trending, or "what real companies use" without tying it to a measured requirement of the system at hand.
- Citing a technology's published benchmark ceiling as if it settles the question, instead of computing this workload's actual utilization against it.
- Giving a single-point future projection with no stated growth assumption.
- Praising an option's strengths at length while omitting where it breaks.
- Treating "cheaper," "simpler to operate," and "less risky to migrate to" as if they're the same claim.
- Proposing a redesign driven by novelty rather than by a named, current pain point (cost, operational burden, or a concrete capability gap).
