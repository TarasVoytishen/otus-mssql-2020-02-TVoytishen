

CREATE OR ALTER PROCEDURE dbo.CustomerSearch_KitchenSinkOtus2
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

  declare @query nvarchar(max);

  set @query='SELECT CustomerID, CustomerName, IsOnCreditHold
    FROM Sales.Customers AS Client
	JOIN Application.People AS Person ON 
		Person.PersonID = Client.PrimaryContactPersonID
	JOIN Application.Cities AS City ON
		City.CityID = Client.DeliveryCityID
	WHERE 1=1	';

  if NOT @CustomerID IS NULL 
	set @query=@query+'
		AND Client.CustomerID = @CustomerID1
		';	
		
  if NOT @CustomerName IS NULL 
	set @query=@query+'
		AND Client.CustomerName LIKE @CustomerName1
		';	
		
  if NOT @BillToCustomerID IS NULL 
	set @query=@query+'
		AND Client.BillToCustomerID = @BillToCustomerID1
		';	
		
  if NOT @CustomerCategoryID IS NULL 
	set @query=@query+'
		AND Client.CustomerCategoryID = @CustomerCategoryID1
		';	
  if NOT @BuyingGroupID IS NULL 
	set @query=@query+'
		AND Client.BuyingGroupID = @BuyingGroupID1
		';	
  if NOT @MinAccountOpenedDate IS NULL 
	set @query=@query+'
		AND Client.AccountOpenedDate >= @MinAccountOpenedDate1
		';	
  if NOT @MaxAccountOpenedDate IS NULL 
	set @query=@query+'
		AND Client.AccountOpenedDate <= @MaxAccountOpenedDate1
		';	
  if NOT @DeliveryCityID IS NULL 
	set @query=@query+'
		AND Client.DeliveryCityID = @DeliveryCityID1
		';	
  if NOT @IsOnCreditHold IS NULL 
	set @query=@query+'
		AND Client.IsOnCreditHold = @IsOnCreditHold1
		';	
  if NOT @OrdersCount IS NULL 
	set @query=@query+'
		AND (SELECT COUNT(*) FROM Sales.Orders
			WHERE Orders.CustomerID = Client.CustomerID)
				>= @OrdersCount1)
		';	
  if NOT @PersonID IS NULL 
	set @query=@query+'
		AND Client.PrimaryContactPersonID = @PersonID1
		';	
  if NOT @DeliveryStateProvince IS NULL 
	set @query=@query+'
		AND City.StateProvinceID = @DeliveryStateProvince1
		';	
  if NOT @PrimaryContactPersonIDIsEmployee IS NULL 
	set @query=@query+'
		AND Person.IsEmployee = @PrimaryContactPersonIDIsEmployee1
		';	

print(@query);

declare @qparams nvarchar(1000);
set @qparams=
' @CustomerID1            int,
  @CustomerName1          nvarchar(100),
  @BillToCustomerID1      int,
  @CustomerCategoryID1    int,
  @BuyingGroupID1         int,
  @MinAccountOpenedDate1  date,
  @MaxAccountOpenedDate1  date,
  @DeliveryCityID1        int,
  @IsOnCreditHold1        bit,
  @OrdersCount1			 INT, 
  @PersonID1				 INT, 
  @DeliveryStateProvince1 INT,
  @PrimaryContactPersonIDIsEmployee1 BIT
';

EXECUTE sp_executesql 
@query,
@qparams
,
  @CustomerID1=@CustomerID,
  @CustomerName1=@CustomerName,
  @BillToCustomerID1=@BillToCustomerID,
  @CustomerCategoryID1=@CustomerCategoryID,
  @BuyingGroupID1=@BuyingGroupID,
  @MinAccountOpenedDate1=@MinAccountOpenedDate,
  @MaxAccountOpenedDate1=@MaxAccountOpenedDate,
  @DeliveryCityID1=@DeliveryCityID,
  @IsOnCreditHold1=@IsOnCreditHold,
  @OrdersCount1=@OrdersCount, 
  @PersonID1=@PersonID, 
  @DeliveryStateProvince1=@DeliveryStateProvince,
  @PrimaryContactPersonIDIsEmployee1=@PrimaryContactPersonIDIsEmployee

;


END

exec dbo.CustomerSearch_KitchenSinkOtus2 
/********************************************************************/

