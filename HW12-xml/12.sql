/*

XML, JSON � ������������ SQL
*/

/*
1. ��������� ������ �� ����� StockItems.xml � ������� Warehouse.StockItems.
������������ ������ � ������� ��������, ������������� �������� ������������ ������ �� ���� StockItemName).
���� StockItems.xml � ������ ��������.
*/
DECLARE @x XML
SET @x = ( 
 SELECT * FROM OPENROWSET
  (BULK 'D:\GitHub\otus-mssql-2020-02-TVoytishen\HW12-xml\StockItems.xml',
   SINGLE_BLOB)
   as d);


declare @docHandle int;

EXEC sp_xml_preparedocument @docHandle OUTPUT, @x;

--���������, ��� ����������� �� xml 
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

--�������� ������� ���� �����
select count(*) as RowsBefore from Warehouse.StockItems;

--����������� ������������ ��� ������������������� ��������� ������
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
ON (target.[StockItemName] = source.[StockItemName])	-- ������� (���������) ��� ��� ���������� ������� �� ������ �����������
WHEN MATCHED AND NOT(									-- ���� ��� ������� ����������, �� ���������
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
WHEN NOT MATCHED  -- ������� 
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
				@PeopleDataConversionOnly		--����������� ������������ 
				)				
;

--�������� ������� ����� �����
select count(*) as RowsAfter from Warehouse.StockItems;

EXEC sp_xml_removedocument @docHandle
/*
2. ��������� ������ �� ������� StockItems � ����� �� xml-����, ��� StockItems.xml

���������� � �������� 1, 2:
* ���� � ��������� � ���� ����� ��������, �� ����� ������� ������ SELECT c ����������� � ���� XML.
* ���� � ��� � ������� ������������ �������/������ � XML, �� ������ ����� ���� XML � ���� �������.
* ���� � ���� XML ��� ����� ������, �� ������ ����� ����� �������� ������ � ������������� �� � �������.
*/

--��������� ��� xml ����������� ���������
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

--�������� ��� ��������� xml ���������
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



--��������� sql ����� ��������� ������� windows ������
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO

--����� � ����, �� ��������� �� ������ �� ������, � ��� ��������� xml, ��� ��������, ���� �� �����
declare @q_text nvarchar(2000);

set @q_text='select	[StockItemName]	as	''@Name'',	[SupplierID] as	''SupplierID'',	[UnitPackageID]	as	''Package/UnitPackageID'',	[OuterPackageID]	as	''Package/OuterPackageID'',	[QuantityPerOuter]	as	''Package/QuantityPerOuter'',	[TypicalWeightPerUnit]	as	''Package/TypicalWeightPerUnit'',	[LeadTimeDays]	as	''LeadTimeDays'',	[IsChillerStock] as	''IsChillerStock'',	[TaxRate]	as	''TaxRate'',	[UnitPrice]	as	''UnitPrice''from 	WideWorldImporters.Warehouse.StockItems for XML  PATH(''Item''), ROOT(''StockItems'')';

declare @cmd_text nvarchar(2000);
set @cmd_text='bcp "'+@q_text+'" queryout "D:\GitHub\otus-mssql-2020-02-TVoytishen\HW12-xml\StockItems2.xml"  -T -c';

print (@cmd_text);

exec xp_cmdshell @cmd_text; 

/*
3. � ������� Warehouse.StockItems � ������� CustomFields ���� ������ � JSON.
�������� SELECT ��� ������:
- StockItemID
- StockItemName
- CountryOfManufacture (�� CustomFields)
- FirstTag (�� ���� CustomFields, ������ �������� �� ������� Tags)
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
4. ����� � StockItems ������, ��� ���� ��� "Vintage".
�������:
- StockItemID
- StockItemName     
- (�����������) ��� ���� (�� CustomFields) ����� ������� � ����� ����

���� ������ � ���� CustomFields, � �� � Tags.
������ �������� ����� ������� ������ � JSON.
��� ������ ������������ ���������, ������������ LIKE ���������.

������ ���� � ����� ����:
... where ... = 'Vintage'

��� ������� �� �����:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%'
*/


--������ �������
select 
	si.StockItemID,
	si.StockItemName,
	STRING_AGG(tt.value,',') as Tags
from 
	Warehouse.StockItems as si
--����� ������ �� StockItems ��� ���� Vintage
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
--������� �� CustomFields ��� Tags
cross apply	(select tt0.value as [value] from OPENJSON(si.CustomFields,'$.Tags') as tt0)as tt 
--����� ������� ��� ���� ����� �������
group by 
	si.StockItemID,
	si.StockItemName
;

--������ ����������
select 
	si.StockItemID,
	si.StockItemName,
	STRING_AGG(tt.value,',') as Tags
from 
	Warehouse.StockItems as si
--����� ������ �� StockItems ��� ���� Vintage
inner join (select 
				si0.StockItemID
			from 
				Warehouse.StockItems as si0
			cross apply	
						OPENJSON(si0.CustomFields,'$.Tags') as tt0  
			where tt0.value='Vintage' 
			) as si_vintage
		on si_vintage.StockItemID=si.StockItemID
--������� �� CustomFields ��� Tags
cross apply	OPENJSON(si.CustomFields,'$.Tags') as tt 
--����� ������� ��� ���� ����� �������
group by 
	si.StockItemID,
	si.StockItemName
;


/*
5. ����� ������������ PIVOT.
�� ������� �� ������� ���������� CROSS APPLY, PIVOT, CUBE�.
��������� �������� ������, ������� � ���������� ������ ���������� ��������� ������� ���������� ����:
�������� �������
�������� ���������� �������

����� �������� ������, ������� ����� ������������ ���������� ��� ���� ��������.
��� ������� ��������� ��������� �� CustomerName.
���� ������ ����� ������ dd.mm.yyyy �������� 25.12.2019

*/

/*���� �� �� 9 ������� �������*/


declare @customer_names nvarchar(max);

--����� ������� �� ������ ����� ��������, ���������� ������������ sql (��� ��� � pivot � ������ ��������� ������ ��������� �������� ������)
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

--exec @query - �� ��������
exec sp_executesql @query;
/*test*/


declare @customer_names nvarchar(max);

--����� ������� �� ������ ����� ��������, ���������� ������������ sql (��� ��� � pivot � ������ ��������� ������ ��������� �������� ������)
select 
	@customer_names='['+STRING_AGG(cast(sc.CustomerName as nvarchar(max)),'],[')+']'
from Sales.Customers sc 
/*where
	sc.CustomerID in (2,3,4,5,6)*/;

print(@customer_names);

