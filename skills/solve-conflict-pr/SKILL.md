---
name: solve-conflict-pr
description: Resolve merge conflicts for GitHub pull requests from prompts such as "solve-conflict-pr", "/solve-conflict-pr", "solve PR conflict", "fix merge conflict", "resolve conflicts in this PR", PR URLs, owner/repo#number references, or a PR number with repository context. Use when Codex should inspect a PR, identify base and head refs, reproduce merge or rebase conflicts locally, resolve conflict markers while preserving intended behavior from both sides, run focused validation, and prepare the conflict-resolution commit or push. Do not merge the PR, force-push, or discard local work unless explicitly requested.
---

# Solve Conflict PR

## Scope

Use this skill when a GitHub pull request cannot be merged cleanly because its branch conflicts with the target branch.

Typical tasks:

- resolve `This branch has conflicts that must be resolved`
- update a PR branch with latest `main`, `master`, `develop`, or release branch
- fix conflicted source, tests, migrations, generated files, lockfiles, or config
- continue from an already-conflicted local merge or rebase
- produce a conflict-resolution summary and validation notes

Do not use this skill for ordinary code review without resolving conflicts. Use `review-pr` for review-only requests.

## Input Handling

Accept loose prompts such as:

```text
solve-conflict-pr
/solve-conflict-pr
fix PR conflict
resolve conflict for https://github.com/owner/repo/pull/123
owner/repo#123
PR 123
```

Parse all PR URLs, `owner/repo#123` references, and bare PR numbers when the repository is known from the workspace or prompt. Preserve user-provided context, JIRA links, conflict notes, CI failures, and reviewer comments as task context.

When multiple PRs are provided, resolve one PR at a time. Do not mix conflict-resolution branches or commits across PRs.

## Safety Rules

Before changing files:

1. Inspect `git status --short` and identify existing local changes.
2. Treat existing changes as user work. Do not overwrite, reset, checkout away, stash, or delete them unless the user explicitly approves.
3. If the working tree is dirty in files needed for conflict resolution, explain the overlap and ask how to proceed.
4. Do not run `git reset --hard`, `git checkout -- <path>`, `git clean`, destructive `rm`, or force-push unless explicitly requested and approved.
5. Do not resolve conflicts by blindly choosing `ours`, `theirs`, `accept current`, or `accept incoming`. Inspect the code and preserve the intended behavior from both sides.
6. Do not merge the PR on GitHub. Only push/update the PR branch when the user explicitly asks or the task clearly includes publishing the fix.

Prefer a merge of the latest base branch into the PR branch unless the user or repository convention asks for rebase. Rebase rewrites PR branch history and needs extra care before pushing.

## Workflow

1. Identify the PR
   - Determine repository, PR number, base branch, head branch, head repo or fork, author, current status, and conflict state.
   - Fetch PR metadata, changed files, review comments, unresolved threads, and CI status when relevant.
   - Read the PR description and any user-provided context to understand intended behavior.

2. Prepare local state
   - Confirm the local repository matches the PR repository.
   - Fetch the latest base branch and PR head ref.
   - Check out the PR branch or create a local conflict-resolution branch from the PR head.
   - Record the starting head SHA and base SHA in your notes.

3. Reproduce the conflict
   - If the repo is already mid-merge or mid-rebase, inspect the current conflict state first.
   - Otherwise, merge the latest base branch into the PR branch with `git merge --no-commit --no-ff <base-ref>` unless rebase was requested.
   - If there is no conflict after fetching current refs, state that clearly and check whether the remote PR status is stale.

4. Resolve conflicts
   - Use `git status --short` and conflict marker searches to list conflicted files.
   - For each conflicted file, read the surrounding code on both sides and the base branch context when needed.
   - Preserve behavior introduced by the PR and behavior added on the base branch.
   - For tests, update expectations to match the merged behavior rather than whichever side is easier.
   - For migrations, schemas, generated files, and lockfiles, follow repository conventions. Regenerate deterministic artifacts when the project provides a generator.
   - Remove all conflict markers and verify no `<<<<<<<`, `=======`, or `>>>>>>>` markers remain.

5. Validate
   - Run focused tests for changed/conflicted areas.
   - Run formatting or linting if the repository expects it and the touched language/tooling is clear.
   - If validation cannot run due to missing dependencies, sandbox restrictions, or time, state exactly what was not run and why.

6. Finish the branch
   - Show the final changed files and summarize how each conflict was resolved.
   - If requested to commit, create a single conflict-resolution commit with a clear message.
   - If requested to push, push to the PR head branch. Avoid force-push unless rebase was explicitly chosen and approved.
   - If requested, comment on the PR with a concise resolution and validation summary.

## Conflict Resolution Standards

Resolve conflicts semantically, not textually.

Check these common failure modes:

- PR logic disappears while resolving nearby base branch changes.
- Base branch bug fixes, permission checks, migrations, or API contract changes are dropped.
- Tests compile but no longer assert the intended PR behavior.
- Generated files or lockfiles are manually edited when regeneration is required.
- Imports, feature flags, config keys, or schema versions are left inconsistent.
- Conflict markers remain in non-code files such as Markdown, YAML, JSON, SQL, or snapshots.

When unsure about intended behavior, inspect:

- PR description and commits
- related tests before and after conflict resolution
- changed base branch code around the same files
- reviewer comments and unresolved threads
- issue or JIRA context provided by the user

Ask a focused question only when the conflict represents a real product or API decision that cannot be inferred from code and tests.

## Output Format

Keep the final response concise and operational:

```text
Resolved PR <number> conflicts against <base-branch>.

Changed files
- <file>: <what was reconciled>

Validation
- <command>: <result>

Notes
- <remaining risk, skipped validation, or push/commit status>
```

If blocked:

```text
Blocked resolving PR <number>.

Reason
- <specific blocker>

Needed
- <one concrete user decision or permission>
```
