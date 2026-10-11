# Lab 11 - Wrap-up and teardown

**Time:** 15 min

## 11.1 What you proved

- Structure and semantics: conversion, deploy, tests
- Data: migrated on SPCS and validated against the live source
- Scale-out: waves, estimates, and a git audit trail

## 11.2 Taking this to a customer

1. Point `scai connection add-sql-server` at the customer's server.
2. Re-run the same prompts; define waves around *their* top-level business objects.
3. Show the estimate with its overrides before you discuss price.

## 11.3 Teardown

Run [snowflake/teardown.sql](https://github.com/sfc-gh-makukreja/AIM_workshop/blob/main/snowflake/teardown.sql)
as `ACCOUNTADMIN`. Revoke the PAT in Snowsight. The facilitator removes the Azure resource group.
