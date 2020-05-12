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
