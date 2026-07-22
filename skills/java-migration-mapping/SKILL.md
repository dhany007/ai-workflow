---
name: java-migration-mapping
description: Map evidence-backed legacy Java behavior, APIs, data access, jobs, sessions, integrations, and business rules to a target architecture such as Go/PostgreSQL while preserving deliberate compatibility and surfacing decisions. Use for prompts such as "java-migration-mapping", "/java-migration-mapping", "map Java to Go", "map MySQL to PostgreSQL", "create rewrite parity matrix", "translate Spring MVC behavior", "plan legacy migration", "compare legacy and target", or after Java extraction/discovery when a rewrite needs source-to-target contracts, data mappings, tests, rollout, and reconciliation criteria.
---

# Java Migration Mapping

## Principle

Map observable behavior and data semantics, not Java classes one for one. Require source evidence for legacy claims and target evidence for implementation status.

Use `java-legacy-extraction` and `java-legacy-discovery` before mapping uncertain domains. Do not promote inferred or defective legacy behavior into target requirements without an explicit decision.

## Mapping Workflow

1. Bound one domain, route family, job, integration, or migration slice.
2. Gather source evidence:
   - behavior records and confidence
   - routes, inputs, outputs, errors, auth, sessions, side effects
   - Java service decisions, MyBatis SQL, source schema, JSP/client assumptions
3. Gather target evidence:
   - target API contracts, domain/service code, schema, migrations, jobs, tests, and deployment constraints
4. Classify every legacy behavior:
   - `Preserve`: required compatibility
   - `Adapt`: same intent with an approved target-specific contract
   - `Fix`: confirmed legacy defect intentionally corrected
   - `Retire`: obsolete behavior intentionally removed
   - `Pending`: owner or runtime evidence required
5. Map contract, data, transaction, security, and operational semantics.
6. Define implementation tasks and parity tests.
7. Define migration rehearsal, reconciliation, cutover, fallback, and observation criteria.

## Parity Matrix

Use one row per observable behavior:

| ID | Legacy Behavior | Evidence | Decision | Target Owner | Target Contract | Validation | Status | Gap |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `<id>` | `<behavior>` | `<file:line>` | Preserve/Adapt/Fix/Retire/Pending | `<module>` | `<route/job/schema>` | `<test/reconciliation>` | Not started/Partial/Done/Blocked | `<gap>` |

Do not mark `Done` from implementation presence alone. Require a test, differential result, reconciliation result, or other explicit validation evidence.

## Contract Mapping

Map:

- route and method, parameter names, body/form encoding, defaults, normalization, and validation
- authentication, authorization, tenant/site context, session/cookie behavior, and CSRF expectations
- status codes, response fields, view/redirect behavior, error body, ordering, pagination, and idempotency
- job schedule, retry, deduplication, locking, ownership, and failure recovery
- cache keys, TTL/invalidation, file naming, messages, and external integration contracts

Use `api-contract-review` for client-visible changes and `security-review` for auth, tenant, input, session, file, or secret-sensitive mapping.

## Data Mapping

Create explicit source-to-target mappings:

| Source Table.Column | Source Semantics | Transform | Target Table.Column | Validation |
| --- | --- | --- | --- | --- |
| `<source>` | `<type/null/default/meaning>` | `<rule>` | `<target>` | `<count/checksum/invariant>` |

Check:

- integer range, unsigned values, decimal precision/scale, and money representation
- null, empty string, sentinel value, default, and missing-row semantics
- character set, collation, case sensitivity, trimming, and identifier normalization
- timezone, date-only, timestamp precision, and zero/invalid legacy dates
- enum/status translations and historical values
- foreign keys, orphan rows, duplicate natural keys, generated identifiers, and ordering
- MySQL-specific SQL translated to target-engine behavior

Apply `database-migrations`, `mysql-patterns`, and `postgres-patterns` for engine-specific design and rollout.

## Transaction And Concurrency Mapping

- Preserve business atomicity, not annotation placement.
- Identify all reads/writes and external side effects inside each legacy transaction.
- Map isolation assumptions, row locking, optimistic checks, duplicate handling, retries, and rollback behavior.
- Separate database commit from cache/message/external effects using an approved reliability pattern when needed.
- Define idempotency for retries, migration replays, jobs, and duplicate requests.

## Validation Strategy

Choose validation proportional to risk:

- golden request/response fixtures for API parity
- behavior tests for business rules and failure paths
- differential tests that run equivalent legacy and target inputs in safe environments
- row counts, grouped counts, null/duplicate checks, sums, checksums, and domain invariants for data migration
- sampled record comparison with sensitive values redacted
- job replay, idempotency, retry, and concurrency tests
- authorization allow/deny matrices
- performance comparison for critical queries and flows

Record expected differences from `Adapt`, `Fix`, and `Retire` decisions so they do not appear as unexplained parity failures.

## Rollout And Safety

- Do not connect to production systems or run migration/cutover commands without explicit authorization and a clear environment.
- Keep extraction and mapping read-only by default.
- Never include credentials or personal data in mapping artifacts.
- Prefer rehearsal on sanitized production-like data.
- Define freeze or dual-write needs, cutover sequencing, fallback boundaries, reconciliation windows, and ownership.
- Treat rollback after data divergence as a forward-recovery problem, not merely an application redeploy.

## Handoff

For a Java-to-Go/PostgreSQL rewrite, coordinate with:

- `go-patterns` and `tdd-workflow` for target implementation
- `api-contract-review` for external compatibility
- `database-migrations`, `mysql-patterns`, and `postgres-patterns` for data movement
- `error-handling`, `observability-check`, and `security-review` for production behavior
- `review-feature` before pull request preparation

## Output Expectations

Report:

1. source and target scope with evidence confidence
2. parity matrix and explicit Preserve/Adapt/Fix/Retire/Pending decisions
3. API, data, transaction, security, job, and integration mappings
4. implementation gaps with target ownership
5. tests, reconciliation queries/invariants, and expected differences
6. rollout, fallback, observability, and unresolved decision points

