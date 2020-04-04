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

--возьмем те записи, которые уже вставили (которые 'newcustomer_%'), и вставим еще раз
--в качестве изменения изменим им кредитный лимит
--если [CustomerName] совпадает то обновим, если не совпадает то вставим 
--для того чтобы 1 не совпадала по имени, та которая '%_updated' изменим имя
MERGE Sales.Customers AS target  
USING (SELECT 
		 case 
			 when scs.[CustomerName] like '%_updated' then scs.[CustomerName]+'2'
			 else scs.[CustomerName]	
		end as [CustomerName]
		,scs.[BillToCustomerID]
		,scs.[CustomerCategoryID]
		,scs.[BuyingGroupID]
		,scs.[PrimaryContactPersonID]
		,scs.[AlternateContactPersonID]
		,scs.[DeliveryMethodID]
		,scs.[DeliveryCityID]
		,scs.[PostalCityID]
		,case 
			when scs.[CreditLimit] is null then 100
			else scs.[CreditLimit]+100
		end as [CreditLimit]
		,scs.[AccountOpenedDate]
		,scs.[StandardDiscountPercentage]
		,scs.[IsStatementSent]
		,scs.[IsOnCreditHold]
		,scs.[PaymentDays]
		,scs.[PhoneNumber]
		,scs.[FaxNumber]
		,scs.[DeliveryRun]
		,scs.[RunPosition]
		,scs.[WebsiteURL]
		,scs.[DeliveryAddressLine1]
		,scs.[DeliveryAddressLine2]
		,scs.[DeliveryPostalCode]
		,scs.[DeliveryLocation]
		,scs.[PostalAddressLine1]
		,scs.[PostalAddressLine2]
		,scs.[PostalPostalCode]
		,scs.[LastEditedBy]
	from 
		Sales.Customers scs
	where 
		scs.[CustomerName] like 'newcustomer_%'	
      ) AS source 
ON (target.[CustomerName] = source.[CustomerName])  
WHEN MATCHED 
    THEN UPDATE SET target.[CreditLimit] = source.[CreditLimit] 
WHEN NOT MATCHED  
    THEN INSERT (
	   [CustomerName]
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
	)
	VALUES(	  
		source.[CustomerName]
      ,source.[BillToCustomerID]
      ,source.[CustomerCategoryID]
      ,source.[BuyingGroupID]
      ,source.[PrimaryContactPersonID]
      ,source.[AlternateContactPersonID]
      ,source.[DeliveryMethodID]
      ,source.[DeliveryCityID]
      ,source.[PostalCityID]
      ,source.[CreditLimit]
      ,source.[AccountOpenedDate]
      ,source.[StandardDiscountPercentage]
      ,source.[IsStatementSent]
      ,source.[IsOnCreditHold]
      ,source.[PaymentDays]
      ,source.[PhoneNumber]
      ,source.[FaxNumber]
      ,source.[DeliveryRun]
      ,source.[RunPosition]
      ,source.[WebsiteURL]
      ,source.[DeliveryAddressLine1]
      ,source.[DeliveryAddressLine2]
      ,source.[DeliveryPostalCode]
      ,source.[DeliveryLocation]
      ,source.[PostalAddressLine1]
      ,source.[PostalAddressLine2]
      ,source.[PostalPostalCode]
      ,source.[LastEditedBy]);

--проверка
select * from Sales.Customers where [CustomerName] like 'newcustomer_%';


--5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert

--настройка sql чтобы выполнить команду windows отсюда
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO

declare @query_text nvarchar(2000);
declare @bcp_text nvarchar(2000);

set @query_text='SELECT CustomerName FROM [WideWorldImporters].[Sales].[Customers] WHERE [CustomerName] like ''newcustomer_%''';
print(@query_text);

-- -c - символьный
-- -T - использовать аутентификацию Windows
-- -t; - заменить разделитель табуляцию на ;
set @bcp_text='bcp "'+@query_text +'" queryout "d:\Customers.csv" -c -t; -T ';
print(@bcp_text);

EXEC xp_cmdshell @bcp_text;

--выгрузили


--теперь загрузим

--пробуем загрузить в новую таблицу
--создадим копию таблицы (чтобы не иметь дело с ограничениями)
CREATE TABLE [Sales].[Customers2](
/*	[CustomerID] [int] NOT NULL,*/
	[CustomerName] [nvarchar](100) NOT NULL/*,
	[BillToCustomerID] [int] NOT NULL,
	[CustomerCategoryID] [int] NOT NULL,
	[BuyingGroupID] [int] NULL,
	[PrimaryContactPersonID] [int] NOT NULL,
	[AlternateContactPersonID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryCityID] [int] NOT NULL,
	[PostalCityID] [int] NOT NULL,
	[CreditLimit] [decimal](18, 2) NULL,
	[AccountOpenedDate] [date] NOT NULL,
	[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
	[IsStatementSent] [bit] NOT NULL,
	[IsOnCreditHold] [bit] NOT NULL,
	[PaymentDays] [int] NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[FaxNumber] [nvarchar](20) NOT NULL,
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[WebsiteURL] [nvarchar](256) NOT NULL,
	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
	[DeliveryAddressLine2] [nvarchar](60) NULL,
	[DeliveryPostalCode] [nvarchar](10) NOT NULL,
	[DeliveryLocation] [geography] NULL,
	[PostalAddressLine1] [nvarchar](60) NOT NULL,
	[PostalAddressLine2] [nvarchar](60) NULL,
	[PostalPostalCode] [nvarchar](10) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[ValidFrom] [datetime2](7)  NOT NULL,
	[ValidTo] [datetime2](7)  NOT NULL*/);

--и в нее уже загрузим

BULK INSERT WideWorldImporters.Sales.[Customers2]
FROM 'd:\Customers.csv'
WITH ( FORMAT='CSV');

--проверяем что загрузилось
select * from Sales.[Customers2];

--удаляем новую таблицу
drop table WideWorldImporters.Sales.[Customers2];


--вернем параметры на место
EXEC sp_configure 'show advanced options', 0
GO
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 0
GO
RECONFIGURE
GO


--P/S
/*
Через bulk insert куча ошибок при загрузке, если грузятся int, datetime2 и т.д
что в формате -n что -t
Похоже из-за конвертации типов так все сложно
Со строками нормально

*/