# Volume of sales per merchant per month
DROP VIEW volume_per_merchant_per_month;
CREATE VIEW volume_per_merchant_per_month AS
  SELECT YEAR(date_sales) AS year, MONTH(date_sales) AS month, SUM(price) AS volume, merchant_id
  FROM sales
  GROUP BY year, month, merchant_id
  ORDER BY year, month, volume DESC;

SELECT * FROM volume_per_merchant_per_month;

# Top 10% of users per month
DROP VIEW total_per_month;
CREATE VIEW total_per_month AS
  SELECT year, month, SUM(volume) AS total
  FROM volume_per_merchant_per_month GROUP BY year, month;

DROP VIEW ratio_per_merchant_per_month;
CREATE VIEW ratio_per_merchant_per_month AS
  SELECT A.year, A.month, volume/B.total AS ratio, merchant_id
  FROM volume_per_merchant_per_month A
  LEFT JOIN total_per_month B
  ON A.year = B.year
    AND A.month = B.month
  ORDER BY year, month, ratio DESC;

SELECT *
FROM ratio_per_merchant_per_month
WHERE ratio >= 0.1
GROUP BY year, month;

# FIXME sum until ratio > 0.1 if necessary

# Merchants selling more than 10 products per day on the last 3m
DROP VIEW sales_per_merchant_per_day_3m;
CREATE VIEW sales_per_merchant_per_day_3m AS
  SELECT YEAR(date_sales) AS year, MONTH(date_sales) AS month, DAY(date_sales) AS day,
    COUNT(transaction_id) AS nb_sales, merchant_id
  FROM sales
  WHERE date_sales BETWEEN
    DATE_SUB(NOW(), INTERVAL 90 DAY)
    AND DATE_SUB(NOW(), INTERVAL 0 DAY)
  GROUP BY year, month, day, merchant_id
  ORDER BY nb_sales DESC;

SELECT year, month, day, merchant_id, nb_sales
FROM sales_per_merchant_per_day_3m
WHERE nb_sales >= 10;

# Products sold by one merchant only on the last 3m
DROP VIEW merchants_per_product_3m;
CREATE VIEW merchants_per_product_3m AS
  SELECT product_id, merchant_id, COUNT(merchant_id) AS nb_sellers
  FROM sales
  WHERE date_sales BETWEEN
    DATE_SUB(NOW(), INTERVAL 90 DAY)
    AND DATE_SUB(NOW(), INTERVAL 0 DAY)
  GROUP BY product_id;

SELECT product_id, merchant_id, nb_sellers
FROM merchants_per_product_3m
WHERE nb_sellers = 1;

# Attractive products matching these two criterias
SELECT A.product_id, B.nb_sales, A.merchant_id
FROM merchants_per_product_3m A
INNER JOIN sales_per_merchant_per_day_3m B
ON A.merchant_id = B.merchant_id
WHERE B.nb_sales >= 10 AND A.nb_sellers = 1;
