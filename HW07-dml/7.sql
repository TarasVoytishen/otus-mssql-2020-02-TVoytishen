--Insert, Update, Merge
--1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers

insert into Sales.Customers 
(	   --[CustomerID] --поле под ограничением
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

--2. удалите 1 запись из Customers, которая была вами добавлена

delete top (1) Sales.Customers
where [CustomerName] like 'newcustomer_%'

--3. изменить одну запись, из добавленных через UPDATE

update top(1) Sales.Customers
set [CustomerName]=[CustomerName]+'_updated'
where [CustomerName] like 'newcustomer_%'

--проверка
select * from Sales.Customers where [CustomerName] like 'newcustomer_%'

--4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть




--5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert



