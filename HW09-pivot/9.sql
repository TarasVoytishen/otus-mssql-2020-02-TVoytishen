--Pivot и Cross Apply
/*1. Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента
МесяцГод Количество покупок

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys
имя клиента нужно поменять так чтобы осталось только уточнение
например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY
дата должна иметь формат dd.mm.yyyy например 25.12.2019

Например, как должны выглядеть результаты:
InvoiceMonth Peeples Valley, AZ Medicine Lodge, KS Gasport, NY Sylvanite, MT Jessie, ND
01.01.2013 3 1 4 2 2
01.02.2013 7 3 4 2 1
*/

/*
declare @customer_names0 nvarchar(max);

--чтобы вручную не писать имена клиентов, используем динамический sql (так как в pivot в список столбиков нельзя поместить например запрос)
select 
	@customer_names0=STRING_AGG(' ['+cast(sc.CustomerID as nvarchar(max))+'] as ['+sc.CustomerName+']',',')
from Sales.Customers sc 
where
	sc.CustomerID in (2,3,4,5,6);

print(@customer_names0);
*/

declare @customer_names nvarchar(max);

--чтобы вручную не писать имена клиентов, используем динамический sql (так как в pivot в список столбиков нельзя поместить например запрос)
select 
	@customer_names='['+STRING_AGG(sc.CustomerName,'],[')+']'
from Sales.Customers sc 
where
	sc.CustomerID in (2,3,4,5,6);

print(@customer_names);


declare @query nvarchar(max);

set @query='
with MonthSales as(
select 
	sc.CustomerName,
	DATEADD(month, DATEDIFF(month, 0, si.InvoiceDate), 0) as [month],
	sum(sil.Quantity) as InvoiceMonth
from
	Sales.Customers sc
	join Sales.Invoices si 
		on si.CustomerID=sc.CustomerID
	join Sales.InvoiceLines sil 
		on sil.InvoiceID=si.InvoiceID
where
	sc.CustomerID in (2,3,4,5,6)
group by
	sc.CustomerName,
	DATEADD(month, DATEDIFF(month, 0, si.InvoiceDate), 0)
)

select 
	
	cast(pvt.[month] as date) as [month],'+@customer_names+'
	
from MonthSales ms
PIVOT
 (	SUM(InvoiceMonth)   
	FOR CustomerName   
	IN ('+@customer_names+')
 ) pvt
 order by pvt.month
';

print(@query);

--exec @query - не работает
exec sp_executesql @query;


/*
with MonthSales as(
select 
	sc.CustomerName,
	DATEADD(month, DATEDIFF(month, 0, si.InvoiceDate), 0) as [month],
	sum(sil.Quantity) as InvoiceMonth
from
	Sales.Customers sc
	join Sales.Invoices si 
		on si.CustomerID=sc.CustomerID
	join Sales.InvoiceLines sil 
		on sil.InvoiceID=si.InvoiceID
where
	sc.CustomerID in (2,3,4,5,6)
group by
	sc.CustomerName,
	DATEADD(month, DATEDIFF(month, 0, si.InvoiceDate), 0)
)
select 
	cast(pvt.[month] as date) as [month],[Tailspin Toys (Sylvanite, MT)],[Tailspin Toys (Peeples Valley, AZ)],[Tailspin Toys (Medicine Lodge, KS)],[Tailspin Toys (Gasport, NY)],[Tailspin Toys (Jessie, ND)]
from MonthSales ms
PIVOT
 (	SUM(InvoiceMonth)   
	FOR CustomerName   
	IN ([Tailspin Toys (Sylvanite, MT)],[Tailspin Toys (Peeples Valley, AZ)],[Tailspin Toys (Medicine Lodge, KS)],[Tailspin Toys (Gasport, NY)],[Tailspin Toys (Jessie, ND)])
 ) pvt
  order by pvt.month;



  with MonthSales as(
select 
	sc.CustomerName,
	DATEADD(month, DATEDIFF(month, 0, si.InvoiceDate), 0) as [month],
	sum(sil.Quantity) as InvoiceMonth
from
	Sales.Customers sc
	join Sales.Invoices si 
		on si.CustomerID=sc.CustomerID
	join Sales.InvoiceLines sil 
		on sil.InvoiceID=si.InvoiceID
where
	sc.CustomerID in (2,3,4,5,6)
group by
	sc.CustomerName,
	DATEADD(month, DATEDIFF(month, 0, si.InvoiceDate), 0)
)

select 
	
	cast(pvt.[month] as date) as [month],[Tailspin Toys (Sylvanite, MT)],[Tailspin Toys (Peeples Valley, AZ)],[Tailspin Toys (Medicine Lodge, KS)],[Tailspin Toys (Gasport, NY)],[Tailspin Toys (Jessie, ND)]
	
from MonthSales ms
PIVOT
 (	SUM(InvoiceMonth)   
	FOR CustomerName   
	IN ([Tailspin Toys (Sylvanite, MT)],[Tailspin Toys (Peeples Valley, AZ)],[Tailspin Toys (Medicine Lodge, KS)],[Tailspin Toys (Gasport, NY)],[Tailspin Toys (Jessie, ND)])
 ) pvt
 order by pvt.month
 */

/*
select 
	0 as InvoiceMonth,[Tailspin Toys (Sylvanite, MT)],[Tailspin Toys (Peeples Valley, AZ)],[Tailspin Toys (Medicine Lodge, KS)],[Tailspin Toys (Gasport, NY)],[Tailspin Toys (Jessie, ND)]	
	*/

