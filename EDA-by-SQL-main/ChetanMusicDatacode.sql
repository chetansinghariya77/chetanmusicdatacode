CREATE DATABASE MUSIC_STORE;
USE MUSIC_STORE;
SHOW DATABASES;
USE MUSIC_STORE;
SHOW TABLES ;
select * from music_store.artist;
select * from music_store.genre;
select * from music_store.media_type;
select * from music_store.playlist;
SELECT * FROM music_store.album;
INSERT INTO  music_store.employee 
values (9,'Madan', 'Mohan','Senior General Manager', NULL,'L7','26-1-1961 00:00:00','14-01-2016 00:00:00','1008 Vrinda Ave MT','Edmonton','AB','Canada','T5H 2N1','+1(780) 428-9482','+1(780) 428-3457','madan.mohan@chinookcorp.com');

-- 1. How many employee are there?
SELECT COUNT(*) AS total_employees FROM music_store.employee;
-- There are 9 employees 

-- 2. Who is the senior most employee based on job title?
SELECT * 
FROM music_store.employee;

SELECT * 
FROM music_store.employee
ORDER BY levels DESC 
LIMIT 1;
-- Madan Mohan is the senior most employee, we can also see that he do not report to anyone else.
-- 3. What is the total sales amount 
SELECT SUM(unit_price*quantity) AS Number_of_Invoices 
FROM music_store.invoice_line;
-- Total sum of invoices is 4709.429999999431

-- 4. Which countries have the most Invoices?
SELECT billing_country, count(*) AS Number_of_Invoices 
FROM music_store.invoice
GROUP BY billing_country
ORDER BY 2 DESC;
-- The countries with the most invoices are USA, Canada, Brazil 

-- 5. What are top 3 values of total invoice?
SELECT distinct total 
FROM music_store.invoice
ORDER BY total DESC 
LIMIT 3;
-- The top 3 values of total invoice are 23.8, 19.8, 18.81, 19.8 was 4 times so I used DISTINCT Clause
-- Where are the most number of the cutomers
SELECT country, count(*) 
FROM music_store.customer
GROUP BY  1
ORDER BY 2 DESC;
-- Most number of customers are from USA
/*6. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals*/
SELECT billing_city, SUM(total) AS invoice_totals 
FROM music_store.invoice
GROUP BY billing_city
ORDER BY  invoice_totals DESC;
-- Prague is the city that has the highest sum of invoice totals 273.24 

/*7. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money*/
SELECT * 
FROM music_store.customer;
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total
FROM music_store.customer AS c
JOIN music_store.invoice AS i
ON C.customer_id=I.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total DESC
LIMIT 1;
-- The best customer is FrantiÅ¡ek WichterlovÃ¡
/* 8. We want to find out the most popular music Genre. We determine the most popular genre as the genre 
with the highest numver of track*/
SELECT genre_id, count(*) as count_genre FROM music_store.track 
group by genre_id order by count_genre desc;
-- It is Rock
/*9. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A
*/
SELECT DISTINCT c.email, c.first_name, c.last_name
FROM music_store.customer AS c
JOIN music_store.invoice AS i ON c.customer_id = i.customer_id
JOIN music_store.invoice_line AS il ON i.invoice_id = il.invoice_id
WHERE track_id IN (
	SELECT track_id FROM music_store.track AS t
    JOIN music_store.genre AS g ON t.genre_id = g.genre_id
    WHERE g.name LIKE 'Rock')
ORDER BY c.email;
;
/*
10. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands
*/
SELECT ar.artist_id , ar.name, COUNT(ar.artist_id) AS number_of_songs
FROM music_store.track AS t
JOIN music_store.album AS a ON a.album_id = t.album_id
JOIN music_store.artist AS ar ON ar.artist_id = a.artist_id
JOIN music_store.genre AS g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY ar.artist_id
ORDER BY number_of_songs DESC 
LIMIT 10;

/*
11. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first*/
SELECT t1.name, t1.milliseconds 
FROM music_store.track AS t1
WHERE t1.milliseconds > (SELECT AVG(t2.milliseconds) FROM music_store.track AS t2 )
ORDER BY t1.milliseconds DESC;

/*12. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/
WITH best_selling_artist AS (
SELECT ar.artist_id AS artist_id, ar.name AS artist_name,
SUM(il.unit_price*il.quantity) AS total_sales
FROM music_store.invoice_line AS il
JOIN music_store.track AS t ON t.track_id = il.track_id
JOIN music_store.album AS a ON a.album_id = t.album_id
JOIN music_store.artist AS ar ON ar.artist_id = a.artist_id
GROUP BY 1
ORDER BY 3 DESC 
LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent 
FROM music_store.invoice AS i 
JOIN music_store.customer AS c ON c.customer_id = i.customer_id
JOIN music_store.invoice_line AS il ON il.invoice_id = i.invoice_id
JOIN music_store.track AS t ON  t.track_id = il.track_id
JOIN music_store.album AS a ON  a.album_id = t.album_id
JOIN best_selling_artist AS BSA ON bsa.artist_id = a.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC ;
-- The best selling artist is AC/DC and the query returns the amount spent by customers for AC/DC
/*
13. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres
*/
WITH popular_genre AS
(
SELECT COUNT(il.quantity) AS purchases, c.country, g.name, g.genre_id,
ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo
FROM invoice_line AS il
JOIN  invoice AS i ON i.invoice_id = il.invoice_id
JOIN  customer AS c ON c.customer_id = i.customer_id
JOIN track AS t ON t.track_id = il.track_id
JOIN genre AS g ON g.genre_id = t.genre_id
GROUP BY 2,3,4
ORDER BY 2 ASC, 1 DESC
)
SELECT * 
FROM popular_genre
WHERE RowNo <=1
-- popular_genre assigns row number according to decreasing order of purchases
-- we can filter out country wise best purchases










