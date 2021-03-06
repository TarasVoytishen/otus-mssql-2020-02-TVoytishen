--1. ��� ������, � ������� � �������� ���� ������� urgent ��� �������� ���������� � Animal

select 
	si.* 
from 
	Warehouse.StockItems si
where
	si.StockItemName like 'Animal%' or si.StockItemName like '%urgent%';



--2. �����������, � ������� �� ���� ������� �� ������ ������ (����� ������� ��� ��� ������ ����� ���������, ������ �������� ����� JOIN)

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
	

--3. ������� � ��������� ������, � ������� ���� �������, ������� ��������, � �������� ��������� �������, 
--�������� ����� � ����� ����� ���� ��������� ���� - ������ ����� �� 4 ������, 
--���� ������ ������ ������ ���� ������, � ����� ������ ����� 100$ ���� ���������� ������ ������ ����� 20. 
--�������� ������� ����� ������� � ������������ �������� ��������� ������ 1000 � ��������� ��������� 100 �������. 
--���������� ������ ���� �� ������ ��������, ����� ����, ���� �������.

select 
	so.*, 
	
	DATENAME(month,so.OrderDate),

	case  
		when MONTH(so.OrderDate) in(1,2,3,4) then '1_third'
		when MONTH(so.OrderDate) in(5,6,7,8) then '2_third'
		when MONTH(so.OrderDate) in(9,10,11,12) then '3_third'
	end as [ThirdOfYear]
	
from
	Sales.Orders so

	inner join 
		(select distinct
			sol_inner_1.OrderID 
		from 
			Sales.OrderLines as sol_inner_1 
		where isnull(sol_inner_1.UnitPrice,9)>100

		union 
		
		select distinct
			sol_inner_2.OrderID
		from 
			Sales.OrderLines as sol_inner_2
		group by 
			sol_inner_2.OrderID 
		having 
			sum(sol_inner_2.Quantity)>20

		) as sol1
		on sol1.OrderID=so.OrderID

where 
	so.PickingCompletedWhen is not null
	/*and
	(so.OrderID in (select sol.OrderID from Sales.OrderLines as sol where isnull(sol.UnitPrice,9)>100 ) 
	or 
	so.OrderID in  (select sol.OrderID/*, sum(sol.Quantity)*/ from Sales.OrderLines as sol group by sol.OrderID having sum(sol.Quantity)>20))*/
order by 
	datepart(quarter,so.OrderDate),
	ThirdOfYear,
	so.OrderDate
	; 

	
select 
	so.*, 
	
	DATENAME(month,so.OrderDate),

	case  
		when MONTH(so.OrderDate) in(1,2,3,4) then '1_third'
		when MONTH(so.OrderDate) in(5,6,7,8) then '2_third'
		when MONTH(so.OrderDate) in(9,10,11,12) then '3_third'
	end as [ThirdOfYear]
	
from
	Sales.Orders so

	inner join 
		(select distinct
			sol_inner_1.OrderID 
		from 
			Sales.OrderLines as sol_inner_1 
		where isnull(sol_inner_1.UnitPrice,9)>100

		union 
		
		select distinct
			sol_inner_2.OrderID
		from 
			Sales.OrderLines as sol_inner_2
		group by 
			sol_inner_2.OrderID 
		having 
			sum(sol_inner_2.Quantity)>20

		) as sol1
		on sol1.OrderID=so.OrderID

where 
	so.PickingCompletedWhen is not null
	/*and
	(so.OrderID in (select sol.OrderID from Sales.OrderLines as sol where isnull(sol.UnitPrice,9)>100 ) 
	or 
	so.OrderID in  (select sol.OrderID/*, sum(sol.Quantity)*/ from Sales.OrderLines as sol group by sol.OrderID having sum(sol.Quantity)>20))*/
order by 
	datepart(quarter,so.OrderDate),
	ThirdOfYear,
	so.OrderDate
	offset 1000 rows fetch next 100 rows only
	; 




--4. ������ �����������, ������� ���� ��������� �� 2014� ��� � ��������� Road Freight ��� Post, �������� �������� ����������, ��� ����������� ���� ������������ �����

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
	po.IsOrderFinalized=1; 



--5. 10 ��������� �� ���� ������ � ������ ������� � ������ ����������, ������� ������� �����.

select top 10 
	so.*, c.CustomerName 
from 
	Sales.Orders as so
	inner join Sales.Customers as c
		on so.CustomerID=c.CustomerID
	inner join Application.People p
		on so.SalespersonPersonID=p.PersonID
	
order by 
	so.OrderDate desc;


--6. ��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� Chocolate frogs 250g

/*
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
	on SpecSales.ContactPersonID=ap.PersonID;
*/

--���� ������� �������
select sc.CustomerID,sc.CustomerName,ap.PhoneNumber
from
Sales.Customers as sc
	
inner join Sales.Orders as so
		on sc.CustomerID=so.CustomerID

--
inner join Sales.OrderLines as sol
		on sol.OrderID=so.OrderID

--�������� �� ������
inner join Warehouse.StockItems as wsi
		on sol.StockItemID=wsi.StockItemID and wsi.StockItemName='Chocolate frogs 250g'

inner join 
	Application.People ap
	on so.ContactPersonID=ap.PersonID;