/*2. Для всех клиентов с именем, в котором есть Tailspin Toys
вывести все адреса, которые есть в таблице, в одной колонке

Пример результатов
CustomerName AddressLine
Tailspin Toys (Head Office) Shop 38
Tailspin Toys (Head Office) 1877 Mittal Road
Tailspin Toys (Head Office) PO Box 8975
Tailspin Toys (Head Office) Ribeiroville
.....
*/

with CustomerAddresses as(
	select CustomerName,DeliveryAddressLine1,DeliveryAddressLine2/*,cast(DeliveryPostalCode as nvarchar(200)) as DeliveryPostalCode*/,PostalAddressLine1,PostalAddressLine2/*,cast(PostalPostalCode as nvarchar(max)) as PostalPostalCode*/ from Sales.Customers
	where CustomerName like '%Tailspin Toys%'
	)
select 
	CustomerName,Addr
from 
	CustomerAddresses
unpivot
	(Addr for Addr2 in (DeliveryAddressLine1,DeliveryAddressLine2/*,DeliveryPostalCode*/,PostalAddressLine1,PostalAddressLine2/*,PostalPostalCode*/)
	) as upvt
;



/*3. В таблице стран есть поля с кодом страны цифровым и буквенным
сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
Пример выдачи

CountryId CountryName Code
1 Afghanistan AFG
1 Afghanistan 4
3 Albania ALB
3 Albania 8
*/

with CountriesCodes as(
	select [CountryName],[IsoAlpha3Code],cast([IsoNumericCode] as nvarchar(3)) as [IsoNumericCode] from Application.Countries
	)
select 
	[CountryName],Code
from 
	CountriesCodes
unpivot
	(Code for Code2 in ([IsoAlpha3Code],[IsoNumericCode])
	) as upvt
;

/*
4. Перепишите ДЗ из оконных функций через CROSS APPLY
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

--5. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
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


--переписано на cross apply
select distinct 
	sc.CustomerID,
	sc.CustomerName,
	sil.StockItemID,
	sil.UnitPrice,
	max(si.InvoiceDate) as last_InvoiceDate--из множества дат покупки выбираем последнюю
from Sales.InvoiceLines sil
join Sales.Invoices si on si.InvoiceID=sil.InvoiceID
join Sales.Customers sc on sc.CustomerID=si.CustomerID

join(--соединение с таблицей где топ2 самых дорогих товаров по клиенту, но нет даты покупки
	select 
		scm.CustomerID,scm.CustomerName, top2_max_price_items.StockItemID,top2_max_price_items.UnitPrice
	from Sales.Customers scm
	cross apply(
			select distinct top 2 --получаем топ2 купленных самых дорогих товаров по каждому клиенту
				sc.CustomerID,
				sil.StockItemID,
				sil.UnitPrice
			from Sales.InvoiceLines sil
			join Sales.Invoices si on si.InvoiceID=sil.InvoiceID
			join Sales.Customers sc on sc.CustomerID=si.CustomerID
			where sc.CustomerID=scm.CustomerID
			order by sil.UnitPrice desc
			  )top2_max_price_items
)as top_customers
on top_customers.CustomerID=sc.CustomerID and top_customers.StockItemID=sil.StockItemID and top_customers.UnitPrice=sil.UnitPrice
group by
	sc.CustomerID,
	sc.CustomerName,
	sil.StockItemID,
	sil.UnitPrice;


/*
5. Code review (опционально). Запрос приложен в материалы Hometask_code_review.sql.
Что делает запрос?
Чем можно заменить CROSS APPLY - можно ли использовать другую стратегию выборки\запроса?
*/

--не осилил, ниже просто попытка разобрать что же делает запрос

--попробуем разобраться
--похоже, dbo.vwFolderHistoryRemove - это таблица история удаления каталогов или файлов в этих каталогах
--#FileVersions - таблица версий файлов
--vwFileHistoryRestore - история восстановления файлов
--vwFileHistoryRemove - история удаления файлов

--запрос выводит каталог, версию файла, файл которые были до того как файл удалили

/*
SELECT T.FolderId,
		   T.FileVersionId,
		   T.FileId		
	FROM dbo.vwFolderHistoryRemove FHR
	CROSS APPLY (
			SELECT TOP 1 FileVersionId, FileId, FolderId, DirId    --берем последнюю версию файла (тот же момент или момент до того как удалили (файл или каталог?))
			FROM #FileVersions V
			WHERE RowNum = 1
				AND DirVersionId <= FHR.DirVersionId
			ORDER BY V.DirVersionId DESC   
			) T														--кажется cross join можно заменить на inner join с 'on DirVersionId <= FHR.DirVersionId' и потом группировка с max(V.DirVersionId)
	WHERE FHR.[FolderId] = T.FolderId                               --вот это условие кажется можно перенести внутрь подзапроса T (cross join сработает как join)
	AND FHR.DirId = T.DirId                                         --и это
	AND EXISTS (SELECT 1 FROM #FileVersions V WHERE V.DirVersionId <= FHR.DirVersionId) --есть среди прошлых версий каталога
	AND NOT EXISTS (												--не встречается среди тех файлов которые удаляли и не были восстановлены
			SELECT 1
			FROM dbo.vwFileHistoryRemove DFHR
			WHERE DFHR.FileId = T.FileId
				AND DFHR.[FolderId] = T.FolderId
				AND DFHR.DirVersionId = FHR.DirVersionId
				AND NOT EXISTS (									--удаление файла не было восстановлено (файл не был восстановлен) 
					SELECT 1
					FROM dbo.vwFileHistoryRestore DFHRes
					WHERE DFHRes.[FolderId] = T.FolderId
						AND DFHRes.FileId = T.FileId
						AND DFHRes.PreviousFileVersionId = DFHR.FileVersionId
					)
			)


*/