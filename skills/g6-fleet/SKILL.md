---
name: g6-fleet
description: Coordinate a single-level implementation fleet when the user explicitly asks for g6-fleet, GPT-6 Luna workers, or parallel Luna implementation. The main thread plans, assigns work, integrates changes, and performs final review; workers implement bounded packages. Do not invoke for requests that only inspect or edit this skill.
---

# G6 Fleet

Use this skill only in the main thread that received the user's fleet request. The main thread owns architecture, task boundaries, shared interfaces, integration, and final acceptance. Workers implement bounded packages, run focused checks, and self-review. Workers are leaf implementers: they do not create subagents or orchestrate another fleet.

## Worker Configuration

Use these values for every `spawn_agent` call. This block is the source of truth for worker configuration:

```json
{
  "agent_type": "worker",
  "model": "gpt-6-luna",
  "reasoning_effort": "xhigh",
  "fork_turns": "none"
}
```

Give each work package a unique `task_name` and a self-contained `message`. Before dispatch, check that the runtime supports the requested model, reasoning effort, and collaboration tool, and inspect active-agent capacity. If the configuration is unavailable, report the specific limitation. Do not silently substitute a model or omit the requested overrides.

There is no fixed worker-count limit in this skill. Choose the number of workers from task size, independent packages, and dependencies. Respect runtime capacity, including the main thread and other active agents. Dispatch all ready packages with non-overlapping write ownership that fit; queue the rest and continue in dependency order as capacity becomes available. Reuse an existing worker for follow-up work when practical. Manage capacity only through lifecycle information the runtime actually provides; do not assume a completed or idle worker releases a slot.

## Plan and Assign Ownership

Inspect applicable repository instructions, relevant source, existing user changes, and validation commands. Translate the request into acceptance criteria, constraints, and bounded work packages. Before dispatch, assign an owner and validation method to every acceptance criterion.

Choose the smallest useful packages with independent write ownership. Keep coupled edits together or schedule them in sequential waves. Settle shared interfaces before dependent implementation begins. The main thread owns cross-package design decisions and final integration.

Assign each file or module to at most one active writer, including shared configuration, lockfiles, and generated artifacts. Workers may read relevant files outside their ownership. Tell workers that they share the workspace with the user and peer workers and must preserve their changes. Do not let workers commit, push, reset, discard changes, or perform destructive Git operations unless the user explicitly authorized that action.

Scale planning detail to the task. A small package can use a concise dispatch; explain architecture, failure modes, and interface contracts when dependencies or risk require it. Include the required work-package context either way.

## Write Self-Contained Work Packages

Workers start without this conversation history. Each dispatch message must include:

- **Role and outcome:** Leaf implementer role, user-visible goal, acceptance criteria, and relevant scope exclusions.
- **Ownership:** Exact writable paths or modules, existing changes to preserve, dependencies, and shared interface contracts.
- **Project instructions:** Every applicable `AGENTS.md` from repository root through owned paths, required referenced documents, and relevant instructions from the conversation. Require workers to read them before editing.
- **Skills:** List required skills by their actual installed names and explain why each applies. Workers must resolve the names against their own available skills, read each applicable `SKILL.md` and routed reference, then make an independent pass for other clearly relevant execution skills. Fleet orchestration stays in the main thread. Do not name hypothetical or unavailable skills as required.
- **Capabilities:** Required tool capabilities, preferred approach, and permitted alternatives. Workers should inspect locally available or discoverable tools instead of assuming a particular executable or MCP server exists. A missing hard requirement is a blocker; a preferred approach may use an approved equivalent. Installing, connecting, or reconfiguring tools requires user authorization.
- **Existing evidence:** Relevant paths and symbols, confirmed behavior, decisions, checks already run, and unresolved questions. Reuse evidence, but recheck assumptions affected by new edits. If using a code graph, include its project, freshness/generation status, coverage, relevant query results and pagination state, and source-fallback checks; follow its validation requirements.
- **Validation:** Meaningful focused checks, applicable quality gates, and checks reserved for final integration. Add or update tests when needed to prove changed behavior. Scale validation to the change and repository requirements.
- **Delivery:** The report format below, ownership handoff rules, and prompt blocker reporting.

Use repository-relative paths for project material and installed skill names for skills. A generic instruction to “follow conventions” does not replace the applicable instruction and capability manifest. Workers must report what they actually loaded and resolved.

## Coordinate Work and Recover from Blockers

Dispatch only packages whose prerequisites are settled. Track each package's owner, dependencies, status, validation evidence, and unresolved risks. Continue useful design or integration preparation while workers run. When no independent work remains, wait in a way that avoids frequent polling while keeping the user informed.

If a worker needs an interface change, a file owned by someone else, or a missing capability, have it report the exact need and impact, then continue its independent in-scope work. The main thread resolves dependencies, assigns changes to their owners, or explicitly transfers ownership.

Transfer ownership only after the previous writer has finished or confirmed it has stopped editing. A delivery report ends that worker's write activity for the package; assign ownership again for follow-up edits. If a worker crashes or becomes unresponsive, stop it and verify its status before reassigning its files. Inspect partial changes and preserve useful work.

Reuse the original worker for a bounded correction when practical. If one clarified retry fails for the same reason, inspect the evidence and let the main thread take over or report the concrete blocker. Avoid repeated blind retries.

## Worker Completion Gate

Before reporting completion, a worker must have loaded applicable instructions and skills, met required capabilities, completed its in-scope implementation, run appropriate checks, and reviewed its diff for correctness, edge cases, compatibility, and accidental edits. Fix self-review findings or disclose each unresolved issue. Distinguish checks that passed, failed, or could not run.

Return a concise report using this contract; write `none` where appropriate:

```text
Status: complete | partial | blocked
Instructions and skills loaded:
Capabilities met and alternatives used:
Files changed:
Implementation and acceptance evidence:
Checks: exact commands, results, and checks not run
Self-review findings and fixes:
Remaining risks or blockers:
Main-thread review focus:
Ownership: stopped editing; ready for handoff
```

## Integration and Acceptance

Inspect each package's actual workspace changes and validation evidence. Worker reports inform review; the main thread independently determines whether the complete implementation meets the request.

Verify instruction and skill loading, required capabilities, ownership boundaries, preservation of existing changes, and every acceptance criterion. Reconcile package interactions, public interfaces, error paths, important failure scenarios, and unresolved worker findings. The main thread decides shared design tradeoffs.

Treat worker-run checks as evidence for the state they tested. Run required final quality gates and checks that prove integrated behavior. Rerun focused checks when integration changes invalidate earlier results; avoid repeating expensive checks when nothing relevant has changed.

For high-risk changes, an available worker may perform a bounded, read-only adversarial review after implementation. The main thread still owns final acceptance.

The task is complete only when every acceptance criterion is met and required checks are accounted for. Report the resulting behavior, validation performed, and material remaining limitations. If work is blocked or partial, state what remains without claiming success.
