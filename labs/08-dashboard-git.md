# Lab 08 - Dashboard and git changes

**Time:** 15 min
**Goal:** see the migration as a reviewer would: progress dashboard and the git trail.

## 8.1 The migration dashboard

The agent serves a local dashboard at `http://127.0.0.1:7878` for the whole run. Open it any time to see progress.

![Migration dashboard at the end of wave 1](images/val-dash-wave1.png)

The pipeline stages across the top show where the project stands after wave 1:

| Stage | Progress | Meaning |
|-------|----------|---------|
| Conversion | 8 / 8 (100%) | All registered objects converted |
| Deployment | 5 / 8 (63%) | Wave 1 deployed; the view and function are pending |
| Data migration | 11 / 11 (100%) | Table data loaded |
| Data validation | 9 / 11 (82%) | The 4 tables are validated |
| Testing | 0 / 8 | Not started |

The **Objects progress** table shows each object as a row of stage dots. The four wave 1 tables (Customer, MenuItem, OrderDetail, OrderHeader) are green through Data validation. `fn_FormatCustomerName` and `vw_TopSellingItems` (wave 2) are green for Conversion only.

Use the **Wave**, **Type** and **Status** filters to narrow the list.

### After wave 2

Once the view and function pass their tests, Testing moves to 2 / 8 and Deployment to 7 / 8. The function and view show Testing green. Their Data migration and validation cells are dashes because neither holds data.

![Dashboard after wave 2](images/w2-wave2-dashboard.png)

Open the function to see its 19 test cases, all PASS.

![Function test cases in the dashboard](images/w2-fn-test-cases.png)

## 8.2 The git trail

The agent commits to git at each milestone. In the observed run it committed to local `main` only: no remote was configured, so nothing was pushed.

![Git graph showing the project setup, housekeeping and final commits](images/val-git-graph.png)

Reading the graph from the bottom up:

1. **Initial migration project** and the `project setup:` commits: register source code, convert source to Snowflake SQL, generate migration assessment, configure the Snowflake target database, configure testing and configure data strategy.
2. **`housekeeping:` commits**: deployment report, data migration workflow and report (including the FAILED one), data validation workflow and report (including the FAILED one). The failed runs are kept, so the trail shows the problems as well as the fixes.
3. **`done migrating objects: ...`**: the final commit for the six wave 1 objects (TastyBytes, TastyBytesDB, OrderHeader, OrderDetail, Customer, MenuItem).

You can also review it in the terminal:

```bash
git log --oneline
git show --stat HEAD
```

The agent reports the result in chat (commit `760f835c`, 25 files, no remote) before it claims wave 2:

![Agent confirms the commit and moves to wave 2](images/val-git-synced.png)

### After wave 2

Closing wave 2 marks the function finished and adds one more commit on top (`180b570e`, 5 files, still local only).

![Git graph after wave 2](images/w2-wave2-git-graph.png)

> **Tip -** The commit history is the audit trail partners hand to the customer: what changed, in which order, and why.

> **Gotcha -** Commits fail if `user.name`/`user.email` are not set.

> **Note -** To share the trail, add a remote yourself (`git remote add origin <url>`) and push. The agent does not do this.

---

**Next:** [09-wave2.md](09-wave2.md)
