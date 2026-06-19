---
name: review-pr-followup
description: Re-review a GitHub pull request after review findings were commented and the author pushed updates, from prompts such as "review-pr-followup", "/review-pr-followup", "follow up PR review", "recheck addressed findings", "verify review comments", PR URLs, owner/repo#number references, PR numbers, or no PR reference when exactly one last reviewed PR is clear in the current session. Use when Codex should fetch PR metadata, review comments, unresolved threads, requested changes, new commits since the prior review, CI/check status, and determine whether each previously raised finding is resolved, partially resolved, not resolved, regressed, or needs clarification. Default to report-only; do not post comments, approve, request changes, merge, label, or modify code unless explicitly asked.
---

# Review PR Follow-up

## Scope

Use this skill after initial `review-pr` findings have been posted or discussed and the PR author has pushed updates.

This is not a full first-pass review. Focus on:

- previously commented findings
- unresolved review threads
- requested changes
- author replies
- commits pushed after the findings
- whether fixes preserve intended behavior without new regressions

Use `review-pr` for initial review. Use this skill for follow-up verification.

## Input Handling

Accept loose prompts such as:

```text
review-pr-followup
/review-pr-followup
follow up PR review
recheck addressed findings
verify review comments
https://github.com/owner/repo/pull/123
owner/repo#123
PR 123
```

PR selection rules:

1. If the prompt includes a PR URL, `owner/repo#123`, or PR number with repository context, use that PR.
2. If the prompt has no PR reference but the current session contains exactly one clearly last-reviewed PR, use that PR.
3. If there are multiple possible PRs, no previous PR context, or ambiguous repository context, ask the user for the PR URL or `owner/repo#number`.
4. When multiple PRs are provided, review each independently and do not mix comments or findings across PRs.

Preserve user-provided JIRA links, reviewer notes, previous findings pasted in chat, and author context as follow-up context.

## Safety Rules

Default to report-only.

Do not:

- edit local files
- push commits
- post GitHub comments
- resolve/unresolve threads
- approve or request changes
- merge or label the PR

unless the user explicitly asks for that action.

If the user asks to post follow-up comments, only post comments for findings that remain `Not Resolved`, `Partially Resolved`, `Regression Introduced`, or `Needs Clarification`. Do not spam threads that are already resolved.

## Workflow

1. Identify the PR
   - Determine repository, PR number, title, base branch, head branch, current head SHA, and latest update time.
   - If using session fallback, state which PR was inferred.

2. Gather follow-up context
   - Fetch review comments, review submissions, unresolved review threads, requested changes, issue comments, and author replies.
   - Identify initial findings from prior `review-pr` output when available in the session.
   - Prefer actual PR review threads/comments over chat-only findings when both exist.
   - Identify commits pushed after the relevant review comments when timestamps are available.
   - Check CI/check status when relevant.

3. Verify each finding
   - Read the current diff and relevant files around the commented code.
   - Compare the author's changes to the original finding.
   - Verify the fix addresses the actual failure mode, not only the surface symptom.
   - Apply `error-handling` when the original finding or follow-up commit involves validation failures, API errors, database errors, external service failures, timeouts, retries, cancellation, or observable failure behavior.
   - Check whether tests were added or updated for the finding when the risk warrants it.
   - Look for regressions introduced by the fix in nearby behavior.

4. Classify status
   - `Resolved`: the finding is fully addressed and validation is adequate.
   - `Partially Resolved`: the fix addresses part of the issue but leaves an important gap.
   - `Not Resolved`: the original issue still exists.
   - `Regression Introduced`: the fix creates a new concrete bug or breaks intended behavior.
   - `Needs Clarification`: the correct behavior depends on product/API/design intent that cannot be inferred.
   - `Obsolete`: the code path or comment is no longer relevant because the PR changed direction.

5. Validation
   - Use CI/check status when available.
   - Run focused local tests only when useful and feasible.
   - If tests are not run, state that clearly.

6. Optional posting
   - Do not post by default.
   - If explicitly asked to post, prepare concise English replies.
   - Prefer replying to existing review threads when possible.
   - Do not approve or request changes unless explicitly asked.

## Output Format

Use this structure:

```text
PR <number> Follow-up Review - <title>

Findings Status
- <Status> [file:line or thread/comment reference] <original finding title>
  Evidence: <what changed or what remains>
  Validation: <CI/test/local inspection result>
  Suggested PR reply: <English reply only when follow-up comment is needed>

New Regressions
- <only include concrete regressions introduced by the fix; otherwise "None found">

Open Questions
- <question or "None">

Tests / CI
- <checks reviewed or commands run>
- <tests not run and why>

Summary
<Ready to approve / Still needs changes / Needs author clarification / Follow-up incomplete>
```

If no previous findings, review comments, or unresolved threads can be found:

```text
PR <number> Follow-up Review - <title>

Blocked
- I could not find previous findings, review comments, unresolved threads, or requested changes to verify.

Needed
- Provide the previous findings or confirm that I should run a fresh `review-pr`.
```

## Review Standards

Be evidence-based. Do not mark a finding resolved only because the author replied or touched the file. Verify the code path, behavior, tests, and CI when possible.

Do not raise broad new review findings unless the author's follow-up commit introduced a concrete regression or the new issue directly affects an existing finding.

When previous findings are available only from chat and not posted to GitHub, say that follow-up confidence is lower because PR threads cannot anchor the original issue.
