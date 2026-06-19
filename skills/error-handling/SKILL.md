---
name: error-handling
description: Review and design backend error handling for Go and Rust changes from prompts such as "error-handling", "/error-handling", "review error handling", "check error paths", or when implementing, planning, or reviewing backend features that touch API errors, validation failures, auth failures, database errors, external service failures, timeouts, retries, workers, jobs, transactions, or observable failure behavior. Use with tech-plan, tdd-workflow, review-feature, api-contract-review, observability-check, and pr-summary when error behavior can affect correctness, client contracts, retries, logs, metrics, or production debugging.
---

# Error Handling

## Scope

Use this skill for backend Go and Rust work when error behavior matters:

- API error responses, status codes, gRPC/RPC codes, or generated contracts
- validation, authn/authz, tenancy, not found, conflict, and idempotency errors
- database, transaction, migration, repository, or queue failures
- external service failures, retries, timeout, cancellation, or fallback behavior
- worker, job, scheduler, stream, and background process failures
- production debugging signals such as error logs, metrics, traces, and correlation IDs
- reviewing whether tests cover important failure modes

Do not use this skill for pure formatting, documentation-only, or mechanical refactors that do not change error paths.

## Core Rule

Handle errors as part of the feature contract, not as incidental plumbing.

For every changed behavior, identify:

```text
failure source -> internal error type/context -> user/client-visible result -> retry/log/metric behavior -> test evidence
```

If any link is unclear, document the assumption or create a review finding.

## Error Classification

Classify errors before choosing a fix:

| Class | Examples | Expected Handling |
| --- | --- | --- |
| Validation | malformed input, invalid enum, missing field | stable client error, no retry, no noisy error log |
| Authn/Authz | missing identity, forbidden tenant/resource | stable unauthorized/forbidden result, no internal detail leak |
| Not found | missing entity or relationship | stable not-found result when expected, no panic |
| Conflict | duplicate key, stale version, idempotency conflict | stable conflict result, safe retry semantics if applicable |
| Transient infrastructure | deadlock, lock timeout, network timeout, unavailable dependency | bounded retry only when idempotent, preserve context |
| Permanent infrastructure | bad config, missing table, unsupported feature | fail fast or surface operational error, no blind retry loop |
| Cancellation/timeout | `context.Canceled`, deadline exceeded, request abort | stop work promptly, avoid false success, avoid noisy logs for client cancel |
| Invariant/programmer error | impossible state, corrupt internal data | explicit guard, panic only when truly unrecoverable and consistent with repo conventions |

## Workflow

1. Identify changed error surfaces:
   - handlers, services, repositories, jobs, migrations, external clients, generated contracts, public functions, and tests.
   - Note whether behavior is client-observable, operational-only, or internal.
2. Trace each important error path:
   - Where is the error created?
   - Is context added without losing the original cause?
   - Is it classified correctly at boundaries?
   - Is the client/user response stable and intentional?
   - Is retry behavior safe and bounded?
   - Is the failure observable without leaking secrets or PII?
3. Check language conventions:
   - For Go, follow `go-patterns` and existing repository error conventions.
   - For Rust, follow `rust-patterns` and existing repository error conventions.
4. Check tests:
   - New behavior should include tests for meaningful failure modes, not only happy paths.
   - API changes should include contract or handler tests for error status/body/code.
   - Retry/timeout/cancellation should include focused tests when feasible.
5. Report only concrete issues:
   - A finding needs a real trigger, bad outcome, and suggested fix.
   - Avoid generic "add more error handling" comments unless a specific error is dropped, misclassified, or leaked.

## Go Guidance

Prefer repository conventions first, then these defaults:

- Wrap lower-level errors with context using `%w`:

```go
return fmt.Errorf("load user %s: %w", userID, err)
```

- Preserve cause checks with `errors.Is` and `errors.As`.
- Use sentinel or typed domain errors only when callers need stable classification.
- Keep `context.Context` as the first parameter for request-scoped work.
- Treat `context.Canceled` and `context.DeadlineExceeded` intentionally.
- Do not ignore errors with `_` unless it is best-effort cleanup and that choice is documented or conventional.
- Do not panic for recoverable request, persistence, or dependency failures.
- For database code, map `sql.ErrNoRows`, duplicate-key, deadlock, lock-timeout, and transaction errors deliberately.
- For external calls, require timeout/cancellation, bounded retries, and idempotency awareness.

