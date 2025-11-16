-- ============================================================
-- Sakila データベース初期化スクリプト（簡易版）
-- SQLパフォーマンスチューニングデモ用
-- ============================================================

USE sakila;

-- 既存のテーブルを削除（クリーンインストール用）
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS film_actor;
DROP TABLE IF EXISTS film_category;
DROP TABLE IF EXISTS rental;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS film;
DROP TABLE IF EXISTS actor;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS address;
DROP TABLE IF EXISTS city;
DROP TABLE IF EXISTS country;
DROP TABLE IF EXISTS language;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS store;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 言語テーブル
-- ============================================================
CREATE TABLE language (
  language_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name CHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (language_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO language (name) VALUES
('English'), ('Italian'), ('Japanese'), ('Mandarin'), ('French'), ('German');

-- ============================================================
-- 映画テーブル
-- ============================================================
CREATE TABLE film (
  film_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT DEFAULT NULL,
  release_year YEAR DEFAULT NULL,
  language_id TINYINT UNSIGNED NOT NULL,
  original_language_id TINYINT UNSIGNED DEFAULT NULL,
  rental_duration TINYINT UNSIGNED NOT NULL DEFAULT 3,
  rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
  length SMALLINT UNSIGNED DEFAULT NULL,
  replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
  rating ENUM('G','PG','PG-13','R','NC-17') DEFAULT 'G',
  special_features SET('Trailers','Commentaries','Deleted Scenes','Behind the Scenes') DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (film_id),
  KEY idx_language_id (language_id),
  CONSTRAINT fk_film_language FOREIGN KEY (language_id) REFERENCES language (language_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 映画データを1000件挿入（パフォーマンステスト用）
INSERT INTO film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating) VALUES
('ACADEMY DINOSAUR', 'A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies', 2006, 1, 6, 0.99, 86, 20.99, 'PG'),
('ACE GOLDFINGER', 'A Astounding Epistle of a Database Administrator And a Explorer who must Find a Car in Ancient China', 2006, 1, 3, 4.99, 48, 12.99, 'G'),
('ADAPTATION HOLES', 'A Astounding Reflection of a Lumberjack And a Car who must Sink a Lumberjack in A Baloon Factory', 2006, 1, 7, 2.99, 50, 18.99, 'NC-17'),
('AFFAIR PREJUDICE', 'A Fanciful Documentary of a Frisbee And a Lumberjack who must Chase a Monkey in A Shark Tank', 2006, 1, 5, 2.99, 117, 26.99, 'G'),
('AFRICAN EGG', 'A Fast-Paced Documentary of a Pastry Chef And a Dentist who must Pursue a Forensic Psychologist in The Gulf of Mexico', 2006, 1, 6, 2.99, 130, 22.99, 'G'),
('AGENT TRUMAN', 'A Intrepid Panorama of a Robot And a Boy who must Escape a Sumo Wrestler in Ancient China', 2006, 1, 3, 2.99, 169, 17.99, 'PG'),
('AIRPLANE SIERRA', 'A Touching Saga of a Hunter And a Butler who must Discover a Butler in A Jet Boat', 2006, 1, 6, 4.99, 62, 28.99, 'PG-13'),
('AIRPORT POLLOCK', 'A Epic Tale of a Moose And a Girl who must Confront a Monkey in Ancient India', 2006, 1, 6, 4.99, 54, 15.99, 'R'),
('ALABAMA DEVIL', 'A Thoughtful Panorama of a Database Administrator And a Mad Scientist who must Outgun a Mad Scientist in A Jet Boat', 2006, 1, 3, 2.99, 114, 21.99, 'PG-13'),
('ALADDIN CALENDAR', 'A Action-Packed Tale of a Man And a Lumberjack who must Reach a Feminist in Ancient China', 2006, 1, 6, 4.99, 63, 24.99, 'NC-17');

-- さらに多くのデータを生成（パフォーマンステスト用）
DELIMITER //
CREATE PROCEDURE generate_films()
BEGIN
  DECLARE i INT DEFAULT 11;
  WHILE i <= 1000 DO
    INSERT INTO film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating)
    VALUES (
      CONCAT('FILM ', i),
      CONCAT('A sample film description for film number ', i, '. This is used for performance testing purposes.'),
      2006,
      (i MOD 6) + 1,
      (i MOD 7) + 1,
      2.99 + (i MOD 3),
      50 + (i MOD 150),
      15.99 + (i MOD 30),
      ELT((i MOD 5) + 1, 'G', 'PG', 'PG-13', 'R', 'NC-17')
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

CALL generate_films();
DROP PROCEDURE generate_films;

-- ============================================================
-- 俳優テーブル
-- ============================================================
CREATE TABLE actor (
  actor_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id),
  KEY idx_actor_last_name (last_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO actor (first_name, last_name) VALUES
('PENELOPE', 'GUINESS'), ('NICK', 'WAHLBERG'), ('ED', 'CHASE'),
('JENNIFER', 'DAVIS'), ('JOHNNY', 'LOLLOBRIGIDA'), ('BETTE', 'NICHOLSON'),
('GRACE', 'MOSTEL'), ('MATTHEW', 'JOHANSSON'), ('JOE', 'SWANK'),
('CHRISTIAN', 'GABLE'), ('ZERO', 'CAGE'), ('KARL', 'BERRY');

-- さらに俳優データを追加
DELIMITER //
CREATE PROCEDURE generate_actors()
BEGIN
  DECLARE i INT DEFAULT 13;
  WHILE i <= 200 DO
    INSERT INTO actor (first_name, last_name)
    VALUES (
      CONCAT('FIRSTNAME', i),
      CONCAT('LASTNAME', i)
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

CALL generate_actors();
DROP PROCEDURE generate_actors;

-- ============================================================
-- 映画-俳優 関連テーブル
-- ============================================================
CREATE TABLE film_actor (
  actor_id SMALLINT UNSIGNED NOT NULL,
  film_id SMALLINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id, film_id),
  KEY idx_fk_film_id (film_id),
  CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
  CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES film (film_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 映画と俳優の関連データを生成
DELIMITER //
CREATE PROCEDURE generate_film_actors()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE j INT;
  WHILE i <= 1000 DO
    SET j = 0;
    WHILE j < 5 DO
      INSERT IGNORE INTO film_actor (actor_id, film_id)
      VALUES ((i MOD 200) + 1, i);
      SET j = j + 1;
      SET i = i + 1;
      IF i > 1000 THEN
        LEAVE;
      END IF;
    END WHILE;
  END WHILE;
END //
DELIMITER ;

CALL generate_film_actors();
DROP PROCEDURE generate_film_actors;

-- ============================================================
-- 国テーブル
-- ============================================================
CREATE TABLE country (
  country_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  country VARCHAR(50) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (country_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO country (country) VALUES
('Japan'), ('United States'), ('Canada'), ('United Kingdom'), ('Germany'),
('France'), ('Italy'), ('Spain'), ('China'), ('Australia');

-- ============================================================
-- 都市テーブル
-- ============================================================
CREATE TABLE city (
  city_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  city VARCHAR(50) NOT NULL,
  country_id SMALLINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (city_id),
  KEY idx_fk_country_id (country_id),
  CONSTRAINT fk_city_country FOREIGN KEY (country_id) REFERENCES country (country_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO city (city, country_id) VALUES
('Tokyo', 1), ('Osaka', 1), ('New York', 2), ('Los Angeles', 2),
('Toronto', 3), ('London', 4), ('Berlin', 5), ('Paris', 6),
('Rome', 7), ('Madrid', 8), ('Beijing', 9), ('Sydney', 10);

-- ============================================================
-- 住所テーブル
-- ============================================================
CREATE TABLE address (
  address_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT UNSIGNED NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (address_id),
  KEY idx_fk_city_id (city_id),
  CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city (city_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 住所データを生成
DELIMITER //
CREATE PROCEDURE generate_addresses()
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= 600 DO
    INSERT INTO address (address, district, city_id, postal_code, phone)
    VALUES (
      CONCAT(i, ' Main Street'),
      CONCAT('District', (i MOD 10) + 1),
      (i MOD 12) + 1,
      LPAD(i, 5, '0'),
      CONCAT('555-', LPAD(i, 4, '0'))
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

CALL generate_addresses();
DROP PROCEDURE generate_addresses;

-- ============================================================
-- 顧客テーブル
-- ============================================================
CREATE TABLE customer (
  customer_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  store_id TINYINT UNSIGNED NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  address_id SMALLINT UNSIGNED NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  create_date DATETIME NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (customer_id),
  KEY idx_fk_address_id (address_id),
  KEY idx_last_name (last_name),
  CONSTRAINT fk_customer_address FOREIGN KEY (address_id) REFERENCES address (address_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 顧客データを生成
DELIMITER //
CREATE PROCEDURE generate_customers()
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= 599 DO
    INSERT INTO customer (store_id, first_name, last_name, email, address_id, active, create_date)
    VALUES (
      (i MOD 2) + 1,
      CONCAT('First', i),
      CONCAT('Last', i),
      CONCAT('customer', i, '@example.com'),
      i,
      IF(i MOD 10 = 0, FALSE, TRUE),
      NOW()
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

CALL generate_customers();
DROP PROCEDURE generate_customers;

-- ============================================================
-- ユーザーテーブル（ログイン用）
-- ============================================================
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'USER',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- デモユーザーを作成（パスワード: password）
-- BCrypt hash for "password"
INSERT INTO users (username, password, role) VALUES
('demo', '$2a$10$xCqWMw7IHqXaJJe5Y9Xz4.zJPLzJj5d7jR8D3k9cQN6J6k7g8h9i0', 'USER'),
('admin', '$2a$10$xCqWMw7IHqXaJJe5Y9Xz4.zJPLzJj5d7jR8D3k9cQN6J6k7g8h9i0', 'ADMIN');
