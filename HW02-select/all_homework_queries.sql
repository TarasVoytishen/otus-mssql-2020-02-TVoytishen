--1. Все товары, в которых в название есть пометка urgent или название начинается с Animal

select 
	si.* 
from 
	Warehouse.StockItems si
where
	si.StockItemName like 'Animal%' or si.StockItemName like '%urgent%';



--2. Поставщиков, у которых не было сделано ни одного заказа (потом покажем как это делать через подзапрос, сейчас сделайте через JOIN)

select 
	s.*
from
	Purchasing.Suppliers s
left join
	Purchasing.PurchaseOrders o
on
	s.SupplierID=o.SupplierID		
where
	o.SupplierID is null;
	

--3. Продажи с названием месяца, в котором была продажа, номером квартала, к которому относится продажа, 
--включите также к какой трети года относится дата - каждая треть по 4 месяца, 
--дата забора заказа должна быть задана, с ценой товара более 100$ либо количество единиц товара более 20. 
--Добавьте вариант этого запроса с постраничной выборкой пропустив первую 1000 и отобразив следующие 100 записей. 
--Сортировка должна быть по номеру квартала, трети года, дате продажи.

select 
	so.*, 
	
	case  MONTH(so.OrderDate)
		when 1 then 'January'
		when 2 then 'Febrary'
		when 3 then 'Marth'
		when 4 then 'April'
		when 5 then 'May'
		when 6 then 'June'
		when 7 then 'July'
		when 8 then 'August'
		when 9 then 'September'
		when 10 then 'October'
		when 11 then 'November'
		when 11 then 'December'
	end as [MonthName],

	case  
		when MONTH(so.OrderDate) in(1,2,3,4) then '1_third'
		when MONTH(so.OrderDate) in(5,6,7,8) then '2_third'
		when MONTH(so.OrderDate) in(9,10,11,12) then '3_third'
	end as [ThirdOfYear]
	
from
	Sales.Orders so
where 
	so.PickingCompletedWhen is not null
	and
	(so.OrderID in (select sol.OrderID from Sales.OrderLines as sol where isnull(sol.UnitPrice,9)>100 ) 
	or 
	so.OrderID in  (select sol.OrderID/*, sum(sol.Quantity)*/ from Sales.OrderLines as sol group by sol.OrderID having sum(sol.Quantity)>20))
order by 
	datepart(quarter,so.OrderDate),
	ThirdOfYear,
	so.OrderDate
	; 

	
	select 
	so.*, 
	
	case  MONTH(so.OrderDate)
		when 1 then 'January'
		when 2 then 'Febrary'
		when 3 then 'Marth'
		when 4 then 'April'
		when 5 then 'May'
		when 6 then 'June'
		when 7 then 'July'
		when 8 then 'August'
		when 9 then 'September'
		when 10 then 'October'
		when 11 then 'November'
		when 11 then 'December'
	end as [MonthName],

	case  
		when MONTH(so.OrderDate) in(1,2,3,4) then '1_third'
		when MONTH(so.OrderDate) in(5,6,7,8) then '2_third'
		when MONTH(so.OrderDate) in(9,10,11,12) then '3_third'
	end as [ThirdOfYear]
	
from
	Sales.Orders so
where 
	so.PickingCompletedWhen is not null
	and
	(so.OrderID in (select sol.OrderID from Sales.OrderLines as sol where isnull(sol.UnitPrice,9)>100 ) 
	or 
	so.OrderID in  (select sol.OrderID/*, sum(sol.Quantity)*/ from Sales.OrderLines as sol group by sol.OrderID having sum(sol.Quantity)>20))
order by 
	datepart(quarter,so.OrderDate),
	ThirdOfYear,
	so.OrderDate
offset 1000 rows fetch next 100 rows only
	; 




--4. Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post, добавьте название поставщика, имя контактного лица принимавшего заказ

select 
	po.*,dm.DeliveryMethodName,s.SupplierName,p.FullName as OrderContactPerson
from 
	Purchasing.PurchaseOrders po
	inner join 
		Purchasing.SupplierTransactions st
			on st.PurchaseOrderID=po.PurchaseOrderID and YEAR(isnull(st.FinalizationDate,'2000-01-01'))=2014
	inner join 
		Application.DeliveryMethods dm
			on po.DeliveryMethodID=dm.DeliveryMethodID and dm.DeliveryMethodName in ('Road Freight','Post') 
	inner join 
		Purchasing.Suppliers s
			on po.SupplierID=s.SupplierID
	inner join 
		Application.People p
			on po.ContactPersonID=p.PersonID
where 
	po.IsOrderFinalized=1 



--5. 10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.

select top 10 
	so.*, c.CustomerName 
from 
	Sales.Orders as so
	inner join Sales.Customers as c
		on so.CustomerID=c.CustomerID
	inner join Application.People p
		on so.SalespersonPersonID=p.PersonID
	
order by 
	so.OrderDate desc


--6. Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g

select sc.CustomerID,sc.CustomerName,ap.PhoneNumber
from
Sales.Customers as sc
inner join
		 (
	select  so.CustomerID, so.ContactPersonID
	from Sales.OrderLines as sol
	inner join Warehouse.StockItems as wsi
		on sol.StockItemID=wsi.StockItemID and wsi.StockItemName='Chocolate frogs 250g'
	inner join Sales.Orders as so
		on so.OrderID=sol.OrderID
		) as SpecSales
		on sc.CustomerID=SpecSales.CustomerID
inner join 
	Application.People ap
	on SpecSales.ContactPersonID=ap.PersonID
