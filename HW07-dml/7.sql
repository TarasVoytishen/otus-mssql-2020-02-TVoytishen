--Insert, Update, Merge
--1. ����������� � ���� 5 ������� ��������� insert � ������� Customers ��� Suppliers

insert into Sales.Customers 
(	   --[CustomerID] --���� ��� ������������
      /*[CustomerID]
	  ,*/[CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
      --,[ValidFrom]
      --,[ValidTo] 
)
select  
     /* [CustomerID]
	  ,*/
	  --NEXT VALUE FOR [Sequences].[CustomerID],
	  'newcustomer_'+[CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
      --,[ValidFrom]
      --,[ValidTo] 
from
Sales.Customers sc
where sc.CustomerID<=5
--order by CustomerID desc

--2. ������� 1 ������ �� Customers, ������� ���� ���� ���������

delete top (1) Sales.Customers
where [CustomerName] like 'newcustomer_%'

--3. �������� ���� ������, �� ����������� ����� UPDATE

update top(1) Sales.Customers
set [CustomerName]=[CustomerName]+'_updated'
where [CustomerName] like 'newcustomer_%'

--��������
select * from Sales.Customers where [CustomerName] like 'newcustomer_%'

--4. �������� MERGE, ������� ������� ������� ������ � �������, ���� �� ��� ���, � ������� ���� ��� ��� ����




--5. �������� ������, ������� �������� ������ ����� bcp out � ��������� ����� bulk insert



