/*�������� �������� ��������� ������������ ������� � ��������� ������� ������ �������.
����: ��������� �������� ��������� ���������� ��������. ������ ������
�������� �������� ��������� ������������ ������� � ��������� ������� ������ �������.
�������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
������������ ������� :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines*/

use WideWorldImporters
go

--������� ��������� ������������ ������� � �������� ���� ������������ ��������� �������
create or alter procedure dbo.getClientWithMaximumOneSale 
@CustomerName nvarchar(100) OUTPUT,
@CustomerId int OUTPUT
as
begin
	SET NOCOUNT ON;

	select 
		@CustomerName=sc.CustomerName,
		@CustomerId=sc.CustomerId
	from 
		Sales.Customers sc
	where sc.CustomerId IN (
							select top 1 
								MaximumOneSale.CustomerID
							from	
								(select 
									SUM(sil.Quantity*sil.UnitPrice) as OneSaleSum,
									si.InvoiceID,
									si.CustomerID
								from
									Sales.InvoiceLines sil
								join 
									Sales.Invoices si on sil.InvoiceID=si.InvoiceID
								group by
									si.InvoiceID,
									si.CustomerID) as MaximumOneSale
							order by 
								MaximumOneSale.OneSaleSum desc);
end;
go

--��������
declare @WhoIsClientName nvarchar(100);
declare @WhoIsClientId int;

exec dbo.getClientWithMaximumOneSale  @WhoIsClientName output , @WhoIsClientId output;

select @WhoIsClientId as [Id],@WhoIsClientName as [Name];

go

--��������� ���������
--�������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
create or alter procedure dbo.getMaximumOneSaleForClient 
@CustomerId int ,  
@MaximumOneSale decimal(18,2) OUTPUT
as
begin
	SET NOCOUNT ON;

	select top 1 
		@MaximumOneSale=MaximumOneSale.OneSaleSum
	from	
		(select 
			SUM(sil.Quantity*sil.UnitPrice) as OneSaleSum,
			si.InvoiceID
			
		from
			Sales.InvoiceLines sil
		join 
			Sales.Invoices si on sil.InvoiceID=si.InvoiceID
		where si.CustomerID=834--@CustomerId
		group by
			si.InvoiceID
			) as MaximumOneSale
	order by 
		MaximumOneSale.OneSaleSum desc;
end;
go

--��������
declare @MaximumOneSale decimal(18,2);
declare @ClientId int;
set @ClientId=2;

exec dbo.getMaximumOneSaleForClient  @ClientId  , @MaximumOneSale output;

select @ClientId as [Id],@MaximumOneSale as [Sum];

go
