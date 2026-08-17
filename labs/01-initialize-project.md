# Lab 01 — Initialize the migration project

**Time:** 10 min
**Goal:** create a migration project and understand its layout.

---

## 1.1 Where the project lives

You create the project **inside** the workshop repo, in a folder called
`my-migration/`. It is gitignored, so your project never collides with anyone
else's, and you can delete it to start over.

```
AIM_workshop/
  source_db/        <- inputs (read-only, do not edit)
  etl/              <- inputs (read-only, do not edit)
  my-migration/     <- YOUR project, created below
```

> `scai init` requires an empty target directory. Do not run it at the repo
> root — the repo already has files, and it will refuse.

## 1.2 Start the agent in the workshop repo

```bash
cd ~/projects/AIM_workshop
```

Then start Cortex Code here and say:

> I want to migrate a SQL Server database to Snowflake. I don't have access to
> the source SQL Server — I only have extracted SQL files on disk. Set up a new
> migration project in ./my-migration

The agent drives the **setup state machine** from here. It asks a fixed sequence
of questions. What follows is what to answer and why.

## 1.3 Answering setup's questions

| Question | Answer | Why |
|---|---|---|
| Project directory | `my-migration` (or accept if already proposed) | Must be empty |
| Acknowledge safe tools | Yes | Lets the agent run `scai` and Snowflake commands without re-prompting every call |
| Source dialect | **SQL Server** | |
| Entry mode | **Fresh** | "Midway" is for when you already have *converted* Snowflake SQL. You don't. |
| Code source | **Local files** (not "extract from a database") | This is the fork that skips the source-connection step entirely |
| Path to source files | `../source_db` | Relative to `my-migration/`, or give the absolute path |

The **code source** answer is the important one. Choosing "local files" makes
the machine mark `configureSourceConnection` as skipped and route straight to
registration. Nothing downstream will ask you for a SQL Server host again.

> If the agent asks for a source database connection, you answered "extract"
> by mistake. Tell it: *"I don't have a source database, I'm using local files"*
> and it will re-route.

## 1.4 What got created

```bash
ls -a my-migration/
cat my-migration/.scai/config/project.yml
```

| Path | What it is |
|---|---|
| `.scai/config/project.yml` | Project identity — id, name, `source_language: SqlServer` |
| `.scai/config/plugin.yml` | Agent-facing settings and **task toggles** (Lab 05 edits these) |
| `.scai/config/project.local.yml` | Your machine-local connection names — not shared |
| `source/` | Where registered source code lands (empty until Lab 02) |
| `artifacts/` | Everything generated: converted SQL, assessment, dbt projects |
| `registry/` | The **Code Unit Registry** — one JSON per object, tracking its state through every task |

The registry is the heart of it. Every object moves through
`register → convert → deploy → ...`, and each task stamps its result on that
object's registry entry. That is how the agent knows what is done, what is
blocked, and what is next — and how a team of five can work the same migration
without stepping on each other.

## 1.5 Checkpoint

```bash
test -f my-migration/.scai/config/project.yml && echo "project OK"
```

Ask the agent:

> what is the current state of the migration?

Expect: project initialized, 0 objects registered, setup phase.

---

**Next:** [02-register-source.md](02-register-source.md)
