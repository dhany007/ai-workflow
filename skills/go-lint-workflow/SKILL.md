---
name: go-lint-workflow
description: Run and interpret Go linting pragmatically for backend feature work from prompts such as "go-lint-workflow", "/go-lint-workflow", "golangci-lint this change", "lint Go changes", "handle gocyclo/funlen/mnd/lll", "fix magic number", "fix long line", or when Codex is implementing, reviewing, or refactoring Go code. Use when Codex should apply scoped golangci-lint/go vet/go fmt checks, distinguish new lint issues from existing baseline debt, handle touched complex functions, magic numbers, and line-length problems without broad refactors, apply test-file-specific lint judgment, and report lint results without treating unrelated legacy issues as blockers.
---

# Go Lint Workflow

## Principle

Lint changed behavior strictly. Handle existing debt pragmatically.

Do not make a feature PR responsible for all existing lint debt in a package or function. Do not use lint as a reason to rewrite broad existing code unless the user explicitly asks for a cleanup/refactor task.

If lint or validation fails because the Go code does not compile, imports are broken, tests fail, or module state blocks validation, use `go-build-resolver` first. Return to this lint workflow after the build failure is resolved.

## Scope

Use this skill for Go backend code:

- production `.go` files
- `*_test.go` unit and integration tests
- API handlers, services, repositories, workers, jobs, migrations, and generated-code boundaries
- feature implementation, bug fixes, refactors, and pre-PR reviews

## Preferred Commands

Prefer scoped or baseline-aware lint:

```bash
go fmt ./path/to/changed/package
go vet ./path/to/changed/package
go test ./path/to/changed/package
golangci-lint run ./path/to/changed/package
golangci-lint run --new-from-rev=origin/main
```

Use full-repo lint only for CI, dedicated cleanup, or explicit user request:

```bash
go fmt ./...
go vet ./...
go test ./...
golangci-lint run ./...
```

If the repository already defines `make lint`, `make test`, `task lint`, or CI-specific commands, prefer those after checking what they run.

## Recommended golangci-lint Baseline

Start with high-signal linters. Avoid `enable-all` by default.

Recommended baseline:

```yaml
linters:
  disable-all: true
  enable:
    - govet
    - staticcheck
    - errcheck
    - ineffassign
    - unused
    - gosimple
    - gofmt
    - goimports
    - misspell
    - revive
    - errorlint
    - nilerr
    - bodyclose
    - rowserrcheck
    - sqlclosecheck
    - gosec
    - gocritic
    - unconvert
    - wastedassign
    - prealloc
    - nolintlint
    - mnd
    - lll
```

Treat style, readability, and complexity linters as guardrails, not as permission for broad incidental refactors.

## Baseline-Aware Decision Rules

For every lint finding, classify it:

- `New issue from this change`: fix in the current task.
- `Existing debt on latest base`: do not block the feature unless it affects correctness or the touched behavior.
- `Introduced by another merged change`: do not assign to this task unless your change relies on or worsens it.
- `Blocking current implementation`: fix the smallest safe surface or ask for scope approval.
- `Requires broad refactor`: document as follow-up unless the user asked for refactor.

When possible, compare against latest base:

```bash
git fetch origin
golangci-lint run --new-from-rev=origin/main
```

Use the repository's actual base branch if not `main`.

## Complexity and Long Functions

For `gocyclo`, `gocognit`, `funlen`, or similar findings:

- Do not rewrite an existing large function just because the feature touches it.
- Do not add more branches to an already complex function if a small helper can isolate new behavior.
- If your change causes the threshold breach, fix it in the current task.
- If the breach existed before, avoid making it worse and document it as existing debt when relevant.
- Prefer extracting new logic into a small helper with focused tests.
- Split broad refactors into a separate PR when they are not required for the feature.

Use `//nolint` only as a last resort. It must be narrow, linter-specific, and include a reason:

