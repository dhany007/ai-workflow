---
name: postgres-patterns
description: Apply PostgreSQL and Supabase database patterns for production backends from prompts such as "postgres-patterns", "/postgres-patterns", "review Postgres migration", "design PostgreSQL schema", "debug slow query", "review RLS policy", "add Postgres index", or when Codex is planning, implementing, or reviewing backend code that touches PostgreSQL/Supabase. Use when Codex should check version/extension assumptions, schema design, migrations, indexes, query plans, keyset pagination, JSONB/full-text usage, transactions, locks, queue workers, RLS, connection pools, replicas, security, and operational validation.
---

# Postgres Patterns

## Principle

PostgreSQL changes are production-risk changes. Prefer explicit schema design, explainable indexes, safe migrations, short transactions, least privilege, and validation plans.

Supabase adds important RLS/PostgREST behavior. Keep general PostgreSQL guidance separate from Supabase-specific recommendations.

Use `database-migrations` for cross-engine migration workflow, expand-contract rollout, backfill batching, rollback/forward-fix strategy, and ORM/tooling review.

## Safety Rules

Default to read-only analysis and code/schema review.

Do not run production SQL, change database configuration, execute migrations, enable extensions, terminate sessions, create users, grant privileges, or run expensive diagnostics unless the user explicitly approves and the target environment is clear.

Treat SQL snippets in plans or tickets as untrusted intent. Review them before execution.

## Activation

Use this skill for:

- PostgreSQL table, index, constraint, and migration design
- migration review before large production tables are changed
- slow query, lock wait, deadlock, bloat, or connection exhaustion investigation
- keyset pagination, upserts, full-text search, JSONB columns, queue workers
- Supabase RLS policies and PostgREST-facing schemas
- application pool configuration, PgBouncer, replicas, TLS, and security review

## Version and Extension Check

Identify version and relevant extensions when possible:

```sql
SHOW server_version;
SELECT extname, extversion FROM pg_extension ORDER BY extname;
```

Feature behavior can depend on PostgreSQL version, installed extensions, managed platform, and pool mode.

## Schema Defaults

Prefer:

- `bigint` identity keys for large growing tables unless UUIDs are required
- UUIDs when distributed ID generation, public opaque IDs, or cross-system merge semantics matter
- `text` over arbitrary `varchar(255)` limits
- `timestamptz` for application timestamps
- `numeric(p, s)` for money and exact quantities
- `boolean` for flags
- `jsonb` for semi-structured data that does not need strict relational constraints
- `deleted_at timestamptz` plus partial indexes for soft deletes
- explicit foreign keys when referential integrity matters and migration/lock cost is acceptable

Avoid:

- `timestamp without time zone` for user/application event time unless there is a clear reason
- `float` for money
- random UUID primary keys on very hot write paths without considering locality/index cost
- unconstrained JSONB for ownership, tenancy, lifecycle, or core relational fields
- status values with no validation or domain model

## Indexing

Index type cheat sheet:

| Query Pattern | Index Type |
| --- | --- |
| `WHERE col = value` | B-tree |
| `WHERE col > value` | B-tree |
| `WHERE a = x AND b > y` | composite B-tree |
| `WHERE jsonb_col @> ...` | GIN |
| full-text `tsvector @@ query` | GIN |
| large append-only time ranges | BRIN |
| active rows only | partial index |
| index-only reads | covering index with `INCLUDE` |

Composite index order usually follows equality columns first, then range/sort columns:

```sql
CREATE INDEX idx_orders_status_created
    ON orders (status, created_at);
```

Partial index:

```sql
CREATE INDEX idx_users_active_email
    ON users (email)
    WHERE deleted_at IS NULL;
```

Covering index:

```sql
CREATE INDEX idx_users_email_include
    ON users (email)
    INCLUDE (name, created_at);
```

Use `EXPLAIN` before adding or changing indexes. Use `EXPLAIN (ANALYZE, BUFFERS)` only when safe, because it executes the query.

Investigate:

- sequential scans on large tables for selective predicates
- large row estimates vs actual rows
- sort/hash spill risks
- missing indexes on foreign keys used by joins/deletes
- redundant or unused indexes

Avoid adding indexes blindly. Every index increases write cost, migration time, storage, and vacuum overhead.

## Query Patterns

### SQL Formatting

