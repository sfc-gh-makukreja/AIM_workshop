# Lab 06 — Deploy objects to Snowflake

**Time:** 30 min
**Goal:** get every object into Snowflake, and work one real deploy-fix loop.

---

## 6.1 Claim your work

> what should I work on next?

The agent lists task groups by object type. Pick claiming first if prompted —
**claiming** assigns objects to you and is what keeps a multi-engineer migration
from colliding. Claim everything; you are working solo today.

## 6.2 Deploy in dependency order

Deploy in this order. The agent enforces it via registry dependencies — a view
whose tables are not deployed shows as **blocked**, not failed.

1. Database and schemas
2. Tables (11)
3. View (1) — expect trouble, see 6.3
4. Function (1)
5. Procedure (1)

The ETL package also deploys, but it needs its own stabilization pass — leave it
for Lab 07.

Drive it with:

> deploy the tables to Snowflake

Then continue through each group. A successful run reports 18 objects deployed
and one failure (the view).

Verify as you go:

```sql
-- In Snowsight
SHOW TABLES IN SCHEMA TASTYBYTESDB.TASTYBYTES;
SELECT COUNT(*) FROM TASTYBYTESDB.TASTYBYTES.CUSTOMER;   -- 0 rows, expected
```

> **Empty tables are the correct outcome.** Structure migrates today; data does
> not. Zero rows is not a failure.

If the database object itself errors with "already exists", that is fine —
`setup.sql` created it in Lab 00.3. Tell the agent to treat it as deployed and
move on.

## 6.3 The deploy-fix loop — `vw_TopSellingItems`

The view will fail. It still carries the unresolved EWI from Lab 03.3:

```
SSC-EWI-0040 - THE 'TOP PERCENT' CLAUSE IS NOT SUPPORTED IN SNOWFLAKE
```

Snowflake reports it as:

```
SQL compilation error: syntax error line 11 at position 24 unexpected '!'.
```

That `unexpected '!'` is the `!!!RESOLVE EWI!!!` tombstone — not valid SQL, by
design.

Ask the agent:

> the view failed to deploy. diagnose it and fix it

This invokes `fixCode`. Expect the agent to:

1. Read the error and locate the EWI.
2. Explain that `TOP 1 PERCENT` means "the top 1% of rows by the ORDER BY",
   which Snowflake has no direct syntax for.
3. Propose `QUALIFY ROW_NUMBER() OVER (ORDER BY ...) <= CEIL(COUNT(*) * 0.01)`
   or an equivalent windowed rewrite.
4. Apply it, redeploy, and stamp the registry.

**Read the proposed fix before accepting it.** Two things to check:

- The `ORDER BY` inside each branch differs — one ranks by quantity, one by
  revenue. A rewrite that collapses them is wrong.
- `TOP 1 PERCENT` of a small table rounds to 1 row in SQL Server. Confirm the
  rewrite's rounding matches.

Then:

```sql
SELECT * FROM TASTYBYTESDB.TASTYBYTES.VW_TOPSELLINGITEMS;   -- 0 rows, compiles
```

Zero rows because the base tables are empty. What you have proven is that it
**compiles and is semantically defensible** — which is exactly as far as you can
get without data, and is worth being precise about with a customer.

> **The talking point:** the tool converted ~95% deterministically and stopped
> at the one construct that encodes a business decision. It did not guess. That
> combination — bulk automation plus explicit escalation — is what makes the
> output reviewable.

## 6.4 If `captureBaseline` blocks the procedure or function

After deploying `sp_UpdateInventory` or `fn_FormatCustomerName`, the walk may
try to capture a test baseline from the source. There is no source, and unlike
the other test tasks this one is **locked** and cannot be disabled (see Lab 5.4).

Ask the agent:

> bypass captureBaseline for this object, reason: workshop has no source database

The agent runs:

```
transition_status(status="bypass", task="captureBaseline",
                  where="id IN ('<object_id>')",
                  reason="workshop: no source database")
```

Note what a bypass is and is not. It is **logged**, **reversible**, and reported
downstream as a bypass — never as a satisfied precondition. Anyone reading the
migration record later sees that a baseline was skipped and why. That is the
difference between a governed exception and quietly editing a status field, and
it is the behaviour you want when a customer's auditor asks.

## 6.5 Finish and merge

Once everything is deployed:

> finish the objects I've completed

This merges your claimed work back to `main`. Leaving finished objects unmerged
keeps your branch ahead and forces teammates to rebase against stale state.

## 6.6 Checkpoint

> what is the current state of the migration?

Expect: all tables, the view, the function and the procedure deployed; **no**
pending data-migration or test groups.

In Snowsight:

```sql
SELECT table_type, COUNT(*)
FROM TASTYBYTESDB.INFORMATION_SCHEMA.TABLES
WHERE table_schema IN ('TASTYBYTES','ETL_RESULTS')
GROUP BY table_type;

SHOW VIEWS IN SCHEMA TASTYBYTESDB.TASTYBYTES;
SHOW USER FUNCTIONS IN SCHEMA TASTYBYTESDB.TASTYBYTES;
SHOW PROCEDURES IN SCHEMA TASTYBYTESDB.TASTYBYTES;
```

---

**Next:** [07-ssis-to-dbt.md](07-ssis-to-dbt.md)
