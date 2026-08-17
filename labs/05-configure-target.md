# Lab 05 — Configure the target, and scope the migration

**Time:** 15 min
**Goal:** point the project at your Snowflake account, and switch off the phases
that need a source database.

---

## 5.1 Git

The agent asks about git. Answer:

- **Main branch:** `main`
- **Remote:** none / skip

Git is not decoration here. The migration commits after each milestone, so
`git log` becomes the migration audit trail — and object *claiming* (Lab 06) is
what lets a team of engineers work the same migration on separate branches
without collisions.

The milestone commits for register, convert and assess all land now, together,
because git was configured after those steps ran.

## 5.2 Snowflake target

| Question | Answer |
|---|---|
| Snowflake connection | your connection name from Lab 00.2 |
| Target database | `TASTYBYTESDB` |

The agent verifies it can reach the database and that your role can create
objects in it.

## 5.3 Testing path

The agent asks whether your source DB has representative production-like data.

**Answer: "Yes" (source-data path).**

The answer is inert — you are about to disable both halves of the testing
machinery in 5.4 — but the state machine needs a value to leave the step. Do
**not** pick synthetic: that route walks into testbed generation, which is a long
detour you do not want mid-workshop.

## 5.4 Scope the migration — the key step

Tell the agent:

> Disable these tasks: migrateData, validateData, validateView, runTests,
> seedSourceDb, etlSeed, etlValidate, setupDataInfrastructure

The agent calls `configure(tasks={...})`, which persists to
`.scai/config/plugin.yml`. Verify:

```bash
grep -A1 -E 'migrateData|validateData|validateView|runTests|seedSourceDb|etlSeed|etlValidate|setupDataInfrastructure' \
  my-migration/.scai/config/plugin.yml
```

All eight should read `enabled: false`. Reference copy with full commentary:
[../config/plugin.workshop.yml](../config/plugin.workshop.yml).

### What each one does, and why it is off

Learn these — a customer will ask, and "we skipped it" is not an answer.

| Task | What it does | Why off today |
|---|---|---|
| `migrateData` | Moves table data source → Snowflake via a worker (SPCS or local) | Nothing to move |
| `validateData` | Row counts, column metrics and row-level checks, source vs target | Nothing to compare |
| `setupDataInfrastructure` | Provisions the compute pool / worker the two above need | Nothing to provision |
| `validateView` | Runs a deployed view and its source twin, diffs the result sets | No source to run |
| `seedSourceDb` | Captures real inputs from the source as test cases | No source to capture from |
| `runTests` | Executes procedures/functions on both sides and compares — including OUTPUT params, multiple result sets, and DML side effects | No source side |
| `etlSeed` | Generates the ETL test YAML pairing source and target tables | No source tables |
| `etlValidate` | Runs the SSIS package and the dbt project, diffs the outputs | Cannot run SSIS |

Two related tasks **cannot** be disabled, and it is worth knowing why:

- **`createTests`** is a router, not a step — it only picks a seeding strategy.
  Both of its destinations are off, so it is a no-op.
- **`captureBaseline`** is locked by the plugin. It captures a source object's
  output as a test baseline, so it does need the source, and it *can* block the
  procedure and function in Lab 06. Lab 06 shows the supported bypass.

### What stays on

`registration`, `convert`, `deploy`, `etlStabilization`, `fixCode`,
`extractRules`, `applyRules`. Everything you are here to see.

## 5.5 Checkpoint

Ask the agent:

> is setup complete?

Expect yes. Then:

> what should I work on next?

Expect deployable objects — and **no** mention of data migration or tests.

---

**Next:** [06-deploy-objects.md](06-deploy-objects.md)
