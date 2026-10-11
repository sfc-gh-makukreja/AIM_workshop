# Troubleshooting

> **Note -** Carried over from the source-less variant of this workshop. Entries that mention lab numbers or local SQL files are historical; the Azure SQL gotchas are inline in each lab and will be consolidated here after the dry run.

Known failure modes, in the order attendees hit them.

---

## Lab 01 — setup

### The agent asks for a source database connection

You answered "extract from a database" at the **code source** question instead of
"local files". Tell the agent:

> I don't have a source database, I'm using local SQL files at ../reference/extracted_source

It re-routes. No need to restart.

### "Project directory is not empty" / `PRJ0001`

`scai init` requires an empty target. You probably pointed it at the repo root.
Use `my-migration` instead.

If `my-migration/` exists from an earlier attempt:

```bash
rm -rf ~/projects/AIM_workshop/my-migration
```

### The agent proposes a project directory outside the repo

Harmless, but keep it at `AIM_workshop/my-migration` so the lab paths
(`../reference/extracted_source`) work as written.

---

## Lab 02 — registration

### `source/` contains `unknown_type/`

**Stop.** Arrange could not classify a file and bucketed it. Everything
downstream inherits the mistake.

```bash
find my-migration/source -path '*unknown_type*'
```

Cause: `code add` was pointed at raw multi-object DDL rather than the extracted
per-object files. Fix:

```bash
rm -rf my-migration
```

Restart Lab 01 and pass `../reference/extracted_source`.

### `ADD0007` — conflict, files already exist

You ran `code add` twice over the same input. Not destructive — the registry is
intact. If the SQL is already in `source/`, skip ahead; only the ETL add is
still needed.

### The ETL add wiped `source/`

`--overwrite` was passed on the second `code add`. Rebuild:

```bash
rm -rf my-migration
```

and restart Lab 01. On the ETL add, no `--overwrite`.

### Fewer than 18 SQL files registered

```bash
find my-migration/source -name '*.sql' | wc -l    # expect 18
```

Check `reports/ArrangeReports/ArrangeErrors*.csv` in the project for the files
that were rejected.

---

## Lab 03 — conversion

### `!!!RESOLVE EWI!!!` in the output

Working as intended. It is a deliberate tombstone that makes the file fail to
compile rather than deploy something subtly wrong. Lab 06.3 resolves it.

### Conversion produced nothing for an object

Confirm it registered (`find my-migration/source -name '<name>*'`). If it never
registered, this is a Lab 02 problem, not a conversion problem.

---

## Lab 05 — target and scoping

### `configure` rejects a task with "router/terminal node"

Expected for `createTests`. It is a router with no executor, and both of its
destinations (`seedSourceDb`, `runTests`) are already off. Drop it from the list
and continue.

### `configure` rejects a task with "is locked"

Expected for `captureBaseline`. It cannot be disabled. Use the bypass in Lab
06.4 if it blocks an object.

### Snowflake connection fails

```bash
snow connection list
snow sql -q "SELECT CURRENT_ACCOUNT(), CURRENT_ROLE()" -c <connection-name>
```

The role must be able to create objects in `TASTYBYTESDB`. On a trial, use
`ACCOUNTADMIN`.

### Setup keeps re-asking the same question

The step is not completing. Do not answer in a loop — ask:

> what is the current state of the migration?

and read the actual state. If a step is genuinely stuck, ask the agent to skip
it.

---

## Lab 06 — deploy

### The database object fails: "already exists"

`snowflake/init.sql` created `TASTYBYTESDB` in Lab 00.3. Tell the agent to treat
it as deployed and continue.

### Objects show as "blocked"

Not an error. A dependency has not deployed yet — a view needs its tables first.
Ask:

> what is blocking these objects?

Deploy the upstream group and they unblock.

### Tables deployed but empty

Correct. Data migration is out of scope.

### The view fails to deploy

Expected — that is Lab 06.3. The error is
`syntax error line 11 at position 24 unexpected '!'`, which is the
`!!!RESOLVE EWI!!!` tombstone. Ask the agent to diagnose and fix it.

### Deploy reports "18 deployed, 1 failed"

That is the expected outcome of Lab 06: everything deploys except
`vw_TopSellingItems`. The ETL package is separate and belongs to Lab 07.

### `captureBaseline` blocks the procedure or function

