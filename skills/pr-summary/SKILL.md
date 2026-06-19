---
name: pr-summary
description: Generate a pull request title and body as a Markdown file for a feature that is ready to become a PR from prompts such as "pr-summary", "/pr-summary", "pr-summary this feature", "generate PR summary", "draft PR body", or "create PR description". Use when Codex should inspect local git branch/worktree changes, compare them with a base branch or commit, include user-provided JIRA/context/release notes, summarize implementation and tests, and create a ready-to-paste PR summary Markdown file without modifying implementation files, creating a PR, pushing, or posting unless explicitly asked.
---

# PR Summary

## Input Handling

Accept loose, team-style prompts. Treat any of these as valid triggers:

```text
pr-summary
/pr-summary
generate PR summary
draft PR body
create PR description
pr-summary this feature
context: group member list projection
JIRA: https://...
```

Use the current repository when no repository is specified. Preserve user-provided `JIRA`, `context`, release notes, acceptance criteria, screenshots, recordings, or reviewer notes and incorporate them into the generated PR body where relevant.

Determine summary scope from the prompt:

- If the user provides a base branch, commit, or range, compare against that exact base.
- Otherwise infer the default base from repository metadata, preferring upstream/default branch metadata when available, then common bases such as `main`, `master`, or `develop`.
- Include staged, unstaged, and untracked files when they are part of the feature.
- If the worktree has unrelated changes that would pollute the PR summary, call out the assumption or ask a focused question.

## Write Safety Contract

This skill may write exactly one summary artifact: a Markdown file containing the PR title and body.

Forbidden during `pr-summary` unless the user explicitly asks for it:

- editing source files
- editing test files
- editing config files
- editing migrations or schemas
- editing generated files
- editing dependency manifests or lockfiles
- running formatters that rewrite code
- running code generators
- creating, updating, pushing, or posting a GitHub PR

Allowed during `pr-summary`:

- reading files
- searching the repository
- inspecting git status/diffs/history
- running read-only commands
- creating or updating only the selected PR summary `.md` file

If the feature needs code cleanup before PR, describe it as a note in the Markdown summary; do not apply it.

## Workflow

1. Identify repository, current branch, base branch/commit, changed files, and relevant commit messages.
2. Inspect git status and diff for the feature scope.
3. Read relevant files when the diff alone is insufficient to explain the behavior.
4. Identify tests added, updated, or run in the current session. Do not invent test results.
5. Identify Go/Rust lint validation that was run in the current session, including `go-lint-workflow` or `rust-lint-workflow` results. Do not run formatters or linters that rewrite files during `pr-summary`.
6. Note migrations, schema changes, generated files, lockfiles, API contracts, feature flags, configuration changes, and frontend screenshots/recordings if relevant.
7. Produce a clear PR title and body in a Markdown file. Do not create a PR, push commits, label, request reviewers, or post to GitHub unless the user explicitly asks.
8. Before finishing, confirm that no source/test/config/migration/generated/dependency files were modified. If any were modified accidentally, stop and report the exact files instead of continuing.

## Output Format

Create a Markdown file by default instead of only replying in chat. Prefer a repository-local summary path if one already exists, such as `docs/`, `plans/`, `.agents/`, `.codex/`, or a memory-system planning folder. If no suitable convention exists, ask for the target path or propose a concise filename such as `pr-summary-<feature-slug>.md`.

The Markdown file must start with a concise PR title, then provide a ready-to-paste PR body.

Use this structure by default:

```markdown
Title: <imperative or concise feature title>

## Summary
- <main user-visible or system behavior change>
- <supporting implementation change>
- <test or validation coverage summary, if useful>

## What Changed
- <specific code/module changes>
- <data/model/API/UI changes>
- <generated/migration/config changes, if any>

## Why
<short context, including JIRA/context links when provided>

## Tests
- <tests run, with exact commands when known>
- <tests not run, if any, and why>

## Lint
- <go-lint-workflow / rust-lint-workflow result, scoped command, or "Not run">
- <new lint issues vs existing debt, if relevant>

## Risk / Rollout
- <migration, compatibility, release, feature flag, or operational notes>
- <"Low risk" only when supported by the diff and tests>

## Screenshots / Recordings
<include only for UI changes or when user provided media notes>
```

Adapt the body to the repository's existing PR template if one exists. Keep the generated summary accurate to the diff and concise enough for reviewers to scan.

After creating the file, reply with the file path, a short summary, and the sentence `No implementation files were modified.`

## Writing Standards

Use clear, neutral engineering language. Prefer concrete implementation facts over vague claims.

Do not overstate impact, testing, or risk. If tests were not run, say so plainly. If behavior depends on assumptions, include them in `Risk / Rollout` or a short `Notes` section.

When the diff includes generated files, lockfiles, migrations, schemas, or cross-repository contracts, mention them explicitly because reviewers often need separate validation.

When the diff includes frontend or visual changes, include a `Screenshots / Recordings` section and state whether screenshots were provided or still need to be attached.

If the user asks for a shorter version, output only:

```markdown
Title: <title>

## Summary
- <bullet>
- <bullet>

## Tests
- <bullet>
```
