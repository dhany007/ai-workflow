---
name: env-config-management
description: Design, review, or troubleshoot environment configuration, YAML/TOML/JSON config files, .env files, secrets, runtime defaults, and startup validation. Use when a task involves DATABASE_URL, ports, service URLs, feature flags, staging/production config, secret hygiene, config examples, missing environment variables, config drift, or making a project easier to run across local/staging/production.
---

# Env Config Management

Use this skill when configuration is part of correctness, not just setup.

## Workflow

1. Inventory config sources.
   - environment variables;
   - config files;
   - command-line flags;
   - compose/Kubernetes/systemd values;
   - defaults in code.

2. Classify each setting.
   - required secret;
   - required non-secret;
   - optional with safe default;
   - derived/generated;
   - local-only/dev-only.

3. Check environment separation.
   - local;
   - test;
   - staging;
   - production.

   Avoid reusing development defaults for production-sensitive settings.

4. Validate startup behavior.
   - fail fast for missing required values;
   - produce actionable error messages;
   - avoid logging secret values;
   - expose safe config summaries only.

5. Update documentation and examples.
   - `.env.example` or sample YAML;
   - required variable table;
   - local run commands;
   - deployment/runbook references.

## Design Preferences

- Prefer explicit config structs or schemas over scattered `os.Getenv` calls.
- Keep secrets out of committed files, logs, screenshots, and test output.
- Use stable defaults for local development.
- Make ports and external URLs obvious and overrideable.
- Keep feature flags named by behavior, not by temporary project phase.

## Review Checklist

- Can a new developer run the project from documented examples?
- Does staging/prod require all secrets explicitly?
- Are default credentials clearly marked as local/staging only?
- Are generated sample configs excluded from git when appropriate?
- Do tests cover config parsing and validation for required values?

## Output

When handing off, list:

- required config;
- optional config;
- defaults;
- secret handling notes;
- commands or files changed;
- any unsafe or unknown settings.
