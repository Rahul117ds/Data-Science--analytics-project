create database project_1;
use project_1;
CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    last_name TEXT,
    first_name TEXT,
    title TEXT,
    reports_to DOUBLE DEFAULT 0,
    levels TEXT,
    birthdate TEXT,
    hiredate TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    postal_code TEXT,
    phone CHAR(17),
    fax TEXT,
    email TEXT
);
select * from employee;
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    company TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    postal_code TEXT,
    phone TEXT,
    fax TEXT,
    email TEXT,
    support_rep_id INT,
    FOREIGN KEY (support_rep_id)
        REFERENCES employee (employee_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
select * from customer;

CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT,
    invoice_date TEXT,
    billing_address TEXT,
    billing_city TEXT,
    billing_state TEXT,
    billing_country TEXT,
    billing_postal_code TEXT,
    total DOUBLE,
    FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
select * from invoice;

CREATE TABLE invoice_line (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT,
    track_id INT,
    unit_price DOUBLE,
    quantity INT,
    FOREIGN KEY (invoice_id)
        REFERENCES invoice (invoice_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
 select * from invoice_line;
 
CREATE TABLE artist (
    artist_id INT PRIMARY KEY,
    name TEXT
);
select * from artist;

CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    name TEXT
);
select * from playlist;


CREATE TABLE media_type (
    media_type_id INT PRIMARY KEY,
    name TEXT
);
select * from media_type;

CREATE TABLE genre (
    genre_id INT PRIMARY KEY,
    name TEXT
);
select * from genre;

CREATE TABLE album (
    album_id INT PRIMARY KEY,
    title TEXT,
    artist_id INT,
    FOREIGN KEY (artist_id)
        REFERENCES artist (artist_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
SELECT 
    *
FROM
    album;


CREATE TABLE track (
    track_id INT PRIMARY KEY,
    name TEXT,
    album_id INT,
    media_type_id INT,
    genre_id INT,
    composer TEXT,
    milliseconds BIGINT,
    bytes BIGINT,
    unit_price DOUBLE,
    FOREIGN KEY (album_id)
        REFERENCES album (album_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (media_type_id)
        REFERENCES media_type (media_type_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (genre_id)
        REFERENCES genre (genre_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
SELECT 
    *
FROM
    track;
 
CREATE TABLE playlist_track (
    playlist_id INT,
    track_id INT,
    FOREIGN KEY (playlist_id)
        REFERENCES playlist (playlist_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (track_id)
        REFERENCES track (track_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
select * from playlist_track;

#Major Task
#Question Set 1 - Easy
#Who is the senior most employee based on job title?
SELECT 
    first_name, last_name, hiredate, title
FROM
    employee
GROUP BY first_name , last_name , hiredate , title
ORDER BY hiredate ASC
LIMIT 1;

## Which countries have the most Invoices?
SELECT 
    billing_country, COUNT(billing_country) AS no_of_times
FROM
    invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC
LIMIT 1;

##What are top 3 values of total invoice?
SELECT DISTINCT
    (total)
FROM
    invoice
ORDER BY total DESC
LIMIT 3;

##Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
##Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
SELECT 
    billing_city, SUM(total) AS sum_of_totals
FROM
    invoice
GROUP BY billing_city
ORDER BY sum_of_totals DESC
LIMIT 1;


##Who is the best customer? The customer who has spent the most money will be declared the best customer. 
##Write a query that returns the person who has spent the most money

select * from invoice;
SELECT 
    c.*, SUM(total) AS Total
FROM
    customer AS c
        INNER JOIN
    invoice AS i ON c.customer_id = i.customer_id
GROUP BY i.customer_id
ORDER BY Total DESC
LIMIT 1;

##Question Set 2 – Moderate
##Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

SELECT 
    c.email, c.first_name, c.last_name, g.name
FROM
    customer AS c
        INNER JOIN
    invoice i ON c.customer_id = i.customer_id
        INNER JOIN
    invoice_line il ON il.invoice_line_id = i.invoice_id
        INNER JOIN
    track t ON il.track_id = t.track_id
        INNER JOIN
    genre g ON t.genre_id = g.genre_id
ORDER BY email ASC
LIMIT 27;
  
##Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands
SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs FROM track
inner JOIN album ON album.album_id = track.album_id
inner JOIN artist ON artist.artist_id = album.artist_id
inner JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

##Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track.
## Order by the song length with the longest songs listed first

SELECT name,milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) AS avg_track_length FROM track )
ORDER BY milliseconds DESC ;

##Question Set 3 – Advance
##Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    a.name,
    SUM(il.unit_price) AS total_spent
FROM
    customer AS c
        INNER JOIN
    invoice AS i USING (customer_id)
        INNER JOIN
    invoice_line AS il USING (invoice_id)
        INNER JOIN
    track AS t USING (track_id)
        INNER JOIN
    album AS al USING (album_id)
        INNER JOIN
    artist AS a USING (artist_id)
GROUP BY a.name , c.customer_id;

##We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
##Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres

With cte as (select i.billing_country,g.name,sum(i.total) as purchase_amount,
dense_rank() over(partition by i.billing_country order by sum(i.total) desc)  as a
 from invoice as i  inner join invoice_line as il using(invoice_id) inner join track as t using(track_id)
 inner join genre as g using(genre_id) group by i.billing_country,g.name)
 select billing_country,name,purchase_amount  from cte where a=1 ;
 
# Write a query that determines the customer that has spent the most on music for each country. 
# Write a query that returns the country along with the top customer and how much they spent.
# For countries where the top amount spent is shared, provide all customers who spent this amount

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;
 
 