---
name: tech-plan
description: Create a backend-only technical implementation plan as a Markdown file before coding from prompts such as "tech-plan", "/tech-plan", "create tech plan", "plan this backend feature", "design backend implementation", or "analyze before implement". Use when Codex should read project memory, inspect requirements and backend code, automatically consult the read-only architect agent for material cross-module, contract, data, migration, consistency, integration, deployment, or legacy-rewrite decisions when subagents are available, apply relevant error/API/observability/database/language skills, identify affected modules, risks, edge cases, tests, rollout, and open questions. The only allowed file write is the Markdown plan file; do not modify source, test, config, migration, generated, lock, or dependency files unless implementation is explicitly requested after the plan.
---

# Tech Plan

## Input Handling

Accept loose, team-style prompts. Treat any of these as valid triggers:

```text
tech-plan
/tech-plan
create tech plan
plan this feature
design implementation
analyze before implement
JIRA: https://...
context: group member list projection
```

Use the current repository when no repository is specified. Preserve user-provided `JIRA`, `context`, acceptance criteria, release notes, product notes, or reviewer notes as planning context, not as proof that the proposed design is correct.

Default to planning-only. Do not implement code, push commits, create PRs, or post to GitHub unless the user explicitly asks.

## Write Safety Contract

This skill may write exactly one planning artifact: a Markdown file containing the tech plan.

Forbidden during `tech-plan` unless the user explicitly asks to implement after the plan:

- editing source files
- editing test files
- editing config files
- editing migrations or schemas
- editing generated files
- editing dependency manifests or lockfiles
- running formatters that rewrite code
- running code generators

Allowed during `tech-plan`:

- reading files
- searching the repository
- inspecting git status/diffs/history
- running read-only commands
- creating or updating only the selected tech plan `.md` file

If a change to code is needed, describe it in the Markdown plan under `Implementation Plan`; do not apply it.

This skill is backend-only by default. Focus on services, handlers, APIs, domain logic, persistence, migrations, generated backend contracts, workers, jobs, queues, configuration, auth, observability, and backend tests. Exclude frontend/UI planning unless the user explicitly asks to include it.

Create a Markdown plan file by default instead of only replying in chat. Prefer a repository-local planning path if one already exists, such as `docs/`, `plans/`, `.agents/`, `.codex/`, or a memory-system planning folder. If no suitable convention exists, ask for the target path or propose a concise filename such as `tech-plan-<feature-slug>.md`. Do not create or edit implementation source files as part of this skill.

## Architect Delegation

Treat `tech-plan` as sufficient authorization to consult the read-only `architect` agent when architecture analysis materially improves the plan. The user does not need to request the agent separately.

Invoke `architect` after gathering the requirement and enough repository evidence when the change involves one or more of:

- cross-module, service, package, or ownership-boundary changes
- new or changed public API, schema, generated contract, integration, queue, or job boundary
- data migration, backfill, transaction, concurrency, consistency, or idempotency decisions
- deployment topology, runtime, availability, recovery, or significant performance constraints
- legacy extraction, rewrite parity, or source-to-target migration such as Java/MySQL to Go/PostgreSQL
- a durable choice with meaningful alternatives that may warrant an ADR

Skip architect delegation for a localized change that follows an established pattern and has no material boundary or operational decision.

Give the architect the requirement, non-goals, repository paths, constraints, existing decisions, and relevant skill names. For legacy Java rewrites, explicitly assign `java-legacy-extraction`, `java-legacy-discovery`, and `java-migration-mapping` as applicable. Do not provide a preferred solution as if already decided.

Wait for the architect, verify its evidence against the repository, and critically evaluate alternatives. The main agent owns the final design, writes the single allowed Markdown plan file, and records any rejected recommendation or unresolved assumption. If custom agents or subagent tools are unavailable, perform the architecture analysis directly and continue.

## Workflow

1. Read project memory first:
   - Search the current repository for directories matching `*-memory-system`.
   - Read relevant index, overview, convention, architecture, decision, domain, API, workflow, or README-like files from those memory directories.
   - Extract project conventions, architecture constraints, domain rules, prior decisions, known risks, and workflow expectations.
   - If no memory folder exists, state that and continue with codebase inspection.
