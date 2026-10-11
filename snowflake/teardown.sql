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
ALTER USER IDENTIFIER(CURRENT_USER()) UNSET AUTHENTICATION POLICY;
DROP DATABASE IF EXISTS POLICY_DB;
DROP WAREHOUSE IF EXISTS XSMALL_WH;

-- Stop any worker service first (name varies; list with SHOW SERVICES IN ACCOUNT).
DROP COMPUTE POOL IF EXISTS TASTYBYTES_MIG_POOL;

-- ----------------------------------------------------------------------------
-- Verify. Both SHOWs should return zero rows.
-- ----------------------------------------------------------------------------
SHOW DATABASES LIKE 'TASTYBYTESDB';
SHOW WAREHOUSES LIKE 'XSMALL_WH';
