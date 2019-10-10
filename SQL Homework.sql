USE sakila;

SELECT * FROM actor;

#----1a.Display the first and last name of all actors from the table "actor"
SELECT first_name, last_name 
FROM actor;

#----1b.Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
#----Concatenate first names and first names in upper cases and leave space in between
SELECT CONCAT(UPPER(first_name), ' ',  UPPER( last_name)) AS Actor_Name
FROM actor;

SELECT * FROM actor;

#----2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name="Joe";

#-----2b.Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, CONCAT(UPPER(first_name), ' ',  UPPER( last_name)) AS Actor_Name
FROM actor
WHERE actor.last_name LIKE "%GEN%";

#----2c.Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor.last_name LIKE "%LI%"
ORDER BY last_name, first_name;

#-----2d.Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT * FROM country;

SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh","China");


#----3a.You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD description BLOB;

#----3b.Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

#----4a.List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*) AS counts
FROM actor
GROUP BY last_name;

#----4b.List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(*) AS counts
FROM actor
GROUP BY last_name
HAVING counts>=2;

#---4c.The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
# Be careful that there might be mulitple people with last name of "WILLIAMS"
UPDATE actor
SET first_name="HARPO"
WHERE first_name="GROUCHO" and last_name="WILLIAMS";

#---4d. erhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name =
CASE 
WHEN first_name="HARPO"
THEN "GROUCHO"
ELSE "MUCHO GROUCHO"
END
WHERE actor_id=172;

#---5a.You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

#---6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT* FROM address;

SELECT s.address_id, s.first_name,s.last_name,a.address
FROM staff AS s
JOIN address AS a
USING (address_id);

#---6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
#SELECT*FROM payment;

SELECT s.staff_id,s.first_name, s.last_name,sum(p.amount)
FROM staff AS s
JOIN payment AS p 
USING (staff_id)
WHERE payment_date LIKE "2005-08-%"
GROUP BY staff_id;

#---6c.List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
#SELECT*FROM film_actor;
#SELECT*FROM film;

SELECT fa.film_id, f.title,sum(fa.actor_id) AS number_of_actor
FROM film_actor AS fa
JOIN film as f
USING (film_id)
GROUP BY film_id;

#----6d.How many copies of the film `Hunchback Impossible` exist in the inventory system?
#SELECT*FROM inventory;
#SELECT*FROM film;

SELECT f.title ,count(i.inventory_id) AS number_of_copies
FROM inventory AS i
JOIN film AS f
USING (film_id)
WHERE f.title="HUNCHBACK IMPOSSIBLE";

#----6e.Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
#SELECT*FROM payment;
#SELECT*FROM customer;

SELECT c.customer_id, c.first_name,c.last_name, SUM(p.amount) AS total_paid
FROM payment AS p
JOIN customer AS c
USING (customer_id)
GROUP BY customer_id
ORDER BY last_name;

#----7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
#----Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
#SELECT*FROM film;
#SELECT*FROM language;

SELECT film.title, language_id
FROM film
WHERE (title Like "K%" or  title Like "Q%") AND language_id IN
		  (SELECT language_id
			FROM language
			WHERE name="English");

#----7b.Use subqueries to display all actors who appear in the film `Alone Trip`.
#SELECT*FROM film;
#SELECT*FROM film_actor;
#SELECT*FROM actor;

SELECT actor_id,first_name,last_name
FROM actor
WHERE actor_id IN 
	(SELECT actor_id
	FROM film_actor
	WHERE film_id IN
			(SELECT film_id
			 FROM film
			 WHERE title="ALONE TRIP"));
             
#---7c.You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
#SELECT*FROM country;
#SELECT*FROM city;
#SELECT*FROM customer;
#SELECT*FROM address; 

SELECT customer_id, first_name,last_name,email
FROM customer
JOIN address
USING (address_id)
JOIN city
USING(city_id)
JOIN country
USING (country_id)
WHERE country="Canada";

#---Alternatively, you can use subqueries to return the same result
SELECT customer_id, first_name,last_name,email
FROM customer
WHERE address_id IN 
			(SELECT address_id
             FROM address
             WHERE city_id IN 
						(SELECT city_id
                         FROM city
                         WHERE country_id IN
										(SELECT country_id
										 FROM country
                                         WHERE country="Canada")));		
                                         

#---7d.Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title,category
FROM film_list
WHERE category="Family";

#---7e.Display the most frequently rented movies in descending order.
#SELECT*FROM rental;
#SELECT*FROM film;
#SELECT*FROM inventory;

SELECT title, count(customer_id) AS number_of_renters
FROM rental
JOIN inventory
USING (inventory_id)
JOIN film
USING (film_id)
GROUP BY film_id
ORDER BY number_of_renters DESC;

#----7f. Write a query to display how much business, in dollars, each store brought in.
#SELECT* FROM store;
#SELECT* FROM staff;
#SELECT* FROM payment;

SELECT store_id, sum(amount) AS business_dollars
FROM store
JOIN staff
USING (store_id)
JOIN payment 
USING (staff_id)
GROUP BY store_id
ORDER BY business_dollars DESC;

#---7g. Write a query to display for each store its store ID, city, and country.
#SELECT* FROM store;
#SELECT* FROM address;
#SELECT* FROM city;
#SELECT* FROM country;

SELECT store_id, city,country
FROM country
JOIN city
USING (country_id)
JOIN address
USING (city_id)
JOIN store
USING(address_id);

#---7h. List the top five genres in gross revenue in descending order. 
#SELECT* FROM category;
#SELECT* FROM film_category;
#SELECT* FROM inventory;
#SELECT* FROM payment;
#SELECT* FROM rental;

SELECT c.name, SUM(amount) AS gross_revenue
FROM category AS c
JOIN film_category AS fc
USING (category_id)
JOIN inventory AS i
USING (film_id) 
JOIN rental AS r
USING( inventory_id)
JOIN payment AS p
USING (rental_id)
GROUP BY c.name
ORDER BY gross_revenue DESC
LIMIT 5;

#----8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view.
#----If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_gross_revenue AS
SELECT c.name, SUM(amount) AS gross_revenue
FROM category AS c
JOIN film_category AS fc
USING (category_id)
JOIN inventory AS i
USING (film_id) 
JOIN rental AS r
USING( inventory_id)
JOIN payment AS p
USING (rental_id)
GROUP BY c.name
ORDER BY gross_revenue DESC
LIMIT 5;

#----8b.How would you display the view that you created in 8a?
SELECT* FROM top_gross_revenue;

#----8c.You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_gross_revenue;