2. Understand the requirement:
   - Restate the requested behavior in concrete terms.
   - Identify user-facing behavior, system behavior, non-goals, and assumptions.
   - Call out missing product or technical details that affect the design.
3. Inspect the codebase:
   - Find relevant backend modules, packages, services, tests, schemas, API handlers, models, migrations, feature flags, generated code, workers, jobs, queues, and configuration.
   - Prefer existing patterns over new abstractions.
   - Note ownership boundaries and cross-module contracts.
4. Design the implementation:
   - Propose a simple approach that satisfies the requirement.
   - Break work into ordered implementation tasks.
   - Include data model, state, validation, error handling, concurrency, performance, and backward compatibility considerations when relevant.
   - If validation failures, API errors, database errors, external service failures, timeouts, retries, cancellation, workers, jobs, or observable failure behavior are involved, apply `error-handling` and include error classification, boundary mapping, retry/timeout/cancellation behavior, privacy-safe logging, and error-path tests.
   - If operationally important endpoints, workers, jobs, external calls, migrations/backfills, retries, or concurrency are involved, apply `observability-check` and include logging/metrics/tracing/telemetry expectations plus PII/secret safety.
   - If schema changes, data backfills, rollback planning, or zero-downtime rollout are involved, apply `database-migrations` and include migration phase, lock risk, rollback/forward-fix plan, and validation.
   - If MySQL/MariaDB schema, query, index, transaction, replica, or pool behavior is touched, apply `mysql-patterns` and include engine/version assumptions plus migration/query validation.
   - If PostgreSQL/Supabase schema, query, index, transaction, RLS, replica, or pool behavior is touched, apply `postgres-patterns` and include version/extension assumptions plus migration/query/RLS validation.
5. Include API design when applicable:
   - Endpoint, method, route, and handler ownership.
   - Request shape, response shape, validation rules, and error model.
   - Auth, permissions, tenancy, idempotency, pagination, filtering, and sorting when relevant.
   - Backward compatibility, versioning, generated clients, and contract tests when relevant.
   - If client-observable API behavior changes, apply `api-contract-review` and classify the change as no contract change, additive compatible change, behavior fix with client impact, or breaking change.
6. Include test and validation plan:
   - Unit, integration, API contract, migration, regression, worker/job, and backend service tests as appropriate.
   - Focused commands to run.
   - Manual verification steps when automation is not enough.
7. Identify risks:
   - Correctness, data loss, security/privacy, concurrency, migration, API compatibility, performance, rollout, and operational risks.
   - Explain mitigations or validation paths.
8. End with open questions:
   - Ask only questions that materially affect implementation.
   - If assumptions are reasonable, state them and proceed with the plan.
9. Add an implementation handoff:
   - State that future implementation should use `tdd-workflow` by default.
   - State that future implementation must follow `coding-standard` automatically.
   - Mention Go/Rust format, lint, type-check, and test expectations when relevant.
   - Remind the implementer to keep changes scoped to the approved backend plan.
10. Before finishing, confirm that no source/test/config/migration/generated/dependency files were modified. If any were modified accidentally, stop and report the exact files instead of continuing.

## Output Format

Create a Markdown file with this structure by default, then reply with the file path, a short summary, and the sentence `No implementation files were modified.`

