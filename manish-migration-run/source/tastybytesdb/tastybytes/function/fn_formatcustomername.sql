USE TastyBytesDB;

GO

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
