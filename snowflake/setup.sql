/* ============================================================================
   AIM Workshop — Snowflake target setup
   ----------------------------------------------------------------------------
   Run this ONCE in your own Snowflake trial account before Lab 01.
   Run it in a Snowsight worksheet, as ACCOUNTADMIN.

   What this creates:
     - Database TASTYBYTESDB with schemas TASTYBYTES and ETL_RESULTS
     - Warehouse XSMALL_WH

   What this deliberately does NOT create:
     - A compute pool. The reference project uses one for the data-migration
       worker (Snowpark Container Services). This workshop skips data
       migration, and trial accounts may not have container services enabled.

   Everything else in TASTYBYTESDB gets created by YOU during the labs, by
   deploying the converted objects. The schemas are pre-created only so the
   very first deploy has somewhere to land.
   ============================================================================ */

USE ROLE ACCOUNTADMIN;

-- Warehouse the migration agent will run all its SQL through.
CREATE WAREHOUSE IF NOT EXISTS XSMALL_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
       AUTO_SUSPEND   = 60
       AUTO_RESUME    = TRUE
       COMMENT        = 'AIM Workshop warehouse';

USE WAREHOUSE XSMALL_WH;

/* CREATE OR REPLACE, not IF NOT EXISTS: re-running this script is the
   supported way to reset to a clean slate if a lab goes sideways.
   WARNING: this drops anything you already deployed. */
CREATE OR REPLACE DATABASE TASTYBYTESDB
  COMMENT = 'AIM Workshop — SQL Server TastyBytes migration target';

USE DATABASE TASTYBYTESDB;

CREATE OR REPLACE SCHEMA TASTYBYTES
  COMMENT = 'Migrated application objects';

CREATE OR REPLACE SCHEMA ETL_RESULTS
  COMMENT = 'ETL logging and reporting tables written by the migrated SSIS package';

/* Do NOT drop the auto-created PUBLIC schema. The ETL deploy in Lab 07 stages
   supporting artifacts (file formats, etl_configuration) into
   TASTYBYTESDB.PUBLIC, and fails with "Schema 'TASTYBYTESDB.PUBLIC' does not
   exist or not authorized" if it is missing. */

-- ----------------------------------------------------------------------------
-- Verify. Expect: TASTYBYTES and ETL_RESULTS, and a running XSMALL_WH.
-- ----------------------------------------------------------------------------
SHOW SCHEMAS IN DATABASE TASTYBYTESDB;
SHOW WAREHOUSES LIKE 'XSMALL_WH';

SELECT CURRENT_ACCOUNT()   AS account,
       CURRENT_ROLE()      AS role,
       CURRENT_DATABASE()  AS database,
       CURRENT_WAREHOUSE() AS warehouse;
