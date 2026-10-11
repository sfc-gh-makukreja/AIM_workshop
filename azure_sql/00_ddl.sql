/*******************************************************************************
 * TASTY BYTES — Global Food Truck Network
 * SQL Server Workload (Transact-SQL)
 *
 * This script creates the full schema for Tasty Bytes: a fictitious global
 * food truck company with localized menu options, customer loyalty, order
 * management, inventory tracking, and employee scheduling.
 *
 * Object types: Tables, Views, Functions, Stored Procedures
 * Deliberately uses T-SQL constructs that generate SnowConvert EWIs.
 ******************************************************************************/

-- Required session settings. JDBC clients (DataGrip, etc.) often connect with
-- ANSI_WARNINGS OFF, which causes error 1934 on SCHEMA_ID, computed columns,
-- and OPENJSON unless corrected before any other statement runs.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_WARNINGS ON;
SET ANSI_PADDING ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO

-- ============================================================================
-- DATABASE & SCHEMA SETUP
-- ============================================================================
-- Azure SQL Database: create the (empty) database TastyBytesDB in the portal or
-- with `az sql db create` first (see FACILITATOR.md), then connect to it and run
-- this script. Azure SQL does not support USE <other db>, CREATE DATABASE here
-- or DROP DATABASE from inside the database.
CREATE SCHEMA TastyBytes;
GO

CREATE SCHEMA etl_results;
GO

-- --------------------------------------------------------------------------
-- ETL audit log
-- Used by the SSIS package(s) to record start/end markers for each run.
-- The package executes:
--   INSERT INTO etl_results.etl_logs(name, execution_date)
--   VALUES ('start execution', CURRENT_TIMESTAMP);
--   INSERT INTO etl_results.etl_logs(name, execution_date)
--   VALUES ('endexecution',    CURRENT_TIMESTAMP);
-- --------------------------------------------------------------------------
CREATE TABLE etl_results.etl_logs (
    LogID           INT IDENTITY(1,1),
    name            NVARCHAR(200) NOT NULL,
    execution_date  DATETIME NOT NULL
);
GO

-- ============================================================================
-- TABLES
-- ============================================================================

-- --------------------------------------------------------------------------
-- 1. Country
--    EWI triggers: FDM-TS0014 (computed column)
-- --------------------------------------------------------------------------
CREATE TABLE TastyBytes.Country (
    CountryID       INT IDENTITY(1,1),
    CountryName     NVARCHAR(100) NOT NULL,
    CountryCode     CHAR(3) NOT NULL,
    CurrencyCode    CHAR(3) NOT NULL,
    TaxRate         DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    DisplayName     AS (CountryCode + N' - ' + CurrencyCode),
    IsActive        BIT NOT NULL DEFAULT 1,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedAt      DATETIME NULL
);
GO

