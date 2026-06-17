---
name: tech-plan
description: Create a backend-only technical implementation plan as a Markdown file before coding from prompts such as "tech-plan", "/tech-plan", "create tech plan", "plan this backend feature", "design backend implementation", or "analyze before implement". Use when Codex should read project memory folders such as "*-memory-system", inspect requirements and backend code, include API design when applicable, identify affected backend modules, risks, edge cases, test strategy, rollout notes, and open questions. The only allowed file write is the Markdown plan file; do not modify source, test, config, migration, generated, lock, or dependency files unless the user explicitly asks to implement after the plan.
---

# Tech Plan

## Input Handling

Accept loose, team-style prompts. Treat any of these as valid triggers:

```text
tech-plan
/tech-plan
create tech plan
plan this feature
design implementation
analyze before implement
JIRA: https://...
context: group member list projection
```

Use the current repository when no repository is specified. Preserve user-provided `JIRA`, `context`, acceptance criteria, release notes, product notes, or reviewer notes as planning context, not as proof that the proposed design is correct.

Default to planning-only. Do not implement code, push commits, create PRs, or post to GitHub unless the user explicitly asks.

## Write Safety Contract

This skill may write exactly one planning artifact: a Markdown file containing the tech plan.

Forbidden during `tech-plan` unless the user explicitly asks to implement after the plan:

- editing source files
- editing test files
- editing config files
- editing migrations or schemas
- editing generated files
- editing dependency manifests or lockfiles
- running formatters that rewrite code
- running code generators

Allowed during `tech-plan`:

- reading files
- searching the repository
- inspecting git status/diffs/history
- running read-only commands
- creating or updating only the selected tech plan `.md` file

If a change to code is needed, describe it in the Markdown plan under `Implementation Plan`; do not apply it.

This skill is backend-only by default. Focus on services, handlers, APIs, domain logic, persistence, migrations, generated backend contracts, workers, jobs, queues, configuration, auth, observability, and backend tests. Exclude frontend/UI planning unless the user explicitly asks to include it.

Create a Markdown plan file by default instead of only replying in chat. Prefer a repository-local planning path if one already exists, such as `docs/`, `plans/`, `.agents/`, `.codex/`, or a memory-system planning folder. If no suitable convention exists, ask for the target path or propose a concise filename such as `tech-plan-<feature-slug>.md`. Do not create or edit implementation source files as part of this skill.

## Workflow

1. Read project memory first:
   - Search the current repository for directories matching `*-memory-system`.
   - Read relevant index, overview, convention, architecture, decision, domain, API, workflow, or README-like files from those memory directories.
   - Extract project conventions, architecture constraints, domain rules, prior decisions, known risks, and workflow expectations.
   - If no memory folder exists, state that and continue with codebase inspection.
2. Understand the requirement:
   - Restate the requested behavior in concrete terms.
   - Identify user-facing behavior, system behavior, non-goals, and assumptions.
   - Call out missing product or technical details that affect the design.
3. Inspect the codebase:
   - Find relevant backend modules, packages, services, tests, schemas, API handlers, models, migrations, feature flags, generated code, workers, jobs, queues, and configuration.
   - Prefer existing patterns over new abstractions.
   - Note ownership boundaries and cross-module contracts.
4. Design the implementation:
   - Propose a simple approach that satisfies the requirement.
   - Break work into ordered implementation tasks.
   - Include data model, state, validation, error handling, concurrency, performance, and backward compatibility considerations when relevant.
5. Include API design when applicable:
   - Endpoint, method, route, and handler ownership.
   - Request shape, response shape, validation rules, and error model.
   - Auth, permissions, tenancy, idempotency, pagination, filtering, and sorting when relevant.
   - Backward compatibility, versioning, generated clients, and contract tests when relevant.
6. Include test and validation plan:
   - Unit, integration, API contract, migration, regression, worker/job, and backend service tests as appropriate.
   - Focused commands to run.
   - Manual verification steps when automation is not enough.
7. Identify risks:
   - Correctness, data loss, security/privacy, concurrency, migration, API compatibility, performance, rollout, and operational risks.
   - Explain mitigations or validation paths.
8. End with open questions:
   - Ask only questions that materially affect implementation.
   - If assumptions are reasonable, state them and proceed with the plan.
9. Add an implementation handoff:
   - State that future implementation must follow `coding-standard` automatically.
   - Mention Go/Rust format, lint, type-check, and test expectations when relevant.
   - Remind the implementer to keep changes scoped to the approved backend plan.
10. Before finishing, confirm that no source/test/config/migration/generated/dependency files were modified. If any were modified accidentally, stop and report the exact files instead of continuing.

## Output Format

Create a Markdown file with this structure by default, then reply with the file path, a short summary, and the sentence `No implementation files were modified.`

```markdown
# Tech Plan - <feature or scope>

## Memory Context
- <memory files/folders read>
- <project conventions, architecture notes, or domain rules discovered>

## Requirement
- <concrete behavior to implement>
- <non-goals or assumptions>

## Backend Scope
- <backend-only scope and explicit frontend exclusions>

## Codebase Context
- <affected backend modules/packages/files>
- <existing patterns to follow>

## API Design
- <endpoint/method/request/response/errors/auth/backward compatibility>
- <omit this section if the feature does not touch API behavior>

## Implementation Plan
1. <task>
2. <task>
3. <task>

## Test Plan
- <automated tests to add/update>
- <commands to run>
- <manual validation, if needed>

## Risks & Mitigations
- <risk and mitigation>

## Open Questions
- <question or "None">

## Implementation Handoff
- When implementing this plan, automatically follow `coding-standard` for any Go or Rust code touched.
- Keep implementation scoped to this backend plan unless the user approves changes outside scope.
- Run focused format, lint, type-check, and test commands listed in `Test Plan` before finishing when feasible.
```

Keep the plan specific enough to implement from, but avoid unnecessary ceremony for small changes. For trivial changes, create a shorter Markdown file with `Requirement`, `Backend Scope`, `Implementation Plan`, `Test Plan`, and `Risks`.

## Planning Standards

Prioritize simplicity and maintainability:

- Prefer the smallest design that satisfies current requirements.
- Avoid speculative abstractions and future-only extension points.
- Follow existing project conventions unless there is a concrete reason to diverge.
- Surface tradeoffs clearly when multiple approaches are viable.
- Treat migrations, schemas, generated files, API contracts, and cross-repository changes as high-attention areas.
- For Go and Rust code, apply `coding-standard` expectations during planning: readability, KISS, DRY, YAGNI, idiomatic naming, formatting, error handling, visibility, linting, type-checking, and tests.
- Keep frontend concerns out of the plan unless explicitly requested. If backend changes require frontend follow-up, list it as an integration note, not as implementation scope.

If the user asks to continue after the plan, implement in a separate step using the approved plan and keep changes scoped to that plan.
