/*
проект - расчет партий по fifo
и всяческих отчетов по продажам
запасам товаров и т.д.
сейчас упрощенно, пока не знаю
какие таблицы нужны и что еще понадобится
считаем что склад один

таблицы:
	incomes - приход товара на склад (поставка от поставщика или оприходование излишков)
		doc_id		- документ прихода
		sku_id		- товар
		price		- цена поставки
		quantity	- количество
		supplier_id - поставщик
		date_time	- дата+время поступления

		первичный ключ: doc_id+sku_id
		внешний ключ: sku_id	

	outcomes - расход товаров со склада (списания)
		doc_id		- документ списания
		sku_id		- товар
		quantity	- количество
		date_time	- дата+время списания

		первичный ключ: doc_id+sku_id
		внешний ключ: sku_id	

	sales - продажи товара (считаем что сразу списался со склада)
		doc_id		- документ продаж
		sku_id		- товар
		price		- цена продажи
		quantity	- количество
		customer_id	- покупатель
		date_time	- дата+время продажи

		первичный ключ: doc_id+sku_id
		внешний ключ: sku_id	
		внешний ключ: customer_id	
		индекс:		  date_time

	returns - возврат товара от клиента (считаем что сразу поступил на склад)
		doc_id		- документ возврата
		doc_sales_id- документ продажи (если есть)
		sku_id		- товар
		price		- цена возврата
		quantity	- количество
		customer_id	- покупатель
		date_time	- дата+время возврата

		первичный ключ: doc_id+sku_id
		внешний ключ: sku_id	
		внешний ключ: customer_id

	customers - клиенты
		id			- ид клиента
		name		- название
		date_create	- дата заведения клиента (при первой продаже)
		
		первичный ключ: id

	suppliers - поставщики товара
		id			- ид поставщика
		name		- название
		date_create	- дата заведения поставщика (при первой поставке)
		
		первичный ключ: id

	sku - товары
		id			- ид товара
		name		- название
		
		первичный ключ: id

представления:
	sku_sale_price - цены товаров по последней продаже
		sku_id		- ид товара
		price		- цена

	sku_wh - остатки товаров на складе
		sku_id		- ид товара
		quantity	- остаток

*/

--создаем бд
CREATE DATABASE otus_project
 ON  PRIMARY 
( NAME = N'otus_project', FILENAME='D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\otus_project.mdf', SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'otus_project_log',FILENAME='D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\otus_project.ldf', SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB );
 GO


  --используем чтобы не писать имя бд
 use otus_project
 go

/*
	sku - товары
		id			- ид товара
		name		- название
		
		первичный ключ: id
*/
create table sku(
	id int not null PRIMARY KEY,
	name nvarchar(200) not null
);
go

 --используем чтобы не писать имя бд
 use otus_project
 go
/*
	customers - клиенты
		id			- ид клиента
		name		- название
		date_create	- дата заведения клиента (при первой продаже)
		
		первичный ключ: id

*/
create table customers(
	id int not null PRIMARY KEY,
	name nvarchar(200) not null CHECK  (
		REPLACE(name,' ','')!='' -- не может быть из пробелов или пустой
	),
	date_create date not null

);
go


 --используем чтобы не писать имя бд
 use otus_project
 go

/*
	suppliers - поставщики товара
		id			- ид поставщика
		name		- название
		date_create	- дата заведения поставщика (при первой поставке)
		
		первичный ключ: id
*/
create table suppliers(
	id int not null PRIMARY KEY,
	name nvarchar(200) not null CHECK  (
		REPLACE(name,' ','')!='' -- не может быть из пробелов или пустой
	),
	date_create date not null

);
go

 --используем чтобы не писать имя бд
 use otus_project
 go

 
 /*
 	incomes - приход товара на склад (поставка от поставщика или оприходование излишков)
		doc_id		- документ прихода
		sku_id		- товар
		price		- цена поставки
		quantity	- количество
		date_time	- дата+время поступления

		первичный ключ: doc_id+sku_id
		внешний ключ: sku_id	

 */
 create table incomes(
	doc_id int not null,
	sku_id int not null FOREIGN KEY REFERENCES sku(id),
	price decimal(15,2)  null,
	quantity decimal(15,3) not null,
	supplier_id int null,
	date_time datetime not null CHECK  (
		date_time<=GETDATE() -- не может быть будущим числом
	)
 
	constraint [PK_incomes] primary key clustered
	(
		doc_id,
		sku_id
	)


);
go
 
 --используем чтобы не писать имя бд
 use otus_project
 go

