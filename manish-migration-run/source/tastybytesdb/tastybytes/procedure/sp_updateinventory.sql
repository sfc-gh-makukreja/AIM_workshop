USE TastyBytesDB;

GO

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
