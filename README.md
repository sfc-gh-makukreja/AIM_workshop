# AIM Workshop - SQL Server (Azure SQL) to Snowflake, wave by wave

A hands-on lab for **Systems Integrator / Data Cloud Services partners**. You use
SnowConvert AI and the Cortex Code migration agent to migrate a live Azure SQL
Database to Snowflake: connect, extract, plan waves, convert, assess, estimate,
deploy, migrate data on SPCS, validate, test, and review the git trail.

Prompts are deliberately short. You give the agent one small instruction at a
time and read what it did before moving on.

**Lab site:** https://sfc-gh-makukreja.github.io/AIM_workshop/

## Quick start

1. Complete [Lab 00](labs/00-prerequisites.md).
2. Work through [labs/](labs/) in order.
3. Tear down with [snowflake/teardown.sql](snowflake/teardown.sql).

## Agenda

| # | Lab | Format |
|---|---|---|
| 00 | [Prerequisites](labs/00-prerequisites.md) | Verify |
| 01 | [Account setup: PAT policy, PAT, init.sql](labs/01-account-setup.md) | Live |
| 02 | [Connect to Azure SQL and extract](labs/02-connect-extract.md) | Live |
| 03 | [Convert](labs/03-convert.md) | Live |
| 04 | [Assess, estimate, overrides](labs/04-assess.md) | Live |
| 05 | [Configure target and deploy](labs/05-configure-target.md) | Live |
| 06 | [Deploy, migrate, validate, fix loop](labs/06-migrate-data.md) | Live |
| 07 | [Deploy, test, fix loop](labs/07-validate-test.md) | Live |
| 08 | [Dashboard and git changes](labs/08-dashboard-git.md) | Live |
| 09 | [Wave 2](labs/09-wave2.md) | Documented |
| 10 | [SSIS to dbt](labs/10-ssis-to-dbt.md) | Documented |
| 11 | [Wrap-up](labs/11-wrapup.md) | Discussion |

## Repository layout

```
azure_sql/         DDL, data and user scripts for the shared source; FACILITATOR.md
snowflake/         init.sql, pat_policy.sql, teardown.sql
etl/               SSIS package (Wave 2 input)
labs/              the lab pages (also the MkDocs site content)
reference/         extracted_source/: per-object T-SQL fallback if extraction is unavailable
config/            reference plugin task overlay
docs/site/         MkDocs build (build_site.py, mkdocs.yml, pages/)
```

## Facilitators

Provision the shared source first: [azure_sql/FACILITATOR.md](azure_sql/FACILITATOR.md).

## Credits

Derived from the Snowflake Labs guide
[`sfguide-scai-e2e-ssis-migration`](https://github.com/Snowflake-Labs/sfguide-scai-e2e-ssis-migration).
