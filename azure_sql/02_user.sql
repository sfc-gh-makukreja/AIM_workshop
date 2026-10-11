-- Read-only + execute account for the migration (Azure SQL Database).
-- Run in two steps.
-- STEP 1: connected to the **master** database on the logical server:
--   CREATE LOGIN demo_user WITH PASSWORD = '<strong password>';
-- STEP 2: connected to **TastyBytesDB**:
CREATE USER demo_user FOR LOGIN demo_user;
GRANT SELECT ON DATABASE::TastyBytesDB TO demo_user;
GRANT EXECUTE ON DATABASE::TastyBytesDB TO demo_user;
-- Metadata visibility used by extraction (sys.* definitions, dependencies):
GRANT VIEW DEFINITION ON DATABASE::TastyBytesDB TO demo_user;
