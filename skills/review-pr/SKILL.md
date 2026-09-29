---
name: review-pr
description: Review one or more GitHub pull requests from prompts such as "review-pr", "/review-pr", PR URLs, owner/repo#number references, or a list of PR numbers with optional JIRA links and context. Use when Codex should inspect PR metadata, diffs, review comments, unresolved threads, and CI status; automatically coordinate code-reviewer, stack-reviewer, and architect agents according to PR scope and risk when subagents are available; apply relevant language, error, API, database, observability, and security skills; and produce a consistent findings-first review without modifying code unless explicitly asked.
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
4. Route focused skill review according to the changed surface:
   - Apply `error-handling` for validation, API, database, dependency, timeout, retry, cancellation, worker, job, or observable failure behavior.
   - Apply `api-contract-review` for client-visible request, response, error, auth, pagination, idempotency, versioning, or generated-contract changes.
   - Apply `database-migrations`, `mysql-patterns`, or `postgres-patterns` for relevant schema, data, query, transaction, lock, RLS, rollout, or engine-specific changes.
   - Apply `observability-check` for operationally important endpoints, workers, integrations, retries, concurrency, migrations, or critical flows.
   - Apply `security-review` for authentication, authorization, tenant, untrusted input, rendering, secrets, sessions, files, webhooks, external integrations, logs, or sensitive data.
5. Prioritize risks in this order: correctness bugs, regressions, data loss, security/privacy issues, concurrency/race issues, API contract breaks, migration/backward compatibility issues, missing tests for risky behavior, then maintainability.
6. Verify whether existing tests cover the changed behavior. If local verification is useful and feasible, run focused tests. If tests are not run, state that clearly.
7. Do not edit files, push commits, request reviewers, approve, merge, label, or comment on GitHub unless the user explicitly asks for that action.

## Agent Delegation

Treat `review-pr <PR URL>` as sufficient authorization to orchestrate read-only review agents. The user does not need to name agents separately.

Inspect PR metadata and the changed-file list before delegating, then choose the smallest useful team:

- Skip delegation for a clearly trivial, low-risk change whose behavior can be verified directly, such as a typo-only documentation edit.
- Spawn `code-reviewer` for every non-trivial PR to inspect language-neutral correctness, regression, security, contract, data-safety, and test risks.
- Spawn one `stack-reviewer` per materially changed stack. Run independent stack reviewers in parallel when the PR spans multiple stacks.
- Spawn `architect` only when the PR changes module or service boundaries, public contracts, schemas or migration strategy, transaction/consistency semantics, deployment topology, major integrations, legacy rewrite parity, or another durable architectural decision.

Assign each `stack-reviewer` a bounded file set and explicitly name the relevant skills:

| Detected stack | Skill lane |
| --- | --- |
| Go | `go-patterns`, `go-lint-workflow`; add `go-build-resolver` only for observed validation failures |
| Rust | `rust-patterns`, `rust-lint-workflow`; add `rust-build-resolver` only for observed validation failures |
| Java | `java-patterns`; add `java-build-resolver` only for observed validation failures and Java legacy skills only for legacy/rewrite scope |
| Python | `python-patterns`, `effective-python`, `python-testing`, `python-lint-workflow` |
| React/TypeScript | `react-patterns`, `typescript-patterns`, `accessibility`, `react-testing`, `react-performance`; add `frontend-build-resolver` only for observed validation failures |
| React Native | `react-native-patterns`, `typescript-patterns` when TypeScript is used; native accessibility and test guidance come from `react-native-patterns` |

Give agents the PR/base/head identifiers, user context, raw diff or changed-file scope, and repository paths needed to rebuild context. Do not leak suspected findings or an intended verdict into their prompts. Keep every agent read-only.

Wait for all requested agents before finalizing. The main reviewer must:

1. Verify each proposed finding against the current PR diff and surrounding code.
2. Drop findings without an exact location and concrete failure mode.
3. Deduplicate cross-agent findings and keep the strongest evidence.
4. Reconcile conflicting severity or assumptions.
5. Own focused validation and the final user-facing output.

If custom agents or subagent tools are unavailable, perform the same scoped review directly and continue without treating that as a blocker.

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

Apply stack-specific skills through `stack-reviewer` or directly when delegation is skipped. Match repository versions and conventions, and do not treat generic style preferences as findings.

For error behavior changes, include `error-handling` findings when they represent concrete swallowed errors, false success, wrong client status/code, leaked internal detail, unsafe retry behavior, missing timeout/cancellation handling, missing error context, noisy or unsafe logs, or missing tests for important failure paths.
