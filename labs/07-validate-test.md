# Lab 07 - Deploy, test, fix loop (wave 2)

**Time:** 25 min
**Goal:** deploy the view and function, then prove the logic matches the source.

## 7.1 Deploy the view and function (deploy-fix loop)

After the commit the agent claims wave 2: the view `vw_TopSellingItems` and the function `fn_FormatCustomerName(INT)`. Neither has data to migrate, so they go straight to deploy and test. It deploys the view first, because the tables it reads are already in Snowflake. Approve the `deploy` call with **Allow**.

### 7.1.1 Deploy the view

![The agent deploys the view first](images/w2-view-deploy.png)

### 7.1.2 Diagnose and fix the view

The deploy fails with a syntax error. The agent reads the converted SQL (`vw_topsellingitems.sql`) and finds the cause: the source view uses `SELECT TOP 1 PERCENT`, which SnowConvert could not translate (this is the TOP PERCENT conversion warning from Lab 03). The agent rewrites it by hand to match SQL Server's behavior: `TOP 1 PERCENT` returns `CEILING(count * 0.01)` rows, so for 26 rows or fewer it rounds up to 1 row. It uses a CTE with `ROW_NUMBER()` compared against `CEIL(COUNT(*) OVER () * 0.01)`, keeps the original ordering, and redeploys.

![The agent diagnoses the syntax error and rewrites the view](images/w2-view-fix.png)

This is the same loop as the tables: deploy, read the error, fix, redeploy.

> **Tip -** Read the rewrite before you click **Allow**. Check it preserves the source semantics (here, the rounding-up rule), not just that it compiles.

### 7.1.3 Redeploy and compare the view

The agent then notes why the first deploy failed with the old SQL: the deploy ran in parallel with the file write, so it used the old file. It redeploys with the fixed file and the view deploys.

![Redeploy succeeds, then the agent starts comparing the view against the source](images/w2-view-redeploy.png)

Testing begins here. The agent immediately runs a `query_source` call that selects `MenuItemID, ItemName, TotalQuantitySold, TotalRevenue, RankingBasis` from the source view, so it can compare the row count and rows against the Snowflake view. Click **Allow**.

> **Gotcha -** If a deploy fails right after the agent edits a file, the deploy may have run before the write finished. The agent catches this and redeploys, but if you see the old error again, ask it to redeploy.

The compare finishes by querying the deployed target view (**Query deployed target view**). The agent then moves to the function and seeds a test YAML for it (**Seed test YAML for function**).

![The view is compared, the function test YAML is seeded and run_tests starts](images/w2-fn-tests.png)

### 7.1.4 Seed the function tests

Because `fn_FormatCustomerName(INT)` takes one parameter, the agent writes the test cases itself: every real customer ID, plus a missing ID and `NULL`. It then calls `run_tests`.

> **Note -** The first `run_tests` attempt hit a source connection problem. The .NET connection worked, but the Python ODBC path failed three times in a row. The agent suspected a transient issue, possibly from Azure SQL serverless auto-pause, and retried. If your source database has been idle, expect a slow first connection.

### 7.1.5 Resume in a new chat

> **Tip -** If the chat session breaks or stalls, open a new chat and ask `/migration-guide where are we at with migration?`. The migration state lives in the project and in Snowflake, not in the chat, so the agent reads it back and reports where you are.

![A new chat reports the migration status](images/w2-status-resume.png)

In this run the status check showed that setup, conversion (2 of 2 wave 2 objects), assessment and migration setup were done. Wave 2 was one of two objects done: the view was deployed and tested, and the function was converted but not yet deployed or tested. The agent proposed deploying and testing the function next. It also mentioned two objects flagged as missing and background jobs it had not monitored. Tell it which of these to pick up, here the function.

### 7.1.6 Capture the baseline

Back in the original run, the function stalled on its first test attempt. Asking the agent what the state machine says gives a clearer picture. One task is left in wave 2: `captureBaseline` on the function. It records the expected outputs from the source SQL Server database. Deploy and test come after it. Nothing is blocked, and there are no escalations. Answer **yes** and the agent loads the baseline skill (`CAPTURE.md`) and runs `run_tests` with `mode: "capture"`.

![The state machine shows captureBaseline is next, and the agent runs the capture](images/w2-baseline-start.png)

### 7.1.7 Bug: capture fails to connect to SQL Server

Capture failed with `Failed to establish sqlserver connection ... [Microsoft][ODBC Driver 18 for SQL Server]Client unable to establish connection`. This is the same error behind the earlier `run_tests` retries. The agent checked everything it could and found that TCP to the server connects, `scai connection test` reports Success, and the migration MCP source connection runs `SELECT 1`. It could not find the cause at first and left `captureBaseline` unchanged.

