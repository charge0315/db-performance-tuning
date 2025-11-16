-- ============================================================
-- インデックス作成スクリプト
-- パフォーマンスチューニングデモ用
-- ============================================================

USE sakila;

-- ============================================================
-- パフォーマンスチューニングデモ用インデックス
-- ============================================================

-- デモ1: タイトル検索用インデックス
-- このインデックスがあると前方一致検索が高速化される
-- LIKE 'keyword%' のようなクエリで有効

-- インデックスなしの状態を確認するため、最初はコメントアウト
-- 講義中に以下のコマンドを実行してパフォーマンスの違いを確認

-- CREATE INDEX idx_title ON film(title);

-- デモ用のEXPLAINクエリ例:
-- インデックスなし（遅い）:
-- EXPLAIN SELECT * FROM film WHERE title LIKE '%ACADEMY%';
-- -> type: ALL, rows: 1000 (フルテーブルスキャン)

-- インデックスなし（これも遅い）:
-- EXPLAIN SELECT * FROM film WHERE title LIKE '%ACADEMY%';
-- -> 後方一致や中間一致はインデックスを使えない

-- インデックスあり（速い）:
-- CREATE INDEX idx_title ON film(title);
-- EXPLAIN SELECT * FROM film WHERE title LIKE 'ACADEMY%';
-- -> type: range, rows: 少数 (インデックスレンジスキャン)

-- ============================================================
-- 既存の推奨インデックス
-- ============================================================

-- 映画テーブルの追加インデックス
CREATE INDEX idx_film_release_year ON film(release_year);
CREATE INDEX idx_film_length ON film(length);
CREATE INDEX idx_film_rating ON film(rating);

-- 顧客テーブルの追加インデックス
CREATE INDEX idx_customer_email ON customer(email);
CREATE INDEX idx_customer_active ON customer(active);

-- 複合インデックスの例
CREATE INDEX idx_film_language_year ON film(language_id, release_year);
CREATE INDEX idx_customer_store_active ON customer(store_id, active);

-- ============================================================
-- パフォーマンス確認用のクエリサンプル
-- ============================================================

-- 1. インデックスなしでの検索（遅い）
-- SELECT * FROM film WHERE title LIKE '%ACADEMY%';

-- 2. インデックスありでの検索（速い）
-- idx_title作成後:
-- SELECT * FROM film WHERE title LIKE 'ACADEMY%';

-- 3. 複合インデックスの効果
-- EXPLAIN SELECT * FROM film WHERE language_id = 1 AND release_year = 2006;

-- 4. JOINのパフォーマンス
-- EXPLAIN SELECT f.title, l.name
-- FROM film f
-- INNER JOIN language l ON f.language_id = l.language_id
-- WHERE f.release_year = 2006;

-- 5. サブクエリの最適化
-- 遅い:
-- EXPLAIN SELECT * FROM film WHERE film_id IN (SELECT film_id FROM film_actor WHERE actor_id = 1);
-- 速い:
-- EXPLAIN SELECT DISTINCT f.* FROM film f INNER JOIN film_actor fa ON f.film_id = fa.film_id WHERE fa.actor_id = 1;
