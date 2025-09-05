--Exceldən import olunan dataları targretə insert etmək üçün table yaratmaq
create table Customers (
	CustomerID nvarchar(50) Primary Key,
	CustomerName nvarchar(100) NOT NULL,
	City nvarchar(50),
	Region nvarchar(50)
);

create table Products (
	ProductID int PRIMARY KEY,
    ProductName nvarchar(100) NOT NULL,
    UnitPrice decimal(10,2)
);

create table Orders(
	OrderID int PRIMARY KEY,
	CustomerID nvarchar(50) REFERENCES Customers(CustomerID),
	ProductID int REFERENCES Products(ProductID),
	OrderDate date,
	Quantity int,
	UnitPrice decimal(10,2),  
	TotalPrice as (Quantity * UnitPrice)
);
--Daha sonra yanlışlıqla Customers cədvəlində PrimaryKey olan CustomerID data type yalnış qeyd olunmuşdur(həmçinin Foreign Keyidə var).
--Bunu adi qaydada dəyişmək olmur və DROP CONSTRAINT ilə silib daha sonra tipini dəyişib yenidən primary və foreign key təyin edirsən

ALTER TABLE Customers DROP CONSTRAINT PK__Customer__A4AE64B8DA87B981;

sp_help 'Customers';

ALTER TABLE Customers
ALTER COLUMN CustomerID nvarchar(50) NOT NULL;

ALTER TABLE Customers
add CONSTRAINT PK_Customers PRIMARY KEY (CustomerID);

ALTER TABLE Orders
ALTER COLUMN CustomerID nvarchar(50) NOT NULL;

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Customers
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);

--daha sonra Exceldən import olunan dataları target cədvələ ötürmək
insert into Customers(CustomerID, CustomerName, City, Region)
select CustomerID, CustomerName, City, Region
from stg_Customers$;

insert into Products(ProductID, ProductName, UnitPrice)
select ProductID, ProductName, UnitPrice
from stg_Products$;

insert into Orders(OrderID, CustomerID , ProductID, OrderDate, Quantity, UnitPrice)
select OrderID, CustomerID, ProductID, OrderDate, Quantity, UnitPrice
from stg_Orders$;

--3.SQL hesabatları hazırla: 
--TOP 5 müştəri (sifariş sayına görə) 
select top 5
	c.CustomerID,
	c.CustomerName,
	count(o.OrderID) as TotalOrders
from Orders o
join Customers c on o.CustomerID = c.CustomerID
group by c.CustomerID, c.CustomerName
order by TotalOrders desc
--TOP 5 məhsul (satış məbləğinə görə) 
select top 5
	p.ProductID,
	p.ProductName,
	sum(o.UnitPrice * o.Quantity) as TotalPrice
from Orders o
join Products p on o.ProductID = p.ProductID
group by p.ProductID, p.ProductName
order by TotalPrice desc;
--Region üzrə aylıq satış trendi 
select
	c.Region,
	format(o.OrderDate, 'yyyy-MM') as OrderMonth,
	sum(o.UnitPrice * o.Quantity) as TotalPrice
from Orders o
join Customers c on o.CustomerID = c.CustomerID
group by c.Region, FORMAT(o.OrderDate, 'yyyy-MM')
order by c.Region, OrderMonth;
--Hər müştərinin son 3 sifarişi 
with LastOrders as (
	select
		o.CustomerID,
		o.OrderID,
		o.OrderDate,
		ROW_NUMBER() over(partition by o.CustomerID order by o.OrderDate desc) as rnk
	from Orders o
)
select *
from LastOrders
where rnk <= 3
order by CustomerID, OrderDate desc;
--Running total və cumulative satış
select
	OrderDate,
	sum(TotalPrice) over(order by OrderDate rows between unbounded preceding and current row) as RunningTotal
from Orders;

select
	year(OrderDate) as OrderYear,
	month(OrderDate) as OrderMonth,
	sum(TotalPrice) as MonthlySales,
	sum(sum(TotalPrice)) over(order by year(OrderDate), month(OrderDate)) as CumulativeSales
from Orders
group by year(OrderDate), MONTH(OrderDate)
order by OrderYear, OrderMonth;

--4.Stored Procedure → Müştərinin ID-sini verəndə bütün sifarişlərini qaytarsın.
create procedure GetCustomersID
	@CustomerID nvarchar(50)
as
begin
select
	c.CustomerID,
	c.CustomerName,
	c.Region,
	o.OrderID,
	o.OrderDate
from Orders o 
join Customers c on o.CustomerID = c.CustomerID
where c.CustomerID = @CustomerID
end;

exec GetCustomersID @CustomerID = 'QUMA'

--5.Trigger → Yeni sifariş əlavə olunanda log cədvəlinə yazsın.
create table OrderLog (
	LogID int identity(1, 1) primary key,
	OrderID int, 
	CustomerID nvarchar(50),
	LogDate datetime default getdate()
);

create trigger trg_AfterInsertTrigger
on Orders
after insert
as
begin
	insert into OrderLog(OrderID, CustomerID)
	select OrderID, CustomerID
	from inserted;
end;

INSERT INTO Orders (OrderID, CustomerID, ProductID, OrderDate, Quantity, UnitPrice)
VALUES (20001, 'ELMA', 43, '2025-08-30', 5, 20);

select * from OrderLog;

--6.Index → Satışlar üzrə sorğunu sürətləndirsin.
create nonclustered index ix_Orders_Search
on Orders(OrderID, OrderDate)