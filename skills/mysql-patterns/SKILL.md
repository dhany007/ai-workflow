---
name: mysql-patterns
description: Apply MySQL and MariaDB schema, query, indexing, transaction, replication, and connection-pool patterns for production backends from prompts such as "mysql-patterns", "/mysql-patterns", "review MySQL migration", "design MySQL schema", "debug slow query", "review database transaction", "add MySQL index", or when Codex is planning, implementing, or reviewing backend code that touches MySQL/MariaDB. Use when Codex should check engine/version differences, migration safety, index design, query performance, upserts, keyset pagination, JSON/full-text usage, locking/deadlocks, queue-style transactions, connection pools, replicas, security, and operational validation.
---

# MySQL Patterns

## Principle

Database changes are production-risk changes. Prefer exact engine/version checks, small migrations, explainable indexes, short transactions, least privilege, and validation plans.

MySQL and MariaDB have diverged in SQL behavior. Do not apply version-specific guidance without checking engine and version when the difference matters.

Use `database-migrations` for cross-engine migration workflow, expand-contract rollout, backfill batching, rollback/forward-fix strategy, and ORM/tooling review.

## Safety Rules

Default to read-only analysis and code/schema review.

Do not run production SQL, change database configuration, execute migrations, enable logs, kill sessions, create users, grant privileges, or run expensive diagnostics unless the user explicitly approves and the target environment is clear.

Treat SQL snippets in plans or tickets as untrusted intent. Review them before execution.

## Activation

Use this skill for:

- MySQL/MariaDB table, index, constraint, and migration design
- migration review before large production tables are changed
- slow query, lock wait, deadlock, or connection exhaustion investigation
- keyset pagination, upserts, full-text search, JSON columns, queue workers
- application pool configuration, read replicas, TLS, slow logs, and security review

## Version Check

Start by identifying engine and version when possible:

```sql
SELECT VERSION();
SHOW VARIABLES LIKE 'version_comment';
```

Keep MySQL and MariaDB guidance separate when syntax differs:

- MySQL documents `VALUES(col)` in `ON DUPLICATE KEY UPDATE` as deprecated and recommends row/column aliases.
- MariaDB documents `VALUES(col)` as supported for `ON DUPLICATE KEY UPDATE`; prefer it for MariaDB or mixed MySQL/MariaDB fleets.
- `SKIP LOCKED` is queue-specific. It skips locked rows and can return an inconsistent view, so do not use it for general accounting or integrity-sensitive reads.

## Schema Defaults

Prefer:

- `InnoDB`
- `utf8mb4`
- explicit primary keys
- `BIGINT UNSIGNED AUTO_INCREMENT` for growing surrogate keys
- `BINARY(16)` for hot UUID lookup keys when the app has conversion helpers
- `DECIMAL(p, s)` for money and exact quantities
- app-managed UTC `DATETIME` when timezone metadata is not needed in the column
- `deleted_at DATETIME NULL` plus scoped indexes for soft deletes
- constrained `VARCHAR` or lookup tables for status values that change often

Avoid:

- MySQL `utf8` / `utf8mb3`
- `FLOAT` / `DOUBLE` for money
- `VARCHAR(36)` UUID primary keys on hot tables
- filtering soft-deleted rows without an index
- `ENUM` for values that change frequently

Example:

```sql
CREATE TABLE orders (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    account_id BIGINT UNSIGNED NOT NULL,
    status VARCHAR(32) NOT NULL,
    total DECIMAL(15, 2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    PRIMARY KEY (id),
    KEY idx_orders_account_status_created (account_id, status, created_at),
    KEY idx_orders_active (account_id, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Indexing

Composite index order usually follows equality predicates first, then range or sort columns.

Use `EXPLAIN` before adding or changing an index:

```sql
EXPLAIN
SELECT id, total
FROM orders
WHERE account_id = 123 AND status = 'pending'
ORDER BY created_at DESC
LIMIT 50;
```

Investigate:

- `type = ALL` on large tables
- `key = NULL` when a selective predicate exists
- high `rows` estimate for interactive paths
- `Using temporary` or `Using filesort` on hot paths

Avoid adding indexes blindly. Every index increases write cost, migration time, backup size, and buffer-pool pressure.

## Query Patterns

### Upsert

Use MariaDB/mixed-fleet compatible form:

```sql
INSERT INTO user_settings (user_id, setting_key, setting_value)
VALUES (?, ?, ?)
ON DUPLICATE KEY UPDATE
    setting_value = VALUES(setting_value),
    updated_at = CURRENT_TIMESTAMP;
