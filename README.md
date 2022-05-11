# Storing-and-Retrieving-Data-Project-21-22

Storing and Retrieving Data Project for the course (Data Science and Advanced Analytics Master)

## Description


A. Think about any commercial business process of a product or service that needs a relational database to work (e.g. online shops, booking systems, food delivery apps, restaurant management, etc).Describe it in 1 page.

B. Design and create an ERD in MySQL workbench. Do not forget to consider the three normal forms when you design your database model. The names of the entities and its attributes must be visible in the ERD. Your ERD should not have less than 10 tables.

C. Create two triggers: (1) one for updates (you can choose any updating process, for example, if a product is sold, the trigger may update the available stock of products). And (2) a trigger that inserts a row in a “log” table (your ERD should include a log table).

D. Create a physical relational database based on your ERD.

E. Insert some data into you newly created database (20 or 30 rows of transactions would be enough). Make sure that you have transactions that involve at least 2 consecutive years. If you want to add more than just a few rows, feel free to look for openly available dataset and/or generate random data.

F. Using MySQL, write the queries to retrieve the following information. When writing the queries examine the query execution plan. Make the necessary adjustments to speed up your queries.

1. List all the customer’s names, dates, and products or services used/booked/rented/bought by these customers in a range of two dates.

2. List the best three customers/products/services/places (you are free to define the criteria for what means “best”)

3. Get the average amount of sales/bookings/rents/deliveries for a period that involves 2 or more years, as in the following example. This query only returns one record:

| PeriodOfSales    | TotalSales (euros)      | YearlyAverage (of the given period)       | MonthlyAverage (of the given period)     |
|----------|----------------|--------------------| -------------|
|01/2010 – 10/2021  |  XXXXX € | XXXXX € | XXXX € |

4. Get the total sales/bookings/rents/deliveries by geographical location (city/country).

5. List all the locations where products/services were sold, and the product has customer’s ratings (Yes, your ERD must consider that customers can give ratings).

G. Your business process includes the generation of an INVOICE (the invoice in next page is just an example). Create two views to recreate the information on the INVOICE, one view for the head and totals, one view for the details.
