CREATE PROCEDURE dbo.CustomerSearch_KitchenSinkOtus
  @CustomerID            int            = NULL,
  @CustomerName          nvarchar(100)  = NULL,
  @BillToCustomerID      int            = NULL,
  @CustomerCategoryID    int            = NULL,
  @BuyingGroupID         int            = NULL,
  @MinAccountOpenedDate  date           = NULL,
  @MaxAccountOpenedDate  date           = NULL,
  @DeliveryCityID        int            = NULL,
  @IsOnCreditHold        bit            = NULL,
  @OrdersCount			 INT			= NULL, 
  @PersonID				 INT			= NULL, 
  @DeliveryStateProvince INT			= NULL,
  @PrimaryContactPersonIDIsEmployee BIT = NULL

AS
BEGIN
  SET NOCOUNT ON;
 
  SELECT CustomerID, CustomerName, IsOnCreditHold
  FROM Sales.Customers AS Client
	JOIN Application.People AS Person ON 
		Person.PersonID = Client.PrimaryContactPersonID
	JOIN Application.Cities AS City ON
		City.CityID = Client.DeliveryCityID
  WHERE (@CustomerID IS NULL 
         OR Client.CustomerID = @CustomerID)
    AND (@CustomerName IS NULL 
         OR Client.CustomerName LIKE @CustomerName)
    AND (@BillToCustomerID IS NULL 
         OR Client.BillToCustomerID = @BillToCustomerID)
    AND (@CustomerCategoryID IS NULL 
         OR Client.CustomerCategoryID = @CustomerCategoryID)
    AND (@BuyingGroupID IS NULL 
         OR Client.BuyingGroupID = @BuyingGroupID)
    AND Client.AccountOpenedDate >= 
        COALESCE(@MinAccountOpenedDate, Client.AccountOpenedDate)
    AND Client.AccountOpenedDate <= 
        COALESCE(@MaxAccountOpenedDate, Client.AccountOpenedDate)
    AND (@DeliveryCityID IS NULL 
         OR Client.DeliveryCityID = @DeliveryCityID)
    AND (@IsOnCreditHold IS NULL 
         OR Client.IsOnCreditHold = @IsOnCreditHold)
	AND ((@OrdersCount IS NULL)
		OR ((SELECT COUNT(*) FROM Sales.Orders
			WHERE Orders.CustomerID = Client.CustomerID)
				>= @OrdersCount
			)
		)
	AND ((@PersonID IS NULL) 
		OR (Client.PrimaryContactPersonID = @PersonID))
	AND ((@DeliveryStateProvince IS NULL)
		OR (City.StateProvinceID = @DeliveryStateProvince))
	AND ((@PrimaryContactPersonIDIsEmployee IS NULL)
		OR (Person.IsEmployee = @PrimaryContactPersonIDIsEmployee)
		);
END