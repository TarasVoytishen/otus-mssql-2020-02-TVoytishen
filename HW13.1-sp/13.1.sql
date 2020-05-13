/*
SP и function
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.

Во всех процедурах, в описании укажите для преподавателям
5) какой уровень изоляции нужен и почему.

Опционально
6) Переписываем одну и ту же процедуру kitchen sink с множеством входных параметров по поиску в заказах на динамический SQL.

Сравниваем планы запроса.

7) Напишите запрос в транзакции где есть выборка, 
вставка\добавление\удаление данных и параллельно запускаем выборку данных в разных уровнях изоляции, 
нужно предоставить мини отчет, 
что на каком уровне было видно со скриншотами и ваши выводы (1-2 предложение)

8) Сделайте параллельно в 2х окнах добавление данных в одну таблицу с разным уровнем изоляции, 
изменение данных в одной таблице, 
изменение одной и той же строки. 
Что в итоге получилось, что нового узнали.
*/

--1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
use WideWorldImporters
go

create or alter function dbo.getBestClient()
returns nvarchar(100)
as
begin
	declare @resultName nvarchar(100);

	/*  СТАРЫЙ ЗАПРОС
	select top 1
		@resultName=sc.CustomerName
	from 
		Sales.Customers sc
	where sc.CustomerId IN (
							select top 1 
								MaximumSales.CustomerID
							from	
								(select 
									SUM(sil.Quantity*sil.UnitPrice) as SaleSum,
									
									si.CustomerID
								from
									Sales.InvoiceLines sil
								join 
									Sales.Invoices si on sil.InvoiceID=si.InvoiceID
								group by
									si.CustomerID) as MaximumSales
							order by 
								MaximumSales.SaleSum desc);
	*/

	--новый запрос
	select top 1
		@resultName=sc.CustomerName
	from
		Sales.InvoiceLines sil
	join 
		Sales.Invoices si on sil.InvoiceID=si.InvoiceID
	join
		Sales.Customers sc on si.CustomerID=sc.CustomerID
	group by
		sc.CustomerName
	order by 
		SUM(sil.Quantity*sil.UnitPrice) desc

	return @resultName;

end;
go

--проверка
select dbo.getBestClient() as BestClient;

--2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
use WideWorldImporters
go

create or alter procedure dbo.getSaleSumForClient
@CustomerID int,
@SaleSum decimal(18,2) output
as
begin
	
	select 
		@SaleSum=SUM(sil.Quantity*sil.UnitPrice)
	from
		Sales.InvoiceLines sil
	join 
		Sales.Invoices si on sil.InvoiceID=si.InvoiceID
	where 
		si.CustomerID=@CustomerID;
	
end;
go

--проверяем
declare @SaleSum decimal(18,3);
exec dbo.getSaleSumForClient 2,@SaleSum output;
select @SaleSum as SaleSum;

--3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.

--сделаем такую же функцию как и процедура
go
create or alter function dbo.getSaleSumForClientF
(@CustomerID int)

returns decimal(18,2)
as
begin
	declare @SaleSum decimal(18,3)
	select 
		--@CustomerID=
		@SaleSum=SUM(sil.Quantity*sil.UnitPrice)
	from
		Sales.InvoiceLines sil
	join 
		Sales.Invoices si on sil.InvoiceID=si.InvoiceID
	where 
		si.CustomerID=@CustomerID;

	return @SaleSum;
		
end;	

go

--проверка
select dbo.getSaleSumForClientF(2) as SaleSum;

--смотрим разницу в производительности
select dbo.getSaleSumForClientF(6) as SaleSum;
declare @SaleSum decimal(18,2);
exec dbo.getSaleSumForClient 6,@SaleSum output;
select @SaleSum as SaleSum;

--это тоже сразу смотрим
select dbo.getSaleSumForClientF(6) as SaleSum;
exec dbo.getSaleSumForClient 6,@SaleSum output;
select @SaleSum as SaleSum;

--и то же самое в виде просто запроса
select 
		SUM(sil.Quantity*sil.UnitPrice) as SaleSum
	from
		Sales.InvoiceLines sil
	join 
		Sales.Invoices si on sil.InvoiceID=si.InvoiceID
	where 
		si.CustomerID=6;

--и вот здесь странное(или пока не понял) - функция выдает результат за 0% времени, как-бы использует уже вычисленное значение


--4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.

--сделаем табличную функцию которая выдаст 
--таблицу 
--SaleSum, InvoiceID
--топ 10 invoice для клиента

go
create or alter function dbo.getTop10InvoicesForClientF(@CustomerID int)
returns TABLE
as
Return(
	select top 10 
		CustomerInvoiceSum.SaleSum,
		CustomerInvoiceSum.InvoiceID
	from(
		select top 10
			si.InvoiceID,
			SUM(sil.Quantity*sil.UnitPrice) as SaleSum
		from
			Sales.InvoiceLines sil
		join 
			Sales.Invoices si on sil.InvoiceID=si.InvoiceID
		where 
			si.CustomerID=@CustomerID
		group by
			si.CustomerID,
			si.InvoiceID) as CustomerInvoiceSum
	order by 
		CustomerInvoiceSum.SaleSum desc
	);
go

--проверка
select * from dbo.getTop10InvoicesForClientF(4);
	
--как ее можно вызвать для каждой строки result set'а без использования цикла
--используем Cross Apply

select 
	sc.CustomerName,
	sc.CustomerID,
	sc_top10invoice.InvoiceID,
	sc_top10invoice.SaleSum
from
	Sales.Customers sc
cross apply dbo.getTop10InvoicesForClientF(sc.CustomerID) as sc_top10invoice
order by 
	sc.CustomerID,
	sc_top10invoice.SaleSum desc;


	

--Во всех процедурах, в описании укажите для преподавателям
--5) какой уровень изоляции нужен и почему.

--пока делаю


--Опционально
--6) Переписываем одну и ту же процедуру kitchen sink с множеством входных параметров по поиску в заказах на динамический SQL.


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

--проверяем что работает
exec dbo.CustomerSearch_KitchenSinkOtus2 29;

--сравниваем как работает по сравнению с обычной
exec dbo.CustomerSearch_KitchenSinkOtus2 2;--39% --на динамическом быстрее
exec dbo.CustomerSearch_KitchenSinkOtus 2;--61%
--картинка скриншот с планами запроса kitten_sink_static_vs_dynamic_sql.jpg
--видно что в общем случае динамический sql быстрее (так как нет лишних условий) и план запроса проще
