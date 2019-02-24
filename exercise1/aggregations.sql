CREATE DATABASE exercise1;
USE exercise1;

DROP TABLE users;
DROP TABLE sales;

CREATE TABLE users(
  user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_email VARCHAR(255) NOT NULL,
  date_creation_profile DATETIME DEFAULT NOW(),
  date_last_visit DATETIME DEFAULT NOW(),
  number_of_visits INT DEFAULT 1,
  PRIMARY KEY (user_id)
);

CREATE TABLE sales(
  transaction_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  merchant_id INT UNSIGNED NOT NULL,
  date_sales DATETIME NOT NULL,
  price DECIMAL(5, 2) NOT NULL,
  PRIMARY KEY (transaction_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users
  (user_email, number_of_visits)
VALUES
  ("alice@backmarket.fr", 1),
  ("bob@backmarket.fr", 1),
  ("charles@backmarket.fr", 12),
  ("david@backmarket.fr", 4),
  ("edwige@backmarket.fr", 5),
  ("fanny@backmarket.fr", 60),
  ("george@backmarket.es", 10),
  ("harry@backmarket.es", 1),
  ("isabel@backmarket.es", 3);

# TODO Generate more test cases to illustrate what is expected from the queries
INSERT INTO sales
  (product_id, user_id, merchant_id, date_sales, price)
VALUES
  (201, 1, 401, '2017-12-10 11:33:08', 300.50),
  (202, 2, 401, '2018-01-10 12:00:00', 20.10),
  (203, 3, 401, '2018-02-10 12:00:00', 42.00),
  (203, 4, 401, '2018-02-10 12:00:00', 42.00),
  (203, 5, 401, '2018-02-10 12:00:00', 42.00),
  (203, 6, 402, '2018-04-10 12:00:00', 42.00),
  (204, 1, 402, '2018-04-15 12:00:00', 30.50),
  (204, 1, 401, '2018-04-15 12:00:00', 30.50),
  (204, 1, 401, '2018-04-15 12:00:00', 30.50),
  (204, 2, 402, '2018-04-10 13:17:00', 10.20),
  (204, 6, 402, '2018-09-10 13:17:00', 10.20),
  (205, 1, 405, '2018-09-10 13:17:00', 20.50),
  (205, 1, 401, '2018-09-10 13:17:00', 20.50),
  (205, 2, 405, '2018-10-10 13:17:00', 20.50),
  (205, 2, 401, '2018-10-10 13:17:00', 20.50),
  (205, 4, 405, '2019-01-22 13:17:00', 20.50),
  (205, 5, 401, '2019-02-22 23:30:15', 2.50),
  (205, 6, 402, '2019-02-18 23:30:16', 2.50),
  (205, 6, 402, '2019-03-18 23:30:17', 2.50);

# Volume of sales per merchant per month
CREATE VIEW volume_per_merchant_per_month AS
  SELECT YEAR(date_sales) AS year, MONTHNAME(date_sales) AS month, SUM(price) AS volume, merchant_id
  FROM sales
  GROUP BY YEAR(date_sales), MONTH(date_sales)
  ORDER BY volume DESC;

SELECT * FROM volume_per_merchant_per_month;

# Top 10% of users per month
CREATE VIEW ratio_per_merchant_per_month AS
  SELECT year, month, volume, volume/SUM(volume) AS ratio, merchant_id
  FROM volume_per_merchant_per_month GROUP BY year, month;

SELECT * FROM ratio_per_merchant_per_month WHERE ratio >= 0.1;

# Merchants selling more than 10 products per day on the last 3m
CREATE VIEW sales_per_merchant_per_day_3m AS
  SELECT YEAR(date_sales) AS year, MONTHNAME(date_sales) AS month, DAY(date_sales) AS day,
    COUNT(transaction_id) AS nb_sales, merchant_id
  FROM sales
  WHERE date_sales BETWEEN
    DATE_SUB(NOW(), INTERVAL 90 DAY)
    AND DATE_SUB(NOW(), INTERVAL 0 DAY)
  GROUP BY YEAR(date_sales), MONTH(date_sales), DAY(date_sales), merchant_id
  ORDER BY nb_sales DESC;

SELECT merchant_id, nb_sales FROM sales_per_merchant_per_day WHERE nb_sales >= 10;

# Products sold by one merchant only on the last 3m
CREATE VIEW merchants_per_product_3m AS
  SELECT product_id, merchant_id, COUNT(merchant_id) AS nb_sellers
  FROM sales
  WHERE date_sales BETWEEN
    DATE_SUB(NOW(), INTERVAL 90 DAY)
    AND DATE_SUB(NOW(), INTERVAL 0 DAY)
  GROUP BY product_id;

SELECT product_id FROM products_per_merchant_3m WHERE nb_sellers = 1;

# Attractive products matching these two criterias
SELECT * FROM merchants_per_product_3m
INNER JOIN sales_per_merchant_per_day_3m
ON merchants_per_product_3m.merchant_id = sales_per_merchant_per_day_3m.merchant_id
WHERE sales_per_merchant_per_day_3m.nb_sales >= 10
WHERE merchants_per_product_3m.nb_sellers = 1;
