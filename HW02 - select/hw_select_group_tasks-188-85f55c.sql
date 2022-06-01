/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT StockItemID, StockItemName 
FROM Warehouse.StockItems 
WHERE StockItemName like '%urgent%' or
StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT s.SupplierID, s.SupplierName
FROM Purchasing.Suppliers s 
LEFT JOIN Purchasing.PurchaseOrders o
ON s.SupplierID = o.SupplierID
WHERE o.SupplierID is NULL

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT 
ol.OrderID,
o.OrderDate as Date,
DATENAME(M, o.OrderDate) as Month,
DatePart(QUARTER, o.OrderDate) as Quarter,
CASE WHEN Month(o.OrderDate) <=4 THEN 1 --  1/3
		WHEN Month(o.OrderDate) >=5 and Month(o.OrderDate) <=8 THEN 2 --2/3
		ELSE 3 -- 3/3
END as 'Third Part'

FROM Sales.OrderLines ol
JOIN Sales.Orders o
ON ol.OrderID = o.OrderID
WHERE (ol.UnitPrice > 100 OR ol.Quantity > 20) AND ol.PickingCompletedWhen IS NOT NULL
ORDER BY Quarter, [Third Part], Date;

SELECT 
ol.OrderID,
o.OrderDate as Date,
DATENAME(M, o.OrderDate) as Month,
DatePart(QUARTER, o.OrderDate) as Quarter,
CASE WHEN Month(o.OrderDate) <=4 THEN 1 --  1/3
		WHEN Month(o.OrderDate) >=5 and Month(o.OrderDate) <=8 THEN 2 --2/3
		ELSE 3 -- 3/3
END as 'Third Part'

FROM Sales.OrderLines ol
JOIN Sales.Orders o
ON ol.OrderID = o.OrderID
WHERE (ol.UnitPrice > 100 OR ol.Quantity > 20) AND ol.PickingCompletedWhen IS NOT NULL
ORDER BY Quarter, [Third Part], Date
OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT 
	m.DeliveryMethodName,
	o.ExpectedDeliveryDate,
	s.SupplierName, 
	p.FullName as ContactPersonName
FROM Purchasing.PurchaseOrders o
JOIN Application.DeliveryMethods m
	ON o.DeliveryMethodID = m.DeliveryMethodID
JOIN Purchasing.Suppliers s
	ON o.SupplierID = s.SupplierID
JOIN Application.People p
	ON o.ContactPersonID = p.PersonID
WHERE o.ExpectedDeliveryDate BETWEEN '2013-01-01' and '2013-02-01'
	AND (m.DeliveryMethodName = 'Air Freight' or m.DeliveryMethodName = 'Refrigerated Air Freight')
	AND o.IsOrderFinalized = 1


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP 10
	o.OrderID,
	o.OrderDate,
	p1.FullName as CustomerName,
	p2.FullName as SalesPersonName
FROM Sales.Orders o
JOIN Application.People p1
	ON o.CustomerID = p1.PersonID
JOIN Application.People p2
	ON o.SalesPersonPersonID = p2.PersonID
ORDER BY o.OrderDate DESC

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT DISTINCT
	c.CustomerID,
	c.CustomerName,
	c.PhoneNumber
FROM Sales.OrderLines ol
JOIN Warehouse.StockItems si
	ON ol.StockItemID = si.StockItemID
JOIN Sales.Orders o
	ON ol.OrderID = o.OrderID
JOIN Sales.Customers c
	ON o.CustomerID = c.CustomerID
WHERE si.StockItemName = 'Chocolate frogs 250g'
