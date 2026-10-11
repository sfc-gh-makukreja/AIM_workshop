USE TastyBytesDB;
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