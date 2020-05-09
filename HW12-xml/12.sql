/*

XML, JSON и динамический SQL
*/

/*
1. Загрузить данные из файла StockItems.xml в таблицу Warehouse.StockItems.
Существующие записи в таблице обновить, отсутствующие добавить сопоставлять записи по полю StockItemName).
Файл StockItems.xml в личном кабинете.
*/
DECLARE @x XML
SET @x = ( 
 SELECT * FROM OPENROWSET
  (BULK 'D:\GitHub\otus-mssql-2020-02-TVoytishen\HW12-xml\StockItems.xml',
   SINGLE_BLOB)
   as d);


declare @docHandle int;

EXEC sp_xml_preparedocument @docHandle OUTPUT, @x;

--проверяем, как загружается из xml 
/*SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item', 3)
WITH ( 
	[StockItemName]			nvarchar(100)	'@Name',
	[SupplierID]			int				'SupplierID',
	[UnitPackageID]			int				'Package/UnitPackageID',
	[OuterPackageID]		int				'Package/OuterPackageID',
	[QuantityPerOuter]		int				'Package/QuantityPerOuter', 
	[TypicalWeightPerUnit]	decimal(18,3)	'Package/TypicalWeightPerUnit', 
	[LeadTimeDays]			int				'LeadTimeDays', 
	[IsChillerStock]		bit				'IsChillerStock', 
	[TaxRate]				decimal(18,3)	'TaxRate',
	[UnitPrice]				decimal(18,2)	'UnitPrice'
);
*/

--проверка сколько было строк
select count(*) as RowsBefore from Warehouse.StockItems;

--специальный пользователь для автоматизированного изменения данных
declare @PeopleDataConversionOnly int;
set @PeopleDataConversionOnly=1;

with TableFromXML
([StockItemName],[SupplierID],[UnitPackageID],[OuterPackageID],[QuantityPerOuter],[TypicalWeightPerUnit],[LeadTimeDays],[IsChillerStock],[TaxRate],[UnitPrice]) 
as
(SELECT [StockItemName],[SupplierID],[UnitPackageID],[OuterPackageID],[QuantityPerOuter],[TypicalWeightPerUnit],[LeadTimeDays],[IsChillerStock],[TaxRate],[UnitPrice]
		FROM OPENXML(@docHandle, N'/StockItems/Item', 3)
	WITH ( 
		[StockItemName]			nvarchar(100)	'@Name',
		[SupplierID]			int				'SupplierID',
		[UnitPackageID]			int				'Package/UnitPackageID',
		[OuterPackageID]		int				'Package/OuterPackageID',
		[QuantityPerOuter]		int				'Package/QuantityPerOuter', 
		[TypicalWeightPerUnit]	decimal(18,3)	'Package/TypicalWeightPerUnit', 
		[LeadTimeDays]			int				'LeadTimeDays', 
		[IsChillerStock]		bit				'IsChillerStock', 
		[TaxRate]				decimal(18,3)	'TaxRate',
		[UnitPrice]				decimal(18,2)	'UnitPrice'
		)
)
MERGE Warehouse.StockItems AS target  
USING TableFromXML
       AS source
ON (target.[StockItemName] = source.[StockItemName])	-- считаем (допущение) что нет одинаковых товаров от разных поставщиков
WHEN MATCHED AND NOT(									-- если нет полного совпадения, то обновляем
				target.[SupplierID]				=source.[SupplierID]			and 
				target.[UnitPackageID]			=source.[UnitPackageID]			and 
				target.[OuterPackageID]			=source.[OuterPackageID]		and 
				target.[QuantityPerOuter]		=source.[QuantityPerOuter]		and
				target.[TypicalWeightPerUnit]	=source.[TypicalWeightPerUnit]  and
				target.[LeadTimeDays]			=source.[LeadTimeDays]			and
				target.[IsChillerStock]			=source.[IsChillerStock]		and
				target.[TaxRate]				=source.[TaxRate]				and
				target.[UnitPrice]				=source.[UnitPrice]				
				)
    THEN UPDATE SET 
				target.[SupplierID]				=source.[SupplierID]			, 
				target.[UnitPackageID]			=source.[UnitPackageID]			, 
				target.[OuterPackageID]			=source.[OuterPackageID]		, 
				target.[QuantityPerOuter]		=source.[QuantityPerOuter]		,
				target.[TypicalWeightPerUnit]	=source.[TypicalWeightPerUnit]  ,
				target.[LeadTimeDays]			=source.[LeadTimeDays]			,
				target.[IsChillerStock]			=source.[IsChillerStock]		,
				target.[TaxRate]				=source.[TaxRate]				,
				target.[UnitPrice]				=source.[UnitPrice]				
