# Lab 02 - Connect to Azure SQL and extract objects

**Time:** 20 min
**Goal:** start a migration project, connect to the source, and pull every object's
DDL into the project. This is the first of several short prompts.

## 2.1 Start the project

Use the cloned `AIM_workshop` repo as your workspace. In Cortex Code Desktop, open
the repo folder and start a **new chat**. You do not need to create a separate
folder. If the workspace is not empty, the agent offers to create a `migration`
subfolder for the project. Accept it.

**Prompt 1**

```text
/migration-guide start a database migration
```

Type `/` in the chat box and pick **migration-guide** from the list, then add the
words after it, or paste the whole line. The leading `/migration-guide` loads the
migration skill explicitly so the agent does not guess.

On first run the agent asks to install the Snowflake AIM for Data Warehouses
plugin. Choose **Yes, install** and **Submit**.

![Install prompt for the AIM plugin](images/start-migration.png)

The install is a one-time step. Behind the scenes the agent **clones the
migrations plugin repo, installs the plugin and its MCP server**, and then sets up
the SnowConvert AI (`scai`) dependencies. You will be asked to **Allow** each
command in turn:

1. Clone the plugin repo (`Snowflake-Labs/cortex-code-migrations`, branch `preview`).

    ![Allow: clone migrations plugin repo](images/install-1.png)

2. Install the plugin into `~/.snowflake/cortex/plugins/`.

    ![Allow: install plugin dir](images/install-2.png)

3. Register the plugin and run the dependency bootstrap.

    ![Allow: register plugin and install dependencies](images/install-3.png)

4. The agent confirms the plugin is installed.

    ![Plugin installed and ready](images/install-4.png)

> **Gotcha -** The second command shows "File write operations detected that cannot
> be auto approved". This is expected, because it writes under
> `~/.snowflake/cortex/plugins/`. Review it and select **Allow**.

> **Gotcha -** The dependency bootstrap can take a few minutes the first time.
> Wait for the agent to confirm before typing anything.

### Confirm the MCP is on

Open **Settings, MCP**. In the dropdown under the title, select **plugins://active**.
Under **From plugins** you should see `snowflake-migration` with an `mcp` entry, and
the `mcp` toggle should be **ON**.

![MCP settings with the snowflake-migration plugin MCP toggled on](images/mcp-toggle.png)

> **Gotcha -** If the toggle is OFF or the plugin is missing from the list, the agent
> cannot run migration steps. Switch the toggle ON and make sure the dropdown is set
> to `plugins://active`.

> **Tip -** If a prompt asks you to trust the migration MCP server, approve it. Then
> continue with the agent as in the next prompts (it may ask you to say "migrate").

> **Gotcha -** When asked how to get code in, choose **extract from a connected
> database**, not "local files". Local files is what the old, source-less version
> of this workshop used.

## 2.2 Connect

**Prompt 2**

```text
connect to my Azure SQL database
```

The agent now asks a short series of questions. Answer them as below.

1. **Project:** "No migration project exists in this directory". Choose **New here**.

    ![Project question](images/connect-project-question.png)

2. **Subfolder:** "The current directory isn't empty". Choose **Create a migration subfolder**. The project is created in `AIM_workshop/migration`.
3. **Allowlist:** choose **Allow**. This adds the plugin's read-only tools to your
   allowed list so you get fewer prompts. Deploy, data migration and validation still ask.
4. **Source database:** choose **SQL Server** (Azure SQL uses the SQL Server dialect).

    ![Allowlist and source database](images/connect-allowlist-source.png)

    The agent picks "fresh start" and "extract from a connected database" on its own.

5. **Connection:** choose **New connection**. Saved connections on your machine are listed too; ignore them.

    ![Choose a connection](images/connect-choose-connection.png)

6. Fill in the form with the details from your facilitator and **Submit**.

    ![Connection details form](images/connect-details-form.png)

7. The agent will not take the password in chat. It gives you a command to run in the
   terminal. Use **Insert into Terminal** (or copy it) and run it. The `!` prefix runs it inside this session.

    ![Insert the command into the terminal](images/connect-run-command.png)

    ```bash
    scai connection add-sql-server -s <connection-name> --auth standard \
      --server-url <server>.database.windows.net --port 1433 \
      --database TastyBytesDB --user demo_user --encrypt --trust-server-certificate
    ```

    **Add `--password <your password>` at the end** and press Enter. Replace the placeholder with the password from your facilitator.

    ![Connection added successfully](images/connect-added.png)

8. Reply **done, added password** in the chat. The agent tests the connection, saves it,
   and moves on to extraction.

    ![Connection tested, next step is extraction](images/connect-tested.png)

> **Gotcha -** Running the command without `--password` fails with `CNX0005 Missing required parameters`. The prompt does not ask interactively. Re-run it with `--password`.

> **Gotcha -** The password is typed in your terminal, so it is not sent to the chat. Do not paste it into the chat.

> **Gotcha -** Azure SQL requires encryption. A timeout or "cannot open server" means
> the server name or port is wrong, or the facilitator has not opened the server yet.

> **Gotcha -** `Cannot open database "TastyBytesDB"` usually means a typo; the agent
> can list databases with `SELECT name FROM sys.databases` (it asks you to Allow this).

## 2.3 Extract

Once the connection test passes, the agent moves on by itself (it asks you to **Allow**
`progress_setup`) and shows an **Extract** question: *What would you like to extract from
TastyBytesDB?*

![Extract question](images/extract-question.png)

Choose **All objects**, or copy this answer into the box:

```text
All objects
```

(If you type your own answer, for example a wave plan, the agent
still extracts everything first and handles waves later, when you start migration.)

![Extraction running](images/extract-running.png)

Watch what is extracted: 19 objects (schemas, 11 tables, 1 view, 1 function, 1 procedure).

### ETL and Power BI

After extraction the agent asks about ETL code (SSIS or Informatica) and Power BI `.pbit`
files.

![ETL question](images/extract-etl-question.png)

Answer **Yes** and paste this as the folder answer:

```text
yes, its under etl/ folder in the repo root dir
```

Answer **No** for Power BI.
The agent runs `scai code add -i ../etl` from the `migration` folder.

![Adding ETL code](images/extract-etl-add.png)

When it finishes, the agent reports all 19 TastyBytesDB objects (database, schemas, tables,
view, function, procedure) plus the SSIS package `daily_sales_agg.dtsx` with its 3 code
units. Allow `progress_setup` and it moves on to conversion.

![Extraction done](images/extract-done.png)

> **Tip -** You do not type a separate extract prompt. The agent asks, and you answer with the text above.

---

**Next:** [03-wave-plan.md](03-wave-plan.md)
