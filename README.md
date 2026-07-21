# AI Workflow

This repository stores Codex skills and supporting scripts for AI-assisted development workflows.

## Project Structure

```text
.
├── notes/
├── scripts/
│   └── sync-from-codex.sh
└── skills/
    ├── accessibility/
    ├── api-contract-review/
    ├── coding-standard/
    ├── database-migrations/
    ├── effective-python/
    ├── error-handling/
    ├── frontend-build-resolver/
    ├── frontend-design-system/
    ├── go-build-resolver/
    ├── go-lint-workflow/
    ├── go-patterns/
    ├── mysql-patterns/
    ├── observability-check/
    ├── postgres-patterns/
    ├── pr-summary/
    ├── python-lint-workflow/
    ├── python-patterns/
    ├── python-testing/
    ├── react-patterns/
    ├── react-performance/
    ├── react-testing/
    ├── review-feature/
    ├── review-pr/
    ├── review-pr-followup/
    ├── rust-build-resolver/
    ├── rust-lint-workflow/
    ├── rust-patterns/
    ├── security-review/
    ├── solve-conflict-pr/
    ├── tdd-workflow/
    ├── tech-plan/
    └── typescript-patterns/
```

## Skills

Available skills in the `skills/` directory:

- `accessibility`: applies practical web accessibility guidance for semantic HTML, keyboard and focus behavior, forms, ARIA, color and contrast, dynamic UI, WCAG-aligned behavior, and testable UI outcomes.
- `api-contract-review`: reviews backend API compatibility for endpoints, request and response shapes, status codes, error models, validation, auth or tenant boundaries, pagination, versioning, generated contracts, and contract tests.
- `coding-standard`: applies Go, Rust, and Python coding standards for implementation, refactoring, review quality, naming, formatting, typing, linting setup, and contributor conventions. It coordinates language pattern, testing, lint, and build/check skills when relevant.
- `database-migrations`: applies production-safe migration practices for PostgreSQL, MySQL/MariaDB, and common ORM migration tools, including rollout, rollback, backfills, indexes, constraints, and zero-downtime changes.
- `effective-python`: applies deeper Python idiom and design judgment for API clarity, data modeling, iteration, resource lifecycle, exceptions, typing, protocols, object design, imports, async, performance tradeoffs, and maintainability.
- `error-handling`: reviews and designs backend error behavior for validation, auth, database, external service, timeout, retry, worker, transaction, and observable failure paths.
- `frontend-build-resolver`: diagnoses and fixes scoped frontend lint, typecheck, test, dev-server, build, bundler, SSR/hydration, CSS pipeline, and framework validation failures without broad dependency or config churn.
- `frontend-design-system`: applies design-system engineering guidance for reusable UI primitives, tokens, variants, theming, responsive behavior, component documentation, and accessible shared components.
- `go-build-resolver`: diagnoses and fixes scoped Go build, test, vet, module, lint, compile, and `golangci-lint` failures without broad unrelated refactors.
- `go-lint-workflow`: runs and interprets scoped Go linting with `golangci-lint`, `go vet`, and `go fmt`, including `mnd`, `lll`, complexity, and test-file judgment while separating new issues from existing baseline debt.
- `go-patterns`: applies idiomatic Go backend patterns for error handling, context propagation, interfaces, packages, dependency injection, concurrency, testing, and performance tradeoffs.
- `mysql-patterns`: applies MySQL and MariaDB production patterns for schema design, migrations, indexes, query performance, transactions, locks, replicas, connection pools, and operational validation.
- `observability-check`: reviews backend logging, metrics, tracing, error context, cardinality, dashboard or alert hooks, and PII or secret leakage risks for operationally important changes.
- `postgres-patterns`: applies PostgreSQL and Supabase production patterns for schema design, migrations, indexes, query plans, keyset pagination, JSONB, full-text search, transactions, locks, RLS, replicas, and security.
- `pr-summary`: generates a ready-to-paste pull request title and body from local branch or worktree changes, including JIRA/context/release notes when provided.
- `python-lint-workflow`: runs and interprets Python linting, formatting, import, type-checking, packaging, pre-commit, tox/nox, and CI validation failures while separating new issues from baseline debt.
- `python-patterns`: applies idiomatic Python backend and application patterns for typing, API boundaries, error handling, data modeling, package organization, dependency management, async/concurrency, testing patterns, tooling, performance tradeoffs, and anti-patterns.
- `python-testing`: applies practical Python testing strategy for pytest or repository-standard tests, RED/GREEN when appropriate, fixtures, mocks/fakes, async tests, coverage, deterministic state, and scoped validation.
- `react-patterns`: applies practical React frontend engineering patterns for components, hooks, state, data flow, forms, accessibility, TypeScript, server/client boundaries, styling, and maintainability.
- `react-performance`: reviews React and Next.js performance issues such as waterfalls, bundle size, hydration scope, server/client boundaries, render cascades, long lists, layout stability, and interaction responsiveness.
- `react-testing`: applies behavior-focused React testing strategy for components, hooks, pages, forms, async UI, accessibility behavior, network interactions, and frontend user flows.
- `review-feature`: reviews local feature work before a PR exists by inspecting branch or worktree diffs, applying coding standards, language patterns, lint workflows, error handling, API contracts, observability, and database safety where relevant.
- `review-pr`: performs first-pass GitHub pull request reviews by inspecting metadata, diffs, comments, unresolved threads, CI status, relevant code context, and changed error behavior where relevant.
- `review-pr-followup`: re-reviews a GitHub pull request after the author pushes updates, then verifies whether prior findings are resolved, partially resolved, unresolved, regressed, or need clarification.
- `rust-build-resolver`: diagnoses and fixes scoped Rust `cargo check`, build, test, clippy, dependency, feature, lifetime, borrow-checker, and `Cargo.toml` failures without broad unrelated refactors.
- `rust-lint-workflow`: runs and interprets scoped Rust validation with `cargo fmt`, `cargo check`, `cargo clippy`, and tests, while separating new warnings from existing workspace debt.
- `rust-patterns`: applies idiomatic Rust backend patterns for ownership, borrowing, errors, enums, traits, modules, async/concurrency, unsafe boundaries, testing, and performance tradeoffs.
- `security-review`: reviews application security risks for authentication, authorization, tenant boundaries, input/output handling, XSS, CSRF, injection, secrets, sessions, cookies, files, webhooks, third-party integrations, logging, and sensitive data.
- `solve-conflict-pr`: resolves GitHub pull request merge conflicts by reproducing the conflict locally, preserving behavior from both sides, and running focused validation.
- `tdd-workflow`: implements backend Go or Rust features, fixes, and refactors with a RED/GREEN/refactor test-driven workflow, using language-specific patterns, error handling guidance, lint workflows, and build resolvers during implementation and validation.
- `tech-plan`: creates backend-only technical implementation plans before coding, including affected modules, API design, error behavior, observability, migrations, database patterns, risks, edge cases, tests, rollout notes, and open questions.
- `typescript-patterns`: applies practical TypeScript type-design patterns for strict-mode-aware code, narrowing, unions, generics, API boundaries, React props, async behavior, generated clients, and maintainable TS/TSX.

