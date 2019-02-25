CREATE DATABASE exercise1;
USE exercise1;

DROP TABLE users;
CREATE TABLE users(
  user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_email VARCHAR(255) NOT NULL,
  date_creation_profile DATETIME DEFAULT NOW(),
  date_last_visit DATETIME DEFAULT NOW(),
  number_of_visits INT DEFAULT 1,
  PRIMARY KEY (user_id)
);

DROP TABLE sales;
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
  (205, 1, 402, '2019-02-18 23:31:16', 2.50),
  (206, 2, 402, '2019-02-18 23:32:16', 2.50),
  (207, 3, 402, '2019-02-18 23:33:16', 2.50),
  (208, 4, 402, '2019-02-18 23:34:16', 2.50),
  (209, 5, 402, '2019-02-18 23:35:16', 2.50),
  (210, 6, 402, '2019-02-18 23:36:16', 2.50),
  (211, 7, 402, '2019-02-18 23:37:16', 2.50),
  (212, 8, 402, '2019-02-18 23:38:16', 2.50),
  (213, 8, 402, '2019-02-18 23:39:16', 2.50),
  (214, 8, 402, '2019-02-18 23:40:16', 2.50),
  (205, 6, 402, '2019-03-18 23:30:17', 2.50);
