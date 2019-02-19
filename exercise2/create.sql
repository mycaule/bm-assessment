CREATE DATABASE exercise12;
USE exercise2;

DROP TABLE messages;

CREATE TABLE messages(
  id INT UNSIGNED NOT NULL,
  send_user_id INT UNSIGNED NOT NULL,
  merchant_user_id INT UNSIGNED NOT NULL,
  merchant_id INT UNSIGNED NOT NULL,
  date_creation DATETIME DEFAULT NOW(),
  country_code VARCHAR(10) NOT NULL,
  sav_group_id TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (id)
)
