# Lab 06 - Deploy, migrate, validate, fix loop (wave 1)

**Time:** 25 min
**Goal:** scope the data migration, deploy the Wave 1 tables, move their data from Azure SQL into Snowflake with the worker on `TASTYBYTES_MIG_POOL`, and handle the computed-column bug.

## 6.1 Data migration setup, scope and claiming objects

With the worker up, the agent moves to the data migration setup. It calls `progress_setup` with `mode="data_migration"` and you click **Allow**.

![Data migration setup](images/mig-dm-setup.png)

It chooses the defaults for you: a **full**, one-time migration of all four tables (`data_migration_type="full"`), then the extraction method. With no cloud bucket available it picks direct **ODBC** from the SPCS worker.

![Migration type full](images/mig-dm-type.png)

Next it scopes the project. It calls `update_registry` with `field="inScope"`, `status="false"` and a `where` of `id NOT IN (...)` to mark everything except your 8 objects as out of scope. Click **Allow**.

![Scoping with update_registry](images/mig-scope.png)

The agent reports that setup is complete and 14 other objects are out of scope. The in-scope objects span waves 1 (tables) and 2 (view and function). It then calls `migration_status` with `mode="my_objects_summary"`.

![Scope complete](images/mig-scope-done.png)

Because you already named the objects, it skips the picker, fetches `next_objects` with a limit of 10 and **claims** the matching IDs.

![Claiming objects](images/mig-claim.png)

## 6.2 Claim wave 1, deploy and verify

The agent notes that wave 1 covers the database, schema and 4 tables, and that the view and function belong to wave 2. It checks `migration_status` again before claiming the six wave 1 objects.

![Wave 1 summary](images/mig-wave1.png)

It then calls `transition_status` with `status="begin"` and a `where` of `id IN (...)` to claim them. Click **Allow**.

![Claiming wave 1](images/mig-begin.png)

The claimed groups look empty, so the agent switches to `next_task` to see the actual objects, reads `DEPLOY.md` and plans to make sure `tastybytesdb` exists before deploying.

![Starting the deploy](images/mig-deploy-start.png)

It runs the `deploy` tool with a `where` clause for the six objects, then moves on to the database verify task and `migrateData`.

![Deploy ran](images/mig-deploy-run.png)

To verify, open **Catalog** in Snowsight. `TASTYBYTESDB.TASTYBYTES` now has the 4 tables (CUSTOMER, MENUITEM, ORDERDETAIL, ORDERHEADER). They are empty (0 rows) because only the structure is deployed so far. The table comment shows the SnowConvert origin tag.

![Deployed tables in Snowsight](images/mig-deployed-tables.png)

## 6.3 Bug: data migration fails on computed columns

After `migrateData` runs, the dashboard shows **Data migration** with 2 tables loaded and 2 failed. Customer and OrderHeader are green. MenuItem and OrderDetail are red.

![Dashboard with 2 failed tables](images/mig-dash-fail.png)

Open the **Data migration** page and hover over a failed table. Extraction succeeded (1/1 partitions, 26/26 rows) but the load did not (0/1 partitions, 0/26 rows).

![Data migration page](images/mig-dm-failed.png)

The agent finds the cause on its own. MenuItem and OrderDetail have SQL Server computed columns (`PriceWithTax`, `LineTotal`). Extraction skips computed columns, so it produces 11 columns while the converted Snowflake DDL has 12. The positional `COPY INTO` mapping breaks.

![Agent diagnosing the mismatch](images/mig-fix-diagnose.png)

The agent checks that `vw_topsellingitems.sql` does not use those columns, then fixes the DDL. It removes the computed column lines from `menuitem.sql` and `orderdetail.sql`, redeploys both tables, and reruns the migration. The migration is full-replace, so no rows are duplicated. If you need the derived values later, add them back with `ALTER TABLE ... ADD COLUMN`.

![Agent edits the DDL and redeploys](images/mig-fix-edit.png)

## 6.4 The deploy, migrate, reset loop

After the edit the agent runs `deploy` for the two tables, then `migrate_data` again. The earlier `migrateData` task is still stamped as failed, so the agent calls `transition_status` with `status: reset` and `task: migrateData` for the affected objects. `reset` clears that stamp so the state machine offers the task again. Click **Allow** when prompted.

![Redeploy, rerun and reset](images/mig-rerun-reset.png)

## 6.5 The rerun succeeds

After the reset, the agent reruns the migration. All four tables are extracted and loaded, and the agent reports "Data migration complete. 4 of 4 tables loaded", then confirms row counts and starts validation.

![Agent reports data migration complete](images/mig-dm-complete-chat.png)

On the dashboard's **Data migration** page, all four tables show Done under a new workflow, with row counts that match the source: Customer 15, MenuItem 26, OrderDetail 39, OrderHeader 25.

![Data migration page: 4 Done, 0 Failed](images/mig-dm-done.png)

The main dashboard now shows Data migration at 11 / 11. Data validation is starting: OrderHeader and Customer show a warning marker while validation is in progress.

![Dashboard after data migration](images/mig-dash-dm-done.png)

