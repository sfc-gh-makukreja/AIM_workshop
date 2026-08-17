# AIM Workshop — AI-driven SQL Server and SSIS migration to Snowflake

A hands-on workshop for **Systems Integrator / Data Cloud Services partners**.

Attendees migrate a SQL Server workload — schema, views, a function, a procedure
and an SSIS package — to Snowflake using SnowConvert AI and the Cortex Code
migration agent, **without any access to a source SQL Server**.

That constraint is the design, not a compromise. It is how most partner
engagements actually begin: you get a code drop, and you have to produce a
credible converted, deployed, reviewable target before anyone funds the data
migration.

---

## Quick start

1. Complete [PREREQS.md](PREREQS.md) — a week ahead, not on the day.
2. Work through [labs/](labs/) in order, starting at
   [labs/00-prerequisites.md](labs/00-prerequisites.md).
3. Tear down with [snowflake/teardown.sql](snowflake/teardown.sql).

---

## Agenda — 3 hours

| # | Lab | Time | Format |
|---|---|---|---|
| 00 | [Prerequisites and orientation](labs/00-prerequisites.md) | 15 min | Verify + facilitator intro |
| 01 | [Initialize the project](labs/01-initialize-project.md) | 10 min | Everyone |
| 02 | [Register the source code](labs/02-register-source.md) | 15 min | Everyone |
| 03 | [Convert to Snowflake SQL](labs/03-convert.md) | 20 min | Everyone |
| — | **Break** | 10 min | |
| 04 | [Assessment](labs/04-assessment.md) | 20 min | Everyone + group discussion |
| 05 | [Configure target and scope](labs/05-configure-target.md) | 15 min | Everyone |
| 06 | [Deploy objects](labs/06-deploy-objects.md) | 30 min | Everyone |
| 07 | [SSIS to dbt](labs/07-ssis-to-dbt.md) | 35 min | Everyone — the centrepiece |
| 08 | [Rules and wrap-up](labs/08-rules-and-wrapup.md) | 20 min | Discussion-heavy |

Total: 3 h with the break. If you are running short, compress 08 to a
demo — do not cut Lab 07.

### Facilitator notes

- **Demo vs do.** Every lab is hands-on. The two worth demoing on the projector
  first are **04.5** (open the SSIS DAG HTML — high impact) and **06.3** (the
  deploy-fix loop — attendees get different agent phrasing and reassurance
  helps).
- **The agent is non-deterministic.** Prompts in the labs are guidance, not
  incantations. Attendees will see different wording and occasionally a
  different order. Teach them to read the state (`what is the current state of
  the migration?`) rather than pattern-match on your screen.
- **`/compact` between labs.** The migration agent is context-hungry. Tell
  attendees to compact between work units.
- **Where people get stuck:** Lab 01 (choosing "extract" instead of "local
  files"), Lab 05.4 (the task-disable step — verify everyone's `plugin.yml`
  before moving on), Lab 07.3 (editing the wrong copy of `sources.yml`). See
  [TROUBLESHOOTING.md](TROUBLESHOOTING.md), which documents the exact errors
  from a real dry-run.
- **Two environment gotchas, both pre-empted:** the connection needs a default
  database and schema before Lab 07, and the database's `PUBLIC` schema must
  exist (the ETL deploy stages artifacts there). `snowflake/setup.sql` and
  `PREREQS.md` both handle this — do not "tidy up" `PUBLIC`.
- **Expect zero rows everywhere.** Say this early and often, or attendees will
  read empty tables as failure. Structure migrates today; data does not.
- **No dbt install needed.** The SSIS package runs as a native Snowflake
  `DBT PROJECT` object. Local dbt is an optional extra in Lab 07.6.

---

## What attendees migrate

**TastyBytes**, a fictional global food-truck network: localized menus, customer
loyalty, order management, inventory, employee scheduling.

| Object type | Count |
|---|---|
| Database | 1 |
| Schemas | 3 |
| Tables | 11 |
| Views | 1 |
| Functions | 1 |
| Procedures | 1 |
| SSIS packages | 1 |

The T-SQL deliberately uses constructs with no clean Snowflake equivalent —
computed columns, `ROWVERSION`, `MONEY`, `NTEXT`, `UNIQUEIDENTIFIER`, explicit
`SQL_Latin1_General_CP1_CI_AS` collations, `TOP 1 PERCENT` — so attendees see
real EWIs and work a real fix loop rather than a happy path.

---

## Phases we skip, and why

Four phases need a live source database. They are switched off explicitly in
Lab 05 via `configure(tasks={...})`, not quietly omitted — attendees see the
mechanism and learn to describe the capability.

| Phase | What it does | Why off |
|---|---|---|
| Data migration | Moves table data via a worker (SPCS or local), full or incremental | Nothing to move from |
| Data validation | Row counts, column metrics, row-level diffs, source vs target | Nothing to compare against |
| Procedure/function tests | Runs each object on both platforms and compares — OUTPUT params, multiple result sets, DML side effects | No source side to run |
| ETL validation | Runs the SSIS package and the dbt project, diffs the outputs | Cannot execute SSIS |

**Say this to attendees, and to customers:** today proves *structural and
semantic* correctness. Those four phases prove *data* correctness. Both should
be funded; today's output is what wins the mandate for the second half.

Full commentary, including the two tasks that cannot be disabled and the
supported bypass for one of them:
[config/plugin.workshop.yml](config/plugin.workshop.yml).

---

## Repository layout

```
AIM_workshop/
  PREREQS.md                    send to attendees a week ahead
  TROUBLESHOOTING.md            known failure modes and recovery
  tasks.md                      build notes (maintainers, not attendees)
  labs/00..08                   the workshop
  source_db/                    extracted T-SQL, one object per file  [input]
  etl/daily_sales_agg.dtsx      SSIS package                          [input]
  snowflake/setup.sql           creates the target DB and warehouse
  snowflake/teardown.sql        removes everything
  config/plugin.workshop.yml    reference task-exclusion overlay
  my-migration/                 created by each attendee (gitignored)
```

`source_db/` and `etl/` are **read-only inputs**. Attendees never edit them; all
generated output lands in `my-migration/`.

---

## Reusing this with a real customer

The workshop is a template. To run it against a customer's workload, change one
thing: the path passed in Lab 01.3. Everything downstream — registration,
conversion, assessment, deploy, SSIS stabilization — is dialect- and
workload-driven.

Two adjustments for real code:

- Customer DDL usually arrives as large multi-object dumps. T-SQL splits
  natively; Oracle, Teradata, Postgres and Redshift need `sc-tag` markers first,
  which the agent's `split_code` tool injects.
- Re-enable the four skipped phases once source connectivity exists.

---

## Credits

Derived from the Snowflake Labs guide
[`sfguide-scai-e2e-ssis-migration`](https://github.com/Snowflake-Labs/sfguide-scai-e2e-ssis-migration),
which runs the same workload end to end *with* a live SQL Server. Use that repo
when you want the four skipped phases; use this one when you do not have a
source database.
