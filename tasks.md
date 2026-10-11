# AIM Workshop v2 - tasks and what worked/failed

## Done
- [x] Labs rewritten for Azure SQL + Wave 1 live flow (labs/00-12)
- [x] azure_sql/ scripts adapted for Azure SQL DB (no CREATE/USE database), FACILITATOR.md
- [x] snowflake/init.sql (+ TASTYBYTES_MIG_POOL), pat_policy.sql, teardown.sql
- [x] MkDocs site builds with --strict (docs/site/build_site.py, .github/workflows/pages.yml)

## To do
- [ ] Dry run the lab; replace images/placeholder.png with real redacted screenshots
- [ ] Replace every "Not yet observed" note with real findings (EWI codes, overrides in estimate, testing path)
- [ ] Confirm exact prompts/commands: wave definition, SPCS worker network rule for Azure SQL, dashboard
- [ ] Consolidate gotchas into TROUBLESHOOTING.md
- [ ] Push and enable Pages: gh api -X POST repos/OWNER/REPO/pages -f build_type=workflow

## Worked
- venv for mkdocs (Homebrew Python blocks system pip, PEP 668): python3 -m venv /tmp/mkvenv
- sfguide repo's 00_ddl.sql/01_data.sql reused as the Azure SQL seed
## Failed / avoid
- update_truck_inventories.dtsx is not in the sfguide repo (only daily_sales_agg.dtsx)
- Original 00_ddl.sql uses USE master / DROP DATABASE: invalid on Azure SQL DB
- Broken heredoc echo in the terminal garbles output; verify files with ls/grep

## Lab 02.2 update (from live run)
- Worked: 2.2 now documents the real flow (project -> migration subfolder -> allowlist -> SQL Server -> New connection -> form -> terminal command -> "done, added password"). Images: docs/images/connect-*.png
- Failed / avoid: `scai connection add-sql-server` without `--password` fails with CNX0005; it is not prompted. Add `--password` in the terminal, never in chat.
- Still to do: 2.3 extraction screenshot (placeholder.png), and check `mkdocs --strict` build.

- 2.3 updated from live run (Extract question + running screenshots). Extraction result and 2.4 paths (migration subfolder) NOT yet observed; 2.4 find commands are provisional.

- 2.3 ETL/Power BI questions + extraction-done screenshots added (19 objects + dtsx, 3 units). Conversion screenshots (Lab 03?) still needed; counts elsewhere (~16) may need 19.

- Lab 04: added 4.0 conversion settings (defaults) + convert-settings.png. Conversion results/EWI screenshots still needed; "convert the Wave 1 objects" prompt may not be needed (agent auto-converts everything).

- Lab 04: replaced Prompt 5 with real flow (auto convert, 19 SQL files/239 units + 1 ETL file, bindings yaml). EWI counts + assessment screenshots still needed (Lab 05). Removed 4.1 placeholder image.

- Lab 05: added 5.0 assessment questions (scope free-text keeps two waves; defaults for dynamic SQL/SSIS/discovery/lineage). Report screenshots, estimates (5.2 Prompt 7) and overrides (5.3) still to verify.

- Lab 03 rewritten: waves come from assessment; agent cannot set custom 2-wave plan (privileged planning.wave); choose "Select your 8 objects explicitly" (generated: W1 17 foundation, W2 5). Lab 03 "Confirm" tail + Lab 07/10 wave refs may need aligning.

- Lab 05 rewritten from dashboard screenshots (127.0.0.1:7878). Observed: 20 objs/2 waves, EWI-0040 x2 (views), 2 missing refs, 22 to migrate, 24h fixed effort. Note 4.1 EWI table should list SSC-EWI-0040 TOP PERCENT x2. Dashboard paths show source/_etl.
