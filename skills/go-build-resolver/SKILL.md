---
name: go-build-resolver
description: Resolve Go build, vet, test, module, and lint failures from prompts such as "go-build-resolver", "/go-build-resolver", "fix Go build", "go build failed", "go test failed", "go vet failed", "fix golangci-lint", "fix staticcheck", "resolve Go compile error", or when Go validation fails during backend implementation. Use when Codex should diagnose errors, read affected Go files, apply minimal scoped fixes, rerun focused validation, and report remaining failures without broad refactors or unrelated cleanup.
---

# Go Build Resolver

## Principle

Fix the build with the smallest correct change. This skill is for compilation, test, vet, module, and lint failures, not broad code review or refactoring.

Use `go-patterns` for idiomatic Go decisions, `go-lint-workflow` for scoped lint handling, and `coding-standard` for general maintainability.

## Safety Rules

Default to package-scoped diagnostics before full-repo commands.

Do not run network-dependent dependency commands such as `go get`, `go mod download`, or broad cache repair commands such as `go clean -modcache` unless the failure requires it and the user approves.

Do not run `go mod tidy` unless dependency/import changes make it necessary. If it changes `go.mod` or `go.sum`, explain why.

Do not add `//nolint`, change public function signatures, rewrite package boundaries, or introduce new abstractions unless the error cannot be fixed surgically.

Do not fix unrelated existing lint debt. Use `go-lint-workflow` to distinguish new failures from baseline issues.

## Activation

Use this skill when:

- `go build`, `go test`, `go vet`, `staticcheck`, or `golangci-lint` fails
- Go compilation errors block implementation
- interface/type mismatches appear after a change
- module or import errors block validation
- a TDD GREEN/refactor step fails because Go validation no longer passes

Do not use this skill for ordinary review. Use `review-feature` or `review-pr` for review-only tasks.

## Workflow

1. Identify scope:
   - Read the failing command and error output if provided.
   - Inspect changed Go files with git diff when available.
   - Determine the smallest package or command that reproduces the failure.
2. Reproduce with the narrowest useful command:
   - Prefer `go test ./path/to/package`, `go vet ./path/to/package`, or `go test ./path/to/package -run TestName`.
   - Use `go build ./...` or `go test ./...` only when package scope is unclear, CI requires it, or the user asks.
3. Read affected files:
   - Read the exact error line plus surrounding code.
   - Check imports, interfaces, call sites, and tests before editing.
4. Apply a minimal fix:
   - Fix the root cause, not just the symptom.
   - Avoid unrelated formatting, lint cleanup, or refactors.
5. Validate:
   - Rerun the same failing command.
   - If it passes, run the next relevant focused command, such as package tests or vet.
   - Stop if the same error persists after three focused attempts or the fix requires architecture changes.

## Command Selection

Start narrow:

```bash
go test ./path/to/package
go vet ./path/to/package
go test ./path/to/package -run TestName
```

Use lint tools only when present and relevant:

```bash
staticcheck ./path/to/package
golangci-lint run ./path/to/package
```

Use full commands only for CI parity, unclear scope, or explicit request:

```bash
go build ./...
go test ./...
go vet ./...
```

Dependency/module commands need caution:

```bash
go mod verify
go mod tidy -v
go mod why -m <module>
go get <module>@<version>
```

Run mutating or network-dependent module commands only when necessary and explain the expected file changes.

## Common Fix Patterns

| Error | Likely Cause | Preferred Fix |
| --- | --- | --- |
| `undefined: X` | typo, missing import, unexported symbol, wrong package | fix name/import/package reference |
| `cannot use X as Y` | pointer/value mismatch, interface mismatch, conversion needed | adapt call site or conversion locally |
| `X does not implement Y` | method missing or wrong receiver/signature | fix receiver/signature if intended by local change |
| `import cycle not allowed` | package boundary problem | stop if it needs architecture change; otherwise move only local helper use |
| `declared but not used` | dead variable/import after edit | remove or use intentionally |
| `multiple-value in single-value context` | ignored return value | handle both value and error |
| `cannot assign to struct field in map` | map value copy semantics | copy-modify-reassign or use pointer map if already intended |
| `missing return` | incomplete branch | add explicit return consistent with existing error model |
| `go vet printf` | format string/argument mismatch | correct format verb or argument |
| module checksum/import error | dependency state issue | inspect `go.mod`/`go.sum`; avoid broad updates without approval |

## Dependency Rules

- Prefer fixing imports and local code before changing dependencies.
- Pin or add dependencies only when the compile error proves the project already depends on that package conceptually.
- Avoid major version upgrades during build resolution.
- Do not run full `go get -u` or broad dependency upgrades for a build fix.
- Preserve existing `replace` directives and workspace conventions.

## Stop Conditions

Stop and report when:

- the same error remains after three focused fix attempts
- the fix requires package architecture changes or import-cycle redesign
- dependency repair requires network access or broad version updates
- resolving one error creates a larger set of unrelated errors
- dirty user changes overlap with files that must be edited

## Output Format

Use this format while resolving:

```text
[FIXED] internal/handler/user.go:42
Error: undefined: UserService
Fix: Added the existing service package import used by nearby handlers.
Validation: go test ./internal/handler passed
Remaining errors: 1
```

Final response:

```text
Build Status: SUCCESS/FAILED
Errors Fixed: <count>
Files Modified:
- <file>: <short fix>
Validation:
- <command>: <result>
Remaining:
- <unresolved blocker or "None">
```