WHEN NOT MATCHED  -- вставка 
    THEN INSERT(
				[StockItemName]					,	
				[SupplierID]					, 
				[UnitPackageID]					, 
				[OuterPackageID]				, 
				[QuantityPerOuter]				,
				[TypicalWeightPerUnit]			,
				[LeadTimeDays]					,
				[IsChillerStock]				,
				[TaxRate]						,
				[UnitPrice]						,
				[LastEditedBy]
				) VALUES(
				source.[StockItemName]			,	
				source.[SupplierID]				, 
				source.[UnitPackageID]			, 
				source.[OuterPackageID]			, 
				source.[QuantityPerOuter]		,
				source.[TypicalWeightPerUnit]	,
				source.[LeadTimeDays]			,
				source.[IsChillerStock]			,
				source.[TaxRate]				,
				source.[UnitPrice]				,
				@PeopleDataConversionOnly		--специальный пользователь 
				)				
;

--проверка сколько стало строк
select count(*) as RowsAfter from Warehouse.StockItems;

EXEC sp_xml_removedocument @docHandle
/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml

Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML.
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы.
*/

--проверяем что xml формируется правильно
/*
with XMLTable as
(
select 
		[StockItemName]			as	'@Name',
		[SupplierID]			as	'SupplierID',
		[UnitPackageID]			as	'Package/UnitPackageID',
		[OuterPackageID]		as	'Package/OuterPackageID',
		[QuantityPerOuter]		as	'Package/QuantityPerOuter', 
		[TypicalWeightPerUnit]	as	'Package/TypicalWeightPerUnit', 
		[LeadTimeDays]			as	'LeadTimeDays', 
		[IsChillerStock]		as	'IsChillerStock', 
		[TaxRate]				as	'TaxRate',
		[UnitPrice]				as	'UnitPrice'
from 
	Warehouse.StockItems 
for XML  PATH('Item'), ROOT('StockItems')
)

select * from XMLTable
;
*/

--проверка что правильно xml формируем
/*
select 
		[StockItemName]			as	'@Name',
		[SupplierID]			as	'SupplierID',
		[UnitPackageID]			as	'Package/UnitPackageID',
		[OuterPackageID]		as	'Package/OuterPackageID',
		[QuantityPerOuter]		as	'Package/QuantityPerOuter', 
		[TypicalWeightPerUnit]	as	'Package/TypicalWeightPerUnit', 
		[LeadTimeDays]			as	'LeadTimeDays', 
		[IsChillerStock]		as	'IsChillerStock', 
		[TaxRate]				as	'TaxRate',
		[UnitPrice]				as	'UnitPrice'
from 
	Warehouse.StockItems 
for XML PATH('Item'), ROOT('StockItems');
*/



--настройка sql чтобы выполнить команду windows отсюда
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO

--пишет в файл, но разбивает на строки по своему, и нет заголовка xml, как побороть, пока не нашел
declare @q_text nvarchar(2000);