![Capture fails on the ODBC connection while other connection checks pass](images/w2-baseline-odbc-fail.png)

> **Tip -** Do not assume Azure is the problem. Here the Azure firewall was open to all addresses, which ruled it out. Tell the agent what you already know, such as the firewall range, so it stops investigating the wrong layer.

### 7.1.8 Agent finds the cause: OpenSSL mismatch

After you point it away from Azure, the agent finds the real cause. The Microsoft ODBC driver 18 loads OpenSSL from `/opt/homebrew/opt/openssl/lib/`. That path now points to OpenSSL 4.0.3, but the driver needs 1.1 or 3.x, so it fails with "OpenSSL library could not be loaded". The other checks passed because `scai connection test` and the migration MCP do not use this ODBC driver. Only `scai test capture` does. `openssl@3` was already installed, so the fix is to repoint the symlink:

```bash
brew unlink openssl@4 && brew link --force openssl@3
```

The agent did not run it because it changes your Homebrew setup, and asked first. Run it yourself, then tell the agent (`i ran it`). Capture then works: 19 of 19 baselines are captured and uploaded to `@SNOWCONVERT_AI.VALIDATION.BASELINES`, and the state machine moves the function to `deploy`.

![The OpenSSL cause, the fix, and a successful capture of 19 baselines](images/w2-baseline-openssl-fix.png)

> **Gotcha -** On a Mac with a recent Homebrew, `openssl` may point to OpenSSL 4, which the Microsoft ODBC driver 18 cannot load. Only the test steps that use ODBC (`capture` and `validate`) fail. Everything else keeps working, which makes it look like a network problem. Ask the facilitator if you hit it.

### 7.1.9 Deploy the function and confirm where it landed

Say `yes please continue with deploy`. The function deploys with 1 deployed and 0 failed, and the state machine moves on to `runTests`. The deploy raised a warning, `DEPLOY_BINDING_UNEDITED`: the `tastybytesdb` binding in `database-bindings.yaml` resolves to `tastybytesdb`, which looks like a placeholder. The agent says it is probably fine, because earlier objects deployed into that database, but it had not confirmed the function landed there. Ask it to confirm, then run the tests: `confirm deployment location and if all okay run tests`. It locates the function in `tastybytesdb` and checks that other deployed objects are in the same database and schema.

![The function deploys with a binding warning, and the agent checks where it landed](images/w2-fn-deploy-check.png)


## 7.2 Test results and closing wave 2

### 7.2.1 Test results

The agent ran the tests on the deployed function and compared them with the baselines. `fn_FormatCustomerName` passed all 19 tests, so no fix loop was needed here.

- **Deploy location:** `TASTYBYTESDB.TASTYBYTES.FN_FORMATCUSTOMERNAME`, the same database and schema as the migrated tables and the view. The `DEPLOY_BINDING_UNEDITED` warning was harmless.
- **Tests:** all 19 Snowflake results match the SQL Server baselines (`data_match`), with 0 failed and 0 errors. The report is written to `reports/TestValidateReport.<timestamp>.csv`.
- **State machine:** no pending tasks remain, and the done count went from 7 to 8.

![The function passes all 19 tests and the agent summarises wave 2](images/w2-fn-tests-pass.png)

The agent also lists what is still open: the function and view finished-status, the missing object `DailySalesAgg`, and an earlier validation job that stalled. Tell it `close wave 2`. It marks the function finished and commits the registry entry, the source SQL, the converted SQL and the artifacts to local `main`. Nothing is pushed. There is no separate "close wave" step, so the wave stays set to 2 until you move to another one.

> **Note -** The agent still reports leftovers from earlier in the run: two objects flagged missing, including `DailySalesAgg`, a suspended SPCS orchestrator and a stalled validation job. These do not block wave 2. Resolve them in the next wave.

### 7.2.2 The dashboard shows the testing stage

Open the function in the dashboard to see each of the 19 test cases (every customer ID, a missing ID, and NULL) with a PASS result at all three levels (L1, L2, L3).

![Dashboard test cases for fn_FormatCustomerName, all passing](images/w2-fn-test-cases.png)

On the main dashboard the function and view show Conversion, Deployment and Testing complete. Data migration and validation show a dash because neither object holds data. The Testing stage moves to 2 / 8.

![Dashboard after wave 2: Testing 2 / 8](images/w2-wave2-dashboard.png)

### 7.2.3 Git records wave 2

The git graph gains a `done migrating objects: TastyBytes.fn_FormatCustomerName` commit on top of the wave 1 history.

![Git graph with the wave 2 commit](images/w2-wave2-git-graph.png)

---

**Next:** [08-dashboard-git.md](08-dashboard-git.md)
