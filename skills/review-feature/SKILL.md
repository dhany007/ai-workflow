---
name: review-feature
description: Review local feature work before a pull request exists from prompts such as "review-feature", "/review-feature", "review my feature", "review local changes", or "review and resolve findings". Use when Codex should inspect the current git branch/worktree diff, compare it with a base branch or commit, read relevant files and tests, produce a review in the same findings-first format as review-pr, and optionally resolve discovered findings in the local code when the user explicitly asks to fix/resolve them.
---

# Review Feature

## Input Handling

Accept loose, team-style prompts. Treat any of these as valid triggers:

```text
review-feature
/review-feature
review my feature before PR
review local changes against main
review and resolve findings
context: group member list projection
JIRA: https://...
```

Use the current repository when no repository is specified. Preserve user-provided `JIRA`, `context`, release notes, acceptance criteria, or reviewer notes as review context, not as proof that the implementation is correct.

Determine review scope from the prompt:

- If the user provides a base branch, commit, or range, compare against that exact base.
- Otherwise infer the default base from the repository, preferring upstream/default branch metadata when available, then common bases such as `main`, `master`, or `develop`.
- Include staged, unstaged, and untracked files when they are part of the feature.
- If the scope is ambiguous or the worktree has unrelated changes that would materially affect the review, state the assumption or ask a focused question.

## Review Workflow

1. Identify repository, current branch, base branch/commit, and changed files.
2. Inspect git status, branch metadata, commit history, and diff or patches for the feature scope.
3. Read relevant base and working-tree files when the diff alone is insufficient to understand behavior.
4. Inspect existing tests and coverage around the changed behavior.
5. Apply `coding-standard` expectations for changed Go and Rust files: readability, KISS, DRY, YAGNI, naming, formatting, structure, idiomatic error handling, visibility, linting, and type-checking.
6. Prioritize risks in this order: correctness bugs, regressions, data loss, security/privacy issues, concurrency/race issues, API contract breaks, migration/backward compatibility issues, missing tests for risky behavior, then maintainability and coding-standard drift.
7. Run focused local validation when feasible and useful. If tests are not run, state that clearly.
8. Do not push commits, create PRs, post comments, merge, or label anything unless the user explicitly asks.

## Resolve Mode

Default to review-only. Modify local files only when the user explicitly asks to resolve or fix findings, for example:

```text
review-feature and resolve findings
review and fix issues
find and resolve before PR
```

When resolve mode is active:

1. Perform the review first and identify concrete findings.
2. Implement fixes for confirmed findings only; avoid unrelated refactors.
3. Preserve user changes and do not revert unrelated work.
4. Add or update focused tests when the fix changes behavior or protects a risky edge case.
5. Run focused validation after the fix.
6. Re-review the final diff and report which findings were resolved.

If a finding requires product clarification, external credentials, migration coordination, or a broad design decision, do not invent the answer. Mark it as unresolved and explain the blocker.

## Output Format

Use code-review stance. Lead with findings, ordered by severity. Avoid long summaries before issues.

For every finding at every severity level (`Critical`, `High`, `Medium`, and `Low`), include:

- severity: `Critical`, `High`, `Medium`, or `Low`
- file and line reference when available
- concise description of the bug or risk
- explanation in Bahasa Indonesia that describes the finding in reviewer-friendly terms
- impact in Bahasa Indonesia that states what can happen if the issue ships
- suggested PR comment text in English, ready to paste into a future PR
- why it matters in the feature context
- suggested fix or validation path
- resolution status when resolve mode is active

Keep the finding title concise, but make the explanation and impact clear enough for the author to understand the concrete failure mode. Do not only summarize in English. If the technical evidence is gathered in English, translate the reviewer-facing explanation and impact into natural Bahasa Indonesia.

The suggested PR comment must be written in English as a polite, actionable review comment addressed to the future PR author. Do not actually post the comment to GitHub unless the user explicitly asks.

If no issues are found, say that clearly and mention residual risk or test gaps.

Use this structure:

```text
Feature Review - <branch or scope>

Findings
- <Severity> [file:line] <short issue title>
  Explanation: <Bahasa Indonesia explanation>
  Impact: <Bahasa Indonesia impact if this ships>
  Suggested PR comment: <English comment ready to paste>
  Suggested fix: <fix or validation path>
  Resolution: <Resolved / Not resolved / Not applicable, when resolve mode is active>

Open Questions
- <question or assumption>

Tests
- <what was run or not run>

Summary
<brief change summary, secondary to findings>

Resolved Changes
<only include in resolve mode; summarize files changed and validations run>
```

## Review Standards

Be specific and evidence-based. Do not report speculative issues unless there is a concrete failure mode. Prefer one strong finding over many weak comments.

Treat user context such as `context: group member list projection` as the intended behavior lens: check whether the implementation matches that intent, whether edge cases are handled, and whether tests prove the intended behavior.

When a feature touches generated files, lockfiles, migrations, schemas, or cross-repository contracts, call that out explicitly because these often require separate validation.

When reviewing local changes, pay extra attention to artifacts that would normally be caught during PR review: forgotten debug code, untracked files, missing generated updates, stale snapshots, accidental environment changes, and incomplete test updates.

For Go and Rust changes, include coding-standard findings when they are meaningful for maintainability or reviewer confidence. Avoid reporting pure formatting nits if `gofmt`, `go fmt`, `cargo fmt`, or an equivalent formatter can handle them.
