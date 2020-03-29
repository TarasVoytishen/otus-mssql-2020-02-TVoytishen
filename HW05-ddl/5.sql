/*
������ - ������ ������ �� fifo
� ��������� ������� �� ��������
������� ������� � �.�.
������ ���������, ���� �� ����
����� ������� ����� � ��� ��� �����������
������� ��� ����� ����

�������:
	incomes - ������ ������ �� ����� (�������� �� ���������� ��� ������������� ��������)
		doc_id		- �������� �������
		sku_id		- �����
		price		- ���� ��������
		quantity	- ����������
		supplier_id - ���������
		date_time	- ����+����� �����������

		��������� ����: doc_id+sku_id
		������� ����: sku_id	

	outcomes - ������ ������� �� ������ (��������)
		doc_id		- �������� ��������
		sku_id		- �����
		quantity	- ����������
		date_time	- ����+����� ��������

		��������� ����: doc_id+sku_id
		������� ����: sku_id	

	sales - ������� ������ (������� ��� ����� �������� �� ������)
		doc_id		- �������� ������
		sku_id		- �����
		price		- ���� �������
		quantity	- ����������
		customer_id	- ����������
		date_time	- ����+����� �������

		��������� ����: doc_id+sku_id
		������� ����: sku_id	
		������� ����: customer_id	
		������:		  date_time

	returns - ������� ������ �� ������� (������� ��� ����� �������� �� �����)
		doc_id		- �������� ��������
		doc_sales_id- �������� ������� (���� ����)
		sku_id		- �����
		price		- ���� ��������
		quantity	- ����������
		customer_id	- ����������
		date_time	- ����+����� ��������

		��������� ����: doc_id+sku_id
		������� ����: sku_id	
		������� ����: customer_id

	customers - �������
		id			- �� �������
		name		- ��������
		date_create	- ���� ��������� ������� (��� ������ �������)
		
		��������� ����: id

	suppliers - ���������� ������
		id			- �� ����������
		name		- ��������
		date_create	- ���� ��������� ���������� (��� ������ ��������)
		
		��������� ����: id

	sku - ������
		id			- �� ������
		name		- ��������
		
		��������� ����: id

�������������:
	sku_sale_price - ���� ������� �� ��������� �������
		sku_id		- �� ������
		price		- ����

	sku_wh - ������� ������� �� ������
		sku_id		- �� ������
		quantity	- �������

*/

--������� ��
CREATE DATABASE otus_project
 ON  PRIMARY 
( NAME = N'otus_project', FILENAME='D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\otus_project.mdf', SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'otus_project_log',FILENAME='D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\otus_project.ldf', SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB );
 GO


  --���������� ����� �� ������ ��� ��
 use otus_project
 go

/*
	sku - ������
		id			- �� ������
		name		- ��������
		
		��������� ����: id
*/
create table sku(
	id int not null PRIMARY KEY,
	name nvarchar(200) not null
);
go

 --���������� ����� �� ������ ��� ��
 use otus_project
 go
/*
	customers - �������
		id			- �� �������
		name		- ��������
		date_create	- ���� ��������� ������� (��� ������ �������)
		
		��������� ����: id

*/
create table customers(
	id int not null PRIMARY KEY,
	name nvarchar(200) not null CHECK  (
		REPLACE(name,' ','')!='' -- �� ����� ���� �� �������� ��� ������
	),
	date_create date not null

);
go


 --���������� ����� �� ������ ��� ��
 use otus_project
 go

/*
	suppliers - ���������� ������
		id			- �� ����������
		name		- ��������
		date_create	- ���� ��������� ���������� (��� ������ ��������)
		
		��������� ����: id
*/
create table suppliers(
	id int not null PRIMARY KEY,
	name nvarchar(200) not null CHECK  (
		REPLACE(name,' ','')!='' -- �� ����� ���� �� �������� ��� ������
	),
	date_create date not null

);
go

 --���������� ����� �� ������ ��� ��
 use otus_project
 go

 
 /*
 	incomes - ������ ������ �� ����� (�������� �� ���������� ��� ������������� ��������)
		doc_id		- �������� �������
		sku_id		- �����
		price		- ���� ��������
		quantity	- ����������
		date_time	- ����+����� �����������

		��������� ����: doc_id+sku_id
		������� ����: sku_id	

 */
 create table incomes(
	doc_id int not null,
	sku_id int not null FOREIGN KEY REFERENCES sku(id),
	price decimal(15,2)  null,
	quantity decimal(15,3) not null,
	supplier_id int null,
	date_time datetime not null CHECK  (
		date_time<=GETDATE() -- �� ����� ���� ������� ������
	)
 
	constraint [PK_incomes] primary key clustered
	(
		doc_id,
		sku_id
	)


);
go
 
 --���������� ����� �� ������ ��� ��
 use otus_project
 go

/*
	outcomes - ������ ������� �� ������ (��������)
		doc_id		- �������� ��������
		sku_id		- �����
		quantity	- ����������
		date_time	- ����+����� ��������

		��������� ����: doc_id+sku_id
		������� ����: sku_id	

*/
 create table outcomes(
	doc_id int not null,
	sku_id int not null FOREIGN KEY REFERENCES sku(id),
	quantity decimal(15,3) not null,
	date_time datetime not null CHECK  (
		date_time<=GETDATE() -- �� ����� ���� ������� ������
	)
 
	constraint [PK_outcomes] primary key clustered
	(
		doc_id,
		sku_id
	)

);
go

 --���������� ����� �� ������ ��� ��
 use otus_project
 go

/*
	sales - ������� ������ (������� ��� ����� �������� �� ������)
		doc_id		- �������� ������
		sku_id		- �����
		price		- ���� �������
		quantity	- ����������
		customer_id	- ����������
		date_time	- ����+����� �������

		��������� ����: doc_id+sku_id
		������� ����: sku_id	
		������� ����: customer_id
		������:		  date_time

*/
 create table sales(
	doc_id int not null,
	sku_id int not null FOREIGN KEY REFERENCES sku(id),
	price decimal(15,2) not null,
	quantity decimal(15,3) not null,
	customer_id	int not null FOREIGN KEY REFERENCES customers(id),
	date_time datetime not null CHECK  (
		date_time<=GETDATE() -- �� ����� ���� ������� ������
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

 --���������� ����� �� ������ ��� ��
 use otus_project
 go

/*
	returns - ������� ������ �� ������� (������� ��� ����� �������� �� �����)
		doc_id		- �������� ��������
		doc_sales_id- �������� ������� (���� ����)
		sku_id		- �����
		price		- ���� ��������
		quantity	- ����������
		customer_id	- ����������
		date_time	- ����+����� ��������

		��������� ����: doc_id+sku_id
		������� ����: sku_id	
		������� ����: customer_id

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
�������������:
	sku_sale_price - ���� ������� �� ��������� �������
		sku_id		- �� ������
		price		- ����

	sku_wh - ������� ������� �� ������
		sku_id		- �� ������
		quantity	- �������

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


--��� ��������, ����� ���������� �� ������ �� otus_project
use master
go







