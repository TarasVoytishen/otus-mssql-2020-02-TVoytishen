--Оконные функции
--1. Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните планы.
--В качестве запроса с временной таблицей и табличной переменной можно взять свой запрос или следующий запрос:

--Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки)
--Выведите id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом
--Пример
--Дата продажи Нарастающий итог по месяцу
--2015-01-29 4801725.31
--2015-01-30 4801725.31
--2015-01-31 4801725.31
--2015-02-01 9626342.98
--2015-02-02 9626342.98
--2015-02-03 9626342.98
--Продажи можно взять из таблицы Invoices.
--Нарастающий итог должен быть без оконной функции.
--SET STATISTICS TIME ON;


declare @time_1 datetime2=sysdatetime();



--с временной таблицей
drop table if exists #total_sales_month;
drop table if exists #total_sales_month_inflate;

select year(si.InvoiceDate) as [year], month(si.InvoiceDate) as [month], sum(sil.Quantity*sil.UnitPrice) as total_sum
into #total_sales_month
from Sales.InvoiceLines sil
join Sales.Invoices si on sil.InvoiceID=si.InvoiceID
where si.InvoiceDate >= '2015-01-01'
group by year(si.InvoiceDate), month(si.InvoiceDate);

--получим таблицу по месяцам с нарастающим итогом
select tsm.year,tsm.month, sum(tsm2.total_sum) as total_sum_inflate
into #total_sales_month_inflate
from #total_sales_month tsm
inner join #total_sales_month tsm2 on (tsm.year+(tsm.month/100.0))>=(tsm2.year+(tsm2.month/100.0))
group by tsm.year,tsm.month;

--выведем ленту продаж
select si.InvoiceID , sum(sil.UnitPrice*sil.Quantity) as InvoiceSum ,si.InvoiceDate, sc.CustomerName, tsmi.total_sum_inflate as total_sales_month_inflate
from Sales.Invoices si
join #total_sales_month_inflate tsmi on tsmi.year=year(si.InvoiceDate) and tsmi.month=month(si.InvoiceDate) 
join Sales.Customers sc on sc.CustomerID=si.CustomerID
join Sales.InvoiceLines sil on si.InvoiceID=sil.InvoiceID
where si.InvoiceDate >= '2015-01-01'
group by si.InvoiceID,si.InvoiceDate,sc.CustomerName,tsmi.total_sum_inflate
order by si.InvoiceDate,si.InvoiceID;

drop table if exists #total_sales_month;
drop table if exists #total_sales_month_inflate;

/**********************************************************/
declare @time_2 datetime2=sysdatetime();

--c табличной переменной (все то же самое)
declare @total_sales_month TABLE ([year] int, [month] int, total_sum decimal(18,2));

insert into @total_sales_month 
select year(si.InvoiceDate) as [year], month(si.InvoiceDate) as [month], sum(sil.Quantity*sil.UnitPrice) as total_sum
from Sales.InvoiceLines sil
join Sales.Invoices si on sil.InvoiceID=si.InvoiceID
where si.InvoiceDate >= '2015-01-01'
group by year(si.InvoiceDate), month(si.InvoiceDate);

--получим таблицу по месяцам с нарастающим итогом
declare @total_sales_month_inflate TABLE ([year] int, [month] int, total_sum_inflate decimal(18,2));

insert into @total_sales_month_inflate 
select tsm.year,tsm.month, sum(tsm2.total_sum) as total_sum_inflate
from @total_sales_month tsm
inner join @total_sales_month tsm2 on (tsm.year+(tsm.month/100.0))>=(tsm2.year+(tsm2.month/100.0))
group by tsm.year,tsm.month;

--выведем ленту продаж
select si.InvoiceID ,sum(sil.UnitPrice*sil.Quantity) as InvoiceSum ,si.InvoiceDate, sc.CustomerName, tsmi.total_sum_inflate as total_sales_month_inflate
from Sales.Invoices si
join @total_sales_month_inflate tsmi on tsmi.year=year(si.InvoiceDate) and tsmi.month=month(si.InvoiceDate) 
join Sales.Customers sc on sc.CustomerID=si.CustomerID
join Sales.InvoiceLines sil on si.InvoiceID=sil.InvoiceID
where si.InvoiceDate >= '2015-01-01'
group by si.InvoiceID,si.InvoiceDate,sc.CustomerName,tsmi.total_sum_inflate
order by si.InvoiceDate,si.InvoiceID;


