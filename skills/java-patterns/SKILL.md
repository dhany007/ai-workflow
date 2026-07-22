---
name: java-patterns
description: Apply maintainable Java patterns for implementation, refactoring, and review across Java 8+ applications, Maven or Gradle builds, Spring MVC/Spring Boot, MyBatis/JPA, servlet applications, jobs, and integrations. Use for prompts such as "java-patterns", "/java-patterns", "implement Java", "review Java code", "refactor this Spring service", "design a Java API", "fix transaction boundaries", "make this Java idiomatic", or when legacy Java must be changed conservatively without assuming modern language or framework features are available.
---

# Java Patterns

## Principle

Match the repository's Java version, framework generation, and established boundaries. Prefer explicit, testable code with clear ownership over clever abstractions or speculative modernization.

For legacy systems, preserve required behavior while improving only the requested area. Use `java-legacy-discovery` before changing code whose observable behavior is unclear.

## Baseline Workflow

1. Inspect `pom.xml`, Gradle files, compiler settings, packaging, profiles, framework versions, and test conventions.
2. Read neighboring controllers, services, repositories/mappers, models, configuration, and tests.
3. Identify the public contract, transaction boundary, failure behavior, and supported Java language level.
4. Make the smallest cohesive change using existing project conventions.
5. Add or update behavior-focused tests where the repository can run them.
6. Validate with repository-standard commands. Use `java-build-resolver` when validation fails.

## Language And API Design

- Use names that describe domain intent; avoid generic `Util`, `Manager`, `Common`, and ambiguous abbreviations.
- Keep methods focused and make side effects visible in names and structure.
- Prefer immutable values and defensive copies at boundaries where the supported Java version permits them.
- Validate required inputs at the boundary that owns the contract.
- Use enums or domain types for closed state sets when compatible with persistence and serialization contracts.
- Use `BigDecimal` for money and exact decimal business values; construct from strings or exact integer units rather than binary floating-point values.
- Use `java.time` when the repository and contract support it; otherwise isolate legacy date/time APIs and document timezone assumptions.
- Return collections instead of `null`; preserve existing external null semantics when compatibility requires them.
- Use `Optional` primarily for return values when the repository already uses it; avoid fields, parameters, and serialization contracts that gain no clarity from it.
- Use streams when they clarify transformations; use loops when control flow, checked exceptions, mutation, or debugging becomes clearer.

## Layers And Dependencies

- Keep transport concerns in controllers, business decisions in domain/services, and persistence details in repositories/mappers.
- Keep transaction boundaries around cohesive business operations, normally at the service layer.
- Avoid calling slow external systems while holding database transactions unless atomicity truly requires it.
- Inject dependencies explicitly using the repository's established style. Prefer constructor injection in new Spring code when framework compatibility permits it.
- Define interfaces at meaningful boundaries, not automatically for every class.
- Avoid static mutable state and service-locator access.
- Keep DTOs, persistence models, and domain models separate when their contracts genuinely differ; avoid ceremonial mapping with no boundary benefit.

## Spring And Web

- Keep controller actions thin and explicit about request binding, validation, authorization, response status, view, or redirect behavior.
- Do not rely on client-side or JSP validation for server-side security or invariants.
- Preserve session, cookie, interceptor, filter, and exception-handler behavior when modifying legacy routes.
- Use framework validation consistently with the project version; map validation failures to stable client-visible behavior.
- Avoid exposing persistence entities directly through external APIs when it couples schema and contract.
- Treat redirects, flash attributes, view model keys, and JSP field names as contracts in server-rendered applications.

## Persistence And Transactions

- Parameterize SQL. In MyBatis, prefer `#{...}`; treat `${...}` as an injection-sensitive boundary requiring strict allowlisting.
- Read mapper interfaces and XML/result maps together before changing signatures or fields.
- Make ordering explicit whenever callers depend on deterministic results.
- Bound list queries and avoid hidden N+1 access patterns.
- Handle generated keys, affected row counts, optimistic concurrency, duplicate keys, and not-found updates deliberately.
- Keep transaction propagation and rollback rules explicit, especially with checked exceptions in older Spring configurations.
- Use `database-migrations`, `mysql-patterns`, or `postgres-patterns` for schema and engine-specific decisions.

## Errors And Observability

- Preserve causes when wrapping exceptions and add domain context without secrets or personal data.
- Distinguish validation, authorization, not found, conflict, dependency failure, timeout, and internal errors.
- Do not catch `Exception` or `Throwable` unless at a deliberate boundary that logs/maps/rethrows correctly.
- Avoid empty catch blocks and error paths that return success.
- Keep logs actionable and structured according to repository conventions; never log credentials, session tokens, full payment data, or sensitive request bodies.
- Apply `error-handling`, `observability-check`, and `security-review` when those concerns are material.

## Concurrency And Resources

- Use try-with-resources for closeable resources when supported.
- Make executor, thread, timer, and scheduler ownership explicit; include shutdown and cancellation behavior.
- Avoid synchronizing broad request paths or using shared mutable singleton state.
- Preserve interruption by restoring the interrupt flag when catching `InterruptedException` unless the method propagates it.
- Add timeouts to external calls using the APIs available in the project's dependency versions.

## Testing

- Test observable behavior, edge cases, failure paths, authorization, transaction rollback, and data mapping.
- Prefer fast unit tests for isolated decisions and focused integration tests for Spring wiring, mapper SQL, transactions, serialization, and route contracts.
- Do not over-mock value objects or framework internals.
- Keep fixtures deterministic and independent of test order, current time, default locale, or default timezone.
- Check whether Maven Surefire or Gradle is configured to skip tests before claiming validation succeeded.

## Legacy Compatibility

- Do not introduce records, sealed classes, pattern matching, newer collection factories, or framework APIs beyond the configured Java/framework version.
- Do not upgrade Java, Spring, Maven plugins, dependencies, packaging, or servlet namespace as part of an unrelated fix.
- Preserve profile filtering, XML bean wiring, WAR/container assumptions, and local JAR dependencies unless migration is explicitly requested.
- Treat strange branches as behavior to investigate, not cleanup opportunities.

## Review Priorities

Prioritize:

1. correctness, security, and observable compatibility
2. transaction, data, and failure semantics
3. framework/version compatibility
4. clear ownership and testability
5. maintainability and performance proportional to evidence

