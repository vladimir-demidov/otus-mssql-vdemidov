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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT 
	YEAR(i.InvoiceDate) as Year,
	MONTH(i.InvoiceDate) as Month,
	AVG(UnitPrice) as AVG_Price,
	SUM(UnitPrice) as Sum_Price
FROM Sales.Invoices i
JOIN Sales.OrderLines ol
	ON i.OrderID = ol.OrderID
JOIN Sales.Orders o
	ON i.OrderID = o.OrderID

GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
ORDER BY YEAR, MONTH


/*
2. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT 
	YEAR(i.InvoiceDate) as Year,
	MONTH(i.InvoiceDate) as Month,
	SUM(UnitPrice) as Sum_Price
FROM Sales.Invoices i
JOIN Sales.OrderLines ol
	ON i.OrderID = ol.OrderID
JOIN Sales.Orders o
	ON i.OrderID = o.OrderID

GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
HAVING SUM(UnitPrice) > 10000
ORDER BY YEAR, MONTH



/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT 
	YEAR(o.OrderDate) as Year,
	MONTH(o.OrderDate) as Month,
	ol.Description as Description,
	SUM(ol.UnitPrice) as SUM_Price,
	MIN(o.OrderDate) as FirstDate,
	COUNT(ol.Quantity) as Quantity
FROM Sales.Orders o
JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
GROUP BY 
	YEAR(o.OrderDate),
	MONTH(o.OrderDate),
	ol.Description
HAVING
	COUNT(ol.Quantity) < 50
ORDER BY Year, Month

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
