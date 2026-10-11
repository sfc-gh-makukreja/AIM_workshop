# Lab 04 - Assess, estimate, overrides

**Time:** 25 min
**Goal:** produce the assessment report, read the effort estimate, and see how
overrides change it.

## 4.0 Assessment questions

No prompt is typed. The agent starts the assessment and asks what to run.

**Scope.** Choose **Proceed with all** and add the wave rule in the free-text box, so the
agent keeps your two-wave plan instead of grouping by complexity:

```text
Proceed with all, but remember I want two waves as mentioned earlier not based on complexity.
```

![Assessment scope](images/assess-scope.png)

**Options.** Accept the defaults and Submit:

| Question | Answer |
|---|---|
| Dynamic SQL | No (generate data only) |
| SSIS depth | No (baseline JSON only) |
| Discovery | Skip |
| Lineage | No Power BI |

![Assessment options](images/assess-options.png)

The assessment then covers waves, optimization opportunities, effort estimates, dynamic SQL,
conversion issues, ETL/SSIS, lineage and an HTML report.

## 4.1 Open the assessment dashboard

When the analyses finish the agent asks **What would you like to do next?** Before moving
on, ask for the dashboard. Type this in the free-text box and Submit:

```text
What is the URL for dashboard?
```

![Next question](images/assess-next.png)

The agent answers with a local, read-only URL (it is only reachable on your machine). The
assessment page is the same URL with `/assessment`.

```text
http://127.0.0.1:7878
http://127.0.0.1:7878/assessment
```

![Dashboard URL](images/assess-url.png)

> **Tip -** The port can differ on your machine. Use the URL the agent gives you.

### Dashboard

The home page tracks the pipeline: conversion is 20 / 20 (100%), everything else is still
pending. Each object shows its wave and status.

![Dashboard home](images/dash-home.png)

### Discovery

Data lineage shows the SSIS pipeline writing to `${tastybytesdb}` and to an unresolved
`[TastyBytes]` target (highlighted as Unknown).

![Discovery lineage](images/dash-discovery.png)

### Code/ETL conversion

**Overview.** 20 objects in 2 waves: 11 tables, 3 schemas, 2 views, 1 database, 1 ETL,
1 function, 1 procedure. Two missing references are flagged:
`sys.database_firewall_rules_table` and `DailySalesAgg` (referenced by the SSIS package).

![Overview](images/dash-overview.png)

**Conversion issues.** 2 instances of one issue, `SSC-EWI-0040` (the `TOP PERCENT` clause is
not supported in Snowflake), both in views.

![Conversion issues](images/dash-issues.png)

**Dependencies.** 22 objects to migrate (including the 2 missing ones), 2 waves, 0 cyclic
dependencies, 0 temporal tables. Customer, Inventory, MenuItem, OrderDetail and OrderHeader
each have a dependent and sit in Wave 1; the view, function, procedure and SSIS package are
in Wave 2.

![Dependencies](images/dash-deps.png)

## 4.2 Estimates

The **Effort estimates** tab is a calculator. Objects are banded Critical, High, Medium and
Low. For this small workload code conversion and unit testing are 0.0 h, and the fixed
budgets (optimization 4 h, integration testing 8 h, bug fixing 4 h, UAT 4 h, delivery 4 h)
come to 24.0 h.

![Effort calculator](images/dash-effort.png)

## 4.3 Overrides

Every hours-per-object cell in the calculator is editable. Your changes are called
**overrides**: they save with the project as you type, the row, section subtotal and total
follow, and Snowflake's own figure stays beside yours. **Download report** builds a fresh
report with your overrides included.

> **Tip -** Estimates are the artifact that wins the mandate for the next wave.
> Always show the overrides alongside the total, never the total alone.

> **Not yet observed -** Wave 1 shown here is the generated one. The dashboard Wave column
> will not match your 8-object plan until you select those objects during migration (Lab 05).

---

**Next:** [05-configure-target.md](05-configure-target.md)
