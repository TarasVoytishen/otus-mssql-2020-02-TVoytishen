--Pivot � Cross Apply
/*1. ��������� �������� ������, ������� � ���������� ������ ���������� ��������� ������� ���������� ����:
�������� �������
�������� ���������� �������

�������� ����� � ID 2-6, ��� ��� ������������� Tailspin Toys
��� ������� ����� �������� ��� ����� �������� ������ ���������
�������� �������� Tailspin Toys (Gasport, NY) - �� �������� � ����� ������ Gasport,NY
���� ������ ����� ������ dd.mm.yyyy �������� 25.12.2019

��������, ��� ������ ��������� ����������:
InvoiceMonth Peeples Valley, AZ Medicine Lodge, KS Gasport, NY Sylvanite, MT Jessie, ND
01.01.2013 3 1 4 2 2
01.02.2013 7 3 4 2 1
*/

/*
declare @customer_names0 nvarchar(max);

--����� ������� �� ������ ����� ��������, ���������� ������������ sql (��� ��� � pivot � ������ ��������� ������ ��������� �������� ������)
select 
	@customer_names0=STRING_AGG(' ['+cast(sc.CustomerID as nvarchar(max))+'] as ['+sc.CustomerName+']',',')
from Sales.Customers sc 
where
	sc.CustomerID in (2,3,4,5,6);

print(@customer_names0);
*/

declare @customer_names nvarchar(max);

--����� ������� �� ������ ����� ��������, ���������� ������������ sql (��� ��� � pivot � ������ ��������� ������ ��������� �������� ������)
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

--exec @query - �� ��������
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

/*2. ��� ���� �������� � ������, � ������� ���� Tailspin Toys
������� ��� ������, ������� ���� � �������, � ����� �������

������ �����������
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



/*3. � ������� ����� ���� ���� � ����� ������ �������� � ���������
�������� ������� �� ������, ��������, ��� - ����� � ���� ��� ���� �������� ���� ��������� ���
������ ������

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
4. ���������� �� �� ������� ������� ����� CROSS APPLY
�������� �� ������� ������� 2 ����� ������� ������, ������� �� �������
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������
*/

--5. �������� �� ������� ������� 2 ����� ������� ������, ������� �� �������
--� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������
--������� � CTE (���� ������� ������)
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


--���������� �� cross apply
select distinct 
	sc.CustomerID,
	sc.CustomerName,
	sil.StockItemID,
	sil.UnitPrice,
	max(si.InvoiceDate) as last_InvoiceDate--�� ��������� ��� ������� �������� ���������
from Sales.InvoiceLines sil
join Sales.Invoices si on si.InvoiceID=sil.InvoiceID
join Sales.Customers sc on sc.CustomerID=si.CustomerID

join(--���������� � �������� ��� ���2 ����� ������� ������� �� �������, �� ��� ���� �������
	select 
		scm.CustomerID,scm.CustomerName, top2_max_price_items.StockItemID,top2_max_price_items.UnitPrice
	from Sales.Customers scm
	cross apply(
			select distinct top 2 --�������� ���2 ��������� ����� ������� ������� �� ������� �������
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
5. Code review (�����������). ������ �������� � ��������� Hometask_code_review.sql.
��� ������ ������?
��� ����� �������� CROSS APPLY - ����� �� ������������ ������ ��������� �������\�������?
*/

--�� ������, ���� ������ ������� ��������� ��� �� ������ ������

--��������� �����������
--������, dbo.vwFolderHistoryRemove - ��� ������� ������� �������� ��������� ��� ������ � ���� ���������
--#FileVersions - ������� ������ ������
--vwFileHistoryRestore - ������� �������������� ������
--vwFileHistoryRemove - ������� �������� ������

--������ ������� �������, ������ �����, ���� ������� ���� �� ���� ��� ���� �������

/*
SELECT T.FolderId,
		   T.FileVersionId,
		   T.FileId		
	FROM dbo.vwFolderHistoryRemove FHR
	CROSS APPLY (
			SELECT TOP 1 FileVersionId, FileId, FolderId, DirId    --����� ��������� ������ ����� (��� �� ������ ��� ������ �� ���� ��� ������� (���� ��� �������?))
			FROM #FileVersions V
			WHERE RowNum = 1
				AND DirVersionId <= FHR.DirVersionId
			ORDER BY V.DirVersionId DESC   
			) T														--������� cross join ����� �������� �� inner join � 'on DirVersionId <= FHR.DirVersionId' � ����� ����������� � max(V.DirVersionId)
	WHERE FHR.[FolderId] = T.FolderId                               --��� ��� ������� ������� ����� ��������� ������ ���������� T (cross join ��������� ��� join)
	AND FHR.DirId = T.DirId                                         --� ���
	AND EXISTS (SELECT 1 FROM #FileVersions V WHERE V.DirVersionId <= FHR.DirVersionId) --���� ����� ������� ������ ��������
	AND NOT EXISTS (												--�� ����������� ����� ��� ������ ������� ������� � �� ���� �������������
			SELECT 1
			FROM dbo.vwFileHistoryRemove DFHR
			WHERE DFHR.FileId = T.FileId
				AND DFHR.[FolderId] = T.FolderId
				AND DFHR.DirVersionId = FHR.DirVersionId
				AND NOT EXISTS (									--�������� ����� �� ���� ������������� (���� �� ��� ������������) 
					SELECT 1
					FROM dbo.vwFileHistoryRestore DFHRes
					WHERE DFHRes.[FolderId] = T.FolderId
						AND DFHRes.FileId = T.FileId
						AND DFHRes.PreviousFileVersionId = DFHR.FileVersionId
					)
			)


*/