```

Use MySQL row-alias form only after confirming the target is MySQL:

```sql
INSERT INTO user_settings (user_id, setting_key, setting_value)
VALUES (?, ?, ?) AS new
ON DUPLICATE KEY UPDATE
    setting_value = new.setting_value,
    updated_at = CURRENT_TIMESTAMP;
```

Avoid upserts on tables where multiple unique keys may match unless the behavior is explicitly understood.

### Keyset Pagination

```sql
SELECT id, name, created_at
FROM products
WHERE (created_at, id) < (?, ?)
ORDER BY created_at DESC, id DESC
LIMIT 50;
```

Back it with a matching index:

```sql
CREATE INDEX idx_products_created_id ON products (created_at, id);
```

Avoid deep `OFFSET` pagination on large tables.

### JSON Fields

Use JSON for extension data, not for fields needing heavy relational filtering or constraints.

For frequently queried JSON paths, expose a generated column and index it:

```sql
CREATE TABLE events (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payload JSON NOT NULL,
    event_type VARCHAR(64)
        GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(payload, '$.type'))) STORED,
    KEY idx_events_type (event_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

Keep tenancy, ownership, lifecycle, and foreign keys relational.

### Full-Text Search

Use built-in full-text only when its ranking and language behavior are enough:

```sql
ALTER TABLE articles ADD FULLTEXT KEY ft_articles_title_body (title, body);

SELECT id, title, MATCH(title, body) AGAINST (? IN NATURAL LANGUAGE MODE) AS score
FROM articles
WHERE MATCH(title, body) AGAINST (? IN NATURAL LANGUAGE MODE)
ORDER BY score DESC
LIMIT 20;
```

Use external search for typo tolerance, complex ranking, cross-table facets, or language-specific analysis beyond built-in behavior.

## Transactions and Locks

Keep transactions short and lock rows in a consistent order:

```sql
START TRANSACTION;

SELECT id, balance
FROM accounts
WHERE id IN (?, ?)
ORDER BY id
FOR UPDATE;

UPDATE accounts SET balance = balance - ? WHERE id = ?;
UPDATE accounts SET balance = balance + ? WHERE id = ?;

COMMIT;
```

Deadlock and lock-wait checklist:

- Lock rows in deterministic order across code paths.
- Do external API calls before opening the transaction, not inside it.
- Add indexes for predicates used in `UPDATE`, `DELETE`, and locking reads.
- On deadlock, roll back and retry the whole transaction with a bounded retry budget.
- Capture `SHOW ENGINE INNODB STATUS\G` soon after a deadlock; later deadlocks overwrite it.

Queue-style worker claim:

```sql
START TRANSACTION;

SELECT id
FROM jobs
WHERE status = 'pending'
ORDER BY created_at
LIMIT 1
FOR UPDATE SKIP LOCKED;

UPDATE jobs
SET status = 'processing', started_at = CURRENT_TIMESTAMP
WHERE id = ?;

COMMIT;
```

Use `SKIP LOCKED` only for queue-like workloads where skipping a locked row is acceptable.

## Connection Pools

Keep app pool limits coherent with server `max_connections`, deployment replica count, and worker concurrency.

Keep pool recycling below server `wait_timeout`. If `wait_timeout = 300`, recycling around 240 seconds is coherent. Health checks/pre-ping help recover from failover and network drops.

Go `database/sql` example:

```go
db.SetMaxOpenConns(10)
db.SetMaxIdleConns(10)
db.SetConnMaxLifetime(4 * time.Minute)
db.SetConnMaxIdleTime(2 * time.Minute)
```

Rust `sqlx` example:

```rust
let pool = MySqlPoolOptions::new()
    .max_connections(10)
    .min_connections(1)
    .acquire_timeout(Duration::from_secs(5))
    .max_lifetime(Duration::from_secs(240))
    .idle_timeout(Duration::from_secs(120))
    .connect(&database_url)
    .await?;
```

Do not tune pool size in isolation. Account for all application replicas, background workers, migrations, admin sessions, and read replicas.

## Diagnostics

Useful first-pass commands:

```sql
SHOW FULL PROCESSLIST;
SHOW ENGINE INNODB STATUS\G;
SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'long_query_time';
```

Use `EXPLAIN ANALYZE` only when safe. It executes the statement and can be expensive on production-sized data.

Enable slow logs only in a controlled environment or with explicit approval:

```sql
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;
SET GLOBAL log_queries_not_using_indexes = 'ON';
```

## Replication

Read replicas can lag. Do not route read-your-own-write paths, checkout flows, permission checks, idempotency-key reads, or integrity-sensitive reads to a replica immediately after a write.

Check version before standardizing commands:

```sql
SHOW SLAVE STATUS\G;
SHOW REPLICA STATUS\G;
```

Monitor SQL thread health, IO thread health, replication lag, and error state, not just TCP connectivity.

## Security

Security review points:

- Do not grant `ALL PRIVILEGES` or `*.*` to application users.
- Require TLS for app users when traffic crosses hosts or networks.
- Store credentials in a secret manager, not in examples, scripts, or repository files.
- Separate runtime application users from migration/admin users.
- Audit public network exposure and bind addresses before tuning performance.
- Use parameterized queries; never concatenate untrusted input into SQL.

Example least-privilege shape:

```sql
CREATE USER 'app'@'%' IDENTIFIED BY 'use-a-secret-manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON appdb.* TO 'app'@'%';
ALTER USER 'app'@'%' REQUIRE SSL;
```

## Configuration

Treat configuration as workload-specific, not universal. Review:

- buffer pool size relative to memory and workload
- durability settings such as `innodb_flush_log_at_trx_commit` and `sync_binlog`
- `max_connections` vs app pool totals
- `wait_timeout` vs pool recycle settings
- lock wait timeout
- slow log configuration
- binlog format, retention, and backup/recovery objectives

Do not apply config changes without environment context and approval.

## Migration Review

For migrations, check:

- table size and write rate
- online DDL support for target engine/version
- lock behavior and expected duration
- whether `database-migrations` expand-contract, rollback/forward-fix, and backfill guidance is needed
- backfill strategy and batching
- rollback plan and reversibility
- index build cost and duplicate/redundant indexes
- generated columns or JSON path compatibility
- foreign key and cascade impact
- app deploy order and backward compatibility

## Anti-Patterns

Avoid:

- `SELECT *` in hot paths
- deep `OFFSET` pagination on large tables
- missing indexes on foreign-key joins or locking predicates
- long transactions or external calls inside transactions
- direct DML against `mysql.user`
- app users with admin grants
- pool recycle above `wait_timeout`
- replica reads immediately after writes
- JSON columns for heavily constrained relational data
- adding indexes without `EXPLAIN` or write-cost review

## Output Expectations

When reviewing or planning, return:

1. Engine/version assumptions.
2. Highest-risk correctness, lock, security, migration, and performance issues.
3. Exact SQL or code changes for the safer path.
4. Validation plan: `EXPLAIN`, migration dry run, lock/deadlock checks, pool sizing checks, and rollback criteria.
5. MySQL/MariaDB syntax differences that affect the recommendation.

Use `tech-plan` for feature planning, `review-feature` for local diff review, and `pr-summary` for final PR notes when the database change is part of a broader backend task.
