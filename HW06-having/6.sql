--Группировки и агрегатные функции
--1. Посчитать среднюю цену товара, общую сумму продажи по месяцам

select 
	year(so.OrderDate) as year
	,month(so.OrderDate) as month
	,sum(sol.Quantity*sol.UnitPrice)/sum(sol.Quantity) as avg_price --так правильно, в расчете среднего учитываем количество проданного товара
	,sum(sol.Quantity*sol.UnitPrice) as total_sum
	,avg(sol.UnitPrice) as avg_price_not_correct --так неправильно, правильно только если весь товар месяц продали по 1 штуке
from Sales.OrderLines as sol
join Sales.Orders so on sol.OrderID=so.OrderID
group by year(so.OrderDate),month(so.OrderDate)
order by year,month;

--с нулевыми месяцами (берем года 2012-2020 полностью)
WITH Years AS(
	SELECT 2012 num
	UNION ALL
	SELECT num+1
	FROM Years
	WHERE num+1 <= 2020
),
Monthes AS(
	SELECT 1 num
	UNION ALL
	SELECT num+1
	FROM Monthes
	WHERE num+1 <= 12
),
YearsMonthes AS(
	SELECT Years.num y,Monthes.num m FROM Years
	cross join Monthes
)
select 
	ym.y as year 
	,ym.m as month 
	,isnull(poor_sales.avg_price,0) as avg_price
	,isnull(poor_sales.total_sum,0) as total_sum
	,isnull(poor_sales.avg_price_not_correct,0) as avg_price_not_correct
from YearsMonthes ym
left join
	(
	select 
		year(so.OrderDate) as year
		,month(so.OrderDate) as month
		,sum(sol.Quantity*sol.UnitPrice)/sum(sol.Quantity) as avg_price --так правильно, в расчете среднего учитываем количество проданного товара
		,sum(sol.Quantity*sol.UnitPrice) as total_sum
		,avg(sol.UnitPrice) as avg_price_not_correct --так неправильно, правильно только если весь товар месяц продали по 1 штуке
	from Sales.OrderLines as sol
	join Sales.Orders so on sol.OrderID=so.OrderID
	group by year(so.OrderDate),month(so.OrderDate)
	)as poor_sales on ym.y=poor_sales.year and ym.m=poor_sales.month
order by year,month;


--с нулевыми месяцами еще один вариант(берем года 2012-2020 полностью)
WITH Years AS(
	SELECT 2012 num
	UNION ALL
	SELECT num+1
	FROM Years
	WHERE num+1 <= 2020
),
Monthes AS(
	SELECT 1 num
	UNION ALL
	SELECT num+1
	FROM Monthes
	WHERE num+1 <= 12
),
YearsMonthes AS(
	SELECT Years.num y,Monthes.num m FROM Years
	cross join Monthes
)
select 
	poor_sales.year 
	,poor_sales.month 
	,sum(poor_sales.avg_price) as avg_price
	,sum(poor_sales.total_sum) as total_sum
	,sum(poor_sales.avg_price_not_correct) as avg_price_not_correct
from (
	select 
		year(so.OrderDate) as year
		,month(so.OrderDate) as month
		,sum(sol.Quantity*sol.UnitPrice)/sum(sol.Quantity) as avg_price --так правильно, в расчете среднего учитываем количество проданного товара
		,sum(sol.Quantity*sol.UnitPrice) as total_sum
		,avg(sol.UnitPrice) as avg_price_not_correct --так неправильно, правильно только если весь товар месяц продали по 1 штуке
	from Sales.OrderLines as sol
	join Sales.Orders so on sol.OrderID=so.OrderID
	group by year(so.OrderDate),month(so.OrderDate)
	union all
	select 
		ym.y,
		ym.m,
		0,
		0,
		0
	from YearsMonthes ym
	)as poor_sales 

group by poor_sales.year,poor_sales.month

order by year,month;



--2. Отобразить все месяцы, где общая сумма продаж превысила 10 000
select 
	year(so.OrderDate) as year
	,month(so.OrderDate) as month
	,sum(sol.Quantity*sol.UnitPrice) as total_sum
from Sales.OrderLines as sol
join Sales.Orders so on sol.OrderID=so.OrderID
group by year(so.OrderDate),month(so.OrderDate)
having sum(sol.Quantity*sol.UnitPrice)>10000
order by year,month;


--3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
--Группировка должна быть по году и месяцу.

--если правильно понял условие задачи, учитываем товары, которые плохо, но продавались
--и в результате выдаем год,месяц,сумму продаж, дату первой продажи,количество проданного
select 
	poor_sale_stock_items.year
	,poor_sale_stock_items.month	
	,sum(poor_sale_stock_items.total_quantity) as total_quantity
	,sum(poor_sale_stock_items.total_sum) as total_sum
	,min(poor_sale_stock_items.first_sale_date_in_month) as first_sale_date_in_month
from
	(select 
		year(so.OrderDate) as year
		,month(so.OrderDate) as month
		,sol.StockItemID as StockItemID
		,sum(sol.Quantity) as total_quantity
		,sum(sol.Quantity*sol.UnitPrice) as total_sum
		,min(so.OrderDate) as first_sale_date_in_month
	from Sales.OrderLines as sol
	join Sales.Orders so on sol.OrderID=so.OrderID
	group by year(so.OrderDate),month(so.OrderDate),sol.StockItemID
	having sum(sol.Quantity)<50
	) as poor_sale_stock_items
group by poor_sale_stock_items.year,poor_sale_stock_items.month
order by year,month;


--4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
/*Дано :
CREATE TABLE dbo.MyEmployees
(
EmployeeID smallint NOT NULL,
FirstName nvarchar(30) NOT NULL,
LastName nvarchar(40) NOT NULL,
Title nvarchar(50) NOT NULL,
DeptID smallint NOT NULL,
ManagerID int NULL,
CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);
INSERT INTO dbo.MyEmployees VALUES
(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273)
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);

Результат вывода рекурсивного CTE:
EmployeeID Name Title EmployeeLevel
1 Ken Sánchez Chief Executive Officer 1
273 | Brian Welcker Vice President of Sales 2
16 | | David Bradley Marketing Manager 3
23 | | | Mary Gibson Marketing Specialist 4
274 | | Stephen Jiang North American Sales Manager 3
276 | | | Linda Mitchell Sales Representative 4
275 | | | Michael Blythe Sales Representative 4
285 | | Syed Abbas Pacific Sales Manager 3
286 | | | Lynn Tsoflias Sales Representative 4
*/

WITH Emp AS(
	
	--EmployeeID Name Title EmployeeLevel
	select  e.EmployeeID,cast('' as nvarchar(200)) as L,                          e.FirstName+' '+e.LastName as Name,e.Title, 1 as EmployeeLevel,e.ManagerID,cast(e.LastName as nvarchar(500)) as NN
	from MyEmployees e where e.ManagerID is null

	union all
	
	SELECT e.EmployeeID,cast(replicate(' |',Emp.EmployeeLevel) as nvarchar(200)) ,  e.FirstName+' '+e.LastName as Name,e.Title, Emp.EmployeeLevel+1,e.ManagerID,cast(''+Emp.NN+''+e.LastName as nvarchar(500))
	FROM MyEmployees e
	join Emp on Emp.EmployeeID=e.ManagerID 
	
)select * from Emp
order by NN


--Опционально:
--Написать все эти же запросы, но, если за какой-то месяц не было продаж, то этот месяц тоже должен быть в результате и там должны быть нули.