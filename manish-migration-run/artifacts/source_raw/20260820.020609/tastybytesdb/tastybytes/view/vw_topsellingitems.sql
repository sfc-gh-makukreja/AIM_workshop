USE TastyBytesDB;
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