USE TastyBytesDB;
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