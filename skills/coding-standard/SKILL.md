---
name: coding-standard
description: Apply coding standards for Go and Rust projects from prompts such as "coding-standard", "/coding-standard", "implement this feature", "implement this tech plan", "continue from tech-plan", "implement a Go feature", "implement a Rust feature", "review code quality", "refactor to coding standard", "set up linting", "enforce naming conventions", or "onboard contributors". Use implicitly when Codex is creating, modifying, reviewing, or refactoring Go or Rust code, especially after a tech-plan Markdown file exists, for new features/modules, code quality and maintainability review, naming/formatting/structural consistency, linting/formatting/type-checking setup, or contributor convention guidance.
---

# Coding Standard

## References

Use these as primary language references:

- Go: Effective Go, https://go.dev/doc/effective_go
- Rust: Effective Rust, https://effective-rust.com/title-page.html

Treat Effective Go as guidance for core Go idioms, naming, formatting, and program construction. Remember that it predates newer Go features such as modules and generics, so combine it with repository conventions and current Go tooling.

Treat Effective Rust as guidance for idiomatic Rust across types, traits, error handling, ownership, dependencies, tooling, testing, Clippy, and CI.

## Core Principles

Apply these principles before language-specific preferences:

1. Readability First
   - Code is read more than written.
   - Prefer clear variable, type, function, and module names.
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
   - implementing a Go or Rust feature
   - starting a new project or module
   - reviewing code quality and maintainability
   - refactoring existing code
   - enforcing naming, formatting, or structure
   - setting up linting, formatting, type-checking, or CI
   - onboarding contributors to conventions
2. Inspect existing style before proposing changes. Prefer the repo's established patterns unless they conflict with correctness, maintainability, or language idiom.
3. Apply the core principles first, then language-specific guidance.
4. Keep changes scoped. Avoid broad rewrites when a focused cleanup is enough.
5. Run or suggest the relevant formatter, linter, type checker, and tests.
6. Report tradeoffs when a standard is subjective or when local conventions differ from external guidance.

## During Feature Implementation

When implementing Go or Rust features, apply this skill even if the user does not explicitly say `coding-standard`.

- If the user says `implement this feature`, `implement this tech plan`, or similar after a `tech-plan`, read the relevant tech plan Markdown file and apply this skill automatically.
- Treat a `tech-plan` file's `Implementation Handoff` section as an instruction to follow coding standards during implementation.
- When `tdd-workflow` is active, apply coding standards during the GREEN/refactor stage without skipping RED/GREEN validation.
- Start from the smallest design that satisfies the requested behavior.
- Follow the surrounding package/module structure before introducing a new abstraction.
- Name new types, functions, traits, modules, and packages for their current responsibility, not future possibilities.
- Prefer clear control flow and explicit error handling over clever compression.
- Add tests that prove the new behavior and important edge cases.
- Run focused format, lint, type-check, and test commands before finishing when feasible.
- Mention any standard-related tradeoffs in the final response only when they materially affected the implementation.

## Go Standards

Use idiomatic Go:

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

For Go validation, prefer:

```bash
go fmt ./...
go vet ./...
go test ./...
```

Use narrower package/test commands when the repository is large or the user asks for focused validation.

## Rust Standards

Use idiomatic Rust:

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

For Rust validation, prefer:

```bash
cargo fmt
cargo clippy --all-targets --all-features
cargo check
cargo test
```

Use narrower package/test commands when the repository is large or feature flags make full validation expensive.

## Review Output

When reviewing or refactoring, report issues in priority order:

1. correctness or safety issues
2. maintainability and readability issues
3. duplicated or speculative abstractions
4. naming, formatting, and structural consistency
5. missing linting, formatting, type-checking, or tests

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

Do not introduce framework, workspace, CI, or lint complexity until the project needs it.