--2. Если вы брали предложенный выше запрос, то сделайте расчет суммы нарастающим итогом с помощью оконной функции.
--Сравните 2 варианта запроса - через windows function и без них. Написать какой быстрее выполняется, сравнить по set statistics time on;
declare @time_3 datetime2=sysdatetime();

select si.InvoiceID ,sum(sil.UnitPrice*sil.Quantity) over(partition by si.InvoiceID) as InvoiceSum ,si.InvoiceDate, sc.CustomerName, sum(sil.UnitPrice*sil.Quantity) over (order by year(si.InvoiceDate)+month(si.InvoiceDate)/100.0 range UNBOUNDED PRECEDING)
from Sales.Invoices si
join Sales.Customers sc on sc.CustomerID=si.CustomerID
join Sales.InvoiceLines sil on si.InvoiceID=sil.InvoiceID
where si.InvoiceDate >= '2015-01-01'
order by si.InvoiceDate,si.InvoiceID;
--SET STATISTICS TIME OFF;

declare @time_4 datetime2=sysdatetime();

--выводим сколько по времени выводились варианты
select 
	DATEDIFF(ms,@time_1,@time_2) as [ВариантСВременнойТаблицей],
	DATEDIFF(ms,@time_2,@time_3) as [ВариантСТабличнойПеременной],
	DATEDIFF(ms,@time_3,@time_4) as [ЧерезОконныеФункции]


--2. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)

select 
	all_sales_rank.month,
	st_i.StockItemName
from(
	select sil.StockItemID,sum(sil.Quantity) as Quatity_sum, month(si.InvoiceDate) as [month],ROW_NUMBER() over (partition by month(si.InvoiceDate) order by sum(sil.Quantity) desc) as stock_rank
	from Sales.InvoiceLines sil 
	inner join Sales.Invoices si on si.InvoiceID=sil.InvoiceID
	where si.InvoiceDate >= '2016-01-01' and si.InvoiceDate<'2017-01-01'
	group by sil.StockItemID,year(si.InvoiceDate),month(si.InvoiceDate)
	) as all_sales_rank
inner join Warehouse.StockItems as st_i on st_i.StockItemID=all_sales_rank.StockItemID
where all_sales_rank.stock_rank in (1,2)
order by all_sales_rank.month;


--3. Функции одним запросом
--Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
--пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
--посчитайте общее количество товаров и выведете полем в этом же запросе
--посчитайте общее количество товаров в зависимости от первой буквы названия товара
--отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
--предыдущий ид товара с тем же порядком отображения (по имени)
--названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
--сформируйте 30 групп товаров по полю вес товара на 1 шт

select 
	wsi.StockItemID,
	wsi.StockItemName,
	wsi.Brand,wsi.UnitPrice, 
	ROW_NUMBER() over (partition by substring(wsi.StockItemName,1,1) order by wsi.StockItemName) as num_name_first_char,
	sum(wsi.QuantityPerOuter) over() as total_Quantity,
	sum(wsi.QuantityPerOuter) over(partition by substring(wsi.StockItemName,1,1)) as total_Quantity_name_first_char,
	lead(wsi.StockItemName) over(order by wsi.StockItemName) as next_item,
	lag(wsi.StockItemName) over(order by wsi.StockItemName) as prev_item,
	lag(wsi.StockItemName,2,'No items') over(order by wsi.StockItemName ) as prev_2_item,
	ntile(30) over(order by wsi.TypicalWeightPerUnit) as weight_group,
	wsi.TypicalWeightPerUnit
from Warehouse.StockItems wsi
order by wsi.StockItemName;

--Для этой задачи НЕ нужно писать аналог без аналитических функций
--4. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
--В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки 

