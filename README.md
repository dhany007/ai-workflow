# AI Workflow

This repository stores Codex skills and supporting scripts for AI-assisted development workflows.

## Project Structure

```text
.
├── scripts/
│   └── sync-from-codex.sh
└── skills/
    ├── coding-standard/
    ├── go-lint-workflow/
    ├── go-patterns/
    ├── pr-summary/
    ├── review-feature/
    ├── review-pr/
    ├── review-pr-followup/
    ├── rust-lint-workflow/
    ├── rust-patterns/
    ├── solve-conflict-pr/
    ├── tdd-workflow/
    └── tech-plan/
```

## Skills

Available skills in the `skills/` directory:

- `coding-standard`: applies Go and Rust coding standards for implementation, refactoring, review quality, naming, formatting, linting setup, and contributor conventions. It also coordinates Go/Rust pattern and lint workflow skills when relevant.
- `go-lint-workflow`: runs and interprets scoped Go linting with `golangci-lint`, `go vet`, and `go fmt`, while separating new issues from existing baseline debt.
- `go-patterns`: applies idiomatic Go backend patterns for error handling, context propagation, interfaces, packages, dependency injection, concurrency, testing, and performance tradeoffs.
- `pr-summary`: generates a ready-to-paste pull request title and body from local branch or worktree changes, including JIRA/context/release notes when provided.
- `review-feature`: reviews local feature work before a PR exists by inspecting branch or worktree diffs, applying coding standards, Go/Rust patterns, and scoped lint workflow guidance.
- `review-pr`: performs first-pass GitHub pull request reviews by inspecting metadata, diffs, comments, unresolved threads, CI status, and relevant code context.
- `review-pr-followup`: re-reviews a GitHub pull request after the author pushes updates, then verifies whether prior findings are resolved, partially resolved, unresolved, regressed, or need clarification.
- `rust-lint-workflow`: runs and interprets scoped Rust validation with `cargo fmt`, `cargo check`, `cargo clippy`, and tests, while separating new warnings from existing workspace debt.
- `rust-patterns`: applies idiomatic Rust backend patterns for ownership, borrowing, errors, enums, traits, modules, async/concurrency, unsafe boundaries, testing, and performance tradeoffs.
- `solve-conflict-pr`: resolves GitHub pull request merge conflicts by reproducing the conflict locally, preserving behavior from both sides, and running focused validation.
- `tdd-workflow`: implements backend Go or Rust features, fixes, and refactors with a RED/GREEN/refactor test-driven workflow, using language-specific pattern and lint skills during implementation and validation.
- `tech-plan`: creates backend-only technical implementation plans before coding, including affected modules, API design when relevant, risks, edge cases, tests, rollout notes, and open questions.

Each skill lives in its own directory and should include at least a `SKILL.md` file.

## Suggested Workflow

For day-to-day usage, the intended flow is:

```text
tech-plan
  -> implement this feature
  -> review-feature
  -> pr-summary
  -> review-pr
  -> review-pr-followup
```

The `implement this feature` step is handled by `tdd-workflow`, with `coding-standard`, language patterns, and scoped lint workflows applied as needed:

```text
tdd-workflow
  -> coding-standard
     -> go-patterns / rust-patterns
     -> go-lint-workflow / rust-lint-workflow
```

Use `solve-conflict-pr` whenever a PR branch cannot be merged cleanly into its target branch.

Use language-specific skills directly when the task is focused on one layer:

- `go-patterns` or `rust-patterns` for idiomatic design and implementation guidance.
- `go-lint-workflow` or `rust-lint-workflow` for scoped formatting, linting, and validation.

## Skill Triggers

Each skill can be invoked explicitly by name, for example:

```text
/tech-plan
/tdd-workflow
/coding-standard
/go-patterns
/go-lint-workflow
/rust-patterns
/rust-lint-workflow
/review-feature
/pr-summary
/review-pr
/review-pr-followup
/solve-conflict-pr
```

Codex can also invoke skills implicitly when the user request matches the skill description.

## Sync from Local Codex

Use this script to copy skills from `~/.codex/skills` into this project's `skills/` directory:

```bash
scripts/sync-from-codex.sh
```

By default, the script:

- reads from `~/.codex/skills`;
- copies into `./skills`;
- copies user skills only;
- skips the `.system` directory;
- does not delete extra files in the target directory.

### Dry Run

Preview changes without writing files:

```bash
scripts/sync-from-codex.sh --dry-run
```

### Sync Specific Skills

```bash
scripts/sync-from-codex.sh review-pr tech-plan
```

### Include System Skills

To also copy `.system` skills:

```bash
scripts/sync-from-codex.sh --include-system
```

### Mirror Target with Source

Use `--delete` when the target skill directory should match the source exactly and files that no longer exist in the source should be removed from the target:

```bash
scripts/sync-from-codex.sh --delete
```

Use this option carefully because it can delete files inside the target skill directory.

## Script Options

```text
Usage: scripts/sync-from-codex.sh [options] [skill ...]

Options:
  --source DIR       Source skills directory (default: ~/.codex/skills)
  --target DIR       Target skills directory (default: ./skills)
  --include-system   Also copy .system skills
  --delete           Delete files in the target skill that no longer exist in source
  -n, --dry-run      Show what would be copied without changing files
  -h, --help         Show help
```

## Development Notes

- Do not edit `.system` unless this project intentionally needs to store system skills.
- Run `scripts/sync-from-codex.sh --dry-run` before large syncs.
- After changing the shell script, validate its syntax with:

```bash
bash -n scripts/sync-from-codex.sh
```
