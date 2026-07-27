---
name: docker-compose-ops
description: Operate and troubleshoot Docker Compose local, staging, or lightweight production-like stacks. Use when a task involves docker compose or docker-compose commands, Dockerfile or compose.yml review, container healthchecks, logs, rebuilds, service dependencies, port conflicts, volumes, database/cache containers, Compose v1/v2 compatibility, or helping a developer run a project through Docker.
---

# Docker Compose Ops

Use this skill when the question is “can this stack run, restart, rebuild, or be debugged through Docker Compose?”

## Workflow

1. Identify the compose entrypoint.
   - Prefer repository scripts or Makefile targets when present.
   - Detect whether the environment has `docker compose` v2 or `docker-compose` v1.
   - If Compose v1 is required, check for v2-only fields such as top-level `name:`.

2. Inspect before changing.
   - Read compose files, Dockerfiles, env examples, and startup scripts.
   - Check service names, ports, healthchecks, volumes, build contexts, and dependencies.
   - Preserve existing project conventions.

3. Bring up narrowly.
   - Start only needed services when possible.
   - Rebuild only changed services unless a clean build is required.
   - Avoid deleting volumes unless the user explicitly approves or the data is clearly disposable.

4. Debug from outside in.
   - `ps` or status first.
   - Healthcheck result next.
   - Logs for failing services.
   - Exec into containers only when logs/config are insufficient.

5. Validate with smoke checks.
   - Use HTTP health/readiness endpoints when available.
   - Verify app-to-database/cache connectivity.
   - Report exact URLs, ports, and commands that passed.

## Common Checks

- Compose command available: `docker compose version` or `docker-compose version`.
- Service status: `docker compose ps`.
- Logs: `docker compose logs --tail=200 <service>`.
- Rebuild one service: `docker compose build <service>`.
- Restart one service: `docker compose up -d <service>`.
- Effective config: `docker compose config`.

Adjust the command spelling to the installed Compose variant.

## Safety Rules

- Do not run destructive volume/database resets without explicit approval.
- Do not expose database/admin ports publicly unless the user asked and the risk is stated.
- Keep secrets out of command output and documentation.
- Treat generated compatibility files as local artifacts unless the user wants them committed.

## Output

When handing off, include:

- compose command variant used;
- services started or changed;
- URLs/ports to test;
- validation commands and results;
- remaining blockers or risky assumptions.
