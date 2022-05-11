
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Beatriz Neto - m20210608
-- Beatriz Selidónio - m20210545
-- Catarina Garcêz - m20210547
-- Sara Silva - m20210619
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

USE tb;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Query 1 - List all the customer’s names, dates, and products or services used/booked/rented/bought by these customers in a range of two dates.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
EXPLAIN 
SELECT c.name AS CustomerName, 
	   DATE_FORMAT(p.payment_datetime, '%Y/%m/%d') AS PaymentDate, 
       CONCAT(e.event_description, ' - ', z.zone_description, ' - ', s.seat_code) AS TicketBought
FROM customer AS c
JOIN order_ AS o
ON c.customer_id = o.customer_id
JOIN payment AS p
ON P.order_id = o.order_id
JOIN order_items AS oi
ON o.order_id = oi.order_id
JOIN ticket AS t
ON oi.bar_code = t.bar_code
JOIN seat AS s
ON t.seat_id = s.seat_id
JOIN zone AS z
ON s.zone_id = z.zone_id
JOIN session as ss
ON z.session_id = ss.session_id
JOIN event AS e
ON ss.event_id = e.event_id
WHERE order_datetime BETWEEN '2019-01-01' AND '2021-01-01';


/* Only Simple select_type query which means that contains no subqueries or unions, refering to all tables and no partitions.
The first table on the execution plan, order, was accessed using the All type meaning that MySQL will scan the entire table to satisfy the query (93 rows were examined). All the other tables are acessed using ref and eq-ref.
Looking at the extra column we can see that where clause was applied once and the filtered field has a value of 11.1% meaning that the query examine a lot of rows that aren't returned.
The eq_ref is used to access 5 tables which is good in terms of performance once the database will access one row from the table for each combination of rows from the previous tables.
Besides the table order, all the other tables have an acceptable number of possible Keys and the Key of almost every join is the primary key of the table.
Fast execution, 65 lines were returned to the client, 603 lines were examined. 
Besides the first access, the filtered field has a value of 100% meaning that the query doesn't examine a lot of rows that aren't returned.
The query has quite a good performance. To improve the performance of the query we would probably need to create an index to make easier the acess to the where clause.*/

-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Query 2 - List the best three customers/products/services/places (you are free to define the criteria for what means “best”)
-- ---------------------------------------------------------------------------------------------------------------------------------------------------

-- NOTE : For the company the best clients are not the ones that spend more money but the ones that buy more tickets

EXPLAIN
SELECT c.name AS BestTreeCustomers, COUNT(o_i.order_id) AS NumberOfOrderItems
FROM order_ AS o
JOIN customer AS c
ON o.customer_id = c.customer_id
JOIN order_items AS o_i
ON o.order_id = o_i.order_id
GROUP BY o.customer_id
ORDER BY NumberOfOrderItems DESC
LIMIT 3;

/* Only Simple select_type query refering to the tables customer (c), order_ (o) and order_items (o_i).
The first table on the execution plan, customer, was accessed using the All type meaning that MySQL will scan the entire table to satisfy the query (88 rows were examined).
Looking at th extra column its possible to see that in the first access MySQL is creating a temporary table once needs to hold the result. This probably happens because the query contains GROUP BY and ORDER BY clauses that list different columns.
Also, in the extra column the using filesort is mentioned meaning that MySQL is forced to perform another pass on the results of the query to sort them. This can result in a performance penalty.
All the other tables are accessed using ref. Ref is used if the join uses the key that is not a PRIMARY KEY or UNIQUE index (in other words, if the join cannot select a single row based on the key value). 
Since the key that is used matches a few rows, this is a good join type.
Besides the fisrt access, all the other tables have an acceptable number of possible Keys and the choosen keys have high cardinality.
Fast execution, 3 lines were returned to the client and 284 lines were examined. 
The query has quite good performance and using the LIMIT clause makes the query faster. 
To improve the performance of the query we would need to find a way of changing the type All and solving the penalty. Creating a meaningful index could be useful.*/

-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Query 3 - Get the average amount of sales/bookings/rents/deliveries for a period that involves 2 or more years.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------

EXPLAIN 
SELECT CONCAT((MIN(CAST(o.`order_datetime` AS DATE))), ' - ', (MAX(CAST(o.`order_datetime` AS DATE)))) AS PeriodOfSales, 
	   CONCAT(SUM(o.total), " ", "€") AS TotalSales_€,
       #Assuming year = 365 days and month = 31 days
       CONCAT(ROUND(SUM(o.total)/(DATEDIFF(MAX(o.`order_datetime`), MIN(o.`order_datetime`))/365), 2), " ", "€") AS YearlyAverage_€,
       CONCAT(ROUND(SUM(o.total)/(DATEDIFF(MAX(o.`order_datetime`), MIN(o.`order_datetime`))/31), 2), " ", "€") AS MonthlyAverage_€
