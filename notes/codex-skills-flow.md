# Codex Skills Flow

Personal cheat sheet untuk workflow backend Go/Rust/Python, legacy Java discovery dan migration mapping, frontend React/TypeScript, security review, serta custom-agent orchestration.

## Main Flow

```text
tech-plan -> tdd-workflow -> review-feature -> pr-summary -> review-pr -> review-pr-followup
```

Custom agents are selected by the skills, so short prompts remain sufficient:

```text
review-pr / review-feature
  -> code-reviewer for non-trivial review
  -> stack-reviewer per changed stack
  -> architect only for material architecture changes
  -> main Codex verifies and consolidates findings

tech-plan
  -> architect only when architecture analysis materially improves the plan
  -> main Codex writes the plan
```

For Python-only implementation, replace the `tdd-workflow` step with:

```text
coding-standard -> python-patterns -> effective-python -> python-testing -> python-lint-workflow
```

For React frontend implementation, use:

```text
react-patterns -> frontend-design-system -> typescript-patterns -> accessibility -> react-testing -> react-performance -> frontend-build-resolver
```

For a legacy Java rewrite, use:

```text
java-legacy-extraction -> java-legacy-discovery -> java-migration-mapping -> target implementation skills
```

For direct Java implementation or repair, use:

```text
java-patterns -> java-build-resolver if validation fails
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
- `python-lint-workflow`
  - Python Ruff/Black/mypy/Pyright/import/package/pre-commit/tox/nox/CI validation, baseline-aware.
- `react-patterns`
  - React components, hooks, state, data flow, forms, server/client boundaries, styling, and maintainability.
- `frontend-design-system`
  - Shared UI primitives, tokens, component variants, visual states, responsive behavior, theming, and component documentation.
- `typescript-patterns`
  - TypeScript type design, narrowing, discriminated unions, useful generics, API boundaries, React props, generated clients, and strict-mode-aware TS/TSX.
- `accessibility`
  - Semantic HTML, keyboard access, focus management, accessible names, forms, ARIA, contrast, dynamic UI behavior, and WCAG-aligned review.
- `react-testing`
  - Behavior-focused React tests with repo-standard Testing Library/Vitest/Jest/MSW/Playwright/Cypress patterns.
- `react-performance`
  - React/Next.js waterfalls, bundles, hydration scope, render cascades, long lists, layout stability, and interaction performance.
- `frontend-build-resolver`
  - Frontend lint/typecheck/test/build/dev-server/bundler/SSR/hydration/CSS validation failure resolution.
- `go-lint-workflow` / `rust-lint-workflow`
  - Scoped lint and formatting validation, baseline-aware. For Go, cover `mnd`, `lll`, complexity, and test-file judgment without broad incidental refactors.
- `go-build-resolver` / `rust-build-resolver`
  - Use only when build/check/test/lint validation fails.
- `java-patterns`
  - Version-aware Java implementation and review across Java 8+, Spring, Maven/Gradle, MyBatis/JPA, transactions, errors, resources, concurrency, and tests.
- `java-build-resolver`
  - Use when Java compile, test, Maven/Gradle, dependency, profile, resource-filtering, WAR, plugin, or classpath validation fails.

Note: Java, Python, and frontend validation resolvers should inspect repo tooling first and use configured commands only when present or approved.

## Conditional Skills

- `java-legacy-extraction`
  - Use to build a source-linked inventory of modules, routes, jobs, service paths, MyBatis queries, JSP actions, configuration variants, and cross-cutting concerns.
- `java-legacy-discovery`
  - Use to reconstruct business rules and end-to-end behavior after extraction, with confidence and preserve/confirm/defect/obsolete classification.
- `java-migration-mapping`
  - Use after discovery to map APIs, data, transactions, jobs, sessions, and integrations to a target architecture with parity and reconciliation criteria.
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
- `security-review`
  - Use for auth, authorization, tenant isolation, input/output handling, XSS, CSRF, injection, secrets, sessions, cookies, files, webhooks, third-party integrations, logging, and sensitive data.

## Language Lanes

### Go

```text
coding-standard -> go-patterns -> go-lint-workflow -> go-build-resolver if validation fails
```

### Rust

```text
coding-standard -> rust-patterns -> rust-lint-workflow -> rust-build-resolver if validation fails
```

### Java

For direct Java implementation or maintenance:

```text
java-patterns -> java-build-resolver if validation fails
```

For legacy extraction and rewrite work:

```text
java-legacy-extraction -> java-legacy-discovery -> java-migration-mapping
```

For 6HC, treat the Java/MySQL system as source evidence. Continue target implementation through `go-patterns`, `tdd-workflow`, `api-contract-review`, `database-migrations`, `mysql-patterns`, and `postgres-patterns` as applicable.

### Python

```text
coding-standard -> python-patterns -> effective-python -> python-testing -> python-lint-workflow
```

For Python, `python-patterns` is the default implementation/review guide, `effective-python` is for deeper idiom/API refinement, `python-testing` is for test strategy and RED/GREEN evidence, and `python-lint-workflow` resolves Ruff/Black/mypy/Pyright/import/package validation.

### React

```text
react-patterns -> frontend-design-system -> typescript-patterns -> accessibility -> react-testing -> react-performance -> frontend-build-resolver
```

For React, `react-patterns` is the default implementation/review guide, `frontend-design-system` keeps shared UI primitives and tokens coherent, `typescript-patterns` keeps TS/TSX contracts safe, `accessibility` checks semantic and keyboard behavior, `react-testing` covers user-behavior tests and test layer decisions, `react-performance` is for waterfalls, bundle, hydration, rendering, and interaction performance, and `frontend-build-resolver` handles validation failures.

## PR And Review Skills

- `review-feature`
  - Review local feature before PR exists.
  - Automatically orchestrates read-only review agents according to scope and changed stacks.
  - Can resolve findings only when explicitly asked.
- `pr-summary`
  - Generate PR title/body Markdown file only.
  - Does not modify implementation files.
- `review-pr`
  - Review GitHub PR and produce findings.
  - Automatically uses `code-reviewer`, per-stack `stack-reviewer`, and conditional `architect` when available.
  - Does not post comments unless explicitly asked.
- `review-pr-followup`
  - Re-review after PR findings were commented and the author pushed updates.
  - Can infer PR only when exactly one last reviewed PR is clear in the same session.
- `solve-conflict-pr`
  - Resolve merge conflicts for a PR.
  - Does not merge, force-push, or discard local work unless explicitly asked.

## Backend Planning Rule

`tech-plan` is planning-only.

For material boundary, contract, migration, consistency, integration, deployment, or legacy-rewrite decisions, it automatically consults the read-only `architect` agent when available. The main thread still owns and writes the final plan.

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
python-lint-workflow fix this Ruff and mypy failure
```

```text
react-patterns build this dashboard view
```

```text
frontend-design-system create shared table and filter primitives
```

```text
typescript-patterns review these component props
```

```text
accessibility review this modal and form
```

```text
react-testing add tests for this form
```

```text
react-performance review this Next.js route
```

```text
frontend-build-resolver fix this pnpm build failure
```

```text
java-legacy-extraction inventory the 6hc-java modules with file:line evidence
```

```text
java-legacy-discovery reconstruct the login and authorization flow
```

```text
java-migration-mapping map this Spring MVC and MySQL behavior to Go and PostgreSQL
```

```text
java-patterns review this Java 8 Spring service change
```

```text
java-build-resolver diagnose why this Maven WAR build skips tests
```

```text
security-review check this auth and file upload change
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
- Let `review-pr`, `review-feature`, and `tech-plan` select agents; name agents manually only when overriding the default orchestration.
- Do not paste the whole repository context unless needed.
- Prefer specific skill names over long instructions.
- Let skills inspect repository files only when relevant.
- Keep notes and generated Markdown artifacts as handoff context between sessions.