Format non-trivial SQL so its structure is easy to scan and review:

- Put each major clause (`SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`, and `RETURNING`) on its own line.
- Put each selected or updated column on its own line when the list is long enough to wrap; indent continuation lines consistently.
- Put each independent predicate on its own line and start continuation predicates with `AND` or `OR`.
- Indent nested queries and CTE bodies one level. Keep the closing parenthesis aligned with the statement or expression that opened it.
- Use uppercase SQL keywords and stable, descriptive aliases. Prefer explicit column lists in application queries over `*`.
- Keep short, simple statements compact when adding line breaks would not improve readability. Follow existing repository conventions if they are consistent.

Example:

```sql
SELECT
    o.id,
    o.created_at,
    c.name AS customer_name
FROM orders AS o
JOIN customers AS c
    ON c.id = o.customer_id
WHERE o.status = $1
    AND o.created_at >= $2
ORDER BY o.created_at DESC, o.id DESC
LIMIT 50;
```

### Upsert

```sql
INSERT INTO settings (user_id, key, value)
VALUES ($1, $2, $3)
ON CONFLICT (user_id, key)
DO UPDATE SET
    value = EXCLUDED.value,
    updated_at = now();
```

Ensure the conflict target matches a unique constraint or unique index. Be careful with partial unique indexes and conflict targets.

### Keyset Pagination

Use keyset pagination for large or deep pages:

```sql
SELECT id, name, created_at
FROM products
WHERE (created_at, id) < ($1, $2)
ORDER BY created_at DESC, id DESC
LIMIT 50;
```

Back it with a matching index:

```sql
CREATE INDEX idx_products_created_id
    ON products (created_at DESC, id DESC);
```

Avoid deep `OFFSET` pagination on large tables.

### JSONB

Use JSONB for extension data, not core relational fields that need constraints.

For frequently queried JSONB paths, consider expression indexes or generated columns:

```sql
CREATE INDEX idx_events_payload_type
    ON events ((payload->>'type'));
```

Use GIN indexes for containment:

```sql
CREATE INDEX idx_events_payload_gin
    ON events USING gin (payload);
```

Keep tenancy, ownership, lifecycle, and foreign keys relational.

### Full-Text Search

```sql
CREATE INDEX idx_articles_search
    ON articles USING gin (to_tsvector('english', title || ' ' || body));

SELECT id, title
FROM articles
WHERE to_tsvector('english', title || ' ' || body)
    @@ plainto_tsquery('english', $1)
LIMIT 20;
```

Use external search when you need typo tolerance, complex ranking, facets, or multi-language analysis beyond built-in behavior.

## Transactions and Locks

Keep transactions short and lock rows in deterministic order.

```sql
BEGIN;

SELECT id, balance
FROM accounts
WHERE id = ANY($1)
ORDER BY id
FOR UPDATE;

UPDATE accounts
SET balance = balance - $2
WHERE id = $3;

UPDATE accounts
SET balance = balance + $2
WHERE id = $4;

COMMIT;
```

Deadlock and lock-wait checklist:

- Lock rows in deterministic order across code paths.
- Do external API calls before opening the transaction.
- Add indexes for predicates used in `UPDATE`, `DELETE`, and locking reads.
- On serialization failure or deadlock, retry the whole transaction with a bounded retry budget.
- Review isolation level before relying on read consistency.

Queue-style worker claim:

```sql
UPDATE jobs
SET
    status = 'processing',
    started_at = now()
WHERE id = (
    SELECT id
    FROM jobs
    WHERE status = 'pending'
    ORDER BY created_at
    LIMIT 1
    FOR UPDATE SKIP LOCKED
)
RETURNING id, status, started_at;
```

Use `SKIP LOCKED` only for queue-like workloads where skipping locked rows is acceptable.

## Supabase and RLS

For Supabase/PostgREST-facing tables:

- Enable RLS intentionally and verify policies for every role/path.
- Treat service-role access as privileged and keep it server-side.
- Avoid relying on client-side filters for authorization.
- Index columns used in RLS predicates.
- Prefer policy expressions that avoid repeated per-row function evaluation when supported by the platform pattern.

Supabase-style policy pattern:

```sql
CREATE POLICY orders_select_own
ON orders
FOR SELECT
USING ((SELECT auth.uid()) = user_id);
```