Each skill lives in its own directory and should include at least a `SKILL.md` file.

## Notes

Project notes are stored in the `notes/` directory. They are synced from `~/.codex/notes` by the same sync script used for skills.

## Suggested Workflow

For day-to-day usage, the intended flow is:

```text
tech-plan
  -> implement this feature
  -> review-feature
  -> pr-summary
  -> review-pr
  -> review-pr-followup
```

For Go and Rust backend implementation, the `implement this feature` step is handled by `tdd-workflow`, with `coding-standard`, language patterns, and scoped lint workflows applied as needed:

```text
tdd-workflow
  -> coding-standard
     -> go-patterns / rust-patterns
     -> go-lint-workflow / rust-lint-workflow
     -> go-build-resolver / rust-build-resolver
  -> error-handling
```

For Python implementation and review, use `coding-standard` with the Python-focused skills:

```text
coding-standard
  -> python-patterns
  -> effective-python
  -> python-testing
  -> python-lint-workflow
  -> error-handling
```

For React frontend implementation and review, use the React-focused skills:

```text
react-patterns
  -> frontend-design-system
  -> typescript-patterns
  -> accessibility
  -> react-testing
  -> react-performance
  -> frontend-build-resolver
```

Use `solve-conflict-pr` whenever a PR branch cannot be merged cleanly into its target branch.

Use focused skills directly when the task is centered on one layer:

