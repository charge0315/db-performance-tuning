-- ============================================
-- 既存のFilmデータに追加して100,000件にするスクリプト
-- ============================================
-- 現在のfilm数: 64,000件
-- 追加数: 36,000件
-- 合計: 100,000件
-- ============================================

USE sakila;

-- 一時的に外部キー制約を無効化
SET FOREIGN_KEY_CHECKS = 0;

-- 現在のfilm数を確認
SELECT COUNT(*) AS 'Before: Film count' FROM film;

-- 洋画のタイトルパターン用のテーブルが既に存在する
-- DROP TABLE IF EXISTS title_patterns;

-- 36回繰り返してデータを複製（64,000 + 36,000 = 100,000件）

DELIMITER $$

DROP PROCEDURE IF EXISTS continue_multiply_films$$

CREATE PROCEDURE continue_multiply_films()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_film_id INT;
    DECLARE batch_start INT DEFAULT 1;
    DECLARE batch_end INT DEFAULT 1000;
    
    WHILE i <= 36 DO
        -- 元の1000件からランダムにデータを複製
        INSERT INTO film (
            title, 
            description, 
            release_year,
            language_id,
            rental_duration,
            rental_rate,
            length,
            replacement_cost,
            rating,
            special_features,
            last_update
        )
        SELECT 
            -- ランダムな洋画風タイトルを生成
            CONCAT(
                (SELECT prefix FROM title_patterns ORDER BY RAND() LIMIT 1),
                ' ',
                (SELECT suffix FROM title_patterns ORDER BY RAND() LIMIT 1),
                ' ',
                CASE 
                    WHEN i % 10 = 0 THEN CONCAT('Part ', FLOOR(i/10))
                    WHEN i % 10 = 1 THEN 'Returns'
                    WHEN i % 10 = 2 THEN 'Reloaded'
                    WHEN i % 10 = 3 THEN 'Revolution'
                    WHEN i % 10 = 4 THEN 'Origins'
                    WHEN i % 10 = 5 THEN 'Legacy'
                    WHEN i % 10 = 6 THEN CONCAT('Vol.', FLOOR(i/6))
                    WHEN i % 10 = 7 THEN 'Rising'
                    WHEN i % 10 = 8 THEN 'Resurrection'
                    ELSE 'Forever'
                END
            ) AS title,
            -- 説明にバリエーションを追加
            CONCAT(
                description,
                CASE 
                    WHEN i % 5 = 0 THEN ' An epic tale of adventure and courage.'
                    WHEN i % 5 = 1 THEN ' A thrilling journey through time and space.'
                    WHEN i % 5 = 2 THEN ' A heartwarming story of love and friendship.'
                    WHEN i % 5 = 3 THEN ' A mysterious saga of betrayal and redemption.'
                    ELSE ' An unforgettable cinematic masterpiece.'
                END
            ) AS description,
            -- リリース年をランダム化 (1980-2024)
            1980 + FLOOR(RAND() * 45) AS release_year,
            language_id,
            rental_duration,
            -- レンタル料をランダム化 (0.99-6.99)
            0.99 + FLOOR(RAND() * 6) AS rental_rate,
            -- 上映時間をランダム化 (80-180分)
            80 + FLOOR(RAND() * 100) AS length,
            replacement_cost,
            -- レーティングをランダム化
            CASE FLOOR(RAND() * 5)
                WHEN 0 THEN 'G'
                WHEN 1 THEN 'PG'
                WHEN 2 THEN 'PG-13'
                WHEN 3 THEN 'R'
                ELSE 'NC-17'
            END AS rating,
            special_features,
            NOW() AS last_update
        FROM film
        WHERE film_id BETWEEN batch_start AND batch_end
        LIMIT 1000;
        
        SET i = i + 1;
        SELECT CONCAT('進捗: ', i, '/36 (', ROUND(i/36*100, 1), '%)') AS Progress;
        
        -- CPUへの負荷を軽減するため少し待機
        DO SLEEP(0.1);
    END WHILE;
    
    SELECT '処理完了！' AS Status;
END$$

DELIMITER ;

-- プロシージャを実行
CALL continue_multiply_films();

-- プロシージャを削除
DROP PROCEDURE IF EXISTS continue_multiply_films;

-- film_actorテーブルも複製（俳優との関連を維持）
-- 新しく追加されたfilmのIDの範囲を取得
SET @new_film_start_id = 64001;
SET @new_film_end_id = (SELECT MAX(film_id) FROM film);

-- 元のfilm_actorレコードを複製
INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT 
  fa.actor_id,
  f.film_id AS new_film_id,
  NOW()
FROM film f
INNER JOIN film fa2 ON fa2.film_id BETWEEN 1 AND 1000
INNER JOIN film_actor fa ON fa.film_id = fa2.film_id
WHERE f.film_id BETWEEN @new_film_start_id AND @new_film_end_id
  AND NOT EXISTS (
    SELECT 1 FROM film_actor fa3 
    WHERE fa3.actor_id = fa.actor_id 
    AND fa3.film_id = f.film_id
  );

-- 外部キー制約を再有効化
SET FOREIGN_KEY_CHECKS = 1;

-- パターンテーブルを削除
DROP TABLE IF EXISTS title_patterns;

-- 結果を確認
SELECT COUNT(*) AS 'After: Film count' FROM film;
SELECT COUNT(*) AS 'After: Film-Actor relations' FROM film_actor;

-- インデックスの再構築を推奨
SELECT 'OPTIMIZE TABLE film; を実行することをお勧めします' AS Recommendation;
