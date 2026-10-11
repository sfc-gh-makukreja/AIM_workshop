# Lab 05 - Scope the migration and configure the target

**Time:** 30 min
**Goal:** tell the agent exactly which objects to migrate first (Wave 1), point it at your Snowflake account, and set up data migration on SPCS.

The assessment ended with a question: *"Do you want to move on to migration setup (Snowflake target, testing, data infrastructure), or modify the assessment first?"* This is where you answer it.

## 5.1 Why these objects

At a customer, waves are how you de-risk: migrate a thin vertical first, prove the whole pipeline, then scale out.

`vw_TopSellingItems` depends on `OrderHeader`, `OrderDetail` and `MenuItem`. `fn_FormatCustomerName` depends on `Customer`. Wave 1 is therefore exactly:

- Database `TastyBytesDB`, schema `TastyBytes`
- Tables `Customer`, `OrderHeader`, `OrderDetail`, `MenuItem`
- View `vw_TopSellingItems`
- Function `fn_FormatCustomerName`

Everything else (remaining tables, `sp_UpdateInventory`, SSIS package) is Wave 2 and is skipped for now.

## 5.2 Prompt

Answer the "Next" question with free text. Copy and paste:

```text
Migrate only the following, rest I want to skip for now. after each deploy, data migrate, validation, test, loop, finish the work and sync the state using git.

- View: vw_TopSellingItems (depends on OrderHeader, OrderDetail, MenuItem)
- Function: fn_FormatCustomerName (depends on Customer)

TastyBytesDB database, TastyBytes schema, 4 tables (Customer, OrderHeader, OrderDetail, MenuItem), 1 view (vw_TopSellingItems), and 1 function (fn_FormatCustomerName).

Set up data migration on SPCS using my existing `TASTYBYTES_MIG_POOL` compute pool with a remote Data Exchange Worker.
```

The prompt does three things: it names the 8 objects (your wave plan), it tells the agent to loop deploy, migrate, validate and test per object and sync with git, and it chooses SPCS for the data infrastructure.

!!! note "Why name the objects instead of setting waves"
    The agent cannot write a custom wave plan. The assessment generated dependency-based waves (Lab 04), which do not match this plan. Selecting the objects by name in this prompt is the workaround. Do not accept "Use generated waves" if you want the thin vertical slice.

## 5.3 What the agent does

The agent works through setup on its own, asking you to approve each MCP call.

1. **Continue to migration.** It runs `progress_setup` with `continue_to_migration = true` and marks the other scope items out of scope.
2. **ETL flow.** Because the SSIS package is out of scope, it picks the lighter `validate` ETL flow and `manual` run mode (`etl_flow = validate`, `run_mode = manual`).
3. **Find your Snowflake connections.** It runs `configure` with `needs_snowflake_connections = true`, then asks which connection hosts `TASTYBYTES_MIG_POOL` and which database to deploy into.
4. **Apply the target.** It runs `configure` with your answers, for example `snowflake_connection = SPN-HOL` and `snowflake_database = tastybytesdb`.

![Continue to migration](images/mig-continue.png)

![ETL flow validate, manual](images/mig-etl-flow.png)

![Find Snowflake connections](images/mig-connections.png)

![Target connection and database](images/mig-target.png)

!!! tip "Tip -"
    Approve each call with **Allow**. Attendees will see different phrasing and a different order. That is normal. Read the state, do not pattern-match on the projector.

## 5.4 Testing, compute pool and worker

After the target is set, the agent creates a sandbox scai profile and asks about testing data.

![Testing question](images/mig-testing.png)

| Question | Answer |
|---|---|
| Does your source DB have representative production-like data? | **Yes - use source data** (tests run against the Azure SQL source) |

Because you asked for a remote worker on `TASTYBYTES_MIG_POOL`, the agent reads the worker-spcs skill and checks the pool, role and warehouse (`configure` with `needs_compute_pools = true`).

![Compute pool check](images/mig-pools.png)

It then asks a few more questions:

| Question | Answer |
|---|---|
| Role and warehouse | `ACCOUNTADMIN` and `COMPUTE_WH` |
| Where should the Data Exchange Worker run? | **SPCS worker (remote)** |
| How many worker instances? | `2` |

It then runs `scai data worker setup --compute-pool TASTYBYTES_MIG_POOL --connection <name> --source-connection azure-sql-source-tastybytesdb --role ACCOUNTADMIN --warehouse COMPUTE_WH --resume-compute-pool`. The CLI creates the secret, network rule and external access integration (EAI) from the saved source credentials.

![Worker setup](images/mig-worker.png)

!!! warning "Gotcha"
    On a **trial account** this step fails with `External access is not supported for trial accounts`. An SPCS worker cannot reach Azure SQL without an EAI. The agent stops with a **Blocker** question:

    - SPCS orchestrator + local worker (needs the Microsoft ODBC driver locally)
    - Fully local (no compute pool)
    - Switch account (a paid account that supports external access)

    **Ask the facilitator to enable EAI on your trial account, or go local.** After it is enabled, answer with free text such as `I have enabled EAI on this trial. so try again.`

    ![EAI blocker](images/mig-blocker.png)

After the retry the worker setup succeeds:

```text
✓ Data Exchange Worker Service set up successfully.
⚠ Remember to stop the Data Exchange Worker Service when it is no longer needed:
scai data worker stop
```

![Worker retry succeeded](images/mig-worker-ok.png)

The agent then calls `data_infrastructure` with `mode="up"`, `compute_pool="TASTYBYTES_MIG_POOL"` and `start_worker=false` (the SPCS worker already exists). Click **Allow** when prompted. It brings up the orchestrator on the pool with the 2 instances you requested, then checks the service status.

The agent then checks the worker service status and notices only **1 instance** is running instead of the 2 you asked for. It skips the local disk check (not relevant for an SPCS worker) and calls `data_infrastructure` again with `skip_doctor=true` and `start_worker=false`. Click **Allow** again.

![Status check and second infrastructure call](images/mig-infra-up.png)

> **Tip -** The worker keeps running (and billing) until you stop it. Run `scai data worker stop` at the end of the workshop (see Lab 11).

---

**Next:** [06-migrate-data.md](06-migrate-data.md)