Go review checks:

- Does wrapping preserve the original error for `errors.Is/As`?
- Does the boundary mapper convert domain errors to the right API code/status?
- Are validation failures separate from internal failures?
- Are retryable errors retried only when the operation is idempotent?
- Are logs contextual but free of tokens, credentials, and sensitive payloads?

## Rust Guidance

Prefer repository conventions first, then these defaults:

- Use `Result` and `?` for recoverable failures.
- Avoid `unwrap()`, `expect()`, `panic!()`, `todo!()`, and `unreachable!()` in production error paths unless the invariant is defensible and documented.
- For libraries, prefer typed errors, commonly with `thiserror` when already used.
- For applications, add context with the project's error stack, commonly `anyhow::Context` when already used.
- Keep error enums meaningful and avoid collapsing all failures into strings when callers need classification.
- Preserve source errors where useful for diagnostics.
- Model business states with enums instead of ambiguous booleans or stringly typed states.
- In async code, avoid blocking operations in failure handling and respect cancellation.
- For `JoinError`, channel close, mutex poisoning, and timeout errors, classify whether the outcome is retryable or terminal.

Rust review checks:

- Is the error variant specific enough for the caller boundary?
- Does `?` preserve useful source/context?
- Are internal details hidden from client-facing responses?
- Are `unwrap`/`expect` limited to tests, setup, or true invariants?
- Are retry and timeout paths tested without flaky sleeps?

## API Boundary Checks

When client-observable API behavior changes, coordinate with `api-contract-review`.

Check:

- status code or RPC code is stable and documented by tests
- response body has stable machine-readable error code when clients need it
- validation errors are deterministic and do not expose internals
- auth/tenant errors do not reveal whether a forbidden resource exists unless intended
- idempotency and conflict errors are distinguishable
- backward compatibility is classified if the error body/status changes

## Retry, Timeout, and Fallback Checks

Retries are allowed only when they are safe:

- operation is idempotent or protected by idempotency key / transaction semantics
- retry budget is bounded
- backoff/jitter follows repository or platform convention
- timeout/deadline is respected across downstream calls
- cancellation stops work promptly
- final failure is surfaced clearly
- metrics/logs distinguish retry attempts from final failure

Do not add retry loops to non-idempotent writes, payment-like flows, ledger mutations, migrations, or queue acknowledgements without explicit design support.

## Observability and Privacy

Coordinate with `observability-check` for operationally important failures.

Good failure signals include:

- stable operation name and error class
- request/job/correlation ID when available
- relevant resource identifiers when safe
- retry count or final failure marker
- latency/timeout information when useful

Avoid:

- logging access tokens, passwords, secrets, raw authorization headers, private keys
- logging full request/response bodies when they may contain PII
- high-cardinality metric labels such as raw error strings, user IDs, order IDs, addresses, or transaction hashes unless the existing metrics design allows it
- swallowing errors after logging them if callers still need to know the operation failed

## Testing Expectations

For changed error behavior, tests should cover the meaningful guarantees:

- invalid input returns the expected validation error
- not-found, conflict, auth, or tenant failures map to expected client results
- downstream/database errors do not become false success
- retryable and non-retryable failures are distinguished
- context cancellation or timeout does not continue work incorrectly
- error response shape remains compatible when API clients depend on it

Use `tdd-workflow` when implementing fixes: write the failing error-path test first, prove RED, implement the smallest fix, prove GREEN, then refactor.

## Output Expectations

When used for planning, include:

- error classes introduced or changed
- boundary mapping/API status and response body expectations
- retry, timeout, and cancellation behavior
- observability and privacy notes
- tests that prove failure behavior

When used for review, include findings only when there is a concrete failure mode:

```text
Error Handling Finding
- <Severity> [file:line] <short issue>
  Trigger: <input/state/downstream failure>
  Bad outcome: <what happens today>
  Expected handling: <classification, response, retry, or logging behavior>
  Suggested fix: <specific change or test>
```

When used for PR summaries, include only factual notes such as changed error models, status codes, retry behavior, timeout handling, and tests run. Do not claim validation that was not executed.
