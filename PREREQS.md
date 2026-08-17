# Prerequisites — AIM Workshop

**Send this to attendees at least one week before the workshop.** Everything
here must be working *before* they arrive. There is no time in a three-hour
session to install tooling or wait on account provisioning.

---

## 1. Snowflake account

You need **your own Snowflake trial account** with a role that can reach
`ACCOUNTADMIN`.

- Sign up: https://signup.snowflake.com (30-day trial, no credit card)
- Any cloud and region is fine.
- If you already have a Snowflake account you can create objects in, use it.

**Verify:**

```sql
SELECT CURRENT_ACCOUNT(), CURRENT_ROLE();
USE ROLE ACCOUNTADMIN;
```

## 2. Cortex Code with the migration plugin

Install Cortex Code (desktop or CLI) and confirm the `snowflake-migration`
plugin is available.

**Verify** — start Cortex Code and ask:

> what migration skills do you have?

It should mention the migration skill and its sub-skills (setup, convert,
assessment, migrate-objects).

## 3. SnowConvert AI CLI (`scai`)

**Verify:**

```bash
scai --version
```

## 4. Snowflake CLI (`snow`) with a configured connection

```bash
snow --version
snow connection add          # interactive; run with a leading ! in Cortex Code
snow connection list
snow sql -q "SELECT CURRENT_ACCOUNT(), CURRENT_ROLE()"
```

**Write down your connection name.** You give it to the agent in Lab 05.

**Set a default database and schema on the connection.** The ETL deploy in Lab 07
fails with `Cannot perform DESCRIBE. This session does not have a current schema`
if they are missing. Either add `database = "TASTYBYTESDB"` and
`schema = "TASTYBYTES"` to the connection in `connections.toml`, or export
`SNOWFLAKE_DATABASE` / `SNOWFLAKE_SCHEMA` before deploying.

## 5. git

```bash
git --version
git config user.name
git config user.email
```

Both config values must be set — the migration commits after each milestone and
will fail without them. No remote or GitHub account needed.

## 6. dbt — optional

**You do not need dbt installed.** The SSIS package deploys to Snowflake as a
native `DBT PROJECT` object and runs with `EXECUTE DBT PROJECT`. Snowflake
supplies the dbt runtime.

Install it only if you want the optional local developer loop in Lab 07.6
(`dbt build`, `dbt docs serve`):

```bash
pip install dbt-core dbt-snowflake
dbt --version
```

## 7. The workshop repo

```bash
git clone <this repo> ~/projects/AIM_workshop
cd ~/projects/AIM_workshop
ls source_db etl snowflake labs
```

---

## What you do NOT need

- **SQL Server.** None. Not a local instance, not Docker, not a VM. The whole
  workshop runs from extracted SQL files, which is the situation most partner
  engagements actually start from.
- **SSIS or Visual Studio.** The `.dtsx` is an input file; nothing executes it.
- **Sample data.** Objects deploy empty by design. Data migration is out of
  scope — see "Phases we skip and why" in the README.

---

## Pre-flight checklist

Run this the day before. Every line must succeed.

```bash
scai --version && \
snow --version && \
git --version && \
snow sql -q "SELECT CURRENT_ACCOUNT()" && \
echo "ALL PREREQS OK"
```

Then run [snowflake/setup.sql](snowflake/setup.sql) in a Snowsight worksheet and
confirm the final `SELECT` echoes your account, `ACCOUNTADMIN`, `TASTYBYTESDB`
and `XSMALL_WH`.

If anything fails, raise it with the facilitator **before** the session.
