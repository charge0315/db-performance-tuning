-- ============================================
-- Filmデータを実際の洋画風に100倍に増やすスクリプト
-- ============================================
-- 元のfilm数: 1000件
-- 増加後: 100,000件
-- ============================================

USE sakila;

-- 一時的に外部キー制約を無効化
SET FOREIGN_KEY_CHECKS = 0;

-- 現在のfilm数を確認
SELECT COUNT(*) AS 'Before: Film count' FROM film;

-- 洋画のタイトルパターン用のテーブル作成
DROP TEMPORARY TABLE IF EXISTS title_patterns;
CREATE TEMPORARY TABLE title_patterns (
    pattern_id INT AUTO_INCREMENT PRIMARY KEY,
    prefix VARCHAR(50),
    suffix VARCHAR(50)
);

-- 実際の洋画風のタイトルパターンを挿入
INSERT INTO title_patterns (prefix, suffix) VALUES
('The Last', 'Warrior'), ('Dark', 'Knight'), ('Iron', 'Man'),
('The Amazing', 'Journey'), ('Secret', 'Garden'), ('Lost', 'City'),
('Rising', 'Sun'), ('Frozen', 'Heart'), ('Golden', 'Eagle'),
('Silver', 'Bullet'), ('Crimson', 'Tide'), ('Blue', 'Lagoon'),
('Green', 'Mile'), ('Black', 'Swan'), ('White', 'Fang'),
('Red', 'Dragon'), ('The Forgotten', 'Empire'), ('Hidden', 'Treasure'),
('Silent', 'Storm'), ('Thunder', 'Road'), ('Lightning', 'Strike'),
('Shadow', 'Hunter'), ('Crystal', 'Palace'), ('Diamond', 'Quest'),
('Midnight', 'Express'), ('Dawn', 'Patrol'), ('Twilight', 'Zone'),
('The Eternal', 'Legend'), ('Sacred', 'Ground'), ('Ancient', 'Mystery'),
('Mystic', 'River'), ('Wild', 'West'), ('The Great', 'Escape'),
('Final', 'Destination'), ('The Ultimate', 'Challenge'), ('Perfect', 'Storm'),
('The Incredible', 'Adventure'), ('Dangerous', 'Mission'), ('Deadly', 'Game'),
('The Magnificent', 'Seven'), ('Brave', 'Heart'), ('The Departed', 'Soul');

-- 100回繰り返してデータを複製（1000 × 100 = 100,000件）
-- バッチ処理で負荷を分散

DELIMITER $$

DROP PROCEDURE IF EXISTS multiply_films$$

CREATE PROCEDURE multiply_films()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_film_id INT;
    DECLARE random_year INT;
    DECLARE random_length INT;
    DECLARE random_rate DECIMAL(4,2);
    DECLARE random_rating VARCHAR(10);
    DECLARE ratings_array VARCHAR(100) DEFAULT 'G,PG,PG-13,R,NC-17';
    
    -- 元のfilm_idの最大値を取得
    SELECT MAX(film_id) INTO max_film_id FROM film;
    
    WHILE i <= 99 DO
        -- バッチごとにコミット
        START TRANSACTION;
        
        -- 既存のfilmレコードを複製（実際の洋画風にデータをバリエーション化）
        INSERT INTO film (
            title, 
            description, 
            release_year, 
            language_id, 
            original_language_id, 
            rental_duration, 
            rental_rate, 
            length, 
            replacement_cost, 
            rating, 
            special_features, 
            last_update
        )
        SELECT 
            -- タイトルをランダムなパターンで生成
            CONCAT(
                (SELECT prefix FROM title_patterns ORDER BY RAND() LIMIT 1),
                ' ',
                (SELECT suffix FROM title_patterns ORDER BY RAND() LIMIT 1),
                ' ', 
                CASE 
                    WHEN i % 10 = 0 THEN CONCAT('Part ', FLOOR(i/10))
                    WHEN i % 7 = 0 THEN 'Returns'
                    WHEN i % 5 = 0 THEN 'Reloaded'
                    WHEN i % 3 = 0 THEN 'Origins'
                    ELSE CONCAT('Vol.', i)
                END
            ) AS title,
            -- 説明文をバリエーション化
            CONCAT(
                description,
                CASE 
                    WHEN i % 4 = 0 THEN ' A thrilling epic adventure.'
                    WHEN i % 4 = 1 THEN ' A dramatic masterpiece.'
                    WHEN i % 4 = 2 THEN ' An action-packed journey.'
                    ELSE ' A captivating story.'
                END
            ) AS description,
            -- 公開年を1980-2024の範囲でランダム化
            1980 + FLOOR(RAND() * 45) AS release_year,
            language_id,
            original_language_id,
            -- レンタル期間を3-7日でランダム化
            3 + FLOOR(RAND() * 5) AS rental_duration,
            -- レンタル料を0.99-6.99でランダム化
            0.99 + FLOOR(RAND() * 60) / 10 AS rental_rate,
            -- 上映時間を80-180分でランダム化
            80 + FLOOR(RAND() * 101) AS length,
            -- 交換費用を9.99-29.99でランダム化
            9.99 + FLOOR(RAND() * 200) / 10 AS replacement_cost,
            -- レーティングをランダム化
            ELT(1 + FLOOR(RAND() * 5), 'G', 'PG', 'PG-13', 'R', 'NC-17') AS rating,
            special_features,
            NOW() AS last_update
        FROM film
        WHERE film_id <= max_film_id;
        
        COMMIT;
        
        -- 進捗表示
        SELECT CONCAT('進捗: ', i, '/99 (', ROUND(i/99*100, 1), '%)') AS Progress;
        
        SET i = i + 1;
        
        -- CPUへの負荷を軽減するため少し待機
        DO SLEEP(0.1);
    END WHILE;
    
    SELECT '処理完了！' AS Status;
END$$

DELIMITER ;

-- プロシージャを実行
CALL multiply_films();

-- プロシージャを削除
DROP PROCEDURE IF EXISTS multiply_films;

-- film_actorテーブルも複製（俳優との関連を維持）
-- 元のfilm_idの範囲を取得
SET @original_max_film_id = 1000;

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT 
    fa.actor_id,
    f.film_id AS new_film_id,
    NOW() AS last_update
FROM film_actor fa
INNER JOIN film f ON CONCAT(
    (SELECT title FROM film WHERE film_id = fa.film_id), 
    ' - Copy'
) LIKE CONCAT(f.title, '%')
WHERE fa.film_id <= @original_max_film_id
  AND f.film_id > @original_max_film_id
  AND NOT EXISTS (
    SELECT 1 FROM film_actor fa2 
    WHERE fa2.actor_id = fa.actor_id 
    AND fa2.film_id = f.film_id
  );

-- 外部キー制約を再有効化
SET FOREIGN_KEY_CHECKS = 1;

-- 結果を確認
SELECT COUNT(*) AS 'After: Film count' FROM film;
SELECT COUNT(*) AS 'After: Film-Actor relations' FROM film_actor;

-- インデックスの再構築を推奨
SELECT 'インデックス最適化のため、以下のコマンドを実行することを推奨します:' AS Note;
SELECT 'OPTIMIZE TABLE film;' AS Command;
SELECT 'OPTIMIZE TABLE film_actor;' AS Command2;

-- 統計情報の更新
ANALYZE TABLE film;
ANALYZE TABLE film_actor;
