# Lab 00 - Prerequisites and orientation

**Time:** 15 min (install Cortex Code Desktop, Python and git a week ahead)
**Goal:** every tool works before the labs start.

## 0.1 What you need

| Need | Check |
|---|---|
| Snowflake account with `ACCOUNTADMIN`, set up with your facilitator at the start | Snowsight: `USE ROLE ACCOUNTADMIN;` |
| Cortex Code Desktop with the migration skill | Ask in chat: `what migration skills do you have?` and look for `migration-guide` |
| Python and git, git with name and email set | Ask Cortex Code: `check my git user name and email` |
| Azure SQL details from your facilitator | server, port, database, user, password |

> **Note -** Everything runs in Cortex Code Desktop. You do not run `scai` or `snow` yourself; the agent does.

![Cortex Code Desktop answering the migration skills question](images/skills-answer.png)

> **Tip -** Expect `migration-guide` (the T-SQL and SSIS path) at the top, and
> `spark-migration` as a neighbour you do not need. The migration skill is bundled;
> there is no separate plugin to install. Wording and the list of related skills vary.

## 0.2 Get the repo

In Cortex Code Desktop, ask:

> clone https://github.com/sfc-gh-makukreja/AIM_workshop into ~/projects and open it

or use GitHub's **Code** button and open the folder.

## 0.3 How this lab works

You will give Cortex Code **short prompts, one step at a time**, and read what it
did before moving on. The agent is non-deterministic: wording and order differ
between people. Prompts here are guidance, not incantations. When lost, ask:

> what is the current state of the migration?

> **Tip -** Run `/compact` between labs. The migration agent is context-hungry.

## 0.4 What we migrate

**TastyBytes**, a fictional food-truck network, living in an Azure SQL Database.
We migrate it in **waves**:

| Wave | Objects | In this workshop |
|---|---|---|
| **1** | Database `TastyBytesDB`, schema `TastyBytes`, tables `Customer`, `OrderHeader`, `OrderDetail`, `MenuItem`, view `vw_TopSellingItems`, function `fn_FormatCustomerName` | Live, end to end |
| **2** | Remaining tables, procedure `sp_UpdateInventory`, SSIS packages | [Documented](09-wave2.md), self-paced |

---

**Next:** [01-account-setup.md](01-account-setup.md)
