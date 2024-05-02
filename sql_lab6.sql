#Use sakila
USE sakila;
#Step 1: Create a View
##First, create a view that summarizes rental information for each customer. 
##The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW customer_rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email AS email_address,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

#Step 2: Create a Temporary Table
##Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
##The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE temp_customer_payment AS
SELECT
    crs.customer_id,
    crs.customer_name,
    crs.email_address,
    crs.rental_count,
    SUM(CASE WHEN p.amount IS NOT NULL THEN p.amount ELSE 0 END) AS total_paid
FROM customer_rental_summary crs
LEFT JOIN payment p ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id, crs.customer_name, crs.email_address, crs.rental_count;

##Step 3: Create a CTE and the Customer Summary Report
##Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
##The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH customer_summary AS (
    SELECT
        crs.customer_name,
        crs.email_address,
        crs.rental_count,
        tcp.total_paid,
        (tcp.total_paid / crs.rental_count) AS average_payment_per_rental
    FROM customer_rental_summary crs
    JOIN temp_customer_payment tcp ON crs.customer_id = tcp.customer_id
)
SELECT
    customer_name,
    email_address,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM customer_summary;