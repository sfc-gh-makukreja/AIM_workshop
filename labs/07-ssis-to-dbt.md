# Lab 07 — SSIS to dbt

**Time:** 35 min
**Goal:** get the converted SSIS package running on Snowflake as a native dbt
project driven by a task graph.

This is the centrepiece of the workshop.

---

## 07.1 What the conversion produced

```bash
cd my-migration
find artifacts/_etl -type f | sort
```

The `.dtsx` was split along the same seam SSIS itself uses:

| Half | Output | SSIS equivalent |
|---|---|---|
| Control flow | `daily_sales_agg.sql` — a **Snowflake task graph** | The package's task sequence |
| Data flow | `df_load_daily_sales/` — a **dbt project** | The Data Flow Task's component graph |

### The control flow

```bash
cat artifacts/_etl/daily_sales_agg/*/daily_sales_agg.sql
```

Four chained tasks, mirroring the package exactly:

```
daily_sales_agg                    (root)
  └─ daily_sales_agg_insert_start_log      INSERT into etl_results.etl_logs
      └─ daily_sales_agg_df_load_daily_sales   EXECUTE DBT PROJECT ... ARGS='build --target dev'
          └─ daily_sales_agg_insert_end_log    INSERT into etl_results.etl_logs
```

SSIS orchestration became Snowflake tasks; the SSIS data flow became a dbt
project the task graph *calls*. Note `WAREHOUSE=DUMMY_WAREHOUSE` — a deliberate
placeholder the deploy substitutes from your connection.

### The data flow

```
df_load_daily_sales/
  dbt_project.yml
  profiles.yml
  models/sources.yml
  models/staging/       +materialized: view        one per source extract
  models/intermediate/  +materialized: ephemeral   one per SSIS transform
  models/marts/         +materialized: incremental the destination
  macros/                                          SSIS variable handling
```

`ephemeral` intermediates are the right call: SSIS transforms are in-memory
pipeline stages, so they compile into CTEs rather than materializing a dozen
throwaway tables.

```bash
ls artifacts/_etl/daily_sales_agg/*/df_load_daily_sales/models/intermediate/
```

| SSIS component | dbt model |
|---|---|
| Merge Join | `int_merge_join.sql` |
| Aggregate | `int_aggregate.sql` |
| Data Conversion | `int_data_conversion.sql` |
| Conditional Split | `int_conditional_split_case_1.sql` + `..._default_output.sql` |
| OLE DB Destination | `marts/ole_db_destination.sql` (aliased `DailySalesAgg`) |

And the macros — the thing people assume cannot be translated:

```bash
cat artifacts/_etl/daily_sales_agg/*/df_load_daily_sales/macros/*.sql
```

`m_update_row_count_variable` and `m_update_control_variable` reproduce SSIS
package variables.

## 07.2 Deploy the ETL

Your Snowflake connection **must have a default database and schema**, or the
dbt half of the deploy fails with `Cannot perform DESCRIBE. This session does
not have a current schema.` Either add them to your connection in
`connections.toml`, or export them for the session:

```bash
export SNOWFLAKE_DATABASE=TASTYBYTESDB
export SNOWFLAKE_SCHEMA=TASTYBYTES
```

Then tell the agent:

> deploy the ETL package to Snowflake

Expect **3 of 4 parts deployed** and this line:

```
4 ETL task(s) deployed SUSPENDED and will not run yet.
```

Suspended-by-default is deliberate: deploying a pipeline should never start
running it in someone's account.

Verify:

```sql
SHOW TASKS IN DATABASE TASTYBYTESDB;         -- 4, all suspended
SHOW DBT PROJECTS IN DATABASE TASTYBYTESDB;  -- 1, dbt_version 1.9.x
```

You now have a **native Snowflake DBT PROJECT object** — versioned
(`VERSION$1`), stored in Snowflake, executable with `EXECUTE DBT PROJECT`. No
local dbt required.

## 07.3 Stabilize: fix the source references

Try running it as-is:

```sql
EXECUTE DBT PROJECT <project_name_from_SHOW> ARGS='build --target dev';
```

It fails:

```
Object 'TASTYBYTESDB.PUBLIC.ORDERDETAIL' does not exist or not authorized.
```

This is the whole point of stabilization. The generated `sources.yml` shipped
with `YOUR_DB` / `YOUR_SCHEMA` placeholders; the deploy resolved them from your
connection to `TASTYBYTESDB.PUBLIC` — but the tables you deployed in Lab 06 live
in `TASTYBYTES`.

**Fix the deploy staging copy, not the artifacts copy.** There are two:

| Path | Role |
|---|---|
| `artifacts/_etl/.../df_load_daily_sales/` | Conversion output — the record of what SnowConvert produced |
| `snowflake/_etl/daily_sales_agg/df_load_daily_sales/` | **Deploy source of truth** — what actually ships |

Editing only `artifacts/` changes nothing, which is a trap worth falling into
once.

