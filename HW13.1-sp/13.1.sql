/*
SP � function
1) �������� ������� ������������ ������� � ���������� ������ �������.
2) �������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
������������ ������� :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
3) ������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.
4) �������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����.

�� ���� ����������, � �������� ������� ��� ��������������
5) ����� ������� �������� ����� � ������.

�����������
6) ������������ ���� � �� �� ��������� kitchen sink � ���������� ������� ���������� �� ������ � ������� �� ������������ SQL.

���������� ����� �������.

7) �������� ������ � ���������� ��� ���� �������, 
�������\����������\�������� ������ � ����������� ��������� ������� ������ � ������ ������� ��������, 
����� ������������ ���� �����, 
��� �� ����� ������ ���� ����� �� ����������� � ���� ������ (1-2 �����������)

8) �������� ����������� � 2� ����� ���������� ������ � ���� ������� � ������ ������� ��������, 
��������� ������ � ����� �������, 
��������� ����� � ��� �� ������. 
��� � ����� ����������, ��� ������ ������.
*/

--1) �������� ������� ������������ ������� � ���������� ������ �������.
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

--��������
select dbo.getBestClient() as BestClient;

--2) �������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
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

--���������
declare @SaleSum decimal(18,3);
exec dbo.getSaleSumForClient 2,@SaleSum output;
select @SaleSum as SaleSum;

--3) ������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.

--������� ����� �� ������� ��� � ���������
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

--��������
select dbo.getSaleSumForClientF(2) as SaleSum;

--������� ������� � ������������������
select dbo.getSaleSumForClientF(6) as SaleSum;
declare @SaleSum decimal(18,2);
exec dbo.getSaleSumForClient 6,@SaleSum output;
select @SaleSum as SaleSum;

--��� ���� ����� �������
select dbo.getSaleSumForClientF(6) as SaleSum;
exec dbo.getSaleSumForClient 6,@SaleSum output;
select @SaleSum as SaleSum;

--� �� �� ����� � ���� ������ �������
select 
		SUM(sil.Quantity*sil.UnitPrice) as SaleSum
	from
		Sales.InvoiceLines sil
	join 
		Sales.Invoices si on sil.InvoiceID=si.InvoiceID
	where 
		si.CustomerID=6;

--� ��� ����� ��������(��� ���� �� �����) - ������� ������ ��������� �� 0% �������, ���-�� ���������� ��� ����������� ��������


--4) �������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����.

--������� ��������� ������� ������� ������ 
--������� 
--SaleSum, InvoiceID
--��� 10 invoice ��� �������

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

--��������
select * from dbo.getTop10InvoicesForClientF(4);
	
--��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����
--���������� Cross Apply

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


	

--�� ���� ����������, � �������� ������� ��� ��������������
--5) ����� ������� �������� ����� � ������.

--���� �����
