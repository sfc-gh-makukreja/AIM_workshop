# Lab 02 — Register the source code

**Time:** 15 min
**Goal:** import the T-SQL and the SSIS package, and understand what
"registration" actually does.

---

## 2.1 Import the SQL

Continue with the agent. If setup is still running it will do this for you; if
you got interrupted, say:

> continue

The agent runs, from inside `my-migration/`:

```bash
scai code add -i ../source_db --json
```

Three things happen:

1. Files are copied verbatim into `artifacts/source_raw/`.
2. The **arrange** engine parses each file, identifies the object, and files it
   under `source/<db>/<schema>/<type>/<name>.sql`.
3. Each object gets a **Code Unit Registry** entry in `registry/`.

Our input is already one object per file, so arrange has an easy job. On a real
engagement you get a 40,000-line `full_dump.sql`; the T-SQL splitter handles it
natively. (For Oracle, Teradata, Postgres and Redshift the same split needs
`sc-tag` markers injected first — the agent's `split_code` tool does that.)

## 2.2 Import the SSIS package

`etl/` sits **outside** `source_db/`, so it needs its own import:

```bash
scai code add -i ../etl --json
```

> **Do not add `--overwrite` here.** On the first import it is harmless; on the
> second it wipes everything already in `source/`. If the agent proposes
> `--overwrite` for the ETL add, say no.

The package lands in `source/_etl/`. From now on conversion picks it up from
there — you never pass the `.dtsx` path again.

## 2.3 Verify the classification

This is the step most worth being fussy about, because a misclassification here
silently corrupts everything downstream.

```bash
find my-migration/source -type f -name '*.sql' | sort
```

Expected — 18 SQL files:

| Type | Count | Lands at |
|---|---|---|
| database | 1 | `source/tastybytesdb/tastybytesdb.sql` |
| schema | 3 | `source/tastybytesdb/<schema>/<schema>.sql` |
| table | 11 (10 in `tastybytes`, 1 in `etl_results`) | `source/tastybytesdb/<schema>/table/<name>.sql` |
| view | 1 | `source/tastybytesdb/tastybytes/view/` |
| function | 1 | `source/tastybytesdb/tastybytes/function/` |
| procedure | 1 | `source/tastybytesdb/tastybytes/procedure/` |

Note that databases and schemas sit one level *above* the typed folders — a
schema is `tastybytes/tastybytes.sql`, not `schema/tastybytes.sql`.

Plus `source/_etl/daily_sales_agg.dtsx`.

```bash
# Must return nothing. If it returns anything, STOP.
find my-migration/source -path '*unknown_type*'
```

`unknown_type/` means arrange could not identify an object and dumped it in a
bucket. The usual cause is pointing `code add` at raw multi-object DDL instead
of the extracted per-object files. Fix: delete `my-migration/`, restart Lab 01,
and pass `../source_db`.

## 2.4 Look at a registry entry

```bash
ls my-migration/registry/ | head
cat my-migration/registry/$(ls my-migration/registry | head -1)
```

Note the fields: object identity (database/schema/name/type), `inScope`,
dependency links, and the per-task status stamps. Right now only registration is
stamped.

Ask the agent:

> what is the current state of the migration?

Expect ~18 objects registered, 0 converted.

## 2.5 Talking point for your customers

Registration is not a file copy. It is the point where an unstructured pile of
DDL becomes an **inventory with dependencies** — which is what makes wave
planning, parallel team assignment, and progress reporting possible at all. When
a customer asks "how do you know you migrated everything?", this is the answer.

---

**Next:** [03-convert.md](03-convert.md)
