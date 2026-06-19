---
name: review-feature
description: Review local feature work before a pull request exists from prompts such as "review-feature", "/review-feature", "review my feature", "review local changes", or "review and resolve findings". Use when Codex should inspect the current git branch/worktree diff, compare it with a base branch or commit, read relevant files and tests, apply coding-standard plus go-patterns for Go code, rust-patterns for Rust code, go-lint-workflow or rust-lint-workflow for changed Go/Rust files, error-handling for changed validation/API/database/external-service/timeout/retry/cancellation failure behavior, api-contract-review for client-observable API behavior changes, observability-check for operationally important endpoints/workers/external calls/migrations/critical flows/retries/concurrency, database-migrations for schema/data migration or zero-downtime rollout changes, mysql-patterns for MySQL/MariaDB schema/query/transaction/pool changes, and postgres-patterns for PostgreSQL/Supabase schema/query/transaction/RLS/pool changes, produce a review in the same findings-first format as review-pr, and optionally resolve discovered findings in the local code when the user explicitly asks to fix/resolve them.
---

# Review Feature

## Input Handling

Accept loose, team-style prompts. Treat any of these as valid triggers:

```text
review-feature
/review-feature
review my feature before PR
review local changes against main
review and resolve findings
context: group member list projection
JIRA: https://...
```

Use the current repository when no repository is specified. Preserve user-provided `JIRA`, `context`, release notes, acceptance criteria, or reviewer notes as review context, not as proof that the implementation is correct.

Determine review scope from the prompt:

- If the user provides a base branch, commit, or range, compare against that exact base.
- Otherwise infer the default base from the repository, preferring upstream/default branch metadata when available, then common bases such as `main`, `master`, or `develop`.
- Include staged, unstaged, and untracked files when they are part of the feature.
- If the scope is ambiguous or the worktree has unrelated changes that would materially affect the review, state the assumption or ask a focused question.

## Review Workflow

1. Identify repository, current branch, base branch/commit, and changed files.
2. Inspect git status, branch metadata, commit history, and diff or patches for the feature scope.
3. Read relevant base and working-tree files when the diff alone is insufficient to understand behavior.
4. Inspect existing tests and coverage around the changed behavior.
5. Apply `coding-standard` expectations for changed Go and Rust files: readability, KISS, DRY, YAGNI, naming, formatting, structure, idiomatic error handling, visibility, linting, and type-checking.
   - For Go changes, use `go-patterns` to review error handling, context propagation, interface boundaries, package ownership, dependency injection, concurrency lifecycle, testing patterns, and performance tradeoffs.
   - For Go changes, use `go-lint-workflow` to distinguish new lint issues from existing baseline debt and to handle `*_test.go`, `gocyclo`, and `funlen` pragmatically.
   - For Rust changes, use `rust-patterns` to review ownership, borrowing, error handling, state modeling, trait/API boundaries, visibility, async/concurrency lifecycle, unsafe boundaries, testing patterns, and performance tradeoffs.
   - For Rust changes, use `rust-lint-workflow` to distinguish new Clippy/check issues from existing workspace debt and to handle unit/integration tests, complexity, public API, and `#[allow(...)]` pragmatically.
   - For validation failures, API errors, database errors, external service failures, timeouts, retries, cancellation, workers, jobs, or observable failure behavior, use `error-handling` to review classification, propagation, boundary mapping, retry safety, logging privacy, and error-path test coverage.
   - For client-observable API request, response, error, auth, pagination, idempotency, or generated contract changes, use `api-contract-review` to review backward compatibility and contract-test coverage.
   - For operationally important endpoints, workers, jobs, external calls, migrations/backfills, critical flows, retries, or concurrency, use `observability-check` to review production debuggability, logs, metrics, tracing/telemetry, and PII/secret safety.
   - For schema changes, data migrations, backfills, or zero-downtime rollout, use `database-migrations` to review migration immutability, lock risk, expand-contract compatibility, rollback/forward-fix strategy, and validation.
   - For MySQL/MariaDB changes, use `mysql-patterns` to review migration safety, schema defaults, indexes, query plans, transactions, locking, replica consistency, connection pools, and least-privilege security.
   - For PostgreSQL/Supabase changes, use `postgres-patterns` to review migration safety, schema defaults, indexes, query plans, transactions, locking, RLS policies, replica consistency, connection pools, and least-privilege security.
6. Prioritize risks in this order: correctness bugs, regressions, data loss, security/privacy issues, concurrency/race issues, API contract breaks, migration/backward compatibility issues, missing tests for risky behavior, then maintainability and coding-standard drift.
7. Run focused local validation when feasible and useful. If tests are not run, state that clearly.
8. Do not push commits, create PRs, post comments, merge, or label anything unless the user explicitly asks.

## Resolve Mode

Default to review-only. Modify local files only when the user explicitly asks to resolve or fix findings, for example:

```text
review-feature and resolve findings
review and fix issues
find and resolve before PR
```

When resolve mode is active:

1. Perform the review first and identify concrete findings.
2. Implement fixes for confirmed findings only; avoid unrelated refactors.
3. Preserve user changes and do not revert unrelated work.
4. Add or update focused tests when the fix changes behavior or protects a risky edge case.
5. Run focused validation after the fix.
6. Re-review the final diff and report which findings were resolved.

If a finding requires product clarification, external credentials, migration coordination, or a broad design decision, do not invent the answer. Mark it as unresolved and explain the blocker.

## Output Format

Use code-review stance. Lead with findings, ordered by severity. Avoid long summaries before issues.

For every finding at every severity level (`Critical`, `High`, `Medium`, and `Low`), include:

- severity: `Critical`, `High`, `Medium`, or `Low`
- file and line reference when available
- concise description of the bug or risk
- explanation in Bahasa Indonesia that describes the finding in reviewer-friendly terms
- impact in Bahasa Indonesia that states what can happen if the issue ships
- suggested PR comment text in English, ready to paste into a future PR
- why it matters in the feature context
- suggested fix or validation path
- resolution status when resolve mode is active

Keep the finding title concise, but make the explanation and impact clear enough for the author to understand the concrete failure mode. Do not only summarize in English. If the technical evidence is gathered in English, translate the reviewer-facing explanation and impact into natural Bahasa Indonesia.

The suggested PR comment must be written in English as a polite, actionable review comment addressed to the future PR author. Do not actually post the comment to GitHub unless the user explicitly asks.

If no issues are found, say that clearly and mention residual risk or test gaps.

Use this structure:

```text
Feature Review - <branch or scope>

Findings
- <Severity> [file:line] <short issue title>
  Explanation: <Bahasa Indonesia explanation>
  Impact: <Bahasa Indonesia impact if this ships>
  Suggested PR comment: <English comment ready to paste>
  Suggested fix: <fix or validation path>
  Resolution: <Resolved / Not resolved / Not applicable, when resolve mode is active>

Open Questions
- <question or assumption>

Tests
- <what was run or not run>

Summary
<brief change summary, secondary to findings>

Resolved Changes
<only include in resolve mode; summarize files changed and validations run>
```

## Review Standards

Be specific and evidence-based. Do not report speculative issues unless there is a concrete failure mode. Prefer one strong finding over many weak comments.

Treat user context such as `context: group member list projection` as the intended behavior lens: check whether the implementation matches that intent, whether edge cases are handled, and whether tests prove the intended behavior.

When a feature touches generated files, lockfiles, migrations, schemas, or cross-repository contracts, call that out explicitly because these often require separate validation.

For API contract changes, include `api-contract-review` findings when they represent concrete client breakage, backward compatibility, error model, validation, auth/tenancy, pagination/filter/sort, idempotency, generated contract, or missing contract-test risk.

For error behavior changes, include `error-handling` findings when they represent concrete swallowed errors, false success, wrong client status/code, leaked internal detail, unsafe retry behavior, missing timeout/cancellation handling, missing error context, noisy or unsafe logs, or missing tests for important failure paths.

For observability changes or operationally important behavior, include `observability-check` findings when they represent concrete production debugging, missing failure/progress signal, metric cardinality, dashboard/alert compatibility, noisy logging, or PII/secret leakage risk.

For migration changes, include `database-migrations` findings when they represent concrete lock, data loss, backward compatibility, rollout, rollback, backfill, dirty-state, or migration drift risk.

For MySQL/MariaDB changes, include `mysql-patterns` findings when they represent concrete migration, locking, deadlock, query performance, data integrity, replica consistency, connection pool, or security risk. State engine/version assumptions when relevant.

For PostgreSQL/Supabase changes, include `postgres-patterns` findings when they represent concrete migration, locking, deadlock, query performance, data integrity, RLS/security, replica consistency, connection pool, or extension/version risk. State version, extension, and Supabase assumptions when relevant.

When reviewing local changes, pay extra attention to artifacts that would normally be caught during PR review: forgotten debug code, untracked files, missing generated updates, stale snapshots, accidental environment changes, and incomplete test updates.

For Go and Rust changes, include coding-standard and lint-workflow findings when they are meaningful for maintainability or reviewer confidence. Avoid reporting pure formatting nits if `gofmt`, `go fmt`, `cargo fmt`, or an equivalent formatter can handle them.

For Go changes, include `go-patterns` findings when they represent concrete maintainability, correctness, API ownership, context propagation, concurrency, or testability risk. Do not report pattern preferences as findings if the repository's existing convention clearly chooses another reasonable style.

For Rust changes, include `rust-patterns` findings when they represent concrete maintainability, correctness, API ownership, ownership/borrowing, state modeling, async/concurrency, unsafe, or testability risk. Do not report pattern preferences as findings if the repository's existing convention clearly chooses another reasonable style.

For lint-related review findings:

- report new lint issues introduced by the feature
- do not block on unrelated existing lint debt from the base branch
- do not require broad refactors of already-complex functions/modules unless the feature worsens them or correctness is at risk
- for test files, apply the relevant test-code rules from `go-lint-workflow` or `rust-lint-workflow`