!!! note "Not yet observed"
    Data validation results and tests will be added next.

---

## 6.6 Data validation

Validation starts automatically. You do not need to type a prompt. As soon as data migration finishes, the agent:

1. Runs a row-count query against the four migrated tables (Customer 15, MenuItem 26, OrderDetail 39, OrderHeader 25) and confirms they match the source.
2. Calls `validate_data` in setup mode, which generates a workflow YAML, and reads that file.
3. Runs it as generated, with schema and row validation on and metrics validation off by default. It notes it may add index columns for row validation if needed.
4. Calls `validate_data` again to run the workflow, then polls `job_status`.

![Validation starts automatically after the row-count check](images/val-auto-start.png)

Validation compares schema and rows (and column metrics, if enabled). Each `job_status` wait can take around 150 seconds, so expect this to be slow.

## 6.7 Intelligent troubleshooting: validation stalls

In the observed run, progress stayed at 2 of 4 tables for about sixteen minutes. The agent did not just keep waiting. It pulled the job details, summarized validation progress by table and queried the validation errors for the pending tables. It found:

- Customer and OrderHeader validated fine.
- MenuItem and OrderDetail could not infer their primary keys, because the converted DDL does not define them.

The agent's fix is to set `indexColumnList` explicitly for those two tables in the validation workflow YAML, then rerun. Review the edit before you click **Allow**.

![Agent diagnoses stalled validation](images/val-stuck-diagnose.png)

> **Tip -** Row-level validation needs a key to match rows. Tables without a primary key need `indexColumnList` set by hand.

## 6.8 The retry: scoped YAML for the two tables

Rather than rerun all four tables (about 15 minutes), the agent copies the workflow into a smaller YAML (`where-5946a153a3a719db-retry.yaml`) scoped to MenuItem and OrderDetail, with `indexColumnList` set explicitly for both. It runs `validate_data`, polls `job_status`, and reads the result:

- **Row validation passes** for both tables, with zero differing rows.
- **Schema validation fails** for MenuItem and OrderDetail only because of the computed columns (`PriceWithTax`, `LineTotal`) removed in Lab 06. This is expected.
- Customer and OrderHeader are fully valid.

The agent considers restoring the computed columns as real columns, then decides against it: the full-replace reload would break on insert because the column count would no longer match, and post-load `ALTER`/`UPDATE` steps would be overwritten on redeploy. It reports this and reports this. What happens next is covered in 6.9 and 7.5.

![Retry validation result: row validation passes, schema fails on the computed columns](images/val-retry-result.png)

## 6.9 Steering the agent

The agent is not always right about order. Here it decides Wave 1 "looks complete" and calls `configure` to advance to Wave 2, the view and function, while MenuItem and OrderDetail are still not validated. This is where you steer it:

![The agent jumps ahead to Wave 2](images/val-jumps-ahead.png)

> **Prompt -** Why not complete the claimed objects and then move to the next claims?

The agent agrees ("I jumped ahead to claiming the view and function before finishing the 6 objects already claimed"), goes back to the claimed objects. The next section covers what it asks you.

> **Tip -** The agent works on its own, but you decide the trade-offs. Interrupt it when it skips ahead, and make the call when it asks.

## 6.10 Resolving the computed columns

The agent checks whether the validation config can exclude columns. It cannot, so it asks you to choose how to handle the computed columns:

![The agent asks how to resolve the computed columns](images/val-steer-computed-cols.png)

| Option | Effect |
|--------|--------|
| Add back and backfill columns in Snowflake | `ALTER TABLE ADD COLUMN` for `PriceWithTax` and `LineTotal`, then `UPDATE` them with the original formulas (`BasePrice*1.08`, `Quantity*UnitPrice-Discount`). Schema and rows should then match. A later `CREATE OR REPLACE` deploy would drop them again. |
| Accept the difference | Keep the tables as migrated (row data validated, 0 diffs). Schema validation stays failed for those two columns, so MenuItem and OrderDetail do not reach "validated". |

Choose **Add back and backfill columns in Snowflake**. The agent adds `PriceWithTax` and `LineTotal` with `ALTER TABLE`, backfills them with the original formulas and revalidates. **All 4 tables now pass validation.**

![All 4 tables pass validation after the backfill](images/val-all-pass.png)

> **Note -** The backfill is a post-load step and is not in the deployed DDL. A later `CREATE OR REPLACE` deploy drops the two columns, so reapply them after any redeploy.

## 6.11 Commit to git

With the 6 wave 1 objects done, the agent commits to local `main` (commit `760f835c`, 25 files, no remote configured), then asks to claim wave 2 (the view and function).

![Agent commits wave 1 and moves to wave 2](images/val-git-synced.png)

The Git graph shows the housekeeping commits (reports and workflows) and the final "done migrating objects" commit.

![Git graph](images/val-git-graph.png)

The dashboard shows the 4 tables green through Data validation (9/11). The view and function are converted only.

![Dashboard after wave 1](images/val-dash-wave1.png)

**Next:** [07-validate-test.md](07-validate-test.md)