- `go-patterns`, `rust-patterns`, or `python-patterns` for idiomatic design and implementation guidance.
- `effective-python` for deeper Python API, object design, typing, resource lifecycle, and maintainability refinement.
- `python-testing` for Python test strategy, fixtures, mocks/fakes, async tests, RED/GREEN loops, and coverage guidance.
- `python-lint-workflow` for Ruff, Black, mypy, Pyright, import/package issues, pre-commit hooks, tox/nox, and Python CI validation.
- `react-patterns` for React components, hooks, state, forms, accessibility, TypeScript, and frontend composition.
- `frontend-design-system` for reusable UI primitives, tokens, variants, theming, visual states, responsive behavior, and Storybook-style documentation.
- `typescript-patterns` for TypeScript type design, narrowing, API boundaries, React props, generics, async modeling, and safe TS/TSX refactors.
- `accessibility` for semantic HTML, keyboard access, focus management, labels, ARIA, contrast, dynamic UI behavior, and WCAG-aligned review.
- `react-testing` for React Testing Library, Vitest/Jest, MSW, accessibility assertions, and E2E/component-test boundaries.
- `react-performance` for React/Next.js waterfalls, bundles, hydration, rendering, and interaction performance.
- `frontend-build-resolver` when frontend lint, typecheck, test, build, bundler, SSR/hydration, CSS, or dev-server validation fails.
- `go-lint-workflow` or `rust-lint-workflow` for scoped formatting, linting, and validation.
- `go-build-resolver` or `rust-build-resolver` when validation fails and needs a minimal fix.
- `api-contract-review` when client-observable API behavior changes.
- `database-migrations`, `postgres-patterns`, or `mysql-patterns` for schema, query, transaction, and rollout work.
- `error-handling` when failure behavior, retries, timeouts, transactions, or API errors change.
- `observability-check` when a change affects production debugging, logging, metrics, tracing, alerts, workers, external calls, or critical flows.
- `security-review` when authentication, authorization, tenant isolation, user input, rendering, secrets, sessions, webhooks, files, third-party integrations, logging, or sensitive data changes.

## Skill Triggers

Each skill can be invoked explicitly by name, for example:

```text
/tech-plan
/tdd-workflow
/coding-standard
/accessibility
/api-contract-review
/database-migrations
/error-handling
/frontend-build-resolver
/frontend-design-system
/go-patterns
/go-lint-workflow
/go-build-resolver
/mysql-patterns
/observability-check
/postgres-patterns
/python-patterns
/effective-python
/python-testing
/python-lint-workflow
/react-patterns
/react-testing
/react-performance
/typescript-patterns
/rust-patterns
/rust-lint-workflow
/rust-build-resolver
/security-review
/review-feature
/pr-summary
/review-pr
/review-pr-followup
/solve-conflict-pr
```

Codex can also invoke skills implicitly when the user request matches the skill description.

## Sync from Local Codex

Use this script to copy skills from `~/.codex/skills` into this project's `skills/` directory and notes from `~/.codex/notes` into this project's `notes/` directory:

```bash
scripts/sync-from-codex.sh
```

You can also use `make`:

```bash
make sync
```

By default, the script:

- reads from `~/.codex/skills`;
- copies into `./skills`;
- reads notes from `~/.codex/notes`;
- copies notes into `./notes`;
- copies user skills only;
- skips the `.system` directory;
- does not delete extra files in the target directory.

### Dry Run

Preview changes without writing files:

```bash
scripts/sync-from-codex.sh --dry-run
```

Or:

```bash
make dry-run
```

### Sync Specific Skills

```bash
scripts/sync-from-codex.sh review-pr tech-plan
```

Or:

```bash
make sync-skills SKILLS="review-pr tech-plan"
```

### Include System Skills

To also copy `.system` skills:

```bash
scripts/sync-from-codex.sh --include-system
```

### Skip Notes

If you only want to sync skills:

```bash
scripts/sync-from-codex.sh --skip-notes
```

### Sync Notes Only

If you only want to sync notes:

```bash
scripts/sync-from-codex.sh --notes-only
```

Or:

```bash
make sync-notes
```

### Make Targets

```text
make help
make sync
make dry-run
make sync-skills SKILLS="review-pr tech-plan"
make sync-notes
make sync-system
make sync-delete
make validate
```

### Mirror Target with Source

Use `--delete` when the target directories should match the source exactly and files that no longer exist in the source should be removed from the target:

```bash
scripts/sync-from-codex.sh --delete
```

Use this option carefully because it can delete files inside the target skill directory.

## Script Options

```text
Usage: scripts/sync-from-codex.sh [options] [skill ...]

Options:
  --source DIR       Source skills directory (default: ~/.codex/skills)
  --target DIR       Target skills directory (default: ./skills)
  --notes-source DIR Source notes directory (default: ~/.codex/notes)
  --notes-target DIR Target notes directory (default: ./notes)
  --skip-notes       Do not sync notes
  --notes-only       Sync notes without syncing skills
  --include-system   Also copy .system skills
  --delete           Delete target files that no longer exist in source
  -n, --dry-run      Show what would be copied without changing files
  -h, --help         Show help
```

## Development Notes

- Do not edit `.system` unless this project intentionally needs to store system skills.
- Run `scripts/sync-from-codex.sh --dry-run` before large syncs.
- After changing the shell script, validate its syntax with:

```bash
bash -n scripts/sync-from-codex.sh
```
