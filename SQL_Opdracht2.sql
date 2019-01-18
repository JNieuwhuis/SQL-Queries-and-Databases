USE Northwind;

/*2.1*/
/*Selecteer alle klanten (CUSTOMERID, COMPANYNAME) die in London wonen en minder dan 5 orders hebben gedaan. 
Orden het resultaat op aantal geplaatste orders.*/

SELECT DISTINCT C.CustomerID, C.CompanyName, C.City, count(OD.OrderID) AS [Order Amount]
FROM Orders O 
INNER JOIN(
	SELECT CustomerID, City, CompanyName
	FROM Customers
	WHERE City LIKE '%Lond_n%'
	) AS C ON O.CustomerID = C.CustomerID
INNER JOIN(
	SELECT OrderID
	FROM [Order Details] OD
	GROUP BY OrderID
	HAVING COUNT(OD.OrderID) <5
	) AS OD ON O.OrderID = OD.OrderID
GROUP BY C.CustomerID, C.CompanyName, C.City
HAVING count(OD.OrderID) < 5
ORDER BY [Order Amount];

/*2.2*/
/*Selecteer alle orders voor “Pavlova” met een salesresultaat van minstens 800.*/

SELECT P.ProductName, ((OD.UnitPrice -OD.Discount) * OD.Quantity) AS Salesresult
FROM [Order Details] OD
INNER JOIN(
	SELECT ProductName, ProductID
	FROM Products P
	WHERE P.ProductName = 'Pavlova'
	) AS P ON OD.PRODUCTID = P.PRODUCTID
WHERE ((OD.UnitPrice - OD.Discount) * OD.Quantity) >= 800
ORDER BY Salesresult DESC;


/*2.3*/
/*Selecteer alle regio’s (REGIONDESCRIPTION) waarin het product “Chocolade” is verkocht.*/

SELECT R.RegionDescription AS RegionSoldTo				
FROM Region R
where R.RegionID in 
	(Select R.RegionId from Region 
	join Territories T on T.regionId = R.regionId
	join EmployeeTerritories ET on ET.territoryId = T.territoryId
	Join Orders O on O.employeeId = ET.employeeId
	join [Order Details] OD on OD.orderId = O.orderId
	JOIN Products P ON OD.PRODUCTID = P.PRODUCTID and P.productName = 'Chocolade')


/*2.4*/
/*Selecteer alle orders (ORDERID, CUSTOMER.COMPANYNAME) voor het product “Tofu” 
waar de ‘freight’ kosten tussen 25 en 50 waren.*/

SELECT O.OrderID, C.CompanyName
FROM Orders O 
INNER JOIN Customers C ON O.CustomerID = C.CustomerID
WHERE O.OrderID IN(
	SELECT O.OrderID FROM Orders O
	JOIN [Order Details] OD ON OD.OrderID = O.ORDERID
	JOIN Products P ON OD.ProductID = P.PRODUCTID 
	AND P.ProductName = 'Tofu')
AND O.Freight BETWEEN 25 AND 50;

/*2.5*/
/*Selecteer de plaatsnamen waarin zowel klanten als werknemers wonen. 
Gebruik een subquery voor deze opdracht.*/

SELECT DISTINCT E.City
FROM Employees E
WHERE E.City IN(
	SELECT C.City
	FROM Customers C);

/*2.6*/
/*Welke producten (PRODUCTID, PRODUCTNAME) zijn het meest verkocht (aantal) aan Duitse klanten, 
en welke werknemers (EMPLOYEEID, LASTNAME, FIRSTNAME, TITLE) hebben deze producten verkocht? 
Orden het resultaat op aantal. Toon alleen de top 5 producten.*/	

SELECT P.ProductID, P.ProductName, SUM(OD.Quantity) AS TotalQuantity,
				E.EmployeeID, E.FirstName, E.LastName, E.Title