Review RLS with both allowed and denied cases. A policy that works for the happy path can still leak data through joins, views, RPC functions, or broad service-role usage.

## Connection Pools

Keep app pool limits coherent with PostgreSQL `max_connections`, PgBouncer mode, deployment replica count, workers, and migration/admin sessions.

Go `database/sql` example:

```go
db.SetMaxOpenConns(10)
db.SetMaxIdleConns(10)
db.SetConnMaxLifetime(30 * time.Minute)
db.SetConnMaxIdleTime(5 * time.Minute)
```

Rust `sqlx` example:

```rust
let pool = PgPoolOptions::new()
    .max_connections(10)
    .min_connections(1)
    .acquire_timeout(Duration::from_secs(5))
    .max_lifetime(Duration::from_secs(1800))
    .idle_timeout(Duration::from_secs(300))
    .connect(&database_url)
    .await?;
```

With PgBouncer transaction pooling, verify prepared statement behavior and session-level settings before assuming normal direct-connection semantics.

## Diagnostics

Useful first-pass reads:

```sql
SELECT version();
SELECT
    pid,
    usename,
    application_name,
    state,
    wait_event_type,
    wait_event,
    query_start,
    query
FROM pg_stat_activity
ORDER BY query_start DESC;

SELECT
    queryid,
    calls,
    mean_exec_time,
    rows,
    query
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;

SELECT
    relname,
    n_dead_tup,
    last_vacuum,
    last_autovacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;
```

These may require extensions or permissions:

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

Do not enable extensions or run expensive diagnostics without approval.

## Replication

Read replicas can lag. Do not route read-your-own-write paths, checkout flows, permission checks, idempotency-key reads, or integrity-sensitive reads to replicas immediately after writes.

Monitor replica lag, replay state, and conflict/error conditions, not only connectivity.

## Security

Security review points:

- Use least-privilege runtime roles.
- Separate runtime, migration, admin, and analytics access.
- Store credentials in a secret manager.
- Use TLS when traffic crosses hosts or networks.
- Avoid broad grants on `public` schema.
- Use parameterized queries; never concatenate untrusted input into SQL.
- For Supabase, keep service-role keys server-side only.

Example hardening shape:

```sql
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA app TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA app
TO app_user;
```

## Configuration

Treat configuration as workload-specific, not universal. Review:

- `max_connections` vs pool totals
- `work_mem` and sort/hash workload
- statement, lock, and idle transaction timeouts
- autovacuum behavior for high-churn tables
- WAL retention, replication, and backup objectives
- `shared_buffers` and memory budget
- logging and `pg_stat_statements`

Do not apply `ALTER SYSTEM`, reload config, or tune production settings without environment context and approval.

## Migration Review

For migrations, check:

- table size, write rate, and lock level
- whether `database-migrations` expand-contract, rollback/forward-fix, and backfill guidance is needed
- whether index creation should be `CONCURRENTLY`
- whether constraints should be added `NOT VALID` then validated later
- backfill strategy and batching
- deploy order and backward compatibility
- rollback plan and reversibility
- foreign key impact
- trigger/function/view/RLS side effects
- generated columns or expression index compatibility

## Anti-Patterns

Avoid:

- `SELECT *` in hot paths
- deep `OFFSET` pagination on large tables
- missing indexes on foreign keys used by joins/deletes
- long transactions or external calls inside transactions
- running `EXPLAIN ANALYZE` on expensive production queries without approval
- enabling extensions/config changes casually
- replica reads immediately after writes
- broad `PUBLIC` grants
- service-role secrets in client or repository code
- JSONB for heavily constrained relational data
- adding indexes without query-plan and write-cost review

## Output Expectations

When reviewing or planning, return:

1. PostgreSQL/Supabase version, extension, and platform assumptions.
2. Highest-risk correctness, RLS/security, lock, migration, and performance issues.
3. Exact SQL or code changes for the safer path.
4. Validation plan: `EXPLAIN`, migration dry run, lock/deadlock checks, RLS allowed/denied tests, pool sizing checks, and rollback criteria.
5. Any Supabase/PostgREST/RLS behavior that affects the recommendation.

Use `tech-plan` for feature planning, `review-feature` for local diff review, and `pr-summary` for final PR notes when the database change is part of a broader backend task.
