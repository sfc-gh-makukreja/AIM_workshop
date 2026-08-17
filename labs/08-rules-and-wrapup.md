# Lab 08 — The rule engine, and wrap-up

**Time:** 20 min
**Goal:** turn a one-off fix into a reusable asset, then tear down.

---

## 08.1 The problem rules solve

In Lab 06 you fixed `TOP 1 PERCENT` in one view. A customer has 200 views using
it. Fixing each by hand is the whole reason migrations run long — and the reason
two engineers on the same project produce two different rewrites of the same
construct.

A **rule** captures one fix as a pattern that can be found and applied
everywhere.

## 08.2 Extract a rule from your fix

> extract a migration rule from the fix I made to vw_TopSellingItems

The agent inspects the change (from the working tree or git history) and proposes
a rule: the pattern it matches, the transformation it applies, and the conditions
under which it is safe.

**Review it before saving.** Ask yourself what you would ask of a junior
engineer's PR:

- Is the match specific enough not to fire on unrelated `TOP` usage?
- Does it preserve each query's own `ORDER BY`?
- Is the rounding behaviour of "1 percent" pinned down?

An over-broad rule applied to 200 views is worse than 200 manual fixes, because
it fails silently and at scale.

## 08.3 Propagate it

> find all code units that match this rule

On this workload the answer is one object — the one you already fixed. The
mechanic is the point:

1. **Extract** once, from a real fix.
2. **Propagate** — find every match across the project.
3. **Review** the match list.
4. **Apply** in bulk.

Rules persist with the project, so they compound: each fix makes the rest of the
migration faster, and the rule library becomes an asset your firm carries from
one engagement to the next. This is the difference between billing bodies and
billing a capability.

## 08.4 Review the audit trail

```bash
cd my-migration && git log --oneline
```

You should see the milestone commits — register, convert, assess — then a commit
per batch of migrated objects. Combined with the registry's per-task stamps
(including any `bypass` you recorded in Lab 06.4), this is a complete, defensible
record of what was migrated, when, by whom, and what was deliberately skipped.

Practise the sentence you would say to a customer's auditor. It is a
differentiator in regulated accounts.

## 08.5 What you did today

| Phase | Outcome |
|---|---|
| Register | 18 objects + 1 SSIS package inventoried with dependencies |
| Convert | Deterministic T-SQL to Snowflake SQL, EWIs raised not guessed |
| Assess | Anti-patterns, exclusion candidates, SSIS DAGs, wave plan — with no source DB and no Snowflake connection |
| Deploy | Every object created in Snowflake, one real deploy-fix loop |
| SSIS to dbt | Binary package to a running, layered, reviewable dbt project |
| Rules | One fix generalized into a reusable asset |

All of it **without a single connection to SQL Server.**

## 08.6 What you would add for a real engagement

Be able to describe these; a customer will ask.

| Phase | What it needs | What it gives |
|---|---|---|
| Data migration | Source connectivity + worker (SPCS or local) | Table data moved, full or incremental |
| Data validation | Same | Row counts, column metrics, row-level diffs |
| Procedure/function tests | Source connectivity | Automated equivalence, including OUTPUT params, multiple result sets and DML side effects |
| ETL validation | Source + ability to run SSIS | Row-level diff of SSIS output vs the dbt project |

The honest framing: today proves **structural and semantic** correctness. Those
four phases prove **data** correctness. A customer should fund both, and today's
output is what gets you the mandate to do the second half.

## 08.7 Teardown

Snowflake — run [../snowflake/teardown.sql](../snowflake/teardown.sql). Both
verification `SHOW`s should return zero rows.

Local, if you want a clean slate:

```bash
cd ~/projects/AIM_workshop && rm -rf my-migration
```

Keep `my-migration/` if you want to revisit the artifacts; it is gitignored
either way.

## 08.8 Where to go next

- Re-run the whole thing against a customer's real extracted DDL — the only
  change is the path you pass in Lab 01.3.
- Add a second SSIS package and watch waves and dependencies do more work.
- Stand up a SQL Server instance (the reference repo has a seedable sample) and
  run the four skipped phases end to end.
- Start a rule library for your practice.

---

**Back to:** [../README.md](../README.md)
