# Codex Agents Flow

Personal reference for Codex custom-agent orchestration. Custom agents are read-only workers; skills provide reusable expertise; the main Codex thread owns decisions, validation, edits, and final output.

## Core Agents

| Agent | Role | Default Use |
| --- | --- | --- |
| `code-reviewer` | Language-neutral correctness, regression, security, contracts, data safety, and test gaps | Every non-trivial `review-pr` or `review-feature` |
| `stack-reviewer` | One language or frontend stack with its matching skills and repository tooling | Once per materially changed stack |
| `architect` | Boundaries, data flow, contracts, migrations, rewrites, trade-offs, and implementation order | Material architecture changes and complex `tech-plan` work |

All agent definitions use `sandbox_mode = "read-only"` and inherit the active parent model configuration.

## Review Flow

```text
review-pr <URL> / review-feature
  -> inspect metadata and changed files
  -> skip agents only for clearly trivial low-risk changes
  -> code-reviewer for non-trivial cross-cutting review
  -> stack-reviewer per changed stack
  -> architect only when architecture triggers are present
  -> wait for all requested agents
  -> verify evidence and failure scenarios
  -> deduplicate and reconcile severity
  -> run focused validation when useful
  -> findings-first final review
```

The user does not need to name agents. These prompts are sufficient:

```text
review-pr https://github.com/org/repo/pull/123
review-feature
review-feature and resolve findings
```

## Stack Routing

| Stack | Skills Assigned To `stack-reviewer` |
| --- | --- |
| Go | `go-patterns`, `go-lint-workflow`; `go-build-resolver` only for observed failures |
| Rust | `rust-patterns`, `rust-lint-workflow`; `rust-build-resolver` only for observed failures |
| Java | `java-patterns`; `java-build-resolver` only for observed failures |
| Python | `python-patterns`, `effective-python`, `python-testing`, `python-lint-workflow` |
| React/TypeScript | `react-patterns`, `typescript-patterns`, `accessibility`, `react-testing`, `react-performance`; `frontend-build-resolver` only for observed failures |

For a multi-stack PR, spawn independent `stack-reviewer` instances in parallel with disjoint file scopes.

## Architect Triggers

Invoke `architect` when work changes:

- module, package, service, or ownership boundaries
- public API, schema, generated contract, queue, job, or integration boundaries
- migration, backfill, transaction, consistency, concurrency, or idempotency strategy
- deployment topology, runtime, availability, recovery, or significant performance constraints
- legacy rewrite parity or source-to-target architecture
- a durable decision with meaningful alternatives that may need an ADR

Skip `architect` for a localized change that follows an established pattern.

For 6HC-style rewrite work:

```text
tech-plan
  -> architect
     -> java-legacy-extraction
     -> java-legacy-discovery
     -> java-migration-mapping
  -> main Codex writes the plan
  -> Go/PostgreSQL implementation skills
```

## Evidence Contract

Agent findings are proposals, not final truth. The main Codex thread must:

1. verify the exact file and line against current source
2. require a concrete trigger, state, and incorrect outcome
3. check surrounding code, callers, tests, and framework guards
4. drop speculative or duplicate findings
5. own final severity, validation, translation, and user-facing output

Returning zero findings is valid.

## Resolve Mode

Custom review agents never edit files. For `review-feature and resolve findings`, the main thread reviews first, applies confirmed fixes, runs focused validation, and re-reviews the final diff.

## Growth Rule

Add a new agent only when a bounded responsibility is repeated often, benefits from isolated context or permissions, can run independently, and produces verifiable output. Prefer adding or refining a skill when only domain knowledge is missing.

Possible future agents include `legacy-rewrite-analyst`, `security-reviewer`, or `database-reviewer`, but create them only after repeated evidence that the three core agents are insufficient.

## Locations And Sync

```text
Personal runtime: ~/.codex/agents/*.toml
Repository mirror: ai-workflow/agents/*.toml
```

```bash
make sync-agents
scripts/sync-agents-from-codex.sh --dry-run
```
