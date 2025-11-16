-- ============================================================
-- パフォーマンスチューニングデモ用クエリ集
-- ============================================================

USE sakila;

-- ============================================================
-- デモ1: インデックスの重要性
-- ============================================================

-- 【遅いクエリ】中間一致・後方一致検索（インデックスを使えない）
-- EXPLAIN分析:
EXPLAIN SELECT * FROM film WHERE title LIKE '%ACADEMY%';
-- 結果: type: ALL (フルテーブルスキャン), rows: ~1000

-- 実行時間測定:
SELECT SQL_NO_CACHE * FROM film WHERE title LIKE '%ACADEMY%';

-- 【速いクエリ】前方一致検索（インデックスを使える）
-- まずインデックスを作成:
-- CREATE INDEX idx_title ON film(title);

EXPLAIN SELECT * FROM film WHERE title LIKE 'ACADEMY%';
-- 結果: type: range (インデックスレンジスキャン), rows: 少数

-- 実行時間測定:
SELECT SQL_NO_CACHE * FROM film WHERE title LIKE 'ACADEMY%';

-- ============================================================
-- デモ2: N+1問題とJOINの最適化
-- ============================================================

-- 【遅いクエリ】N+1問題（アプリケーション側で複数回クエリ実行）
-- まず映画を取得:
SELECT film_id, title, language_id FROM film LIMIT 10;
-- 次に各映画に対して言語を取得（10回実行）:
-- SELECT name FROM language WHERE language_id = ?;

-- 【速いクエリ】JOINを使用して1回のクエリで取得
EXPLAIN SELECT
    f.film_id,
    f.title,
    f.language_id,
    l.name as language_name
FROM film f
INNER JOIN language l ON f.language_id = l.language_id
LIMIT 10;

-- 実行時間測定:
SELECT
    f.film_id,
    f.title,
    f.language_id,
    l.name as language_name
FROM film f
INNER JOIN language l ON f.language_id = l.language_id
LIMIT 100;

-- ============================================================
-- デモ3: サブクエリの最適化
-- ============================================================

-- 【遅いクエリ】相関サブクエリを使用
EXPLAIN SELECT
    f.film_id,
    f.title,
    (SELECT l.name FROM language l WHERE l.language_id = f.language_id) as language_name,
    (SELECT COUNT(*) FROM film_actor fa WHERE fa.film_id = f.film_id) as actor_count
FROM film f
WHERE f.length >= 90
LIMIT 50;

-- 実行時間測定:
SELECT
    f.film_id,
    f.title,
    (SELECT l.name FROM language l WHERE l.language_id = f.language_id) as language_name,
    (SELECT COUNT(*) FROM film_actor fa WHERE fa.film_id = f.film_id) as actor_count
FROM film f
WHERE f.length >= 90
LIMIT 50;

-- 【速いクエリ】JOINとGROUP BYを使用
EXPLAIN SELECT
    f.film_id,
    f.title,
    l.name as language_name,
    COUNT(DISTINCT fa.actor_id) as actor_count
FROM film f
INNER JOIN language l ON f.language_id = l.language_id
LEFT JOIN film_actor fa ON f.film_id = fa.film_id
WHERE f.length >= 90
GROUP BY f.film_id, f.title, l.name
LIMIT 50;

-- 実行時間測定:
SELECT
    f.film_id,
    f.title,
    l.name as language_name,
    COUNT(DISTINCT fa.actor_id) as actor_count
FROM film f
INNER JOIN language l ON f.language_id = l.language_id
LEFT JOIN film_actor fa ON f.film_id = fa.film_id
WHERE f.length >= 90
GROUP BY f.film_id, f.title, l.name
LIMIT 50;

-- ============================================================
-- デモ4: 不要なJOINの削減
-- ============================================================

-- 【遅いクエリ】必要以上のJOINを実行
EXPLAIN SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    a.address,
    ci.city,
    co.country
FROM customer c
LEFT JOIN address a ON c.address_id = a.address_id
LEFT JOIN city ci ON a.city_id = ci.city_id
LEFT JOIN country co ON ci.country_id = co.country_id
WHERE c.active = 1
LIMIT 100;

-- 【速いクエリ】必要な情報のみ取得
EXPLAIN SELECT
    customer_id,
    first_name,
    last_name,
    email
FROM customer
WHERE active = 1
LIMIT 100;

-- ============================================================
-- デモ5: SELECT * の問題
-- ============================================================

-- 【遅いクエリ】不要なカラムも取得
EXPLAIN SELECT * FROM film WHERE release_year = 2006;

-- 【速いクエリ】必要なカラムのみ取得
EXPLAIN SELECT film_id, title, release_year, length FROM film WHERE release_year = 2006;

-- ============================================================
-- パフォーマンス分析用のコマンド
-- ============================================================

-- クエリ実行計画の確認
-- EXPLAIN SELECT ...;

-- より詳細な実行計画
-- EXPLAIN FORMAT=JSON SELECT ...;

-- 実際の実行統計を取得（MySQL 8.0.18+）
-- EXPLAIN ANALYZE SELECT ...;

-- プロファイリングを有効化
-- SET profiling = 1;
-- SELECT ...;
-- SHOW PROFILES;
-- SHOW PROFILE FOR QUERY 1;

-- インデックスの使用状況を確認
-- SHOW INDEX FROM film;

-- テーブルの統計情報を更新
-- ANALYZE TABLE film;

-- ============================================================
-- インデックス追加/削除のデモ用コマンド
-- ============================================================

-- インデックスを作成してパフォーマンスの違いを確認
-- CREATE INDEX idx_title ON film(title);

-- インデックスを削除して元の状態に戻す
-- DROP INDEX idx_title ON film;

-- 複合インデックスの作成
-- CREATE INDEX idx_language_year ON film(language_id, release_year);

-- インデックスの確認
-- SHOW INDEX FROM film;
