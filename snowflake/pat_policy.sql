/* ============================================================================
   AIM Workshop - let a programmatic access token (PAT) work without an IP
   network policy
   ----------------------------------------------------------------------------
   By default a PAT can only be used by a user who is subject to a network
   policy. This authentication policy makes the network policy "enforced but not
   required" for PATs: if a network policy exists it is still enforced, but you
   do not need one to use a PAT. Run as ACCOUNTADMIN BEFORE generating the PAT.
   ============================================================================ */
USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS POLICY_DB;
CREATE SCHEMA IF NOT EXISTS POLICY_DB.PUBLIC;

CREATE AUTHENTICATION POLICY IF NOT EXISTS POLICY_DB.PUBLIC.pat_no_network_policy_required
  PAT_POLICY = (
    NETWORK_POLICY_EVALUATION = ENFORCED_NOT_REQUIRED
  );

-- Attach to YOUR user only (replaces any authentication policy already on it).
ALTER USER IDENTIFIER(CURRENT_USER()) UNSET AUTHENTICATION POLICY;
ALTER USER IDENTIFIER(CURRENT_USER()) SET AUTHENTICATION POLICY POLICY_DB.PUBLIC.pat_no_network_policy_required;

-- Verify: expect the policy name in the result.
SHOW PARAMETERS LIKE 'AUTHENTICATION_POLICY' IN USER IDENTIFIER(CURRENT_USER());
