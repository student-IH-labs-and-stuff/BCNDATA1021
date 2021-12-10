--- LAB | subqueries
---
-- 1 How many copies of the film Hunchback Impossible exist in the
--   inventory system? Could also be solved with a join

-- step 1: first look into the film-table and find out
--         the film_id of the movie (subquery)
-- step 2: use that subquery (result is a film ID) to
--         query the inventory table
SELECT
    COUNT(film_id) AS counts
FROM
    inventory
WHERE
    film_id = (SELECT
            film_id
        FROM
            sakila.film
        WHERE
            title = 'Hunchback Impossible');

-- 2 List all films whose length is longer than the
--   average of all the films.
--   length is sotre in the film table, which contains
--   all unique films that we have. this is the table
--   we need. Step 1: find out whats the average length
--   of the movies
SELECT
    title, length
FROM
    sakila.film
WHERE
    length > (SELECT
            AVG(length)
        FROM
            sakila.film);

-- 3 Use subqueries to display all actors who appear in
--   the film Alone Trip.
-- Step 1: Find the film_id of the movie "Alone trip"
-- Step 2: Use that in the film_actor table to select
--         only actor_ids with that film_id
-- Step 3: use the actor table to filter only those actor
--         names whose actor_ids are in the result from previous
SELECT
    CONCAT(first_name, ' ', last_name) AS Actor
FROM
    sakila.actor
WHERE
    actor_id IN (SELECT
            actor_id
        FROM
            sakila.film_actor
        WHERE
            film_id = (SELECT
                    film_id
                FROM
                    sakila.film
                WHERE
                    title = 'ALONE TRIP'));

-- 4 Sales have been lagging among young families, and
--  you wish to target all family movies for a promotion.
--  Identify all movies categorized as family films.

-- show in ERD, bridge between tables: category-film_category-film

-- step 1: where is the information stored if some movie
--         is family? -> category table. find category_id
-- step 2: with category_id, look into bridge table film_category
--         select those film_id's that have that category
-- step 3: query the film table for those resulting film_id's
SELECT
    title AS Title
FROM
    sakila.film
WHERE
    film_id IN (SELECT
            film_id
        FROM
            sakila.film_category
        WHERE
            category_id IN (SELECT
                    category_id
                FROM
                    sakila.category
                WHERE
                    name = 'Family'));


-- 5 Get name and email from customers from Canada using subqueries.
--   Do the same with joins. Note that to create a join, you will have to
--   identify the correct tables with their primary keys and foreign keys,
--    that will help you get the relevant information.

-- with subqueries
-- Step 1: country table, get country_id of Canada
-- Step 2: use that country_id to find all the cities that are in that country_id
-- Step 3: use the address_id to find all the addresses that are in those cities
-- Step 4: use the custormer table to filter the obtained addresses id's
address_id IN (SELECT
        address_id
    FROM
        sakila.address
    WHERE
        city_id IN (SELECT
                city_id
            FROM
                sakila.city
            WHERE
                country_id IN (SELECT
                        country_id
                    FROM
                        sakila.country
                    WHERE
                        country = 'Canada')));

-- with join: very similar, but first join the tables starting FROM
--   the last (city, country_id), work your way outwardly
--   show with select * first
--   show on drawing board, drawing sets & joins on the id's
--   draw vertically
SELECT
    CONCAT(first_name, ' ', last_name) AS customer_name,
    email,
    country
FROM
  sakila.customer
    JOIN
      (sakila.address
          JOIN
              (sakila.city
                  JOIN sakila.country
                  USING (country_id))
              USING (city_id))
      USING (address_id)
WHERE
    country = 'Canada';

-- 6 Which are films starred by the most prolific actor? Most
-- prolific actor is defined as the actor that has acted in the
-- most number of films. First you will have to find the most prolific
-- actor and then use that actor_id to find the different films that
-- he/she starred.

-- step 1, find most prolific actor_id)
-- explain it with this first:
SELECT
	count(film_id) as count_film_id,
    actor_id
FROM
    sakila.actor
        JOIN
    sakila.film_actor USING (actor_id)
        JOIN
    sakila.film USING (film_id)
GROUP BY actor_id
ORDER BY count_film_id DESC
LIMIT 1;

-- then remove the count(...) from SELECT, put it in ORDER BY
-- so that query only results in actor_id

SELECT
    actor_id
FROM
    sakila.actor
        JOIN
    sakila.film_actor USING (actor_id)
        JOIN
    sakila.film USING (film_id)
GROUP BY actor_id
ORDER BY COUNT(film_id) DESC
LIMIT 1;

-- now get the films starred by that most prolific actor (for
-- this we need to join actor, film_actor and film and then query
-- the resulting table with the actor_id obtained in step 1)
SELECT
    CONCAT(first_name, ' ', last_name) AS actor_name,
    film.title,
    film.release_year
FROM
    sakila.actor
        INNER JOIN
    sakila.film_actor USING (actor_id)
        INNER JOIN
    film USING (film_id)
WHERE
    actor_id = (SELECT
            actor_id
        FROM
            sakila.actor
                INNER JOIN
            sakila.film_actor USING (actor_id)
                INNER JOIN
            sakila.film USING (film_id)
        GROUP BY actor_id
        ORDER BY COUNT(film_id) DESC
        LIMIT 1)
ORDER BY release_year DESC;

-- 7

-- very similar like previous!

-- step 1: find ID of most profitable customer
--     join the customer to the payment table
select customer_id
from sakila.customer
inner join payment using (customer_id)
group by customer_id
order by sum(amount) desc
limit 1;

-- step 2: films rented by most profitable customer.
-- we use the customer_id obtained in step 1 to query
-- the joined film, inventory, rental and payment table
-- note: we need to bring rental and inventory into the
-- game because these are the only links from film to
-- payment!
SELECT
    film_id,
    title,
    rental_date,
    amount
FROM
    sakila.film
        INNER JOIN
    inventory USING (film_id)
        INNER JOIN
    rental USING (inventory_id)
        INNER JOIN
    payment USING (rental_id)
WHERE
    rental.customer_id = (SELECT
            customer_id
        FROM
            customer
                INNER JOIN
            payment USING (customer_id)
        GROUP BY customer_id
        ORDER BY SUM(amount) DESC
        LIMIT 1)
ORDER BY rental_date DESC;

-- 8 Customers who spent more than the average payments.

-- step 1: find out the average payment. Let's create a
--         table for that showing the total payment for
--         every customer id:

SELECT
    customer_id,
     SUM(amount) total_payment
FROM
    payment
GROUP BY customer_id;

-- step 2: now I can just select from that the AVG:
-- note: derived tables must be aliased
SELECT
	AVG(total_payment)
FROM (
SELECT
    customer_id, SUM(amount) total_payment
FROM
    payment
GROUP BY customer_id
) t;


-- step 3: join customer and payment, group by customer id
--         and filter with the condition that the amount spent
--         must be greater than what is obtained in step 2
--         yes, that needs a HAVING

SELECT
    customer_id,
    SUM(amount) AS payment
FROM
    sakila.customer
        INNER JOIN
    payment USING (customer_id)
GROUP BY customer_id
HAVING SUM(amount) > (SELECT
        AVG(total_payment)
    FROM
        (SELECT
            customer_id, SUM(amount) total_payment
        FROM
            payment
        GROUP BY customer_id) t)
ORDER BY payment DESC;