```bash
# snowflake/_etl/daily_sales_agg/df_load_daily_sales/models/sources.yml
#   schema: PUBLIC   ->   schema: TASTYBYTES
```

Or ask the agent:

> the dbt sources point at TASTYBYTESDB.PUBLIC but the tables are in
> TASTYBYTES. fix the deploy copy under snowflake/_etl and redeploy

Redeploy, and confirm a **new version** appeared (`VERSION$2`, `VERSION$3`, ...)
in `SHOW DBT PROJECTS`. Versioning is per deploy — that is your rollback path.

## 07.4 Run it

```sql
EXECUTE DBT PROJECT <project_name> ARGS='build --target dev';
```

Expect:

```
Found 8 models, 2 sources, 476 macros
1 of 3 OK created sql view model PUBLIC.stg_raw__orderdetailsource
2 of 3 OK created sql view model PUBLIC.stg_raw__orderheader
3 of 3 OK created sql incremental model PUBLIC.DailySalesAgg
Completed successfully
Done. PASS=3 WARN=0 ERROR=0 SKIP=0 TOTAL=3
```

Confirm the objects:

```sql
SELECT table_schema, table_name, table_type
FROM TASTYBYTESDB.INFORMATION_SCHEMA.TABLES
WHERE table_name ILIKE 'DAILYSALESAGG' OR table_name ILIKE 'STG_RAW%';
```

Three things to point out:

1. **`DailySalesAgg` did not exist in the source DDL.** The SSIS package owned
   it. dbt created it from the `incremental` materialization. Migrating the
   schema alone would have missed it entirely.
2. **Models land in `PUBLIC`**, because that is the schema in the generated
   `profiles.yml`. In a real engagement you would point this at a proper
   reporting schema.
3. **Zero rows processed.** The source tables are empty (Lab 06). `PASS=3` proves
   every model **compiles and executes against real Snowflake metadata** —
   column names, types, joins, aggregations all resolve. It does **not** prove
   row-level equivalence with the SSIS package; that is `etlValidate`, which
   needs the source (Lab 5.4). Be precise about this distinction with customers.

If it fails, paste the error to the agent — that is `fixCode`, and iterating here
is the realistic experience. `SELECT SYSTEM$GET_DBT_LOG('<query_id>')` gives you
the full dbt log.

## 07.5 Two more stabilization findings

Read the deployed task definitions:

```sql
SELECT name, definition FROM TASTYBYTESDB.INFORMATION_SCHEMA.TASKS;
-- or: SHOW TASKS IN DATABASE TASTYBYTESDB;
```

Two things a careful engineer catches, and neither is caught by "it deployed":

- **The end-log task writes the wrong message.** Both log tasks insert
  `'pkg_daily_sales_aggregate start'`. The end task should say `end`. A faithful
  conversion of a copy-paste bug in the original package — fix it in Snowflake,
  and mention it to the customer.
- **`SSC-FDM-0007 - MISSING DEPENDENT OBJECT "etl_results.etl_logs"`.** Raised at
  conversion time, when `etl_logs` had not been deployed yet. It has been since
  Lab 06, so the warning is now stale — but verify rather than assume.

Optionally resume the graph and watch it run (children before root):

> resume the ETL task graph and run it

## 07.6 Running dbt locally instead (optional)

If you have `dbt-core` and `dbt-snowflake` installed and want the local
developer loop:

```bash
cd artifacts/_etl/daily_sales_agg/*/df_load_daily_sales/
# fill dbt_project.yml (name, profile, and the key under models:) and profiles.yml
dbt debug && dbt build
dbt docs generate && dbt docs serve
```

`dbt docs` is worth the detour — compare the dbt DAG against the SSIS data-flow
DAG from Lab 04.5. Same graph, now version-controlled, testable and reviewable.

## 07.7 Why this matters commercially

SSIS is usually the reason a SQL Server migration stalls. The tables are easy and
everybody knows it; the hundreds of packages are the risk, and the fear is they
must be hand-rewritten by someone fluent in both SSIS and dbt.

What you just demonstrated:

- A binary, proprietary, unreviewable package became a **layered dbt project
  plus a Snowflake task graph**.
- Component-to-model mapping is **traceable** — point at `int_merge_join` and
  name the SSIS component it came from.
- Package variables survived, as macros.
- It runs **natively in Snowflake**, versioned, with no external orchestrator
  and no dbt infrastructure to operate.
- The output is **maintainable by a data engineer who has never opened SSIS**.

That last point is the actual sale. The customer is not just moving a pipeline;
they are exiting a skills dependency.

## 07.8 Checkpoint

```sql
SHOW TASKS IN DATABASE TASTYBYTESDB;
SHOW DBT PROJECTS IN DATABASE TASTYBYTESDB;
SELECT COUNT(*) FROM TASTYBYTESDB.PUBLIC.DAILYSALESAGG;   -- 0, expected
```

---

**Next:** [08-rules-and-wrapup.md](08-rules-and-wrapup.md)
