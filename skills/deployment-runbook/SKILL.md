---
name: deployment-runbook
description: Create, review, or update deployment runbooks for local, staging, or production handoff. Use when a task asks for deploy steps, server setup, Docker or process startup instructions, environment preparation, smoke tests, rollback, restart, backup/restore pointers, troubleshooting, release handoff, or new-developer operational documentation.
---

# Deployment Runbook

Use this skill when the deliverable is a human-followable operational guide, not just working code.

## Runbook Structure

Keep the runbook concrete and copy-paste friendly:

1. Scope
   - environment covered;
   - services included;
   - what is intentionally not covered.

2. Prerequisites
   - OS/runtime/tool versions;
   - required ports;
   - required credentials or secrets by name, not value;
   - repository access assumptions.

3. First-time setup
   - clone/pull commands;
   - dependency installation;
   - configuration files or environment variables;
   - database bootstrap/migrations/seeds.

4. Start or deploy
   - exact commands;
   - expected service names;
   - expected URLs.

5. Validation
   - health/readiness checks;
   - frontend smoke checks;
   - admin/member or role-specific smoke checks;
   - logs to inspect if validation fails.

6. Restart and update
   - safe pull/rebuild/restart flow;
   - commands that preserve data.

7. Rollback
   - previous image/commit/version strategy;
   - database rollback or forward-fix policy;
   - smoke checks after rollback.

8. Troubleshooting
   - common symptoms;
   - likely causes;
   - commands to gather evidence.

## Review Checklist

- A new developer can follow it without private chat history.
- Commands use the repository's actual scripts where possible.
- Ports and URLs match compose/config defaults.
- Secrets are referenced safely.
- Rollback and validation are explicit.
- Dangerous commands are labelled.

## Output

If creating a file, prefer a clear docs path such as `docs/operations/...` or `docs/deployment/...`.

In the final response, include:

- runbook path;
- most important commands;
- validation performed;
- any manual server/cloud steps the runbook cannot execute.
