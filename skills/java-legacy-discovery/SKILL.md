---
name: java-legacy-discovery
description: Reconstruct business behavior and runtime flows from legacy Java applications using source-linked evidence from Spring MVC, services, MyBatis, JSP, SQL, filters, interceptors, schedulers, caches, and integrations. Use for prompts such as "java-legacy-discovery", "/java-legacy-discovery", "understand this legacy Java flow", "discover business rules", "trace controller to database", "explain this Spring MVC module", "find hidden JSP behavior", "analyze 6hc-java", or when a rewrite needs behavioral understanding beyond a mechanical file inventory.
---

# Java Legacy Discovery

## Principle

Reconstruct observable behavior, not legacy architecture. Treat legacy code as evidence of what the system may do, then distinguish deliberate rules, accidental behavior, dead paths, and unknown runtime dependencies.

Use `java-legacy-extraction` first when the codebase is large or not yet inventoried. Preserve `file:line` evidence and confidence labels from the extraction.

## Discovery Workflow

1. Choose one bounded domain, route family, job, or user journey.
2. Identify all entry points and runtime selectors:
   - routes, HTTP methods, form actions, AJAX calls, schedulers, listeners, and integrations
   - Spring wiring, interceptors, filters, profiles, product editions, and environment properties
3. Trace each path end to end:
   - request or trigger
   - normalization and validation
   - authentication and authorization
   - service decisions and state transitions
   - queries, writes, transactions, cache changes, and external calls
   - response, view, redirect, message, or failure behavior
4. Compare alternate paths:
   - success, validation failure, unauthorized, not found, duplicate, retry, timeout, partial failure, and concurrent update
5. Corroborate rules across controller, service, mapper, schema/SQL, JSP/JavaScript, tests, and operational documentation.
6. Classify findings and unresolved questions.

Do not stop at method names. Read implementation, callers, mapper SQL, and relevant UI or consumer behavior.

## Behavior Classification

Classify each discovered behavior as:

- `Preserve candidate`: observable behavior likely required for compatibility.
- `Confirm with owner`: plausible rule with incomplete or conflicting evidence.
- `Legacy defect candidate`: unsafe or inconsistent behavior that should not be copied without a decision.
- `Obsolete candidate`: deployment, product, or workflow path that appears unused but requires confirmation.
- `Unknown`: behavior depends on unavailable runtime data, binary code, infrastructure, or external services.

Never silently convert `Legacy defect candidate` or `Obsolete candidate` into a target requirement.

## Business Rule Record

```text
Rule ID: <domain.rule-name>
Trigger: <route/job/event>
Preconditions: <auth, state, configuration>
Inputs and normalization: <effective values>
Decision: <condition and result>
State transition: <before -> after>
Data effects: <reads/writes/transaction>
External effects: <cache, message, file, API>
Failure behavior: <status/view/error/retry/rollback>
Observable output: <response or UI outcome>
Variants: <profile/product/environment>
Classification: <preserve/confirm/defect/obsolete/unknown>
Evidence:
- path/to/File.java:line
Confidence: Confirmed/Corroborated/Inferred/Unknown
Open questions: <questions requiring runtime or owner input>
```

## Legacy Java Reading Guide

- Spring MVC: inspect class and method mappings, parameter binding, model attributes, redirects, exception handlers, interceptors, and session annotations.
- Service layer: inspect transaction annotations/XML, branching, state mutation order, retries, synchronization, and calls to other domains.
- MyBatis: inspect mapper interfaces and XML together, especially `<if>`, `<choose>`, `<foreach>`, `${...}`, generated keys, and result maps.
- JSP/JavaScript: inspect submitted field names, default values, hidden state, displayed labels, client routing, and assumptions about response shapes.
- Configuration: inspect bean aliases, profile filtering, property substitution, duplicated resources, scheduler definitions, and environment-specific endpoints.
- Data: preserve decimal scale, null semantics, collation/case behavior, timezone handling, sentinel values, and ordering assumptions.

## Safety And Accuracy

- Do not execute production-facing actions or connect to live infrastructure.
- Do not expose secrets or personal data found in source or dumps.
- Treat comments and documentation as claims that require code or runtime corroboration.
- Treat tests as useful evidence, not proof that production follows the tested path.
- Distinguish unreachable code from merely unreferenced code; reflection, XML wiring, JSP routes, and external callers can hide entry points.
- State when findings apply only to a specific Maven profile, product variant, tenant, or deployment.

## Handoff

Send confirmed and classified behavior to `java-migration-mapping`. Apply `api-contract-review` for client-visible compatibility, `database-migrations` plus `mysql-patterns`/`postgres-patterns` for data movement, and `security-review` for security-sensitive behavior.

## Output Expectations

Report:

1. bounded scope and runtime variants examined
2. end-to-end behavior narrative or flow
3. business rule records with evidence and confidence
4. failure, authorization, transaction, and side-effect behavior
5. preserve/confirm/defect/obsolete decisions still needed
6. evidence gaps and targeted next investigation

