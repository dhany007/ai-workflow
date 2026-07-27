---
name: production-readiness-audit
description: Audit whether an application or service is ready for staging handoff, production cutover, or stakeholder testing. Use when a task asks if a project is done, ready to deploy, ready for users, production-ready, safe to hand off, or needs final review across security, observability, performance, backup/restore, CI, deployment, migration, rollback, documentation, and accepted gaps.
---

# Production Readiness Audit

Use this skill to turn “it works locally” into a clear readiness decision.

## Readiness Areas

Check only areas relevant to the project, but do not silently ignore high-risk gaps.

1. Build and validation
   - tests;
   - lint/typecheck;
   - generated files;
   - reproducible local/staging commands.

2. Runtime health
   - health/readiness endpoints;
   - dependency checks;
   - graceful startup/shutdown;
   - resource limits where applicable.

3. Security
   - authentication and authorization;
   - secret handling;
   - public ports;
   - TLS/proxy assumptions;
   - CSRF/CORS/CSP/session/cookie behavior for web apps.

4. Data safety
   - migrations;
   - backups;
   - restore rehearsal;
   - reconciliation;
   - rollback/forward-fix plan.

5. Observability
   - structured logs;
   - error context;
   - metrics/tracing hooks if used;
   - privacy-safe logging;
   - operator troubleshooting commands.

6. Performance
   - smoke or baseline load;
   - known hot paths;
   - database indexes and query patterns;
   - capacity assumptions.

7. Operations
   - deployment runbook;
   - restart/update commands;
   - known gaps;
   - cutover warnings.

## Decision Labels

Use one of:

- `Ready for local/staging testing`
- `Ready for limited stakeholder testing`
- `Conditionally production-ready`
- `Not production-ready`

Avoid saying “production-ready” without listing validation evidence and remaining gates.

## Output

Prefer a concise scorecard:

- status;
- evidence checked;
- blockers;
- accepted risks;
- recommended next actions.

If writing a document, use an existing docs readiness or operations area when present.
