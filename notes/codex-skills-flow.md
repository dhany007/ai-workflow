# Codex Skills Flow

Personal cheat sheet untuk workflow backend Go/Rust/Python.

## Main Flow

```text
tech-plan -> tdd-workflow -> review-feature -> pr-summary -> review-pr -> review-pr-followup
```

For Python-only implementation, replace the `tdd-workflow` step with:

```text
coding-standard -> python-patterns -> effective-python -> python-testing
```

## Daily Backend Flow

```text
1. tech-plan context: <task>
2. implement this feature from <tech-plan.md>
3. review-feature
4. pr-summary this feature
5. review-pr <PR URL>
6. review-pr-followup <PR URL>
```

## Always On During Implementation

- `coding-standard`
  - Go/Rust/Python readability, KISS, DRY, YAGNI, naming, structure, formatting, typing, linting, tests.
- `go-patterns` / `rust-patterns` / `python-patterns`
  - Idiomatic language-specific backend/application design and implementation.
- `effective-python`
  - Deeper Python API design, data modeling, iteration, resource lifecycle, typing, object design, imports, async, and maintainability refinement.
- `python-testing`
  - Python test strategy, pytest or repo-standard tests, fixtures, mocks/fakes, async tests, RED/GREEN loops, deterministic state, and coverage guidance.
- `go-lint-workflow` / `rust-lint-workflow`
  - Scoped lint and formatting validation, baseline-aware.
- `go-build-resolver` / `rust-build-resolver`
  - Use only when build/check/test/lint validation fails.

Note: no dedicated Python lint/build resolver exists yet. For Python, inspect repo tooling first and use configured commands such as `python -m pytest`, Ruff, Black, mypy, or Pyright only when present or approved.

## Conditional Skills

- `error-handling`
  - Use for validation errors, API errors, DB errors, external service failures, timeout, cancellation, retry, workers, jobs, and observable failure behavior.
- `api-contract-review`
  - Use when request, response, status code, error body, auth behavior, pagination, idempotency, OpenAPI/proto/generated client, or client-visible API behavior changes.
- `observability-check`
  - Use for logging, metrics, tracing, telemetry, production debuggability, retry/failure signals, and PII/secret safety.
- `database-migrations`
  - Use for schema changes, data migrations, backfills, zero-downtime rollout, rollback/forward-fix planning.
- `mysql-patterns`
  - Use for MySQL/MariaDB schema, query, index, transaction, locking, replica, pool, and security concerns.
- `postgres-patterns`
  - Use for PostgreSQL/Supabase schema, query, index, transaction, RLS, replica, pool, and security concerns.

## Language Lanes

### Go

```text
coding-standard -> go-patterns -> go-lint-workflow -> go-build-resolver if validation fails
```

### Rust

```text
coding-standard -> rust-patterns -> rust-lint-workflow -> rust-build-resolver if validation fails
```

### Python

```text
coding-standard -> python-patterns -> effective-python -> python-testing
```

For Python, `python-patterns` is the default implementation/review guide, `effective-python` is for deeper idiom/API refinement, and `python-testing` is for test strategy and RED/GREEN evidence.

## PR And Review Skills

- `review-feature`
  - Review local feature before PR exists.
  - Can resolve findings only when explicitly asked.
- `pr-summary`
  - Generate PR title/body Markdown file only.
  - Does not modify implementation files.
- `review-pr`
  - Review GitHub PR and produce findings.
  - Does not post comments unless explicitly asked.
- `review-pr-followup`
  - Re-review after PR findings were commented and the author pushed updates.
  - Can infer PR only when exactly one last reviewed PR is clear in the same session.
- `solve-conflict-pr`
  - Resolve merge conflicts for a PR.
  - Does not merge, force-push, or discard local work unless explicitly asked.

## Backend Planning Rule

`tech-plan` is planning-only.

It may create or update one Markdown plan file, but must not edit source, test, config, migration, generated, lock, or dependency files unless implementation is explicitly requested after the plan.

Before planning, it should read project memory folders such as:

```text
*-memory-system
```

## TDD Rule

For Go/Rust backend implementation:

```text
write failing test -> prove RED -> implement minimal code -> prove GREEN -> refactor -> validate
```

Use `tdd-workflow` for Go/Rust backend TDD. For Python, use `python-testing` to apply the same RED/GREEN discipline with the repository's configured test runner.

No automatic commits unless explicitly requested.

## Error Handling Rule

For changed error behavior, trace:

```text
failure source -> internal error/context -> client result -> retry/log/metric behavior -> test evidence
```

Check for:

- swallowed errors
- false success
- wrong status code or error code
- leaked internal details
- unsafe retries
- missing timeout or cancellation handling
- missing error context
- noisy or unsafe logs
- missing error-path tests

## Good Prompt Examples

```text
tech-plan context: add retry-safe webhook delivery
```

```text
implement this feature from .codex/plans/webhook-delivery.md
```

```text
implement this Python feature with coding-standard and python-patterns
```

```text
use effective-python to refine this API
```

```text
python-testing add regression coverage for this bug
```

```text
review-feature
```

```text
review-feature and resolve findings
```

```text
pr-summary this feature
```

```text
review-pr https://github.com/org/repo/pull/123
```

```text
review-pr-followup https://github.com/org/repo/pull/123
```

```text
solve-conflict-pr https://github.com/org/repo/pull/123
```

## Context Engineering Notes

- Keep prompts short and trigger-oriented.
- Do not paste the whole repository context unless needed.
- Prefer specific skill names over long instructions.
- Let skills inspect repository files only when relevant.
- Keep notes and generated Markdown artifacts as handoff context between sessions.
