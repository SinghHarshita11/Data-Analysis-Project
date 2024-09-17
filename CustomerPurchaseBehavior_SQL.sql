Create database CustomerPurchaseBehaviour;
Use CustomerPurchaseBehaviour;
Select * from Customers;

Create table Customers(
CustomerID int,
CustomerName varchar(100),
Country varchar(100),
PRIMARY KEY (CustomerID, CustomerName)
);

Create table Products(
ProductID int,
ProductName varchar(100),
ProductCategory varchar(100)
);

CREATE INDEX idx_product_id ON Products(ProductID);

create table OrderDetails(
TransactionID INT PRIMARY KEY,
PurchaseDate date,
ProductID int,
CustomerID int,
CustomerName varchar(100),
PurchaseQuantity INT,
PurchasePrice DECIMAL(10, 2),
FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
foreign key(CustomerID,CustomerName) references Customers(CustomerID,CustomerName)
);


Select * from Customers;
Select * from products;
Select * from orderdetails;

-- Total Purchases per Customer

select CustomerID,CustomerName,summ from (Select c.CustomerID,c.CustomerName,sum(od.PurchaseQuantity) 
as summ,
rank() over (partition by sum(od.PurchaseQuantity) order by sum(od.PurchaseQuantity) desc,c.CustomerName asc
)as rnk from Customers c
join orderdetails od 
on c.CustomerName=od.CustomerName and
c.CustomerID=od.CustomerID
group by 1,2) as a
where rnk=1
order by 3 desc,2 asc;

-- --Total Sales per Product(from each different kind-top 5 products)
Select ProductID,ProductName,totalRevenue from(Select a.ProductID,a.ProductName,totalRevenue,rank()over
(partition by a.ProductName order by a.totalRevenue desc) as rnk
from (Select p.ProductID,p.ProductName,sum(od.PurchaseQuantity*od.PurchasePrice) as totalRevenue
from products p join orderdetails od
on p.ProductID=od.ProductID
group by 1,2) as a) as b
where rnk<=5;

-- Total Purchases per Country
Select sum(od.PurchaseQuantity) as TotalQuantity,c.Country from Customers c join orderdetails od on
c.CustomerName=od.CustomerName and
c.CustomerID=od.CustomerID
group by 2
order by 2, 1 desc;

-- Total sales per category
Select sum(od.PurchaseQuantity*od.PurchasePrice),p.ProductCategory from products p join orderdetails od on
p.ProductID=od.ProductID 
group by 2
order by 2, 1 desc;

-- Ntile to Segment Customers into Quartiles Based on Total Purchase
Select c.CustomerID,c.CustomerName,sum(od.PurchaseQuantity * od.PurchasePrice) AS TotalSpent,
ntile(4) over(order by sum(od.PurchaseQuantity * od.PurchasePrice) desc) as nt
from Customers c join orderdetails od on
c.CustomerName=od.CustomerName and
c.CustomerID=od.CustomerID
group by 1,2;

-- Yearwise Quarterwise Purchase Price
select year(od.PurchaseDate),quarter(od.PurchaseDate),sum(od.PurchasePrice)
from  orderdetails od
group by 1,2
order by 3 desc;

-- Merging all 3 tables
SELECT od.*, p.*, c.*
FROM Customers c
JOIN orderdetails od
    ON c.CustomerID = od.CustomerID
    AND c.CustomerName = od.CustomerName
JOIN products p
    ON p.ProductID = od.ProductID;

-- Total Purchase Price
Select sum(PurchasePrice) as Total_Purchase_Price from orderdetails;

-- Total Revenue
Select sum(PurchasePrice*PurchaseQuantity) as Total_Revenue from orderdetails;