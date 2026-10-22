---
name: coding-standard
description: Apply shared, repository-aware coding standards for Go, Rust, and Python when a task needs cross-cutting maintainability guidance, contributor conventions, or toolchain setup. Use the language-specific pattern, testing, lint, and build skills for focused work; this skill does not cover Java or frontend code.
---

# Coding Standard

## Built-in Ponytail Principles

Apply these principles whenever this skill is used, without requiring a separate Ponytail invocation or installed plugin. They apply within this skill's existing language and task scope.

- Read the affected flow and callers before choosing a solution; include required updates to callers, tests, fixtures, configuration, and exports.
- Prefer, in order: existing repository code and conventions, the standard library or platform features, an already installed dependency, then the smallest readable new implementation that fully meets the request.
- Omit unrequested features and speculative abstractions, wrappers, options, and dependencies. Preserve established boundaries and interfaces; fewer lines alone do not justify a rewrite or dependency change.
- Preserve requested behavior, trust-boundary validation, protection against data loss, error handling, security, and accessibility wherever applicable. Reuse is appropriate only when it meets these requirements.
- Validate changed behavior with focused checks using the relevant language/testing skill. State material limitations or checks not run without inventing evidence or adding a mandatory report for trivial changes.

These are embedded implementation principles, not a request to activate Ponytail session modes, hooks, extra commands, or external actions.

## References

Use these as primary language references:

- Go: Effective Go, https://go.dev/doc/effective_go
- Rust: Effective Rust, https://effective-rust.com/title-page.html
- Python: PEP 8, https://peps.python.org/pep-0008/
- Python documentation: typing, dataclasses, packaging, logging, asyncio, and standard-library guidance
- Python testing: pytest documentation when the repository uses pytest
- Effective Python as a practical idiom reference, combined with current Python docs and the repository's supported Python version

Treat Effective Go as guidance for core Go idioms, naming, formatting, and program construction. Remember that it predates newer Go features such as modules and generics, so combine it with repository conventions and current Go tooling.

Treat Effective Rust as guidance for idiomatic Rust across types, traits, error handling, ownership, dependencies, tooling, testing, Clippy, and CI.

Treat Python references as guidance for clarity, explicit boundaries, packaging, typing, testing, and maintainability. Python style varies by project and toolchain, so prefer the repository's `pyproject.toml`, formatter, linter, type checker, test framework, and supported Python version.

## Core Principles

Apply these principles before language-specific preferences:

1. Readability First
   - Code is read more than written.
   - Prefer clear variable, type, function, module, package, and crate names.
   - Prefer self-documenting code over comments that restate code.
   - Keep formatting consistent and automated.

2. KISS
   - Choose the simplest solution that works.
   - Avoid over-engineering and premature optimization.
   - Prefer understandable code over clever code.

3. DRY
   - Extract common logic when duplication becomes meaningful.
   - Share utilities across modules only when they represent real shared behavior.
   - Avoid copy-paste programming, but do not create abstractions for accidental similarity.

4. YAGNI
   - Do not build features before they are needed.
   - Avoid speculative generality.
   - Add complexity only when required by current behavior.
   - Start simple and refactor when the need is proven.

## Workflow

1. Identify the language, repository conventions, project maturity, and current task:
   - implementing a Go, Rust, or Python feature
   - starting a new project, package, crate, module, or service
   - reviewing code quality and maintainability
   - refactoring existing code
   - enforcing naming, formatting, typing, linting, or structure
   - setting up linting, formatting, type-checking, tests, or CI
   - onboarding contributors to conventions
2. Inspect existing style before proposing changes. Prefer the repo's established patterns unless they conflict with correctness, maintainability, or language idiom.
3. Apply the core principles first, then language-specific guidance.
4. Keep changes scoped. Avoid broad rewrites when a focused cleanup is enough.
5. Run or suggest the relevant formatter, linter, type checker, build/check command, and tests.
6. Report tradeoffs when a standard is subjective or when local conventions differ from external guidance.

## During Feature Implementation

Use this skill for shared standards, contributor onboarding, toolchain setup, or cross-cutting maintainability decisions. Do not load it solely because a Go, Rust, or Python file changed; use the focused language and validation skills for that work and apply these principles as relevant.

- When the user asks to implement a feature from a `tech-plan`, read the relevant plan and use this skill only for standards decisions that cross language-specific guidance.
- Treat a `tech-plan` file's `Implementation Handoff` section as task context, not as a reason to broaden scope.
- When `tdd-workflow` is active, apply coding standards during GREEN/refactor without skipping RED/GREEN validation.
- Start from the smallest design that satisfies the requested behavior.
- Follow the surrounding package/module/crate structure before introducing a new abstraction.
- Name new types, functions, traits, modules, packages, and crates for their current responsibility, not future possibilities.
- Prefer clear control flow and explicit error handling over clever compression.
- Add tests that prove the new behavior and important edge cases.
- Run focused format, lint, type-check, build/check, and test commands before finishing when feasible.
- Mention standard-related tradeoffs in the final response only when they materially affected the implementation.

For changed validation failures, API errors, database errors, external service failures, timeouts, retries, cancellation, workers, jobs, or observable failure behavior, use `error-handling` for classification, propagation, boundary mapping, retry safety, logging privacy, and error-path tests.

## Go Standards

Use idiomatic Go:

- Apply `go-patterns` when designing or reviewing Go backend behavior.
- Format with `gofmt` or `go fmt`.
- Use `go vet` where applicable.
- Prefer simple package names: short, lowercase, no underscores.
- Use `MixedCaps` or `mixedCaps`, not snake_case.
- Let package names reduce repetition in exported names, for example `bufio.Reader` rather than `bufio.BufReader`.
- Do not use `Get` in simple getter names unless the domain convention requires it.
- Use small interfaces at the consumer boundary when practical.
- Keep error handling explicit and close to the failing operation.
- Prefer early returns over deeply nested control flow.
- Keep goroutine/channel usage simple and justified by actual concurrency needs.
- Avoid clever abstractions around generics; use them when they remove real duplication without hiding behavior.

