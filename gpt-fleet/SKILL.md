---
name: gpt-fleet
description: Main-thread-only orchestration for a Luna implementation fleet when the human user explicitly asks for a GPT fleet, Luna fleet, or parallel Luna workers. Never invoke this skill inside a delegated worker; workers execute their assigned package directly with relevant domain and tool skills.
---

# GPT Fleet

Run a single-level implementation fleet. This skill belongs exclusively to the main thread that received the human user's fleet request. The main thread is the planner, commander, integrator, and final reviewer. Every worker uses `gpt-5.6-luna` with `xhigh` reasoning and owns an implementation, targeted testing, and self-review loop.

Luna workers are leaf implementers. They execute their assigned package directly, use relevant project, domain, and tool skills, and return their report to the main thread. Delegation and fleet orchestration remain with the main thread.

## Main-Thread Command Responsibility

Before dispatching Luna workers, the main thread must establish a command plan that:

- translates the request into explicit goals, non-goals, constraints, and acceptance criteria;
- inspects the repository and existing changes deeply enough to ground the plan;
- reasons through architecture, dependencies, shared interfaces, invariants, failure modes, and high-risk decisions;
- maps the work into dependency-aware packages or execution waves with one writer per file or module;
- assigns an owner, inputs, outputs, validation method, and completion criterion to every package;
- inventories the repository instructions and task-relevant skills that govern every package;
- reserves cross-cutting design decisions, scope reconciliation, and final tradeoffs for the main thread.

Planning is complete only when every acceptance criterion maps to a worker package or an explicit main-thread responsibility, and every package has known dependencies and validation evidence. Luna workers may surface local design evidence and risks, but the main thread retains whole-task reasoning and decision authority.

## Command the Fleet

1. Complete the command plan and identify existing user changes, relevant quality gates, and safe ownership boundaries.
2. Select the smallest useful independently writable packages. Keep coupled changes in one package or place them in sequential execution waves.
3. Build the instruction and skill manifest for each package as specified below.
4. Check available collaboration capacity. Use at most the available slots; when the runtime permits four active agents including the main thread, run no more than three Luna workers concurrently. A fleet may contain one worker when the work cannot be safely parallelized.
5. Dispatch each package with `spawn_agent` using:
   - `agent_type: "worker"`
   - `model: "gpt-5.6-luna"`
   - `reasoning_effort: "xhigh"`
   - `fork_turns: "none"`
6. Schedule packages by dependency wave, track worker status and blockers, and issue precise follow-ups without violating ownership. Continue useful main-thread reasoning or integration preparation while workers run; use long waits rather than frequent polling when no independent work remains.
7. Collect every worker report and inspect the actual workspace changes. Treat a worker's completion claim as evidence to verify, not final approval.
8. Synthesize the implementation across package boundaries, resolve integration issues, run the relevant repository-wide checks, review the complete diff against the command plan and user's request, and only then present the final result.

## Rehydrate Project Context

`fork_turns: "none"` gives each worker a clean conversation, so every work package must explicitly reconstruct the project context the main thread would use for that package.

Before dispatch, the main thread must:

1. Identify every applicable `AGENTS.md` from the repository root through the worker-owned paths, including any documents those files require for the task. Name them in the package and instruct the worker to read them completely before editing.
2. Select task-relevant project, domain, and tool skills using the same trigger rules the main thread applies. Include only skills that help execute the owned package; fleet orchestration stays on the main thread. Name every required execution skill as `$skill-name`; instruct the worker to read its complete `SKILL.md` and only the supporting resources that its routing requires.
3. Tell the worker to perform its own skill-selection pass after reading the package and load any additional execution skill that clearly applies. The main-thread manifest is a required minimum, while orchestration skills remain outside the worker's role.
4. Require the worker to list the instructions, skills, and routed references it actually loaded before it reports implementation work. An unavailable required file or skill is a blocker to report, not a reason to proceed without the governing context.

Context rehydration is complete only when the package names the governing instruction chain and required skills, and the worker confirms them in its delivery report. Do not dispatch a generic instruction such as “follow repository conventions” in place of this manifest.

## Write Complete Work Packages

Because workers receive no conversation fork, every dispatch message must be self-contained. Include:

- the worker's role as a leaf implementer that executes this package directly and returns its report without delegating;
- the user-visible objective and acceptance criteria;
- exact file, directory, or module ownership;
- the applicable `AGENTS.md` chain and required referenced project documents;
- the required `$skill-name` manifest and the worker's independent skill-selection obligation;
- existing changes that must be preserved;
- interfaces or assumptions shared with other packages;
- required implementation and tests;
- commands or quality gates the worker should run;
- the required delivery report below.

Tell every worker that it is not alone in the workspace, must preserve user and peer changes, must stay inside its ownership boundary, and must not create subagents. Workers do not commit, push, reset, discard changes, or perform destructive Git operations unless the user explicitly requested that exact action.

Use this delivery contract:

```text
Status: complete | partial | blocked
Instructions and skills loaded:
Files changed:
Implementation:
Tests and results:
Self-review findings and fixes:
Remaining risks:
Main-thread review focus:
```

## Worker Completion Gate

A Luna worker is complete only after it has:

1. loaded and reported every applicable repository instruction, required skill, and routed reference before editing;
2. implemented the owned package without expanding its scope;
3. added or updated meaningful tests when behavior changed;
4. run the most relevant targeted tests and applicable formatter, lint, or type checks;
5. inspected its own diff for correctness, missing cases, accidental edits, compatibility problems, and violations of repository instructions;
6. fixed its self-review findings or disclosed each unresolved risk in the delivery report.

The worker reports exact commands and outcomes. It must distinguish a check it ran successfully from one it could not run.

## Main-Thread Final Review

The main thread retains final responsibility. Before declaring completion:

- compare the combined implementation with every acceptance criterion;
- re-evaluate the architecture, assumptions, invariants, dependency interactions, and tradeoffs using the completed implementation as evidence;
- reason through important failure scenarios and cross-package behavior that no single Luna worker could validate locally;
- inspect all relevant diffs, including interactions across worker-owned boundaries;
- verify that pre-existing user changes remain intact;
- verify each worker loaded the package's complete instruction and skill manifest before editing; treat a missing manifest entry as incomplete work;
- check public interfaces, error paths, edge cases, and regression risk;
- run integration or repository-level tests beyond the workers' targeted checks when available;
- send a precise follow-up to the owning Luna worker when a bounded correction is needed, or fix the integration directly when ownership has ended;
- report incomplete checks and residual risk honestly.

The main thread performs this whole-task reasoning itself. Worker summaries and self-reviews inform the decision but never substitute for independent final judgment.

Reuse the original worker for related corrections when practical. Stop repeated blind retries: after one clarified retry fails for the same reason, inspect and take over the work or report the concrete blocker.

## Parallelism Boundaries

Parallelize independent vertical slices, separate modules, tests for already stable interfaces, or documentation isolated from implementation. Execute sequentially when packages would edit the same files, depend on an unsettled schema or API, require the output of another package, or compete over generated artifacts.

For security-sensitive changes, concurrency, migrations, public APIs, or broad refactors, the main thread may assign an available Luna worker a read-only adversarial review after implementation. This supplements the main-thread final review and never replaces it.
