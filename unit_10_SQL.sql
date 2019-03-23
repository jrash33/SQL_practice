-- SQL Unit 10 Assignment
-- Joey Ashcroft

USE sakila;

-- 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name,' ',last_name) as `Actor Name`
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name="JOE";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name
FROM actor
WHERE last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name like '%LI%'
ORDER BY last_name ASC;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD description BLOB(30) NOT NULL;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name as `Last Name`, count(*) as `Count`
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors.
SELECT last_name as `Last Name`, count(*) as `Count`
FROM actor
GROUP BY last_name
HAVING count(*)>1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name='GROUCHO' and last_name='WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' and last_name='WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- manually
create table address(
address_id int not null auto_increment,
address varchar(45) null,
address2 varchar(45) null,
district varchar(45) null,
city_id int not null,
postal_code int not null,
phone int not null,
location blob(30) null,
last_update varchar(30) not null,
primary key(address_id)
);

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address
	FROM address a
	INNER JOIN staff s on s.address_id=a.address_id
;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, sum(p.amount) as total_amount
	FROM payment p
	INNER JOIN staff s on s.staff_id=p.staff_id
    WHERE p.payment_date like '2005-08%'
    GROUP BY s.first_name
;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, count(*) as actor_count
	FROM film_actor fa
    INNER JOIN film f ON f.film_id=fa.film_id
    GROUP BY title
;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, count(*) as inventory_count
	FROM inventory i
    INNER JOIN film f ON f.film_id=i.film_id
    WHERE title='Hunchback Impossible'
    GROUP BY title
;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, sum(p.amount) as total_paid
	FROM payment p
    INNER JOIN customer c ON c.customer_id=p.customer_id
    GROUP BY c.first_name
    ORDER BY c.last_name ASC
;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of 
-- movies starting with the letters K and Q whose language is English.
SELECT f.title, l.`name`
	FROM language l
    INNER JOIN film f ON f.language_id=l.language_id
    WHERE f.title LIKE 'K%' OR f.title LIKE 'Q%' AND l.`name`='English';
;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT subquery.first_name, subquery.last_name, f.title
FROM (SELECT fa.film_id, a.first_name, a.last_name
		FROM film_actor fa
		JOIN actor a on a.actor_id=fa.actor_id
		) subquery
INNER JOIN film f on f.film_id=subquery.film_id
WHERE title='Alone Trip'
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the 
-- names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT co.first_name, co.last_name, co.email, c.country
FROM country c 
	JOIN city on city.country_id = c.country_id -- 600
    JOIN address a on a.city_id=city.city_id -- 603
    JOIN customer co on co.address_id=a.address_id -- 599
WHERE country='Canada'
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT f.title, c.`name`
FROM category c 
	JOIN film_category fc on fc.category_id = c.category_id
    JOIN film f on f.film_id=fc.film_id
WHERE c.`name`='Family'
;

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, count(*) as times_rented
FROM rental r
	JOIN inventory i on i.inventory_id = r.inventory_id
    JOIN film f on f.film_id=i.film_id
    GROUP BY f.title
    ORDER BY times_rented DESC
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id, sum(amount) as total_amount
FROM store st
	JOIN staff s on s.store_id = st.store_id
    JOIN payment p on p.staff_id=s.staff_id
    GROUP BY st.store_id
;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT st.store_id, c.city, co.country
FROM store st
	JOIN address a on a.address_id = st.address_id
    JOIN city c on c.city_id=a.city_id
    JOIN country co on co.country_id=c.country_id
;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.`name` as genre, sum(amount) as gross_revenue
FROM payment p
	JOIN rental r on r.rental_id = p.rental_id
    JOIN inventory i on i.inventory_id=r.inventory_id
    JOIN film_category fc on fc.film_id=i.film_id
    JOIN category c on c.category_id=fc.category_id
GROUP BY genre
ORDER BY gross_revenue DESC
LIMIT 5
;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
CREATE VIEW top_5_genres_revenue AS
SELECT c.`name` as genre, sum(amount) as gross_revenue
FROM payment p
	JOIN rental r on r.rental_id = p.rental_id
    JOIN inventory i on i.inventory_id=r.inventory_id
    JOIN film_category fc on fc.film_id=i.film_id
    JOIN category c on c.category_id=fc.category_id
GROUP BY genre
ORDER BY gross_revenue DESC
LIMIT 5
;

-- 8b. How would you display the view that you created in 8a?
SELECT * 
FROM top_5_genres_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_5_genres_revenue;