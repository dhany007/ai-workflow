---
name: review-pr
description: Review one or more GitHub pull requests from prompts such as "review-pr", "/review-pr", PR URLs, owner/repo#number references, or a list of PR numbers with optional JIRA links and context. Use when Codex should inspect PR metadata, diffs, review comments, unresolved threads, CI status when relevant, and produce a consistent findings-first code review without modifying code unless explicitly asked.
---

# Review PR

## Input Handling

Accept loose, team-style prompts. Treat any of these as valid triggers:

```text
review-pr
/review-pr
hy team,
please review this pr ya
https://github.com/owner/repo/pull/123
https://github.com/owner/other-repo/pull/456/changes
JIRA: https://...
context: group member list projection
thankyou
```

Parse all GitHub PR URLs, `owner/repo#123` references, and bare PR numbers when the repository is known from the current workspace or prompt. Preserve user-provided `JIRA`, `context`, release notes, or reviewer notes as review context, not as proof that the code is correct.

When multiple PRs are provided, review each PR independently, then provide a short cross-PR risk summary if the changes appear related.

## Review Workflow

1. Identify repository and PR number for each requested PR.
2. Fetch PR metadata, changed files, diff or patches, discussion comments, review submissions, unresolved review threads, and CI/check status when available.
3. Read the relevant base and head files when the diff alone is insufficient to understand behavior.
4. Prioritize risks in this order: correctness bugs, regressions, data loss, security/privacy issues, concurrency/race issues, API contract breaks, migration/backward compatibility issues, missing tests for risky behavior, then maintainability.
5. Verify whether existing tests cover the changed behavior. If local verification is useful and feasible, run focused tests. If tests are not run, state that clearly.
6. Do not edit files, push commits, request reviewers, approve, merge, label, or comment on GitHub unless the user explicitly asks for that action.

## Output Format

Use code-review stance. Lead with findings, ordered by severity. Avoid long summaries before issues.

For every finding at every severity level (`Critical`, `High`, `Medium`, and `Low`), include:

- severity: `Critical`, `High`, `Medium`, or `Low`
- file and line reference when available
- concise description of the bug or risk
- explanation in Bahasa Indonesia that describes the finding in reviewer-friendly terms
- impact in Bahasa Indonesia that states what can happen if the issue ships
- suggested PR comment text in English, ready to paste into the relevant PR
- why it matters in the PR context
- suggested fix or validation path

Keep the finding title concise, but make the explanation and impact clear enough for the PR author to understand the concrete failure mode. Do not only summarize in English. If the technical evidence is gathered in English, translate the reviewer-facing explanation and impact into natural Bahasa Indonesia.

The suggested PR comment must be written in English as a polite, actionable review comment addressed to the PR author. Do not actually post the comment to GitHub unless the user explicitly asks.

If no issues are found, say that clearly and mention residual risk or test gaps.

Use this structure:

```text
PR <number> - <title>

Findings
- <Severity> [file:line] <short issue title>
  Explanation: <Bahasa Indonesia explanation>
  Impact: <Bahasa Indonesia impact if this ships>
  Suggested PR comment: <English comment ready to paste>
  Suggested fix: <fix or validation path>

Open Questions
- <question or assumption>

Tests
- <what was run or not run>

Summary
<brief change summary, secondary to findings>
```

For multiple PRs, repeat the structure per PR. End with:

```text
Overall Risk
<short ranking of PRs by review risk or "No major issues found">
```

## Review Standards

Be specific and evidence-based. Do not report speculative issues unless there is a concrete failure mode. Prefer one strong finding over many weak comments.

Treat user context such as `context: group member list projection` as the intended behavior lens: check whether the implementation matches that intent, whether edge cases are handled, and whether tests prove the intended projection behavior.

When a PR touches generated files, lockfiles, migrations, schemas, or cross-repository contracts, call that out explicitly because these often require separate validation.
