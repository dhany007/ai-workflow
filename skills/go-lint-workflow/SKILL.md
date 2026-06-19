---
name: go-lint-workflow
description: Run and interpret Go linting pragmatically for backend feature work from prompts such as "go-lint-workflow", "/go-lint-workflow", "golangci-lint this change", "lint Go changes", "handle gocyclo/funlen", or when Codex is implementing, reviewing, or refactoring Go code. Use when Codex should apply scoped golangci-lint/go vet/go fmt checks, distinguish new lint issues from existing baseline debt, handle touched complex functions without broad refactors, apply test-file-specific lint judgment, and report lint results without treating unrelated legacy issues as blockers.
---

# Go Lint Workflow

## Principle

Lint changed behavior strictly. Handle existing debt pragmatically.

Do not make a feature PR responsible for all existing lint debt in a package or function. Do not use lint as a reason to rewrite broad existing code unless the user explicitly asks for a cleanup/refactor task.

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
```

Treat style and complexity linters as guardrails, not as permission for broad incidental refactors.

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
- duplicated setup across a small number of tests
- longer test functions for comprehensive scenario setup
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
