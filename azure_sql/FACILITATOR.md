# Facilitator guide - the shared Azure SQL source

Attendees only *connect* to a shared Azure SQL Database. You provision it once.

## 1. Create the server and database

```bash
az group create -n aim-workshop-rg -l <region>
az sql server create -g aim-workshop-rg -n <unique-server-name> -l <region> \
  --admin-user sqladmin --admin-password '<strong password>'
az sql db create -g aim-workshop-rg -s <unique-server-name> -n TastyBytesDB \
  --service-objective S0
```

## 2. Firewall

For the workshop the server is open to the internet, so attendees' laptops and the
**SPCS data-migration worker** (which connects from Snowflake) can both reach it:

```bash
az sql server firewall-rule create -g aim-workshop-rg -s <server> -n open-for-workshop \
  --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255
```

This is acceptable only because the database holds fictional data and `demo_user`
is read-only. Remove the rule (or delete the resource group) afterwards.

## 3. Load the data (connect to TastyBytesDB, in this order)

1. `00_ddl.sql` - schemas, tables, view, function, procedure
2. `01_data.sql` - sample data
3. `02_user.sql` - read-only `demo_user` (step 1 on `master`, step 2 on `TastyBytesDB`)

## 4. Verify

```sql
SELECT s.name AS schema_name, COUNT(*) AS tables
FROM sys.tables t JOIN sys.schemas s ON s.schema_id = t.schema_id GROUP BY s.name;
SELECT COUNT(*) FROM TastyBytes.OrderHeader;
```

## 5. Hand out

Give attendees: server FQDN (`<server>.database.windows.net`), port 1433,
database `TastyBytesDB`, user `demo_user`, password. Azure SQL requires
encryption: they must pass encrypt on.

## 6. Afterwards

`az group delete -n aim-workshop-rg --yes`