-- --------------------------------------------------------------------------
-- 2. City
-- --------------------------------------------------------------------------
CREATE TABLE TastyBytes.City (
    CityID          INT IDENTITY(1,1),
    CityName        NVARCHAR(150) NOT NULL,
    CountryID       INT NOT NULL,
    StateProvince   NVARCHAR(100) NULL,
    Latitude        DECIMAL(9,6) NULL,
    Longitude       DECIMAL(9,6) NULL,
    PopulationSize  INT NULL,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- --------------------------------------------------------------------------
-- 3. FoodTruck
--    EWI triggers: ROWGUIDCOL
-- --------------------------------------------------------------------------
CREATE TABLE TastyBytes.FoodTruck (
    TruckID         INT IDENTITY(1,1),
    TruckGUID       UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL DEFAULT NEWID(),
    TruckName       NVARCHAR(200) NOT NULL,
    LicensePlate    VARCHAR(20) NOT NULL,
    CityID          INT NOT NULL,
    TruckConfig     NVARCHAR(MAX) NULL,
    YearPurchased   INT NULL,
    MaxCapacity     INT NOT NULL DEFAULT 500,
    IsOperational   BIT NOT NULL DEFAULT 1,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedAt      DATETIME NULL
);
GO

-- --------------------------------------------------------------------------
-- 4. Menu
--    EWI triggers: MONEY type, NTEXT (deprecated)
-- --------------------------------------------------------------------------
CREATE TABLE TastyBytes.Menu (
    MenuID          INT IDENTITY(1,1),
    MenuName        NVARCHAR(200) NOT NULL,
    TruckID         INT NOT NULL,
    CuisineType     NVARCHAR(100) NOT NULL,
    MenuDescription NTEXT NULL,
    BasePriceTier   MONEY NOT NULL DEFAULT 0.00,
    IsSeasonalMenu  BIT NOT NULL DEFAULT 0,
    EffectiveFrom   DATE NOT NULL DEFAULT GETDATE(),
    EffectiveTo     DATE NULL,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- --------------------------------------------------------------------------
-- 5. MenuItem
--    EWI triggers: FDM-TS0014 (computed column), ROWVERSION
-- --------------------------------------------------------------------------
CREATE TABLE TastyBytes.MenuItem (
    MenuItemID      INT IDENTITY(1,1),
    MenuID          INT NOT NULL,
    ItemName        NVARCHAR(200) NOT NULL,
    ItemDescription NVARCHAR(MAX) NULL,
    BasePrice       MONEY NOT NULL,
    CalorieCount    INT NULL,
    IsVegetarian    BIT NOT NULL DEFAULT 0,
    IsGlutenFree    BIT NOT NULL DEFAULT 0,
    IsSpicy         BIT NOT NULL DEFAULT 0,
    PriceWithTax    AS (CAST(BasePrice * 1.08 AS DECIMAL(10,2))),
    RowVer          ROWVERSION,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- --------------------------------------------------------------------------
-- 6. Customer
--    EWI triggers: UNIQUEIDENTIFIER + NEWID()
-- --------------------------------------------------------------------------
CREATE TABLE TastyBytes.Customer (
    CustomerID      INT IDENTITY(1,1),
    CustomerGUID    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    FirstName       NVARCHAR(100) NOT NULL,
    LastName        NVARCHAR(100) NOT NULL,
    Email           VARCHAR(255) NULL,
    PhoneNumber     VARCHAR(20) NULL,
    PreferredCityID INT NULL,
    LoyaltyPoints   INT NOT NULL DEFAULT 0,
    MemberSince     DATE NOT NULL DEFAULT GETDATE(),
    IsActive        BIT NOT NULL DEFAULT 1,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedAt      DATETIME NULL
);
GO

-- --------------------------------------------------------------------------
-- 7. OrderHeader
--    CompletedAt changed from DATETIMEOFFSET to DATETIME so the cloud data
--    migration ODBC/Arrow worker can convert the column without ArrowTypeError.
--    Timezone information is dropped intentionally.
-- --------------------------------------------------------------------------
CREATE TABLE TastyBytes.OrderHeader (
    OrderID         INT IDENTITY(1,1),
    CustomerID      INT NOT NULL,
    TruckID         INT NOT NULL,
    OrderDate       DATETIME NOT NULL DEFAULT GETDATE(),
    CompletedAt     DATETIME NULL,
    OrderStatus     VARCHAR(20) NOT NULL DEFAULT 'Pending',
    TotalAmount     MONEY NOT NULL DEFAULT 0.00,
    TipAmount       MONEY NULL DEFAULT 0.00,
    PaymentMethod   VARCHAR(30) NULL,
    OrderNotes      NVARCHAR(500) NULL,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedAt      DATETIME NULL
);
GO

-- --------------------------------------------------------------------------
-- 8. OrderDetail
--    EWI triggers: Compound PK, SMALLMONEY
-- --------------------------------------------------------------------------
CREATE TABLE TastyBytes.OrderDetail (
    OrderID         INT NOT NULL,
    LineNumber      INT NOT NULL,
    MenuItemID      INT NOT NULL,
    Quantity        INT NOT NULL DEFAULT 1,
    UnitPrice       SMALLMONEY NOT NULL,
    Discount        SMALLMONEY NOT NULL DEFAULT 0.00,
    LineTotal       AS (CAST((Quantity * UnitPrice) - Discount AS DECIMAL(10,2))),
    SpecialRequests NVARCHAR(300) NULL
);
GO

-- --------------------------------------------------------------------------
-- 9. Inventory
--    EWI triggers: SPARSE column
-- --------------------------------------------------------------------------
CREATE TABLE TastyBytes.Inventory (
    InventoryID     INT IDENTITY(1,1),
    TruckID         INT NOT NULL,
    IngredientName  NVARCHAR(200) NOT NULL,
    QuantityOnHand  DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    UnitOfMeasure   VARCHAR(20) NOT NULL,
    ReorderLevel    DECIMAL(10,2) NOT NULL DEFAULT 10.00,
    SupplierNotes   NVARCHAR(500) SPARSE NULL
);
GO

-- --------------------------------------------------------------------------
-- 10. EmployeeShift
--    StartTime/EndTime changed from TIME to DATETIME so the cloud data
--    migration ODBC/Arrow worker can convert these columns. The HoursWorked
--    computed column still works correctly because DATEDIFF(MINUTE, ...) is
--    valid on DATETIME values.
-- --------------------------------------------------------------------------
CREATE TABLE TastyBytes.EmployeeShift (
    ShiftID         INT IDENTITY(1,1),
    EmployeeName    NVARCHAR(200) NOT NULL,
    TruckID         INT NOT NULL,
    ShiftDate       DATE NOT NULL,
    StartTime       DATETIME NOT NULL,
    EndTime         DATETIME NOT NULL,
    HoursWorked     AS (DATEDIFF(MINUTE, StartTime, EndTime) / 60.0),
    Role            VARCHAR(50) NOT NULL DEFAULT 'Cook',
    HourlyRate      SMALLMONEY NOT NULL,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================================
-- VIEWS
-- ============================================================================

-- --------------------------------------------------------------------------
-- 1. vw_TopSellingItems — TOP 1 PERCENT + UNION
--    EWI triggers: SSC-EWI-TS0006 (TOP N PERCENT not supported in
--    Snowflake SELECT).
--    Combines the top sellers ranked by quantity with those ranked by
--    revenue into a single result set.
-- --------------------------------------------------------------------------
CREATE VIEW TastyBytes.vw_TopSellingItems
AS
    SELECT * FROM (
        SELECT TOP 1 PERCENT
            mi.MenuItemID, mi.ItemName,
            SUM(od.Quantity)                AS TotalQuantitySold,
            SUM(od.Quantity * od.UnitPrice) AS TotalRevenue,
            'By Quantity'                   AS RankingBasis
        FROM TastyBytes.OrderDetail od
        INNER JOIN TastyBytes.OrderHeader oh ON od.OrderID = oh.OrderID
        INNER JOIN TastyBytes.MenuItem  mi ON od.MenuItemID = mi.MenuItemID
        WHERE oh.OrderStatus = 'Completed'
        GROUP BY mi.MenuItemID, mi.ItemName
        ORDER BY SUM(od.Quantity) DESC, mi.MenuItemID
    ) AS q
    UNION
    SELECT * FROM (
        SELECT TOP 1 PERCENT
            mi.MenuItemID, mi.ItemName,
            SUM(od.Quantity)                AS TotalQuantitySold,
            SUM(od.Quantity * od.UnitPrice) AS TotalRevenue,
            'By Revenue'                    AS RankingBasis
        FROM TastyBytes.OrderDetail od
        INNER JOIN TastyBytes.OrderHeader oh ON od.OrderID = oh.OrderID
        INNER JOIN TastyBytes.MenuItem  mi ON od.MenuItemID = mi.MenuItemID
        WHERE oh.OrderStatus = 'Completed'
        GROUP BY mi.MenuItemID, mi.ItemName
        ORDER BY SUM(od.Quantity * od.UnitPrice) DESC, mi.MenuItemID
    ) AS r;
GO

-- ============================================================================
-- USER-DEFINED FUNCTIONS
-- ============================================================================

-- --------------------------------------------------------------------------
-- 1. fn_FormatCustomerName — simple scalar UDF.
--    Takes a CustomerID, looks up the row in TastyBytes.Customer, and
--    returns "LASTNAME, Firstname" (last name uppercased, first name trimmed).
--    Uses only built-ins available in both SQL Server and Snowflake:
--    UPPER, LTRIM, RTRIM, ISNULL/COALESCE, string concatenation.
-- --------------------------------------------------------------------------
CREATE   FUNCTION TastyBytes.fn_FormatCustomerName
(
    @P_CustomerID INT
)
RETURNS NVARCHAR(402)
AS
BEGIN
    DECLARE @FullName NVARCHAR(402);

    SELECT @FullName =
        CAST(
            UPPER(RTRIM(LTRIM(ISNULL(LastName, '')))) +
            ', ' +
            RTRIM(LTRIM(ISNULL(FirstName, '')))
        AS NVARCHAR(402))
    FROM TastyBytes.Customer
    WHERE CustomerID = @P_CustomerID;

    RETURN @FullName;
END
GO

-- ============================================================================
-- STORED PROCEDURES
-- ============================================================================

-- --------------------------------------------------------------------------
-- 1. sp_UpdateInventory
--    Restocks inventory for a truck. Caller passes the stock count and a
--    flag controlling how it is applied:
--      * @Override = 1 — sets QuantityOnHand to @StockCount.
--      * @Override = 0 — adds @StockCount to the existing QuantityOnHand.
--    Returns no result set.
-- --------------------------------------------------------------------------
CREATE PROCEDURE TastyBytes.sp_UpdateInventory
    @TruckID     INT            = NULL,
    @StockCount  DECIMAL(10, 2) = 0,
    @Override    BIT            = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @TruckID IS NULL
        RETURN;

    IF @Override = 1
        UPDATE TastyBytes.Inventory
        SET QuantityOnHand = @StockCount
        WHERE TruckID = @TruckID;
    ELSE
        UPDATE TastyBytes.Inventory
        SET QuantityOnHand = QuantityOnHand + @StockCount
        WHERE TruckID = @TruckID;
END;
GO

-- EWI: TS0002 — ANSI_PADDING OFF not supported in Snowflake
SET ANSI_PADDING OFF;
GO

-- EWI: TS0003 — ANSI_WARNINGS OFF not supported in Snowflake
SET ANSI_WARNINGS OFF;
GO

-- Restore session settings so the script can be re-run in the same connection
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
GO

PRINT '=== Tasty Bytes workload deployment complete ===';
GO
