USE TastyBytesDB;

GO

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
