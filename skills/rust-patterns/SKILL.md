---
name: rust-patterns
description: Apply idiomatic Rust backend patterns from prompts such as "rust-patterns", "/rust-patterns", "implement Rust code", "review Rust code", "refactor Rust crate", "design Rust module", or when Codex is planning, implementing, testing, or reviewing Rust backend changes. Use when Codex should apply practical Rust judgment for ownership and borrowing, error handling, enums and state modeling, traits and generics, module/crate structure, async and concurrency, unsafe boundaries, testing patterns, performance tradeoffs, and anti-patterns while following the repository's existing conventions.
---

# Rust Patterns

## Principle

Rust code should make invalid states hard to express and ownership easy to reason about.

Prefer the repository's established patterns first. Use these patterns as judgment, not as rigid rules. The compiler prevents many classes of bugs, but logic, API, concurrency, and integration bugs still require tests and review.

## Ownership and Borrowing

- Borrow with `&T`, `&str`, or slices when ownership is not needed.
- Take ownership when the function stores, consumes, transfers, or must outlive the caller's data.
- Avoid cloning only to quiet the borrow checker. Clone when it is semantically needed or clearly cheaper than complex lifetime gymnastics.
- Prefer `&[T]` over `&Vec<T>` and `&str` over `&String` at API boundaries.
- Use `Cow` only when flexible borrowed/owned data avoids real allocation or API friction.

## Error Handling

- Return `Result` for recoverable failures.
- Use `?` to propagate errors with context.
- Avoid `unwrap()` and `expect()` in production paths unless the invariant is impossible to violate and the message documents why.
- Prefer typed errors for libraries and domain boundaries.
- `thiserror` is a good fit for structured library/domain errors.
- `anyhow` is a good fit for application boundaries, CLIs, binaries, or orchestration code where rich context matters more than matching variants.
- Follow existing repository error conventions before introducing a new error crate or pattern.

## Enums and State Modeling

- Use enums to model finite states and make illegal states unrepresentable.
- Prefer explicit variant handling for business-critical enums.
- Avoid wildcard `_` matches when new variants should force review.
- Use guard clauses or helper methods when match arms become too large.
- Keep data attached to variants when it belongs only to that state.

## Traits and Generics

- Use traits when behavior abstraction is real: multiple implementations, test seams, plugin-style dispatch, or public API contracts.
- Prefer generics for static dispatch when performance and concrete typing matter.
- Prefer trait objects (`dyn Trait`) for heterogeneous collections, plugin systems, or runtime dispatch.
- Keep trait bounds readable; move complex bounds to helper traits or type aliases when local conventions support it.
- Return concrete types unless abstraction is part of the API design.
- Avoid designing trait hierarchies before the current use case requires them.

## Data Modeling

- Use newtypes for IDs, domain primitives, units, and values that are easy to swap accidentally.
- Use builders only when construction has many optional fields, validation, or staged configuration.
- Prefer `Default` when a safe default is meaningful.
- Use `#[must_use]` for return values that callers should not silently ignore.
- Keep public fields private unless direct struct construction is part of the intended API.

## Module and Crate Structure

- Follow existing crate/module organization first.
- Organize by domain or ownership boundary when adding new modules.
- Keep visibility minimal: private by default, then `pub(crate)`, then `pub` only for intended API.
- Re-export from `lib.rs` or module roots only when it improves API clarity.
- Avoid making helpers public to work around tests; prefer testing through public behavior or `pub(crate)` where repository convention supports it.

## Async and Concurrency

- Use async only when the operation is genuinely async or the surrounding stack requires it.
- Do not block async executors with `std::thread::sleep`, blocking IO, or long CPU work; use async equivalents or spawn blocking work appropriately.
- Use channels for message passing and ownership transfer.
- Use `Arc<Mutex<T>>` or `Arc<RwLock<T>>` only when shared mutable state is necessary.
- Keep lock scopes small and avoid holding locks across `.await`.
- Prefer cancellation-aware tasks and clear task ownership.
- Handle task join errors; do not silently drop panics or cancellation.

