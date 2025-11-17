USE sakila;

-- usersテーブルの作成
CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'USER',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 初期ユーザーの作成（パスワード: password）
INSERT IGNORE INTO users (username, password, role) VALUES 
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMye6bvz3C7vCmJWPSxMjx3gx7VVz2rJdXe', 'ADMIN'),
('user', '$2a$10$N9qo8uLOickgx2ZMRZoMye6bvz3C7vCmJWPSxMjx3gx7VVz2rJdXe', 'USER');

-- customerテーブルの作成  
CREATE TABLE IF NOT EXISTS customer (
  customer_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  create_date DATETIME NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (customer_id)
);

-- サンプル顧客データの挿入
INSERT IGNORE INTO customer (first_name, last_name, email, create_date) VALUES 
('John', 'Doe', 'john.doe@example.com', NOW()),
('Jane', 'Smith', 'jane.smith@example.com', NOW()),
('Mike', 'Johnson', 'mike.johnson@example.com', NOW());