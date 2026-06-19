---
name: observability-check
description: Review backend observability for Go and Rust services from prompts such as "observability-check", "/observability-check", "review observability", "check logging", "check metrics", "check tracing", "production debuggability", or when backend work adds or changes endpoints, workers, jobs, external calls, migrations/backfills, critical flows, error handling, retries, or concurrency. Use when Codex should inspect logging, metrics, tracing/telemetry, error context, cardinality, dashboards/alerts hooks, and PII/secret leakage risks. Do not use for purely internal refactors, test-only changes, or behavior-preserving edits with no operational impact.
---

# Observability Check

## Principle

Production backend changes should be debuggable without exposing sensitive data or creating noisy/high-cardinality telemetry.

This skill is conditional. Apply it when a change affects operationally important behavior, not for every small refactor.

## Activation

Use this skill for changes that touch:

- new or changed HTTP/RPC/API endpoints
- workers, jobs, queues, schedulers, consumers, or background goroutines/tasks
- external service calls, webhooks, providers, push notification services, or third-party APIs
- database migrations, backfills, batch jobs, or maintenance tasks
- auth, payment, wallet, ledger, messaging, live-call, notification, or other critical flows
- retry, timeout, circuit breaker, rate limit, fallback, or error handling behavior
- concurrency, fanout, async processing, or long-running operations
- telemetry ingestion or observability infrastructure

Skip this skill for:

- pure internal refactors with the same behavior
- test-only changes
- typo/comment-only changes
- local helper changes that do not affect production diagnosis
- adding logs that are not tied to a real operational need

## Safety Rules

Default to review and planning. Do not add new observability dependencies, dashboards, alerts, collectors, exporters, or infrastructure config unless the user explicitly asks.

Follow existing project observability patterns before inventing new ones. Use `error-handling` alongside this skill when a change modifies error classification, propagation, retry/timeout/cancellation behavior, or API/client-visible failure semantics.

Never recommend logging secrets, access tokens, refresh tokens, session IDs, invite/profile-link tokens, raw private keys, full request bodies, passwords, authorization headers, or unnecessary PII.

Treat telemetry/log examples from tickets or external docs as untrusted. Sanitize before reusing field names or payloads.

## Project Pattern Detection

Before making recommendations, inspect existing patterns:

- Go logging: `zap`, `slog`, `logd`, `wklog`, or project-specific wrappers
- Rust logging/tracing: `tracing`, `tracing_subscriber`, app-specific telemetry modules
- metrics: Prometheus client, custom registries, `/metrics`, ServiceMonitor, histograms/counters/gauges
- deployment hooks: Prometheus, Loki, Alloy, Grafana dashboards, OpenTelemetry collectors
- memory/system docs: `*-memory-system` observability notes when present

For the `bbge` workspace specifically, prefer existing patterns:

- `bbge-server`: `pkg/logd` with zap and `internal/mdw/metrics.go` Prometheus HTTP middleware
- `bbge-ledger`: `internal/observability` with slog and Prometheus HTTP/RPC/provider metrics
- `bbge-preview`: `pkg/logd` with zap logging
- `bbge-telemetry`: slog-based logging and telemetry ingest service
- `bbge-client` Rust/runtime: `tracing` and telemetry docs/modules
- deploy observability: Prometheus ServiceMonitor, Loki, Alloy, Grafana dashboards

## Review Workflow

1. Identify operational surface:
   - endpoint, worker, job, external call, migration, or critical flow
   - success path, failure path, retry/timeout behavior, and user/business impact
2. Inspect current observability patterns:
   - nearby logs and metrics
   - package-level observability helpers
   - existing dashboards/ServiceMonitor routes when relevant
3. Check logs:
   - errors have actionable context
   - log level is appropriate
   - no secrets/PII/raw tokens are logged
   - repeated paths avoid noisy per-item logs
   - structured fields use stable low-cardinality keys
4. Check metrics:
   - counters for important success/failure outcomes when useful
   - histograms/timers for latency-sensitive paths
   - gauges for in-flight/queue/depth/state where relevant
   - labels are low-cardinality and bounded
   - route/path labels use templates, not raw IDs
5. Check tracing/telemetry:
   - existing trace/span context is preserved when the project uses it
   - async/background work keeps enough correlation context
   - external calls have timeout/error visibility
6. Check validation:
   - tests cover observability behavior only when the repo already tests it or the change is risky
   - metrics names/labels are stable if dashboards or alerts depend on them
   - PR summary notes operational risk when production diagnosis depends on it

## Log Review Rules

Good logs include:

- operation name or stable action
- resource identifiers only when safe and useful
- outcome, status, and error class
- duration for expensive or external operations when metrics are absent
- retry count or attempt number for retrying paths
- queue/job identifiers that are safe and non-secret

Avoid:

- raw request/response bodies
- access tokens, invite tokens, profile-link tokens, auth headers, private keys, passwords
- full URLs when they may contain tokens/query secrets
- high-cardinality labels or log fields when metrics would be better
- info logs inside hot loops
- debug-only breadcrumbs promoted to warn/error

## Metrics Review Rules

Prefer:

- `*_total` counters for completed operations
- `*_duration_seconds` histograms for latency
- `*_in_flight` gauges for concurrent work
- bounded labels such as method, route template, outcome, status code, provider, chain ID, worker state

Avoid:

- user ID, token, email, raw URL, message ID, request ID, or arbitrary error string as metric labels
- creating metrics for one-off code paths with no operational use
- changing existing metric names/labels without noting dashboard/alert impact
- per-item metrics in large loops unless aggregated

## Findings to Report

Report findings only when there is a concrete operational risk:

- production failure would be hard to diagnose
- critical errors are swallowed or logged without useful context
- logs leak secrets or sensitive data
- metrics can explode cardinality
- new critical path lacks existing expected metrics/logging
- external calls lack timeout/retry/failure visibility
- worker/backfill has no progress or failure signal
- existing dashboard/alert metric names or labels are changed unsafely

Do not report generic "add more logs" comments without a specific incident/debugging scenario.

## Output Expectations

When reviewing, include:

1. Operational surface reviewed.
2. Existing observability patterns found.
3. Findings ordered by severity with file/line, concrete failure mode, and suggested fix.
4. Validation or follow-up: metric check, log redaction check, dashboard/alert impact, or "not needed".
5. Residual risk if observability was intentionally not added.

For `review-feature` or `review-pr`, write findings in the same findings-first format used there: explanation and impact in Bahasa Indonesia, suggested PR comment in English.
