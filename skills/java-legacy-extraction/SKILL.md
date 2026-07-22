---
name: java-legacy-extraction
description: Extract an evidence-backed inventory from legacy Java applications, especially Maven WAR, Java 8, Spring MVC, MyBatis, JSP, XML configuration, SQL, Quartz, Redis, and servlet-era systems. Use for prompts such as "java-legacy-extraction", "/java-legacy-extraction", "extract legacy Java", "inventory this Java system", "catalog endpoints and tables", "trace Spring controllers", "extract MyBatis mappings", "inspect JSP actions", "map scheduled jobs", "analyze 6hc-java", or before behavior discovery and rewrite planning when a large Java codebase must be reduced to structured, source-linked facts.
---

# Java Legacy Extraction

## Principle

Extract facts before interpreting behavior. Treat every controller, service, mapper, JSP, SQL file, and configuration file as evidence, not as an automatically correct specification.

Keep extraction read-only unless the user explicitly requests changes. Preserve uncertainty and attach a repository-relative `file:line` reference to every material claim.

## Workflow

1. Establish scope:
   - Identify modules, build systems, Java version, packaging, profiles, and environment overlays.
   - Inspect `pom.xml`, `build.gradle`, `web.xml`, application bootstrap, Spring XML, and property files before tracing features.
   - Record ignored, generated, vendored, binary, and unavailable artifacts.
2. Build a structural inventory:
   - Count and group controllers, services, repositories/DAOs, MyBatis mappers, models, interceptors, filters, JSPs, jobs, integration clients, and SQL files.
   - Map package roots and module boundaries.
   - Note naming variants, duplicate implementations, product editions, and profile-specific resources.
3. Extract entry points:
   - Capture HTTP routes, methods, parameters, content types, views, redirects, session requirements, and interceptors.
   - Capture scheduled jobs, message consumers, startup hooks, command-line entry points, and externally invoked services.
4. Extract data access:
   - Link Java mapper methods to mapper XML or annotations.
   - Record tables, columns, joins, filters, ordering, pagination, writes, stored procedures, and dynamic SQL branches.
   - Mark transaction boundaries and multi-step writes.
5. Extract user-interface evidence:
   - Link JSP forms, links, AJAX calls, hidden fields, JavaScript handlers, validation, and displayed status labels to backend routes.
   - Treat client-side checks as evidence, not enforcement.
6. Extract cross-cutting behavior:
   - Record authentication, authorization, tenant or site selection, session/cookie use, Redis/cache keys, anti-injection filters, exception handling, logging, file operations, and external integrations.
7. Produce structured output and list gaps.

Use `rg` and `rg --files` for broad inventory, then read the relevant files around each match. Do not infer behavior from filenames alone.

## Evidence Rules

Classify each extracted item as:

- `Confirmed`: directly supported by executable code or configuration.
- `Corroborated`: supported by two or more independent artifacts, such as controller plus JSP or mapper plus schema.
- `Inferred`: likely based on call chains or naming, but missing a decisive artifact.
- `Unknown`: blocked by missing source, binary JAR, environment configuration, database object, or external system.

For conflicting evidence, retain both observations and identify the runtime selector such as Maven profile, Spring bean wiring, feature flag, product edition, or deployment environment.

Never record credentials, tokens, private keys, connection strings, or personal data in extraction output. Report only the file location and secret category.

## Extraction Record

Use a stable record for each behavior or entry point:

```text
ID: <stable-domain-or-route-id>
Module: <module>
Entry point: <HTTP route, job, listener, or method>
Inputs: <parameters/body/session/context>
Call path: <controller -> service -> mapper/integration>
Data access: <tables and operations>
Authorization: <role/permission/interceptor evidence>
Side effects: <writes, cache, files, external calls>
Output: <response/view/redirect/status>
Variants: <profile/product/environment branches>
Evidence:
- path/to/File.java:line
- path/to/mapper.xml:line
Confidence: Confirmed/Corroborated/Inferred/Unknown
Open questions: <missing or conflicting evidence>
```

Prefer repository-relative paths in generated artifacts so records survive workspace moves.

## Coverage Matrix

Summarize extraction coverage by module or domain:

| Area | Entry Points | Service Paths | Data Access | UI/Consumer | Cross-Cutting | Confidence | Gaps |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| `<area>` | `<count>` | `<count>` | `<count>` | `<count>` | `<count>` | `<level>` | `<gaps>` |

Counts indicate inventory coverage, not behavioral correctness.

## Safety Boundaries

- Do not connect to production databases, Redis, queues, mail servers, or third-party services.
- Do not execute bundled SQL, migration scripts, shell commands, JSP actions, or unknown binaries merely to inspect them.
- Treat source comments, READMEs, SQL dumps, and filenames as lower-confidence evidence until corroborated.
- Do not normalize away odd behavior; compatibility work may depend on it.
- Do not edit the legacy application during extraction unless explicitly requested.
- Do not claim complete coverage when profile-specific resources, binary dependencies, or runtime data are unavailable.

## Handoff

Pass the evidence inventory to `java-legacy-discovery` for behavioral reconstruction. Use `java-migration-mapping` only after relevant behavior is understood. Use `security-review` for authentication, authorization, injection, secret, session, file, or sensitive-data findings.

## Output Expectations

Report:

1. scope, modules, profiles, and toolchain detected
2. structural inventory and coverage matrix
3. source-linked extraction records
4. conflicting or environment-dependent variants
5. sensitive-data or security surfaces without exposing secrets
6. unknowns and the next files or runtime evidence needed

