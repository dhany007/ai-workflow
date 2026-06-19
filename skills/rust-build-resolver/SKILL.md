---
name: rust-build-resolver
description: Resolve Rust cargo check, build, test, clippy, dependency, feature, lifetime, and borrow-checker failures from prompts such as "rust-build-resolver", "/rust-build-resolver", "fix Rust build", "cargo check failed", "cargo test failed", "fix clippy", "borrow checker error", "fix lifetime error", "Cargo.toml problem", or when Rust validation fails during backend implementation. Use when Codex should diagnose Rust errors, read affected files, apply minimal scoped fixes, rerun focused validation, and report remaining failures without broad refactors or unrelated cleanup.
---

# Rust Build Resolver

## Principle

Fix the Rust validation failure with the smallest correct change. This skill is for build/check/test/clippy/dependency failures, not broad review or architecture cleanup.

Use `rust-patterns` for idiomatic Rust decisions, `rust-lint-workflow` for scoped Clippy/check handling, and `coding-standard` for general maintainability.

## Safety Rules

Default to package-scoped diagnostics before full workspace commands.

Do not run network-dependent dependency commands, broad `cargo update`, or dependency/cache repair commands unless the failure requires it and the user approves.

Do not use `unsafe`, `unwrap`, `expect`, broad `.clone()` additions, or `#[allow(...)]` to silence compiler/lint errors unless there is a clear invariant and the user approves or the surrounding code already uses that pattern responsibly.

Do not change public APIs, ownership model, feature flags, or workspace dependency versions unless the error cannot be fixed surgically.

Do not fix unrelated existing Clippy debt. Use `rust-lint-workflow` to distinguish new failures from baseline issues.

## Activation

Use this skill when:

- `cargo check`, `cargo build`, `cargo test`, `cargo clippy`, or `cargo fmt --check` fails
- borrow checker, lifetime, trait bound, feature, or dependency errors block implementation
- a TDD GREEN/refactor step fails because Rust validation no longer passes
- Cargo.toml or workspace dependency issues block validation

Do not use this skill for ordinary review. Use `review-feature` or `review-pr` for review-only tasks.

## Workflow

1. Identify scope:
   - Read the failing command and error output if provided.
   - Inspect changed Rust files and Cargo files with git diff when available.
   - Determine the smallest crate/package/test that reproduces the failure.
2. Reproduce narrowly:
   - Prefer `cargo check -p <package>`, `cargo test -p <package> <test_name>`, or the exact failing command.
   - Use full workspace commands only when scope is unclear, CI requires it, or the user asks.
3. Read affected context:
   - Read the exact error span plus surrounding code.
   - Check trait impls, lifetimes, ownership flow, async boundaries, feature gates, and tests before editing.
4. Apply a minimal fix:
   - Fix root cause, not just the symptom.
   - Prefer restructuring ownership over cloning when the clean fix is local.
   - Keep changes scoped to the failing crate/files.
5. Validate:
   - Rerun the same failing command.
   - If it passes, run the next relevant focused command such as package tests or Clippy.
   - Stop if the same error persists after three focused attempts or the fix requires architecture redesign.

## Command Selection

Start narrow:

```bash
cargo check -p <package>
cargo test -p <package>
cargo test -p <package> <test_name>
cargo clippy -p <package> --all-targets
cargo fmt --check
```

Use full workspace commands only for CI parity, unclear scope, or explicit request:

```bash
cargo check --workspace
cargo test --workspace
cargo clippy --workspace --all-targets
```

Dependency diagnostics need caution:

```bash
cargo tree -d
cargo tree -i <crate>
cargo check -p <package> --features <feature>
```

Run mutating dependency commands such as `cargo update` only with explicit approval.

## Common Fix Patterns

| Error | Likely Cause | Preferred Fix |
| --- | --- | --- |
| cannot borrow as mutable | immutable borrow still live | narrow borrow scope, clone only if local and cheap, or restructure |
| does not live long enough | returning/holding borrowed temporary | return owned value or extend owner lifetime |
| cannot move out of borrowed content | moving behind reference | borrow, clone intentionally, `take`, or restructure ownership |
| trait bound not satisfied | missing bound/derive/impl/import | add the narrow bound/import/derive if semantically correct |
| mismatched types | wrong conversion/reference shape | use `as_ref`, `as_deref`, `into`, explicit conversion, or adjust local signature |
| async future is not `Send` | non-Send value held across `.await` | drop/narrow value before await or use async-safe type |
| no method named | trait not in scope or wrong receiver | import trait or fix receiver |
| unresolved import | wrong module path/feature/dependency | fix path or enable existing feature; avoid new dependency unless necessary |
| clippy warning | meaningful lint or baseline debt | fix local meaningful warning; avoid broad cleanup |

## Borrow Checker Rules

- Prefer ending borrows earlier by narrowing scopes.
- Prefer borrowing inputs as `&T`, `&str`, or `&[T]` when ownership is not needed.
- Use owned values when returning data that cannot safely borrow from a local.
- Add `.clone()` only when ownership is genuinely needed and allocation cost is acceptable in context.
- Do not use `unsafe` to bypass the borrow checker.

## Cargo Rules

- Check package features before changing dependencies.
- Avoid broad version upgrades for local build errors.
- Preserve workspace dependency conventions.
- Do not update `Cargo.lock` unless dependency resolution requires it.
- Do not switch edition or MSRV without explicit project reason and user approval.

## Stop Conditions

Stop and report when:

- the same error remains after three focused fix attempts
- the fix requires ownership model or public API redesign
- dependency repair requires network access or broad version updates
- resolving one error creates a larger unrelated error set
- dirty user changes overlap with files that must be edited

## Output Format

Use this format while resolving:

```text
[FIXED] src/handler/user.rs:42
Error: E0502 - cannot borrow `map` as mutable because it is also borrowed as immutable
Fix: Narrowed the immutable lookup scope before inserting into the map.
Validation: cargo check -p api passed
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
