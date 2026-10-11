# Lab 09 - Wave 2 (documented, self-paced)

**Time:** not part of the live HOL
**Goal:** know what Wave 2 looks like so you can run it on your own after the session.

Wave 2 is everything not in Wave 1:

- Remaining tables: `Country`, `City`, `FoodTruck`, `Menu`, `Inventory`, `EmployeeShift`, `etl_results.etl_logs`
- Procedure `TastyBytes.sp_UpdateInventory`
- SSIS package `daily_sales_agg.dtsx` (control flow and data flow)

The loop is the same as Wave 1; only the objects change.

| Step | Prompt |
|---|---|
| Switch wave | `move on to Wave 2` |
| Convert | `convert the Wave 2 objects` |
| Deploy | `deploy the Wave 2 objects` |
| Data | `migrate the data for Wave 2` |
| Validate | `validate the Wave 2 data` |
| Test the procedure | `test sp_UpdateInventory on both platforms` |
| SSIS | continue with [Lab 10](10-ssis-to-dbt.md) |

> **Tip -** Procedures are where the interesting differences live: `OUTPUT`
> parameters, multiple result sets, DML side effects. Use `azure_sql/query_log.csv`
> as the source of realistic test calls.

> **Not yet observed -** Wave 2 has not been run end to end against Azure SQL.

---

**Next:** [10-ssis-to-dbt.md](10-ssis-to-dbt.md)
