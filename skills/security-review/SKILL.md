---
name: security-review
description: Review application security risks and mitigations from prompts such as "security-review", "/security-review", "review security", "auth review", "authorization review", "XSS", "CSRF", "injection", "secrets", "session security", "token handling", "input validation", "dependency risk", "secure headers", "CSP", "file upload security", or when Codex is planning, implementing, testing, or reviewing changes that touch authentication, authorization, tenant boundaries, user input, HTML rendering, API exposure, storage, encryption, secrets, sessions, cookies, redirects, webhooks, third-party integrations, file handling, logging, or sensitive data. Use when Codex should identify concrete exploit paths, prioritize risk, suggest minimal mitigations, and request expert review for high-impact security decisions.
---

# Security Review

Use this skill to review code and plans for practical application security risks. Be concrete: name the attacker capability, affected asset, exploit path, impact, and mitigation. Do not present security review as a guarantee.

Primary references when current behavior is uncertain:

- OWASP Cheat Sheet Series - https://owasp.org/www-project-cheat-sheets/
- OWASP Top Ten - https://owasp.org/www-project-top-ten/

## Scope First

Before reviewing or changing code, identify:

- Trust boundaries: browser, API, worker, database, storage, queue, webhook, third-party service, admin surface, tenant boundary.
- Sensitive assets: credentials, tokens, PII, payment data, internal IDs, authorization state, audit logs, secrets, and privileged actions.
- Entry points: request bodies, query params, headers, cookies, uploads, redirects, HTML/Markdown rendering, webhooks, environment variables, and background jobs.
- Existing security controls: auth middleware, RBAC/ABAC policy checks, CSRF protection, CSP, validation schemas, RLS, audit logging, rate limiting, and secret management.

When the change touches high-impact auth, crypto, payments, production secrets, or compliance-sensitive data, recommend human security review in addition to code fixes.

## Review Checklist

### Authentication And Sessions

- Verify that login, logout, refresh, password reset, magic links, OAuth callbacks, and MFA flows bind tokens to the intended user and lifecycle.
- Check cookie flags: `HttpOnly`, `Secure`, `SameSite`, domain/path scope, and expiration.
- Avoid storing long-lived secrets in browser-accessible storage unless the architecture explicitly accepts that risk.
- Ensure logout and account changes invalidate relevant sessions or tokens when required.

### Authorization And Tenant Boundaries

- Check authorization at the server-side action or data access boundary, not only in UI.
- Verify object ownership, tenant IDs, role checks, admin checks, and row-level policies.
- Watch for IDOR: user-controlled IDs that access objects without ownership checks.
- Ensure list, search, export, and bulk operations enforce the same policy as single-object reads.

### Input, Output, And Injection

- Validate and normalize untrusted input at boundaries.
- Use parameterized queries or ORM-safe APIs; avoid string-built SQL, shell commands, and template injection.
- Escape or sanitize user-controlled HTML/Markdown. Treat rich text rendering as a security-sensitive feature.
- Avoid unsafe URL redirects; restrict redirect targets or resolve them relative to known origins.

### Browser And Frontend Security

- Review XSS risks in `dangerouslySetInnerHTML`, HTML parsers, Markdown renderers, script injection, URL construction, and third-party widgets.
- Use CSRF protection where cookie-authenticated state-changing requests are possible.
- Keep secrets out of frontend bundles, logs, source maps, and public environment variables.
- Review CSP, security headers, iframe embedding, and cross-origin messaging when changed.

### Secrets And Sensitive Data

- Do not print tokens, passwords, API keys, session IDs, auth headers, private URLs, or sensitive payloads in logs or errors.
- Check config defaults and examples for accidental real secrets.
- Keep secrets in approved secret stores or environment mechanisms, not source files.
- Minimize sensitive data in client state, analytics, telemetry, and crash reports.

### Files, Webhooks, And Integrations

- Validate file type, size, storage path, scanning expectations, and public/private access.
- Prevent path traversal and unsafe archive extraction.
- Verify webhook signatures, timestamps, replay windows, idempotency, and failure behavior.
- Treat third-party callbacks and metadata as untrusted input.

## Mitigation Style

- Prefer small, local mitigations that fit existing security architecture.
- Add regression tests for concrete exploit paths when practical.
- Use `api-contract-review` when security changes alter API status codes, error bodies, auth behavior, or client-visible contracts.
- Use `error-handling` when failure paths could leak details, hide auth failures, or create false success.
- Use database skills when authorization depends on RLS, queries, transactions, or migrations.

## Anti-Patterns

- Relying on hidden UI controls as authorization.
- Trusting IDs, roles, tenant IDs, prices, or ownership fields from the client.
- Logging sensitive payloads to debug a failure.
- Adding broad CORS, CSP, or cookie relaxations to make a local flow work.
- Swallowing auth failures and returning default data.
- Using security terms without a concrete exploit path.

## Review Guidance

Lead findings with exploitable behavior and impact. Include file/line references when reviewing code, explain the smallest mitigation, and distinguish confirmed issues from hardening suggestions or assumptions.