```markdown
# Tech Plan - <feature or scope>

## Memory Context
- <memory files/folders read>
- <project conventions, architecture notes, or domain rules discovered>

## Requirement
- <concrete behavior to implement>
- <non-goals or assumptions>

## Backend Scope
- <backend-only scope and explicit frontend exclusions>

## Codebase Context
- <affected backend modules/packages/files>
- <existing patterns to follow>

## API Design
- <endpoint/method/request/response/errors/auth/backward compatibility>
- <omit this section if the feature does not touch API behavior>

## Implementation Plan
1. <task>
2. <task>
3. <task>

## Test Plan
- <automated tests to add/update>
- <commands to run>
- <manual validation, if needed>

## Risks & Mitigations
- <risk and mitigation>

## Open Questions
- <question or "None">

## Implementation Handoff
- When implementing this plan, automatically use `tdd-workflow` for backend Go/Rust changes: write tests first, prove RED, implement minimal code, prove GREEN, then refactor.
- When implementing this plan, automatically follow `coding-standard` for any Go or Rust code touched.
- For Go changes, automatically apply `go-patterns` for idiomatic backend design and implementation.
- For Rust changes, automatically apply `rust-patterns` for idiomatic backend design and implementation.
- For Go changes, use `go-lint-workflow` for scoped or baseline-aware lint; for Rust changes, use `rust-lint-workflow` for scoped cargo fmt/check/clippy/test validation.
- If Go validation fails during implementation, use `go-build-resolver` for minimal scoped fixes. If Rust validation fails, use `rust-build-resolver`.
- For validation failures, API errors, database errors, external service failures, timeouts, retries, cancellation, workers, jobs, or observable failure behavior, use `error-handling` for error classification, propagation, boundary mapping, retry safety, logging privacy, and error-path tests.
- For API request, response, error, auth, pagination, idempotency, or generated contract changes, use `api-contract-review` for compatibility and contract-test validation.
- For operationally important endpoints, workers, jobs, external calls, migrations/backfills, critical flows, retries, or concurrency, use `observability-check` for logging, metrics, tracing/telemetry, error context, and PII/secret safety.
- For schema changes, data migrations, backfills, or zero-downtime rollout, use `database-migrations` for migration safety, expand-contract planning, rollback/forward-fix strategy, and validation.
- For MySQL/MariaDB changes, use `mysql-patterns` for schema, query, index, transaction, replication, pool, security, and migration validation.
- For PostgreSQL/Supabase changes, use `postgres-patterns` for schema, query, index, transaction, RLS, replication, pool, security, and migration validation.
- Keep implementation scoped to this backend plan unless the user approves changes outside scope.
- Run focused format, lint, type-check, and test commands listed in `Test Plan` before finishing when feasible.
```

Keep the plan specific enough to implement from, but avoid unnecessary ceremony for small changes. For trivial changes, create a shorter Markdown file with `Requirement`, `Backend Scope`, `Implementation Plan`, `Test Plan`, and `Risks`.

## Planning Standards

Prioritize simplicity and maintainability:

- Prefer the smallest design that satisfies current requirements.
- Avoid speculative abstractions and future-only extension points.
- Follow existing project conventions unless there is a concrete reason to diverge.
- Surface tradeoffs clearly when multiple approaches are viable.
- Treat migrations, schemas, generated files, API contracts, and cross-repository changes as high-attention areas.
- For API designs that change client-observable behavior, apply `api-contract-review` for request/response shape, error model, validation, auth/tenancy, pagination/filter/sort, idempotency, generated artifacts, backward compatibility, and contract tests.
- For backend designs that touch validation failures, API errors, database errors, external service failures, timeouts, retries, cancellation, workers, jobs, or observable failure behavior, apply `error-handling` for error classification, propagation, API/client boundary mapping, retry safety, timeout/cancellation handling, and error-path tests.
- For operationally important backend designs, apply `observability-check` for logging, metrics, tracing/telemetry, correlation context, dashboard/alert impact, and sensitive-data redaction.
- For schema/data migration designs, apply `database-migrations` for migration immutability, phased rollout, lock safety, backfill batching, compatibility, rollback/forward-fix planning, and validation.
- For MySQL/MariaDB designs, apply `mysql-patterns` for engine/version assumptions, migration safety, indexing, query plans, locking/deadlocks, replica consistency, connection pools, and least-privilege access.
- For PostgreSQL/Supabase designs, apply `postgres-patterns` for version/extension assumptions, migration safety, indexing, query plans, locks/deadlocks, RLS/security, replica consistency, connection pools, and least-privilege access.
- For Go and Rust code, apply `coding-standard` expectations during planning: readability, KISS, DRY, YAGNI, idiomatic naming, formatting, error handling, visibility, linting, type-checking, and tests.
- For Go backend designs, apply `go-patterns` for error handling, context propagation, interface boundaries, package ownership, dependency injection, concurrency lifecycle, zero-value design, testability, and performance tradeoffs.
- For Rust backend designs, apply `rust-patterns` for ownership and borrowing, error handling, state modeling, traits/generics, module visibility, async/concurrency lifecycle, unsafe boundaries, testability, and performance tradeoffs.
- Keep frontend concerns out of the plan unless explicitly requested. If backend changes require frontend follow-up, list it as an integration note, not as implementation scope.

If the user asks to continue after the plan, implement in a separate step using the approved plan and keep changes scoped to that plan.
