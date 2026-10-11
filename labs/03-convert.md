# Lab 03 - Convert

**Time:** 15 min
**Goal:** convert Wave 1 T-SQL to Snowflake SQL and read the issues.

## 3.0 Conversion settings

After extraction the agent starts conversion by itself and asks four questions. Keep the
defaults and press **Submit**.

| Question | Answer |
|---|---|
| Chains: consolidate dbt model chains? | **No** (keep separate models) |
| Projects: one dbt project per SSIS package? | **No** (one per Data Flow) |
| Tableau workbooks to repoint? | **No** |
| Settings | **Go with defaults** |

![Conversion settings questions](images/convert-settings.png)

> **Tip -** The dbt questions come from the SSIS package added in Lab 02. They only affect how the ETL is converted (Lab 10).

## 3.0b Conversion runs

You do not type a convert prompt. After Submit the agent runs **Run code conversion**
(Allow when asked). It converts everything, not only Wave 1.

![Conversion done](images/convert-done.png)

Expect: *19 SQL files (239 code units) and 1 ETL file converted into `snowflake/`*, with
database bindings written to `.scai/bindings/database-bindings.yaml` for you to adjust if
needed. The agent then asks to Allow `progress_setup` and starts the assessment.

## 3.1 What to look for

| Source construct | What happens | Where |
|---|---|---|
| `MONEY`, `NTEXT`, `UNIQUEIDENTIFIER` | Mapped to `NUMBER`, `VARCHAR`, `VARCHAR` | Customer, MenuItem |
| Computed columns | Rewritten, often with an EWI | tables |
| `ROWVERSION` | No Snowflake equivalent; EWI | tables |
| `SQL_Latin1_General_CP1_CI_AS` collation | Rewritten as `COLLATE` | tables |
| `TOP 1 PERCENT` | Needs manual attention | view |

> **Tip -** Open `source/` next to `snowflake/` and compare one table and the view.
> Reading one diff makes the EWI numbers meaningful.

> **Not yet observed -** Exact EWI codes for this run; the facilitator fills these in
> after the dry run.

---

**Next:** [04-assess.md](04-assess.md)
