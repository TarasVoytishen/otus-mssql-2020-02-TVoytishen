/*Подзапросы и CTE
Для всех заданий где возможно, сделайте 2 варианта запросов:
1) через вложенный запрос
2) через WITH (для производных таблиц)
*/

--Напишите запросы:
--1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.

select *
from Application.People ap
where ap.IsSalesperson=1 and
not ap.PersonID   in (select distinct so.SalespersonPersonID from Sales.Orders so);



with RealSalesPeople as (select distinct so.SalespersonPersonID from Sales.Orders so)
select *
from Application.People ap
where ap.IsSalesperson=1 and
not ap.PersonID   in (select SalespersonPersonID from RealSalesPeople);

--2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса.
select wsi.* from Warehouse.StockItems wsi
where wsi.UnitPrice=(
select min(UnitPrice) minprice from Warehouse.StockItems );

select wsi.* from Warehouse.StockItems wsi
inner join (select min(UnitPrice) minprice from Warehouse.StockItems) wsi_min
 on wsi.UnitPrice=wsi_min.minprice;

 --2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса.
select wsi.* from Warehouse.StockItems wsi
where wsi.UnitPrice=(select min(UnitPrice) minprice from Warehouse.StockItems );

select wsi.* from Warehouse.StockItems wsi
where wsi.UnitPrice in (select min(UnitPrice) minprice from Warehouse.StockItems);
 
select wsi.* from Warehouse.StockItems wsi
inner join (select min(UnitPrice) minprice from Warehouse.StockItems) wsi_min
on wsi.UnitPrice=wsi_min.minprice;

with MinPrice(minprice) as (select min(UnitPrice) minprice from Warehouse.StockItems )  
select wsi.* from Warehouse.StockItems wsi
where wsi.UnitPrice=(select minprice from MinPrice);

--3. Выберите информацию по клиентам, которые перевели компании 5 максимальных платежей из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)

select sc.* from
Sales.Customers sc
where sc.CustomerID in
(
select top 5 sct.CustomerID
from Sales.CustomerTransactions sct
order by sct.TransactionAmount desc);


select sc.* from
Sales.Customers sc
inner join
(
select distinct top5.CustomerID
from
(
select top 5 sct.CustomerID
from Sales.CustomerTransactions sct
order by sct.TransactionAmount desc) top5)top5d

on sc.CustomerID=top5d.CustomerID
;

with top5 as (select top 5 sct.CustomerID from Sales.CustomerTransactions sct order by sct.TransactionAmount desc)
select sc.* from
Sales.Customers sc
where sc.CustomerID in
(
select CustomerID
from top5
);

--4. Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, а также Имя сотрудника, который осуществлял упаковку заказов

select ac.CityID,ac.CityName,ap.FullName
from
Application.Cities ac
inner join(


select distinct sc.DeliveryCityID,top_orders.PickedByPersonID
from
Sales.Customers sc

inner join (
 select distinct so.CustomerID,so.PickedByPersonID
 from Sales.Orders so
 where so.OrderID in(
	select distinct sol.OrderID
	from Sales.OrderLines sol
	where sol.StockItemID in
		(select top 3 StockItemID 
		from Warehouse.StockItems
		order by UnitPrice desc))) top_orders on top_orders.CustomerID=sc.CustomerID
		
	)top_cities_pickedperson on top_cities_pickedperson.DeliveryCityID=ac.CityID
	
inner join Application.People ap on top_cities_pickedperson.PickedByPersonID=ap.PersonID	
	;


with top_orders as  (
 select distinct so.CustomerID,so.PickedByPersonID
 from Sales.Orders so
 where so.OrderID in(
	select distinct sol.OrderID
	from Sales.OrderLines sol
	where sol.StockItemID in
		(select top 3 StockItemID 
		from Warehouse.StockItems
		order by UnitPrice desc)))
		 
select ac.CityID,ac.CityName,ap.FullName
from
Application.Cities ac
inner join(

select distinct sc.DeliveryCityID,top_orders.PickedByPersonID
from
Sales.Customers sc

inner join  top_orders on top_orders.CustomerID=sc.CustomerID
		
	)top_cities_pickedperson on top_cities_pickedperson.DeliveryCityID=ac.CityID
	
inner join Application.People ap on top_cities_pickedperson.PickedByPersonID=ap.PersonID	
	;


--5. Объясните, что делает и оптимизируйте запрос:
/*SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
(SELECT People.FullName
FROM Application.People
WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName,
SalesTotals.TotalSumm AS TotalSummByInvoice,
(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
FROM Sales.OrderLines
WHERE OrderLines.OrderId = (SELECT Orders.OrderId
FROM Sales.Orders
WHERE Orders.PickingCompletedWhen IS NOT NULL
AND Orders.OrderId = Invoices.OrderId)
) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN
(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

Приложите план запроса и его анализ, а также ход ваших рассуждений по поводу оптимизации.
Можно двигаться как в сторону улучшения читабельности запроса (что уже было в материале лекций), так и в сторону упрощения плана\ускорения.
*/

--это оригинал запроса
SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
	(SELECT People.FullName
	FROM Application.People
	WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,--берет из таблицы Application.People FullName (тоже самое по результату что и через join)

SalesTotals.TotalSumm AS TotalSummByInvoice,

	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) FROM Sales.OrderLines WHERE OrderLines.OrderId = 
				(SELECT Orders.OrderId FROM Sales.Orders WHERE Orders.PickingCompletedWhen IS NOT NULL AND Orders.OrderId = Invoices.OrderId)
	) AS TotalSummForPickedItems --сумма по строкам ордера (который завершен) который связан с платежом

FROM Sales.Invoices --из оплат

JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm FROM Sales.InvoiceLines GROUP BY InvoiceId HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals --берет строки из оплат в которых сумма >27000
		ON Invoices.InvoiceID = SalesTotals.InvoiceID --соединяем с платежами где общая сумма платежа >27000
ORDER BY TotalSumm DESC;


--изменяем (упрощаем с точки зрения читаемости)
SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
ap.FullName AS SalesPersonName,

SalesTotals.TotalSumm AS TotalSummByInvoice,

isnull(PickedItemsOrders.ts,0) as TotalSummForPickedItems

FROM Sales.Invoices --из оплат

JOIN
	(SELECT sil.InvoiceId, SUM(sil.Quantity*sil.UnitPrice) AS TotalSumm FROM Sales.InvoiceLines  sil GROUP BY sil.InvoiceId HAVING SUM(sil.Quantity*sil.UnitPrice) > 27000) AS SalesTotals --берет строки из оплат в которых сумма >27000
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
left join 
	Application.People ap on ap.PersonID=Invoices.SalespersonPersonID

left join (SELECT SUM(sol.PickedQuantity*sol.UnitPrice) as ts, sol.OrderID  FROM Sales.OrderLines sol 

			inner join Sales.Orders so on so.OrderID=sol.OrderID

			WHERE so.PickingCompletedWhen IS NOT NULL

			group by sol.OrderID) PickedItemsOrders on PickedItemsOrders.OrderID=Invoices.OrderId

ORDER BY TotalSumm DESC;


/*
Опциональная часть:
В материалах к вебинару есть файл HT_reviewBigCTE.sql - прочтите этот запрос и напишите что он должен вернуть и в чем его смысл, можно если есть идеи по улучшению тоже их включить.
*/