set @q_text='select	[StockItemName]	as	''@Name'',	[SupplierID] as	''SupplierID'',	[UnitPackageID]	as	''Package/UnitPackageID'',	[OuterPackageID]	as	''Package/OuterPackageID'',	[QuantityPerOuter]	as	''Package/QuantityPerOuter'',	[TypicalWeightPerUnit]	as	''Package/TypicalWeightPerUnit'',	[LeadTimeDays]	as	''LeadTimeDays'',	[IsChillerStock] as	''IsChillerStock'',	[TaxRate]	as	''TaxRate'',	[UnitPrice]	as	''UnitPrice''from 	WideWorldImporters.Warehouse.StockItems for XML  PATH(''Item''), ROOT(''StockItems'')';

declare @cmd_text nvarchar(2000);
set @cmd_text='bcp "'+@q_text+'" queryout "D:\GitHub\otus-mssql-2020-02-TVoytishen\HW12-xml\StockItems2.xml"  -T -c';

print (@cmd_text);

exec xp_cmdshell @cmd_text; 

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select 
	StockItemID,
	StockItemName,
	JSON_VALUE(CustomFields,'$.CountryOfManufacture') as CountryOfManufacture,
	JSON_VALUE(CustomFields,'$.Tags[0]') as FirstTag,
	CustomFields
from 
	Warehouse.StockItems;

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести:
- StockItemID
- StockItemName     
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%'
*/


--первый вариант
select 
	si.StockItemID,
	si.StockItemName,
	STRING_AGG(tt.value,',') as Tags
from 
	Warehouse.StockItems as si
--берем только те StockItems где есть Vintage
inner join (select 
				si0.StockItemID
			from 
				Warehouse.StockItems as si0
			cross apply	(
						select 
							tt0.value as [value] 
						from OPENJSON(si0.CustomFields,'$.Tags') as tt0  
						where tt0.value='Vintage' 
						)as tt 
			) as si_vintage
		on si_vintage.StockItemID=si.StockItemID
--достаем из CustomFields все Tags
cross apply	(select tt0.value as [value] from OPENJSON(si.CustomFields,'$.Tags') as tt0)as tt 
--чтобы сделать все теги через запятую
group by 
	si.StockItemID,
	si.StockItemName
;

--первый улучшенный
select 
	si.StockItemID,
	si.StockItemName,
	STRING_AGG(tt.value,',') as Tags
from 
	Warehouse.StockItems as si
--берем только те StockItems где есть Vintage
inner join (select 
				si0.StockItemID
			from 
				Warehouse.StockItems as si0
			cross apply	
						OPENJSON(si0.CustomFields,'$.Tags') as tt0  
			where tt0.value='Vintage' 
			) as si_vintage
		on si_vintage.StockItemID=si.StockItemID
--достаем из CustomFields все Tags
cross apply	OPENJSON(si.CustomFields,'$.Tags') as tt 
--чтобы сделать все теги через запятую
group by 
	si.StockItemID,
	si.StockItemName
;


/*
5. Пишем динамический PIVOT.
По заданию из занятия “Операторы CROSS APPLY, PIVOT, CUBE”.
Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента
МесяцГод Количество покупок

Нужно написать запрос, который будет генерировать результаты для всех клиентов.
Имя клиента указывать полностью из CustomerName.
Дата должна иметь формат dd.mm.yyyy например 25.12.2019

*/

/*взял из ДЗ 9 немного изменил*/


declare @customer_names nvarchar(max);

--чтобы вручную не писать имена клиентов, используем динамический sql (так как в pivot в список столбиков нельзя поместить например запрос)
select 
	@customer_names='['+STRING_AGG(cast(sc.CustomerName as nvarchar(max)),'],[')+']'
from Sales.Customers sc 
/*where
	sc.CustomerID in (2,3,4,5,6)*/;

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
/*where
	sc.CustomerID in (2,3,4,5,6)*/
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
/*test*/


declare @customer_names nvarchar(max);

--чтобы вручную не писать имена клиентов, используем динамический sql (так как в pivot в список столбиков нельзя поместить например запрос)
select 
	@customer_names='['+STRING_AGG(cast(sc.CustomerName as nvarchar(max)),'],[')+']'
from Sales.Customers sc 
/*where
	sc.CustomerID in (2,3,4,5,6)*/;

print(@customer_names);