FROM Products P
INNER JOIN [Order Details] OD ON P.ProductID = OD.ProductID
INNER JOIN Orders O ON OD.OrderID = O.OrderID
INNER JOIN  Customers C ON C.CustomerID = O.CustomerID
INNER JOIN Employees E ON E.EmployeeID = O.EmployeeID
WHERE C.Country = 'Germany'
AND P.ProductID IN (
	SELECT TOP 5 OD.ProductID
	FROM [Order Details] OD
	INNER JOIN Orders O ON OD.OrderID = O.OrderID
	INNER JOIN Customers C ON C.CustomerID = O.CustomerID
	WHERE C.Country = 'Germany'
	GROUP BY OD.ProductID
	ORDER BY SUM(OD.Quantity) DESC
	)
GROUP BY P.ProductID, P.ProductName, E.EmployeeID, E.FirstName, E.LastName, E.Title
ORDER BY TotalQuantity DESC;

/*2.7*/
/*Welke producten (PRODUCTID, PRODUCTNAME) zorgden voor de hoogste salesresultaten (SALESRESULT) aan Duitse klanten, 
en welke werknemers (EMPLOYEEID, LASTNAME, FIRSTNAME, TITLE) hebben deze producten verkocht. 
Orden op sales resultaat. Toon alleen de top 5 producten.*/

SELECT P.ProductID, P.ProductName, SUM(OD.UnitPrice * OD.Quantity) AS Salesresult, E.EmployeeID, E.FirstName, E.LastName, E.Title
FROM Products P
INNER JOIN [Order Details] OD ON P.ProductID = OD.ProductID
INNER JOIN Orders O ON OD.OrderID = O.OrderID
INNER JOIN  Customers C ON C.CustomerID = O.CustomerID
INNER JOIN Employees E ON E.EmployeeID = O.EmployeeID
WHERE C.Country = 'Germany'
AND P.ProductID IN (
	SELECT TOP 5 OD.ProductID
	FROM [Order Details] OD
	INNER JOIN Orders O ON OD.OrderID = O.OrderID
	INNER JOIN Customers C ON C.CustomerID = O.CustomerID
	WHERE C.Country = 'Germany'
	GROUP BY OD.ProductID
	ORDER BY SUM(OD.UnitPrice * OD.Quantity) DESC
	)
GROUP BY P.ProductID, P.ProductName, E.EmployeeID, E.FirstName, E.LastName, E.Title
ORDER BY Salesresult DESC;

/*2.8*/
/* Join de tabellen Products en Suppliers. 
Join de tabellen met: Inner Join, Left Join, Right Join, Full Join
Verklaar de resultaten van deze joins en teken een plaatje van elke join. */

SELECT *
FROM Products P 
INNER JOIN Suppliers S ON S.SupplierID = P.SupplierID;

SELECT *
FROM Products P 
LEFT JOIN Suppliers S ON S.SupplierID = P.SupplierID;

SELECT *
FROM Products P 
RIGHT JOIN Suppliers S ON S.SupplierID = P.SupplierID;

SELECT *
FROM Products P 
FULL JOIN Suppliers S ON S.SupplierID = P.SupplierID;

--Deze tabellen verschillen hier niet, omdat ze direct aan elkaar gelinkt zijn. 
/*
W3Schools:
- The INNER JOIN keyword selects records that have matching values in both tables.
- The LEFT JOIN keyword returns all records from the left table (table1), and the 	matched records from the right table (table2). 
- The RIGHT JOIN keyword returns all records from the right table (table2), and the matched records from the left table (table1).
- The FULL OUTER JOIN keyword return all records when there is a match in either left (table1) or right (table2) table records.
*/

/*2.9*/
/* Geef het gemiddelde salesresultaat van elke werknemer (EMPLOYEEID, LASTNAME, FIRSTNAME, TITLE, AVARAGE_SALESRESULT). Orden op salesresultaat.*/

SELECT E.EmployeeID, E.LastName, E.FirstName, E.Title, AVG(OD.UnitPrice * OD.Quantity) AS AVARAGE_SALESRESULT
FROM Employees E 
LEFT JOIN Orders O ON O.EmployeeID = E.EMPLOYEEID
INNER JOIN [Order Details] OD ON OD.OrderID = O.ORDERID
GROUP BY E.EmployeeID, E.LastName, E.FirstName, E.Title
ORDER BY AVARAGE_SALESRESULT DESC;