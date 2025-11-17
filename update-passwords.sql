USE sakila;

-- 正しいBCryptハッシュでパスワードを更新（パスワード: password）
UPDATE users SET password = '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG' WHERE username='admin';
UPDATE users SET password = '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG' WHERE username='demo';
UPDATE users SET password = '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG' WHERE username='user';

SELECT username, LENGTH(password) as password_length, LEFT(password, 10) as password_start FROM users;
