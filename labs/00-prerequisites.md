# Lab 00 — Prerequisites and orientation

**Time:** 15 min (mostly done before the workshop)
**Goal:** confirm your machine and your Snowflake account are ready, and
understand what you are about to migrate.

---

## 0.1 Confirm your tooling

Run each of these. The first three must succeed.

```bash
scai --version          # SnowConvert AI CLI
snow --version          # Snowflake CLI
git --version
dbt --version           # OPTIONAL — only for the local loop in Lab 07.6
```

`dbt` is not required. The SSIS package deploys to Snowflake as a native
`DBT PROJECT` object and runs with `EXECUTE DBT PROJECT`, using Snowflake's own
dbt runtime.

You also need **Cortex Code** (desktop or CLI) with the `snowflake-migration`
plugin available. Verify by asking the agent:

> what migration skills do you have?

It should mention the migration skill and its sub-skills (setup, convert,
assessment, migrate-objects).

If any of the required three fails, see [../PREREQS.md](../PREREQS.md).

## 0.2 Confirm your Snowflake connection

```bash
snow connection list
snow sql -q "SELECT CURRENT_ACCOUNT(), CURRENT_ROLE()"
```

You need a connection whose role can reach `ACCOUNTADMIN`. On a trial account
your default user has it.

Note the **connection name** — you will give it to the agent in Lab 05.

Also make sure the connection has a **default database and schema**, or export
them; Lab 07's ETL deploy needs a current schema:

```bash
export SNOWFLAKE_DATABASE=TASTYBYTESDB
export SNOWFLAKE_SCHEMA=TASTYBYTES
```

## 0.3 Create the Snowflake target

Open [../snowflake/setup.sql](../snowflake/setup.sql) in a Snowsight worksheet
and run it. It creates `TASTYBYTESDB` (schemas `TASTYBYTES`, `ETL_RESULTS`) and
the `XSMALL_WH` warehouse.

The final `SELECT` should echo your account, `ACCOUNTADMIN`, `TASTYBYTESDB`,
`XSMALL_WH`.

> The schemas are empty on purpose. Everything inside them is created by *you*,
> during Lab 06, by deploying converted code.

## 0.4 What you are migrating

**TastyBytes** is a fictional global food-truck network on SQL Server:
localized menus, customer loyalty, order management, inventory, employee
scheduling.

| What | Count | Where |
|---|---|---|
| Database | 1 | `source_db/database/` |
| Schemas | 3 (`TastyBytes`, `etl_results`, `dbo`) | `source_db/tastybytesdb/schema/` |
| Tables | 11 | `source_db/tastybytesdb/*/table/` |
| Views | 1 | `.../view/vw_topsellingitems.sql` |
| Functions | 1 | `.../function/fn_formatcustomername.sql` |
| Procedures | 1 | `.../procedure/sp_updateinventory.sql` |
| SSIS packages | 1 | `etl/daily_sales_agg.dtsx` |

The T-SQL is deliberately unfriendly. It uses computed columns, `ROWVERSION`,
`MONEY`, `NTEXT`, `UNIQUEIDENTIFIER`, `IDENTITY`, explicit
`SQL_Latin1_General_CP1_CI_AS` collations, and `TOP 1 PERCENT`. Several of those
have no direct Snowflake equivalent, which is the point — you will see how the
tooling flags them and how the agent resolves them.

Take two minutes to skim one table and the view:

```bash
cat source_db/tastybytesdb/tastybytes/table/customer.sql
cat source_db/tastybytesdb/tastybytes/view/vw_topsellingitems.sql
```

## 0.5 The one thing that makes this workshop unusual

**You have no SQL Server.** Not a stripped-down demo — a real constraint, and
the one most partner engagements start from. You get read-only extracts of the
customer's DDL and packages, and you have to produce a credible converted,
deployed, reviewable target before anyone will fund the data migration.

That is exactly the slice you will run today:

| Phase | Today | Needs a source DB |
|---|---|---|
| Register source code | yes | no |
| Convert to Snowflake SQL | yes | no |
| Assessment (waves, anti-patterns, ETL DAGs) | yes | no |
| Deploy objects | yes | no |
| SSIS to dbt | yes | no |
| Rule engine | yes | no |
| Data migration | **skipped** | yes |
| Data validation | **skipped** | yes |
| Procedure/function equivalence tests | **skipped** | yes |
| ETL output validation | **skipped** | yes |

The skipped phases are real product capabilities. Lab 05 switches them off
explicitly, and the README explains what each one does so you can speak to them
with a customer.

---

**Next:** [01-initialize-project.md](01-initialize-project.md)