/*
select 
	ap.PersonID, 
	ap.FullName, 
	si.InvoiceDate, 
	sc.CustomerName, 
	LAST_VALUE(sc.CustomerName) over (partition by ap.PersonID order by si.InvoiceDate,si.InvoiceID ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as last_client,
	sum(sil.UnitPrice*sil.Quantity) over(partition by si.InvoiceID) as InvoiceSum
from Application.People ap
left join Sales.Invoices si on ap.PersonID=si.SalespersonPersonID
left join Sales.Customers sc on sc.CustomerID=si.CustomerID
left join Sales.InvoiceLines sil on sil.InvoiceID=si.InvoiceID
where ap.IsSalesperson=1
order by ap.FullName,si.InvoiceDate,si.InvoiceID;
*/

select distinct
	SalesMan_and_LastInvoice.PersonID,
	SalesMan_and_LastInvoice.FullName,
	SalesMan_and_LastInvoice.last_CustomerID,
	sc.CustomerName as last_CustomerName,
	SalesMan_and_LastInvoice.last_InvoiceDate,
	sum(sil.UnitPrice*sil.Quantity) over(partition by sil.InvoiceID) as last_InvoiceSum
from
	(select distinct
		ap.PersonID, 
		ap.FullName, 
		LAST_VALUE(si.InvoiceID) over (partition by ap.PersonID order by si.InvoiceDate,si.InvoiceID ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as last_InvoiceID,
		LAST_VALUE(si.CustomerID) over (partition by ap.PersonID order by si.InvoiceDate,si.InvoiceID ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as last_CustomerID,
		LAST_VALUE(si.InvoiceDate) over (partition by ap.PersonID order by si.InvoiceDate,si.InvoiceID ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as last_InvoiceDate
	from Application.People ap
	left join Sales.Invoices si on ap.PersonID=si.SalespersonPersonID
	where ap.IsSalesperson=1) as SalesMan_and_LastInvoice
left join Sales.InvoiceLines sil on sil.InvoiceID=SalesMan_and_LastInvoice.last_InvoiceID
left join Sales.Customers sc on sc.CustomerID=SalesMan_and_LastInvoice.last_CustomerID
order by SalesMan_and_LastInvoice.FullName;

--5. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки

select 
	all_sales.CustomerID,
	all_sales.CustomerName,
	all_sales.StockItemID,
	all_sales.UnitPrice,
	all_sales.InvoiceDate
from(
	select distinct 
		sc.CustomerID,
		sc.CustomerName,
		sil.StockItemID,
		sil.UnitPrice,
		--si.InvoiceDate as InvDate,
		last_value(si.InvoiceDate) over (partition by sc.CustomerID,sil.StockItemID order by si.InvoiceDate,si.InvoiceID ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as InvoiceDate,
		DENSE_RANK  () over (partition by sc.CustomerID order by sil.UnitPrice desc) as cost_rank
	from Sales.InvoiceLines sil
	join Sales.Invoices si on si.InvoiceID=sil.InvoiceID
	join Sales.Customers sc on sc.CustomerID=si.CustomerID) all_sales
where
	all_sales.cost_rank in (1,2);

--вариант с CTE (чуть удобнее читать)
with all_sales
as
(	select distinct 
		sc.CustomerID,
		sc.CustomerName,
		sil.StockItemID,
		sil.UnitPrice,
		--si.InvoiceDate as InvDate,
		last_value(si.InvoiceDate) over (partition by sc.CustomerID,sil.StockItemID order by si.InvoiceDate,si.InvoiceID ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as InvoiceDate,
		DENSE_RANK  () over (partition by sc.CustomerID order by sil.UnitPrice desc) as cost_rank
	from Sales.InvoiceLines sil
	join Sales.Invoices si on si.InvoiceID=sil.InvoiceID
	join Sales.Customers sc on sc.CustomerID=si.CustomerID)
select
	CustomerID,
	CustomerName,
	StockItemID,
	UnitPrice,
	InvoiceDate
from all_sales
where cost_rank in (1,2);



--Опционально можно сделать вариант запросов для заданий 2,4,5 без использования windows function и сравнить скорость как в задании 1.

--Bonus из предыдущей темы
--Напишите запрос, который выбирает 10 клиентов, которые сделали больше 30 заказов и последний заказ был не позднее апреля 2016.