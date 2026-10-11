# Lab 01 - Account setup: PAT policy, PAT, init.sql

**Time:** 20 min
**Goal:** a Snowflake account ready for the migration, and a PAT the tools can use.

Order matters: **PAT policy first, then the PAT, then `init.sql`.**

## 1.1 Sign in as ACCOUNTADMIN

Open the Snowflake account you set up with your facilitator and open a Snowsight worksheet. Run `USE ROLE ACCOUNTADMIN;`.

## 1.2 Allow PATs without an IP network policy

A PAT can only be used by a user who is subject to a network policy. Rather than
maintaining an IP allow-list, create an **authentication policy** that makes the
network policy *enforced but not required* for PATs. Copy this into a Snowsight
worksheet and run it as `ACCOUNTADMIN` (also in
[snowflake/pat_policy.sql](https://github.com/sfc-gh-makukreja/AIM_workshop/blob/main/snowflake/pat_policy.sql)):

```sql
USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS POLICY_DB;
CREATE SCHEMA IF NOT EXISTS POLICY_DB.PUBLIC;

CREATE AUTHENTICATION POLICY IF NOT EXISTS POLICY_DB.PUBLIC.pat_no_network_policy_required
  PAT_POLICY = (
    NETWORK_POLICY_EVALUATION = ENFORCED_NOT_REQUIRED
  );

-- Attach to YOUR user only (replaces any authentication policy already on it).
ALTER USER IDENTIFIER(CURRENT_USER()) UNSET AUTHENTICATION POLICY;
ALTER USER IDENTIFIER(CURRENT_USER()) SET AUTHENTICATION POLICY POLICY_DB.PUBLIC.pat_no_network_policy_required;

-- Verify: expect the policy name in the result.
SHOW PARAMETERS LIKE 'AUTHENTICATION_POLICY' IN USER IDENTIFIER(CURRENT_USER());
```

![Worksheet with the PAT authentication policy SQL](images/pat-auth-policy.png)

> **Gotcha -** Run this **before** you generate the PAT, and attach it to **your
> user** only. `UNSET` first removes any authentication policy already on the user;
> an existing one would otherwise block the `SET`.

> **Tip -** An alternative is to bypass the requirement for a single existing
> token: `ALTER USER <you> MODIFY PROGRAMMATIC ACCESS TOKEN <name> SET MINS_TO_BYPASS_NETWORK_POLICY_REQUIREMENT = 1440;`.
> It needs the token to exist first, so the policy above is simpler for a workshop.

## 1.3 Generate the PAT

In Snowsight, open your user menu (bottom left), then **Settings**, then
**Authentication**. Under **Programmatic access tokens**, select **Generate token**
and fill in the dialog:

| Field | Value |
|---|---|
| Name | `DEMO_PAT` |
| Comment | optional |
| Expires in | the shortest option that covers the session (1 month is fine) |
| Grant access | **Single role**, `ACCOUNTADMIN` |

![New programmatic access token dialog](images/pat-generate.png)

Select **Generate**, then copy the token.

> **Gotcha -** The token value is shown **once**. Copy it into a password manager
> or a scratch file immediately; if you lose it you must generate a new one.

> **Tip -** Snowflake documents the same flow under *Governance & security, Users &
> roles, (your user), Programmatic access tokens*. The Settings route above is the
> quickest for your own user.

## 1.4 Connect Cortex Code Desktop to your account

On the **Welcome to Cortex Code** screen, fill in the connection form:

| Field | Value |
|---|---|
| Account identifier | your account identifier (`myorg-myaccount`) |
| Connection name | optional, auto-generated from the account |
| Username | your Snowflake login name |
| Authentication method | **Password** |

Choose **Password** (not Local OAuth) and paste the **PAT** from 1.3 into the
password field, then select **Sign in**.

![Cortex Code Desktop connection form](images/desktop-connect.png)

> **Tip -** To find the account identifier and login name: sign in at
> `app.snowflake.com`, click your avatar (bottom-left), choose
> **Connect a tool to Snowflake**, and copy both values.

> **Note -** A PAT is used in place of the password. It only works because of the
> authentication policy you set in 1.2.

Reference: [Cortex Code Desktop onboarding and authentication](https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-desktop/onboarding-and-authentication).

### Test the connection

Once you are signed in, ask Cortex Code in the chat:

> run SELECT CURRENT_ACCOUNT(), CURRENT_ROLE()

You should see your account and `ACCOUNTADMIN`. If so, the PAT and the
authentication policy both work.

> **Gotcha -** If sign-in fails with a network policy or "token not allowed" error,
> the policy from 1.2 is not attached to your user. Re-run the 1.2 script and
> check `SHOW PARAMETERS LIKE 'AUTHENTICATION_POLICY' IN USER ...` shows it.

> **Gotcha -** The role is `ACCOUNTADMIN` only if the PAT was generated with that
> role in 1.3. A token limited to another role will connect but fail later steps.
> Later deploys can also fail with `This session does not have a current schema`;
> after running init.sql in 1.5, ask Cortex Code to use `TASTYBYTESDB.TASTYBYTES`.

## 1.5 Run init.sql

Run [snowflake/init.sql](https://github.com/sfc-gh-makukreja/AIM_workshop/blob/main/snowflake/init.sql)
in Snowsight as `ACCOUNTADMIN`. It creates `TASTYBYTESDB` (schemas `TASTYBYTES`,
`ETL_RESULTS`), the `XSMALL_WH` warehouse and the `TASTYBYTES_MIG_POOL` compute
pool.

Open `init.sql` in a Snowsight workspace and select **Run all**. The final
result shows your account, `ACCOUNTADMIN`, `TASTYBYTESDB` and `XSMALL_WH`.

![init.sql run in a Snowsight workspace](images/init-sql-run.png)

> **Gotcha -** Do not drop the `PUBLIC` schema. The ETL deploy stages artifacts there.

> **Gotcha -** No compute pool? SPCS may be unavailable in your region
> or edition. The data-migration lab has a local-worker fallback.

---

**Next:** [02-connect-extract.md](02-connect-extract.md)