FROM order_ AS o;

/* Simple select_type query which means that contains no subqueries or unions, refering to the table order (as o) and no partitions.
Case of type ALL, which means that all the rows of the table order were examined for query execution (93 rows).
A single line was returned to the client. The filtered field has a value of 100% meaning that the query doesn't examine a lot of rows that aren't returned.
The query doesn´t do a great performance since all rows from the column have to be examine. To improve the performance of the query we would need to find a way of changing the type All (don't examine all rows). 
Creating a meaningful index could be useful .*/

- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Query 4 - Get the total sales/bookings/rents/deliveries by geographical location (city/country).
-- ---------------------------------------------------------------------------------------------------------------------------------------------------

EXPLAIN 
SELECT l.city AS City, SUM(o.total) AS TotalSales_€
FROM order_ AS o 
JOIN customer AS c ON o.customer_id = c.customer_id
JOIN location AS l ON c.location_id = l.location_id
GROUP BY City
ORDER BY TotalSales_€ DESC;

/* Simplye select_type query refering to all tables and no partitions.
One Case of type Index, in other words, the entire index is scanned to find a match for the query (88 rows were examined - Full table scan).
The other types of access were ref and eq_ref which is quite good.
Once again, looking at th extra column its possible to see that in the first access MySQL is creating a temporary table because the query contains GROUP BY and ORDER BY clauses that list different columns.
Also, in the extra column the using filesort is mentioned meaning that MySQL is forced to perform another pass on the results of the query to sort them. This can result in a performance penalty.
All tables have an acceptable number of possible Keys and the choosen keys have high cardinality.
The filtered field has a value of 100% meaning that the query doesn't examine a lot of rows that aren't returned.
Fast execution, 42 lines were returned to the client and 316 lines were examined. 
The performance of the query could be better. To improve the performance of the query we would need to find a way of changing the type index and solving the penalty. Creating a meaningful index could be useful.*/

-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Query 5 - List all the locations where products/services were sold, and the product has customer’s ratings.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------

-- NOTE: This query is listing all the cities where the all events with customer's rating happened, the name of the events and the average rating per event

EXPLAIN
SELECT l.city AS 'Location of purchased Events', 
	   e.event_description AS 'Purchased Events with Customer`s Ratings', 
	   ROUND(AVG(r.rating_value), 1) AS AverageRating
FROM rating AS r, location AS l, event_space AS es, event AS e, session AS ss, zone AS z, seat AS s, ticket AS t, order_items AS o_i, order_ AS o
WHERE l.location_id = es.location_id
AND es.event_space_id = e.event_space_id
AND e.event_id = ss.event_id
AND ss.session_id IN (SELECT session_id FROM rating)
AND ss.session_id = r.session_id
AND ss.session_id = z.session_id
AND z.zone_id = s.zone_id
AND s.seat_id = t.seat_id
AND t.bar_code = o_i.bar_code 
AND o_i.order_id = o.order_id
AND o.order_id IN (SELECT order_id FROM payment)
GROUP BY e.event_description
ORDER BY AverageRating DESC;


/* Simply select_type query for all tables, no partitions.
The query connects 11 tables using the where clause instead of join once we need to assure that the session had rating associated and the order was really paid. 
The types observed through the explain command are indexes (once with a High cost), ref(six times - Low-medium cost), eq_ref(four times - Low cost) and all (once with High cost).

- When accessing the table rating (one Case of type Index) the entire index was scanned to find a match for the query (30 rows were examined - Full table scan).
Once again, looking at the extra column its possible to see that in the first access MySQL is creating a temporary table because the query contains GROUP BY and ORDER BY clauses that list different columns.
Also, in the extra column the using filesort is mentioned meaning that MySQL is forced to perform another pass on the results of the query to sort them. This can result in a performance penalty.
The filtered field on the rating row has a value of 63.3% meaning that the query examine a considerable number of rows that aren't returned.

- When accessing the table event (one Case of type All) all the rows of the table were examined for query execution (31 rows) and the where cause was applied.
The filtered field on the event row has a value of 3.23% meaning that the query examines a lot of rows that aren't returned.

Besides from the event table, all the other tables have an acceptable number of possible Keys and the choosen keys have high cardinality.
Almost every key is the primary one or the foreign Key since we are "joining" tables. As a result of that the number of rows examined per scan is 1.
Besides the first access and the access to the event table, the filtered field has always a value of 100% which means that the query doesn't examine a lot of rows that aren't returned.
Fast execution, 18 lines were returned to the client and 643 lines were examined. 
The performance of the query could be better. To improve the performance of the query we would need to find a way of changing the types index and All and solving the penalty. Creating an index to make easier the acess to the where clause could be useful.*/

