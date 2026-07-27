---
name: data-reconciliation
description: Compare source and target data for migrations, backfills, imports, exports, rewrites, ETL jobs, or synchronization. Use when a task involves source-to-target validation, row counts, grouped totals, money/status reconciliation, reject reports, checksum comparisons, dry-run migration output, historical backfill confidence, or proving that migrated data matches legacy/source data.
---

# Data Reconciliation

Use this skill when “the job ran” is not enough; the question is whether the data is correct.

## Reconciliation Layers

Apply the deepest layer that is practical:

1. Inventory
   - source tables/files/endpoints;
   - target tables/files/endpoints;
   - filters, date ranges, tenants, statuses.

2. Counts
   - total rows;
   - grouped by status/type/date/tenant/domain key;
   - inserted/skipped/rejected counts.

3. Identity mapping
   - source primary keys to target IDs;
   - natural keys;
   - missing or duplicate records.

4. Money and quantities
   - sums by currency/account/status/date;
   - debit/credit balance;
   - rounding rules;
   - zero/null treatment.

5. Field-level sampling
   - deterministic sample IDs;
   - edge cases;
   - rejected rows with reasons.

6. Presentation parity, if relevant
   - report totals;
   - pagination;
   - date filters;
   - export layout or operator-visible values.

## Dry-Run Report Shape

Prefer a report with:

- source scope;
- target scope;
- counts by domain/status;
- rejected rows and reasons;
- warnings for lossy mappings;
- money/quantity totals;
- unresolved decisions.

## Safety Rules

- Never mark reconciliation complete from counts alone when money, balances, or reports are involved.
- Do not mutate source data unless the user explicitly authorizes a local-only adjustment.
- Keep raw credentials and personal data out of committed reports.
- If production snapshots are unavailable, label the result as local/sample confidence only.

## Output

When reporting results, separate:

- matched;
- mismatched;
- skipped by policy;
- rejected as invalid;
- unknown due to missing source evidence.