```go
//nolint:gocyclo // Existing parser branches predate this change; new validation is isolated and tested.
func parseLegacyPayload(...) error {
    ...
}
```

## Magic Numbers and Line Length

For `mnd`, `lll`, or similar readability findings, prefer readable code over mechanical appeasement.

### `mnd`

Treat magic-number findings as a request to explain intent:

- Replace repeated or domain-significant numbers with named constants.
- Prefer units in names, such as `requestTimeoutSeconds`, `maxRetryAttempts`, or `defaultPageSize`.
- Keep obvious sentinel or arithmetic values inline when naming them would add noise.
- Prefer standard library constants and domain constants over duplicated literals.
- Avoid extracting a constant only to satisfy lint when the name repeats the value without explaining meaning.

Allow more flexibility for:

- test table values that are clearer inline
- common HTTP status codes when `http.Status...` is not available or would obscure the case
- small arithmetic values such as `0`, `1`, `2`, and simple slice/index operations
- examples, fixtures, and generated-code boundaries

Use scoped suppression only with a concrete reason:

```go
//nolint:mnd // Protocol version is fixed by the external payment provider.
const paymentProtocolVersion = 3
```

### `lll`

Treat long lines as a real readability issue. Code that requires horizontal scrolling should usually be refactored.

Prefer these fixes:

- Break function calls across arguments with one meaningful argument per line.
- Split long table-driven test cases into named fields or helper builders.
- Move repeated setup into small helpers when it reduces visual width.
- Use raw strings or adjacent string fragments only when the resulting text remains easier to read.
- Split long SQL, GraphQL, JSON, or expected payloads into fixtures or named constants when that improves reviewability.
- Break chained builders at semantic boundaries.

Avoid these fixes:

- hiding long lines by using vague helper names
- making logs or error messages harder to search
- splitting URLs, regexes, or generated values in a way that changes meaning
- adding `//nolint:lll` because wrapping feels mildly inconvenient

Use scoped suppression for unavoidable machine-readable literals, generated-like expectations, or protocol strings:

```go
//nolint:lll // Golden test vector must stay byte-for-byte identical to the provider fixture.
const signedWebhookFixture = "..."
```

If a repository configures `lll`, prefer its threshold. When adding or tuning config, start from the golangci-lint default line length unless the repo has an existing width convention.

## Test Code Rules

Lint `*_test.go` files too, but judge them differently from production code.

Keep strict:

- test determinism
- clear assertions
- cleanup of files, database rows, goroutines, servers, and mocks
- no hidden ordering dependency between tests
- no ignored errors that can hide failed setup
- no flaky sleeps when better synchronization exists

Allow more flexibility when it improves readability:

- table-driven test size
- repeated literals that make cases clear
- inline numeric case values when extraction would hide the scenario being tested
- duplicated setup across a small number of tests
- longer test functions for comprehensive scenario setup
- longer fixture or golden-output lines when preserving exact data is more important than wrapping
- helper functions that use `t.Helper()`

Do not disable lint globally for tests. Use scoped `//nolint` with a reason when necessary:

```go
//nolint:funlen // Table-driven regression test documents all legacy status transitions.
func TestLegacyStatusTransitions(t *testing.T) {
    ...
}
```

## Review Guidance

When reviewing Go diffs:

- report new lint issues caused by the PR as findings
- mention existing debt only when it affects the changed behavior or review risk
- do not require broad cleanup of unrelated legacy lint failures
- suggest scoped commands and base-aware lint results
- include whether production code or test code rules apply

## Output Notes

When reporting lint results, include:

```text
Go lint
- Scope: <changed package / new-from-rev / full repo>
- Commands: <commands run>
- Result: <pass/fail/skipped>
- Findings: <new issues vs existing debt>
- Notes: <nolint reasons, follow-up debt, or skipped validation>
```

Do not invent lint results. If lint was not run, say why.
