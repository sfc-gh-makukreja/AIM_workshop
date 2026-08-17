# Lab 04 — Assessment

**Time:** 20 min
**Goal:** produce the artifact you would actually put in front of a customer.

---

## 4.1 Run the assessment

> continue

The agent generates the assessment. It needs **no Snowflake connection and no
source database** — deliberately, so a partner can produce a real assessment from
a code drop alone, before any commercial commitment.

## 4.2 What comes out

```bash
cd my-migration
find artifacts/assessment -type f | sort
```

| Artifact | What it answers |
|---|---|
| `assessment.json` | The assessment identity and headline numbers |
| `anti-patterns-*.json` | Which source constructs will hurt on Snowflake, and why |
| `object_exclusion_analysis_*.json` | Which objects are temp/deprecated/duplicate and should not migrate at all |
| `etl/ai_ssis_summary.html` | Plain-language explanation of what each SSIS package does |
| `etl/dags/*.html` | Rendered control-flow and data-flow graphs |
| `etl/etl_assessment_analysis_*.json` | Structured ETL findings |

## 4.3 The anti-patterns report

```bash
python3 -m json.tool artifacts/assessment/anti-patterns-*.json | head -60
```

Findings are bucketed three ways — `performance_risks`,
`architecture_security`, `behavior_semantic` — and prioritized
critical/high/medium/low.

On this workload you should see roughly **28 occurrences across 11 objects** of
a single medium-priority flag:

**`SSC-PRF-0002` — case-insensitive columns slow queries.** Every
`COLLATE SQL_Latin1_General_CP1_CI_AS` column became a `COLLATE 'en-ci'` column.
It is *correct*, and it is *slow*: Snowflake normalizes text on every comparison,
and collated columns lose some pruning and join optimizations.

The recommendation is the useful part: confirm case-insensitivity is genuinely
required. In most SQL Server schemas it was inherited from a server-level default
that nobody chose. Where it is not needed, drop to default collation; where it
is, apply it per-column or per-comparison with `UPPER()`.

> **This is your consulting hook.** A finding like this is worth real money to
> the customer and is invisible in a naive lift-and-shift. Twelve tables here;
> at a customer it is 1,200.

## 4.4 The object exclusion report

```bash
python3 -m json.tool artifacts/assessment/object_exclusion_analysis_*.json
```

Expect `total_objects_found: 18` and zeros for temp/staging, deprecated,
testing, and duplicates — this sample is clean.

Real workloads are not. This report is how you get a customer to agree that
`Customer_bak_20190304`, `tmp_load_v2`, and `sp_test_dont_use` are out of scope
*before* you have spent a sprint migrating them. Scope reduction is usually the
single biggest lever on migration cost.

## 4.5 The SSIS assessment — open these in a browser

```bash
open artifacts/assessment/etl/ai_ssis_summary.html
open artifacts/assessment/etl/dags/etl_daily_sales_agg__control_flow.html
open artifacts/assessment/etl/dags/etl_daily_sales_agg__df_load_daily_sales_data_flow.html
```

The `.dtsx` you imported is 150 KB of XML that no human reads. What you get
instead:

- **AI summary** — what the package does, in prose.
- **Control flow DAG** — task sequencing, including the `start execution` /
  `endexecution` logging brackets around the run.
- **Data flow DAG** — sources, transforms and destinations as a graph.

Trace the data flow: `OrderHeader` and `OrderDetail` sources → `Data Conversion`
→ `Merge Join` → `Aggregate` → `Conditional Split` → destination. Then look back
at the dbt models from Lab 03.4 — they map one-to-one.

## 4.6 Wave planning

Ask the agent:

> based on the assessment, what wave plan do you recommend?

Waves are dependency-ordered batches. Tables before the views that select from
them; views before the procedures that call them. Because registration captured
dependencies, this can be computed rather than guessed.

This workload is small enough for one wave. At a customer, waves are how you
turn "migrate 4,000 objects" into something you can staff and schedule.

## 4.7 The post-assessment gate

The agent now asks whether to continue to migration. **Say yes.**

This gate exists because a large share of real engagements *stop here* — the
assessment is the deliverable. Note what the machine has *not* asked you for
yet: no Snowflake connection, no target database, no git remote. All of that sits
behind this gate, so an assessment-only engagement never touches them.

Answering "yes" queues the remaining setup steps, which is Lab 05.

---

**Next:** [05-configure-target.md](05-configure-target.md)