/*
	outcomes - расход товаров со склада (списания)
		doc_id		- документ списания
		sku_id		- товар
		quantity	- количество
		date_time	- дата+время списания

		первичный ключ: doc_id+sku_id
		внешний ключ: sku_id	

*/
 create table outcomes(
	doc_id int not null,
	sku_id int not null FOREIGN KEY REFERENCES sku(id),
	quantity decimal(15,3) not null,
	date_time datetime not null CHECK  (
		date_time<=GETDATE() -- не может быть будущим числом
	)
 
	constraint [PK_outcomes] primary key clustered
	(
		doc_id,
		sku_id
	)

);
go

 --используем чтобы не писать имя бд
 use otus_project
 go

/*
	sales - продажи товара (считаем что сразу списался со склада)
		doc_id		- документ продаж
		sku_id		- товар
		price		- цена продажи
		quantity	- количество
		customer_id	- покупатель
		date_time	- дата+время продажи

		первичный ключ: doc_id+sku_id
		внешний ключ: sku_id	
		внешний ключ: customer_id
		индекс:		  date_time

*/
 create table sales(
	doc_id int not null,
	sku_id int not null FOREIGN KEY REFERENCES sku(id),
	price decimal(15,2) not null,
	quantity decimal(15,3) not null,
	customer_id	int not null FOREIGN KEY REFERENCES customers(id),
	date_time datetime not null CHECK  (
		date_time<=GETDATE() -- не может быть будущим числом
	)
 
	constraint [PK_sales] primary key clustered
	(
		doc_id,
		sku_id
	)


);
go
CREATE INDEX I_date_time ON sales
(
	date_time DESC
);
go

 --используем чтобы не писать имя бд
 use otus_project
 go

/*
	returns - возврат товара от клиента (считаем что сразу поступил на склад)
		doc_id		- документ возврата
		doc_sales_id- документ продажи (если есть)
		sku_id		- товар
		price		- цена возврата
		quantity	- количество
		customer_id	- покупатель
		date_time	- дата+время возврата

		первичный ключ: doc_id+sku_id
		внешний ключ: sku_id	
		внешний ключ: customer_id

*/
 create table [returns](
	doc_id int not null,
	doc_sales_id int not null,
	sku_id int not null FOREIGN KEY REFERENCES sku(id),
	price decimal(15,2) not null CHECK  (
		price>0
	),
	quantity decimal(15,3) not null,
	customer_id	int not null FOREIGN KEY REFERENCES customers(id),
	date_time datetime not null
 
	constraint [PK_returns] primary key clustered
	(
		doc_id,
		sku_id
	)

);
go

/*
представления:
	sku_sale_price - цены товаров по последней продаже
		sku_id		- ид товара
		price		- цена

	sku_wh - остатки товаров на складе
		sku_id		- ид товара
		quantity	- остаток

*/

CREATE VIEW sku_sale_price
AS
select 
	sku.id sku_id,
	s.price price
from sku sku
left join sales s on sku.id=s.sku_id
inner join(
	select 
		s_max.sku_id, 
		max(s_max.date_time) max_date_time 
	from 
		sales s_max 
	group by 
		s_max.sku_id) s_max

on s.date_time=s_max.max_date_time and s.sku_id=s_max.sku_id;
GO

CREATE VIEW sku_wh
AS
select
	sku_inout.sku_id,
	sum(sku_inout.quantity) quantity

from(
	select sku_id,quantity
	from incomes
	union all
	select sku_id,quantity
	from [returns]
	union all
	select sku_id,-quantity
	from outcomes
	union all
	select id,0
	from sku
	) sku_inout

group by
	sku_inout.sku_id;
go


--для удобства, чтобы соединение не висело на otus_project
use master
go