Expected. Use the logged bypass:

> bypass captureBaseline for this object, reason: workshop has no source database

### "Insufficient privileges" on deploy

Your role cannot create that object type. Switch to `ACCOUNTADMIN` in the
connection and retry.

---

## Lab 07 — SSIS to dbt

All of the following were hit during a real dry-run.

### `Cannot perform DESCRIBE. This session does not have a current schema`

The dbt half of the ETL deploy needs a current schema, and `--schema` on the
deploy command does **not** propagate to it. Set it on the connection or in the
environment:

```bash
export SNOWFLAKE_DATABASE=TASTYBYTESDB
export SNOWFLAKE_SCHEMA=TASTYBYTES
```

Then redeploy. The deploy summary should go from `2 / 4` to `3 / 4`.

### `Schema 'TASTYBYTESDB.PUBLIC' does not exist or not authorized`

The ETL deploy stages supporting artifacts (file formats, `etl_configuration`)
in the database's `PUBLIC` schema. Do not drop it:

```sql
CREATE SCHEMA IF NOT EXISTS TASTYBYTESDB.PUBLIC;
```

The shipped `snowflake/init.sql` leaves `PUBLIC` in place for this reason.

### `Object 'TASTYBYTESDB.PUBLIC.ORDERDETAIL' does not exist`

`sources.yml` resolved `YOUR_SCHEMA` to `PUBLIC`, but the tables are in
`TASTYBYTES`. Fix the **deploy staging copy**, not the artifacts copy:

```
snowflake/_etl/daily_sales_agg/df_load_daily_sales/models/sources.yml
  schema: PUBLIC   ->   schema: TASTYBYTES
```

Editing `artifacts/_etl/.../sources.yml` alone changes nothing — that path is the
conversion record, not what ships. Redeploy after fixing; `SHOW DBT PROJECTS`
should show a new `VERSION$n`.

### Redeployed but `EXECUTE DBT PROJECT` still fails the same way

You edited the wrong copy (see above), or the deploy did not produce a new
version. Check `default_version_name` in `SHOW DBT PROJECTS IN DATABASE
TASTYBYTESDB` — it should have incremented.

### `EXECUTE DBT PROJECT` succeeds but processes 0 rows

Correct and expected. The source tables are empty. `PASS=3 WARN=0 ERROR=0` is the
pass condition: every model compiled and executed against real Snowflake
metadata.

### Where did the dbt models go?

`PUBLIC`, not `TASTYBYTES` — that is the schema in the generated `profiles.yml`.

```sql
SELECT table_schema, table_name FROM TASTYBYTESDB.INFORMATION_SCHEMA.TABLES
WHERE table_name ILIKE 'DAILYSALESAGG' OR table_name ILIKE 'STG_RAW%';
```

### I need the full dbt log

```sql
SELECT SYSTEM$GET_DBT_LOG('<query_id from the error message>');
```

### The tasks reference a warehouse I do not have

The converted script uses `WAREHOUSE=DUMMY_WAREHOUSE` as a placeholder; the
deploy substitutes one from your connection (often `COMPUTE_WH`). To retarget:

```sql
ALTER TASK <task_name> SUSPEND;
ALTER TASK <task_name> SET WAREHOUSE = XSMALL_WH;
```

Suspend children before the root, and resume in the reverse order.

### `dbt` command not found (local loop only)

Lab 07.6 is optional. If you want it:

```bash
pip install dbt-core dbt-snowflake
```

If installed in a virtualenv, activate it in the same shell.

### `dbt debug` fails on profile (local loop only)

Placeholders are unfilled. `dbt_project.yml` needs `name` **and** the key under
`models:` set to the same value, plus `profile` matching the top-level key in
`profiles.yml`. A mismatch between those three is the most common cause.

---

## General

### The agent loses track / repeats itself

Run `/compact`, then:

> what is the current state of the migration?

The state lives in `my-migration/registry/`, not in the conversation. It survives
a compact, a restart, and a new session.

### Start completely over

```bash
cd ~/projects/AIM_workshop && rm -rf my-migration
```

Then re-run `snowflake/init.sql` — its `CREATE OR REPLACE DATABASE` resets the
Snowflake side — and restart at Lab 01.

### Everything is broken and time is short

Skip to Lab 07 using the facilitator's project, or watch a neighbour. Lab 07 is
the one not to miss.
