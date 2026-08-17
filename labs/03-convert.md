# Lab 03 — Convert to Snowflake SQL

**Time:** 20 min
**Goal:** run SnowConvert AI over the registered code and learn to read EWIs.

---

## 3.1 Run the conversion

> continue

The agent runs the conversion across every registered object plus the SSIS
package. Output lands in:

```
my-migration/artifacts/<db>/<schema>/<type>/<name>/deterministic/<timestamp>/<name>.sql
```

"deterministic" is the rule-based pass — the same input always yields the same
output. That matters for auditability: a customer can diff two conversion runs
and see exactly what changed.

## 3.2 Read a clean conversion

```bash
cd my-migration
find artifacts -path '*table/customer*' -name '*.sql' | xargs cat
```

Compare against the source:

```bash
cat ../source_db/tastybytesdb/tastybytes/table/customer.sql
```

Things to notice:

| T-SQL | Snowflake | Note |
|---|---|---|
| `nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS` | `VARCHAR(100) COLLATE 'en-ci'` | Case-insensitivity preserved, flagged as a perf risk in Lab 04 |
| `uniqueidentifier` | `VARCHAR(36)` | No native GUID type |
| `IDENTITY(1,1)` | `IDENTITY(1,1)` / `AUTOINCREMENT` | Direct equivalent |
| `datetime` | `TIMESTAMP_NTZ(3)` | Precision made explicit |
| `getdate()` | `CURRENT_TIMESTAMP()` | |

Every converted object also carries a `COMMENT` with the SnowConvert version and
a migration id. That is your provenance trail.

## 3.3 Read a conversion that needs help

The view is the interesting one:

```bash
find artifacts -path '*vw_topsellingitems*' -name '*.sql' | xargs grep -n 'EWI'
```

You will see:

```
TOP 1 !!!RESOLVE EWI!!! /*** SSC-EWI-0040 - THE 'TOP PERCENT' CLAUSE IS NOT SUPPORTED IN SNOWFLAKE ***/!!!
```

**EWI** = Error, Warning, or Issue. `!!!RESOLVE EWI!!!` is a deliberate
tombstone: it makes the file **fail to compile** rather than silently deploy
something subtly wrong.

This is a design decision worth understanding. `TOP 1 PERCENT` *could* be
machine-rewritten as `QUALIFY ROW_NUMBER() OVER (...) <= CEIL(COUNT(*) * 0.01)`,
but "1 percent of rows" is a business rule, and the deterministic pass will not
guess at business rules. It stops and asks.

Lab 06 is where the agent resolves this one.

## 3.4 Look at the SSIS conversion

```bash
find artifacts/_etl -type f | sort
```

The `.dtsx` became a **dbt project**:

```
artifacts/_etl/daily_sales_agg/<timestamp>/
  daily_sales_agg.sql            control flow, as an orchestration script
  df_load_daily_sales/           the data flow, as a dbt project
    dbt_project.yml
    profiles.yml
    sources.yml
    models/staging/              one model per source extract
    models/intermediate/         one model per SSIS transform
    models/marts/                the destination
    macros/                      SSIS variable handling
```

Open a couple of intermediate models:

```bash
find artifacts/_etl -name 'int_*.sql' | head -3 | xargs -n1 cat
```

Each SSIS data-flow component became one dbt model:
`Merge Join` → `int_merge_join.sql`, `Aggregate` → `int_aggregate.sql`,
`Conditional Split` → one model per output branch, `Data Conversion` →
`int_data_conversion.sql`.

This is the part partners tend to underestimate. The output is not a
lift-and-shift of a proprietary binary format — it is an idiomatic, layered dbt
project a data engineer can read, review in a PR, and maintain. Lab 07 goes
deeper.

## 3.5 Checkpoint

Ask the agent:

> what is the current state of the migration?

Expect: all objects converted. Then:

> show me every object that has an unresolved EWI

---

**Next:** [04-assessment.md](04-assessment.md)