## Unsafe Boundaries

- Avoid `unsafe` unless necessary for FFI, performance-critical internals, or APIs that cannot be expressed safely.
- Keep unsafe blocks small and isolated.
- Document invariants with `// SAFETY:` comments.
- Public unsafe functions must include a `# Safety` section.
- Do not use unsafe to bypass the borrow checker for convenience.
- Add tests around safe wrappers and boundary conditions.

## Testing Patterns

- Test behavior and contracts, not private implementation details.
- Put unit tests near the module when they need module context.
- Use `tests/*.rs` integration tests for public API and cross-module behavior.
- Use fixtures/builders only when they make test intent clearer.
- `unwrap()` or `expect()` is acceptable in tests when setup should fail fast; prefer `expect()` when the message helps diagnose failure.
- Keep async tests deterministic and avoid sleeps when synchronization or fake time is available.
- Use property/fuzz-style tests for parsers, codecs, validators, and state machines when supported by the repo.
- Use `#[tokio::test]` or the repository's async test runtime for async code.
- Prefer `assert_eq!` / `assert_ne!` over broad `assert!` when equality output helps debugging.
- Test `Result` and specific error variants instead of relying on panics for expected failures.
- Use `#[should_panic]` only for APIs whose contract is explicitly to panic.
- Use doc tests for public examples that should compile and remain accurate.
- Use Criterion or existing benchmark tooling only for performance-sensitive code.
- Use `cargo llvm-cov` or repository coverage tooling only when already available or explicitly approved.
- Do not add `rstest`, `proptest`, `mockall`, `criterion`, or coverage tools unless the repo already uses them or the user approves.

Unit test shape:

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rejects_empty_name() {
        let err = UserName::new("").expect_err("empty name should be rejected");
        assert!(matches!(err, UserNameError::Empty));
    }

    #[test]
    fn creates_valid_name() {
        let name = UserName::new("alice").expect("valid name");
        assert_eq!(name.as_str(), "alice");
    }
}
```

Integration tests belong in `tests/*.rs` when the public API or cross-module behavior is the contract under test.

Async tests should avoid real sleeps when fake time, channels, barriers, or explicit synchronization can prove the behavior.

## Performance

- Do not optimize prematurely.
- Prefer clear ownership and borrowing before micro-optimizing allocations.
- Preallocate collections when size is known and it keeps code clear.
- Avoid unnecessary clones in hot paths, but do not make simple code obscure only to save a small clone.
- Benchmark before introducing complex performance patterns.
- Be careful with allocation, dynamic dispatch, lock contention, and async task fan-out in hot paths.

## Patterns To Use Carefully

- `Cow`: useful for conditional allocation; avoid when a simple `String` or `&str` API is clearer.
- Builders: useful for complex construction; avoid for simple structs.
- Newtypes: useful for domain safety; avoid wrapping everything without behavior or risk.
- Trait objects: useful for runtime polymorphism; avoid when generics or concrete types are simpler.
- Macros: useful for removing real repetition; avoid when they hide control flow or errors.

## Anti-Patterns

Avoid:

- `unwrap()` in production error paths
- cloning to avoid understanding ownership
- exposing broad `pub` surfaces by default
- changing public API only to satisfy a lint
- wildcard matches for business-critical enums
- blocking operations inside async tasks
- holding locks across `.await`
- global mutable state
- broad incidental refactors in feature PRs
- `#[allow(...)]` without a narrow lint and reason
- `unsafe` without documented invariants

## Review Guidance

When reviewing Rust code, prioritize:

1. correctness, error handling, and state modeling
2. ownership clarity and unnecessary clones in meaningful paths
3. public API, visibility, and trait boundaries
4. async/concurrency lifecycle and lock usage
5. unsafe boundaries and documented invariants
6. behavior-focused tests
7. maintainability and idiomatic simplicity
8. performance only when relevant to the change

Use `rust-lint-workflow` for Clippy/tooling decisions and `coding-standard` for broader Go/Rust quality principles.
