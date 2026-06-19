---
name: rust-lint-workflow
description: Run and interpret Rust linting pragmatically for backend feature work from prompts such as "rust-lint-workflow", "/rust-lint-workflow", "cargo clippy this change", "lint Rust changes", "handle clippy warnings", or when Codex is implementing, reviewing, or refactoring Rust code. Use when Codex should apply scoped cargo fmt/check/clippy/test validation, distinguish new warnings from existing workspace debt, handle touched complex code without broad refactors, apply test-code-specific lint judgment, and report lint results without treating unrelated legacy issues as blockers.
---

# Rust Lint Workflow

## Principle

Lint changed behavior strictly. Handle existing debt pragmatically.

Do not make a feature PR responsible for all existing Clippy or workspace lint debt. Do not change public API, visibility, ownership structure, or feature flags only to satisfy lint unless that change is part of the approved task.

## Scope

Use this skill for Rust backend code:

- library and binary crates
- `src/**/*.rs`
- unit tests inside modules
- integration tests under `tests/`
- services, domain logic, API handlers, workers, jobs, persistence, migrations, and generated-code boundaries
- feature implementation, bug fixes, refactors, and pre-PR reviews

## Preferred Commands

Prefer package-scoped validation:

```bash
cargo fmt -p <package>
cargo check -p <package>
cargo test -p <package>
cargo clippy -p <package> --all-targets
```

When feature flags are relevant, use the smallest accurate feature set:

```bash
cargo check -p <package> --features <feature>
cargo test -p <package> --features <feature>
cargo clippy -p <package> --all-targets --features <feature>
```

Use full workspace checks for CI, dedicated cleanup, or explicit user request:

```bash
cargo fmt --all
cargo check --workspace
cargo test --workspace
cargo clippy --workspace --all-targets --all-features
```

If the repository defines `make lint`, `cargo xtask`, `just lint`, or CI-specific commands, prefer those after checking what they run.

Optional dependency/security checks when the repo already uses them:

```bash
cargo deny check
cargo audit
```

Do not install these tools unless the user approves.

## Baseline-Aware Decision Rules

For every lint finding, classify it:

- `New issue from this change`: fix in the current task.
- `Existing debt on latest base`: do not block the feature unless it affects correctness or touched behavior.
- `Introduced by another merged change`: do not assign to this task unless your change relies on or worsens it.
- `Blocking current implementation`: fix the smallest safe surface or ask for scope approval.
- `Requires broad refactor`: document as follow-up unless the user asked for refactor.

Rust workspaces often make exact new-from-base lint harder than Go. Prefer scoped package checks and inspect whether the warning is in code changed by the task.

## Complexity, API, and Visibility

For Clippy warnings related to complexity, type complexity, argument count, needless clones, visibility, or API design:

- Do not rewrite broad existing modules just because the feature touches them.
- Do not change public APIs or trait contracts only to satisfy lint without checking compatibility.
- Do not fight the borrow checker with clever abstractions when a clear helper or owned value is more maintainable.
- If your change introduces the warning, fix it in the current task.
- If the warning existed before, avoid making it worse and document it as existing debt when relevant.
- Prefer isolating new behavior into a small function/module with focused tests.

Use `#[allow(...)]` only as a last resort. It must be narrow, lint-specific, and include a reason:

```rust
#[allow(clippy::too_many_arguments)] // Existing public constructor kept for API compatibility.
pub fn new(...) -> Self {
    ...
}
```

## Test Code Rules

Lint unit and integration tests too, but judge them differently from production code.

Keep strict:

- deterministic tests
- isolated fixtures and temp state
- clear assertions and failure messages
- no hidden dependency on test ordering
- cleanup for files, database rows, async tasks, servers, and mocks
- no ignored `Result` values that hide failed setup

Allow more flexibility when it improves readability:

- `unwrap()` or `expect()` in tests when setup should fail fast
- clones of small test values
- repeated literals that make cases clear
- longer test functions for scenario setup
- fixture builders with extra arguments when they are local to tests

Prefer `expect("clear reason")` over `unwrap()` when the failure message matters.

Do not disable Clippy globally for tests. Use scoped `#[allow(...)]` with a reason when necessary:

```rust
#[allow(clippy::unwrap_used)] // Fixture construction failure should fail the test immediately.
fn valid_fixture() -> Fixture {
    ...
}
```

## Review Guidance

When reviewing Rust diffs:

- report new Clippy/check warnings caused by the PR as findings
- mention existing debt only when it affects changed behavior or review risk
- do not require broad cleanup of unrelated workspace warnings
- suggest scoped package commands and feature flags
- include whether production code or test code rules apply
- be careful with suggestions that alter public API, ownership model, trait bounds, feature flags, or unsafe boundaries

## Output Notes

When reporting lint results, include:

```text
Rust lint
- Scope: <package / feature set / workspace>
- Commands: <commands run>
- Result: <pass/fail/skipped>
- Findings: <new issues vs existing debt>
- Notes: <allow reasons, follow-up debt, or skipped validation>
```

Do not invent lint results. If lint was not run, say why.