For Go linting, use `go-lint-workflow`: prefer scoped or baseline-aware lint, do not assign unrelated legacy lint debt to the current feature, and handle `gocyclo`/`funlen` pragmatically.

For Go build, test, vet, module, or lint failures during implementation, use `go-build-resolver` to make minimal scoped fixes before broad cleanup.

For Go validation, prefer:

```bash
go fmt ./path/to/changed/package
go vet ./path/to/changed/package
go test ./path/to/changed/package
golangci-lint run ./path/to/changed/package
```

Use `golangci-lint run --new-from-rev=<base-ref>` when reviewing PR/new branch changes. Use full repo commands only for CI, dedicated cleanup, or explicit user request. See `go-lint-workflow` for baseline-aware lint decisions, test-file rules, and `//nolint` standards.

## Rust Standards

Use idiomatic Rust:

- Apply `rust-patterns` when designing or reviewing Rust backend behavior.
- Format with `cargo fmt`.
- Use `cargo clippy` and address meaningful warnings.
- Use `cargo check` for fast type-checking and `cargo test` for validation.
- Express invalid states through types where practical.
- Prefer `Option` and `Result` transforms when they are clearer than verbose `match` blocks.
- Use idiomatic error types and avoid panics in library or recoverable paths.
- Minimize visibility; make items `pub` only when part of the intended API.
- Avoid wildcard imports in production code.
- Prefer iterator transforms when they improve clarity; use explicit loops when they are easier to read.
- Avoid unsafe code unless it is necessary, isolated, documented, and tested.
- Use builders for complex construction only when they reduce call-site confusion.
- Manage dependency and feature creep deliberately.

For Rust linting, use `rust-lint-workflow`: prefer package-scoped `cargo check/test/clippy`, avoid broad API/visibility refactors for existing Clippy debt, and handle test code with readability-aware judgment.

For Rust cargo check, test, clippy, dependency, lifetime, or borrow-checker failures during implementation, use `rust-build-resolver` to make minimal scoped fixes before broad cleanup.

For Rust validation, prefer:

```bash
cargo fmt -p <package>
cargo clippy -p <package> --all-targets
cargo check -p <package>
cargo test -p <package>
```

Use full workspace/all-features commands only for CI, dedicated cleanup, or explicit user request. See `rust-lint-workflow` for scoped Clippy decisions, test-code rules, and `#[allow(...)]` standards.

## Python Standards

Use idiomatic Python:

- Apply `python-patterns` when designing, implementing, or reviewing Python behavior.
- Apply `effective-python` when refining Python API shape, iteration, data modeling, object design, resource lifecycle, typing, or maintainability beyond basic style.
- Apply `python-testing` when adding or reviewing Python tests, fixtures, mocks/fakes, async tests, coverage, or regression coverage.
- Follow the supported Python version before using newer syntax such as `X | None`, `typing.Self`, `StrEnum`, `TaskGroup`, or `ExceptionGroup`.
- Follow the repository's formatter and linter before introducing Black, Ruff, isort, pylint, mypy, Pyright, pytest, or plugins.
- Prefer clear function signatures, explicit boundary validation, and named data structures over loose dictionaries in core logic.
- Prefer `pathlib.Path`, context managers, explicit encodings for text IO, and dependency injection for clients, repositories, clocks, and configuration when useful.
- Keep imports explicit and avoid import-time side effects.
- Keep async code cancellation-aware and avoid blocking the event loop.
- Keep type hints meaningful at public boundaries and avoid broad `Any`, `cast`, `# type: ignore`, or lint disables without a narrow reason.

For Python validation, inspect repo config first. Prefer the configured command, but common focused commands include:

```bash
python -m pytest tests/path/test_file.py::test_name
python -m ruff check path/to/changed
python -m ruff format path/to/changed
python -m black path/to/changed
python -m mypy path/to/changed
pyright path/to/changed
```

Use only commands backed by the repository's tooling or user approval. Use full-suite commands only for CI, dedicated cleanup, or explicit user request.

## Review Output

When reviewing or refactoring, report issues in priority order:

1. correctness or safety issues
2. maintainability and readability issues
3. duplicated or speculative abstractions
4. naming, formatting, typing, linting, and structural consistency
5. missing validation, tests, or coverage of changed behavior

For each meaningful issue, include:

- file and line reference when available
- principle violated
- language-specific convention involved
- suggested fix
- validation command to run

Avoid nitpicks that an autoformatter will handle unless the formatter is missing from the workflow.

## New Project or Module Setup

For new Go modules, recommend a minimal structure first:

- `go.mod`
- small packages with clear ownership
- `go fmt`, `go vet`, and `go test` in local/CI workflows
- simple README or package docs only when helpful for contributors

For new Rust crates, recommend a minimal structure first:

- `Cargo.toml`
- `src/lib.rs` and/or `src/main.rs`
- `cargo fmt`, `cargo clippy`, `cargo check`, and `cargo test` in local/CI workflows
- clear module visibility and crate-level docs when public APIs exist

For new Python packages or applications, recommend a minimal structure first:

- `pyproject.toml`
- declared supported Python version
- package layout that matches the project type, often `src/<package>/` for distributable packages
- focused tests using the repo's chosen test runner
- formatter, linter, type checker, and dependency manager only when the project needs them

Do not introduce framework, workspace, CI, lint, type-check, or packaging complexity until the project needs it.
