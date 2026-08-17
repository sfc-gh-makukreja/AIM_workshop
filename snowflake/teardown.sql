/* ============================================================================
   AIM Workshop — teardown
   ----------------------------------------------------------------------------
   Run this after the workshop to remove everything the labs created in your
   Snowflake account. Safe to run more than once.

   This does NOT touch your local migration project folder — delete
   AIM_workshop/my-migration/ yourself if you want a truly clean slate.
   ============================================================================ */

USE ROLE ACCOUNTADMIN;

DROP DATABASE IF EXISTS TASTYBYTESDB;
DROP WAREHOUSE IF EXISTS XSMALL_WH;

/* Only needed if you also ran the reference project's init.sql, which creates
   a compute pool for data migration. This workshop never creates one. */
DROP COMPUTE POOL IF EXISTS TASTYBYTES_MIG_POOL;

-- ----------------------------------------------------------------------------
-- Verify. Both SHOWs should return zero rows.
-- ----------------------------------------------------------------------------
SHOW DATABASES LIKE 'TASTYBYTESDB';
SHOW WAREHOUSES LIKE 'XSMALL_WH';
