-- ============================================
-- Actorデータを実在の俳優名をモデルに100倍に増やすスクリプト
-- ============================================
-- 元のactor数: 200件
-- 増加後: 20,000件
-- ============================================

USE sakila;

-- 一時的に外部キー制約を無効化
SET FOREIGN_KEY_CHECKS = 0;

-- 現在のactor数を確認
SELECT COUNT(*) AS 'Before: Actor count' FROM actor;

-- actor_idをINT型に変更（SMALLINT上限65535対策）
ALTER TABLE film_actor 
  MODIFY COLUMN actor_id INT UNSIGNED NOT NULL;

ALTER TABLE actor 
  MODIFY COLUMN actor_id INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- 実在の俳優のファーストネーム
DROP TABLE IF EXISTS actor_first_names;
CREATE TABLE actor_first_names (
    name VARCHAR(50)
);

INSERT INTO actor_first_names (name) VALUES
('Tom'), ('Brad'), ('Leonardo'), ('Johnny'), ('Robert'),
('Chris'), ('Scarlett'), ('Jennifer'), ('Angelina'), ('Matt'),
('Ryan'), ('George'), ('Will'), ('Denzel'), ('Samuel'),
('Morgan'), ('Keanu'), ('Harrison'), ('Hugh'), ('Christian'),
('Mark'), ('Ben'), ('Jake'), ('Natalie'), ('Emma'),
('Anne'), ('Sandra'), ('Julia'), ('Meryl'), ('Cate'),
('Nicole'), ('Charlize'), ('Kate'), ('Margot'), ('Amy'),
('Jessica'), ('Michelle'), ('Reese'), ('Cameron'), ('Drew'),
('Michael'), ('Daniel'), ('Russell'), ('Tom'), ('Colin'),
('Jude'), ('Ewan'), ('Orlando'), ('Viggo'), ('Ian'),
('Anthony'), ('Gary'), ('Ralph'), ('Alan'), ('Patrick'),
('Sean'), ('Pierce'), ('Liam'), ('Gerard'), ('Clive');

-- 実在の俳優のラストネーム
DROP TABLE IF EXISTS actor_last_names;
CREATE TABLE actor_last_names (
    name VARCHAR(50)
);

INSERT INTO actor_last_names (name) VALUES
('Cruise'), ('Pitt'), ('DiCaprio'), ('Depp'), ('Downey'),
('Hemsworth'), ('Johansson'), ('Lawrence'), ('Jolie'), ('Damon'),
('Gosling'), ('Clooney'), ('Smith'), ('Washington'), ('Jackson'),
('Freeman'), ('Reeves'), ('Ford'), ('Jackman'), ('Bale'),
('Wahlberg'), ('Affleck'), ('Gyllenhaal'), ('Portman'), ('Watson'),
('Hathaway'), ('Bullock'), ('Roberts'), ('Streep'), ('Blanchett'),
('Kidman'), ('Theron'), ('Winslet'), ('Robbie'), ('Adams'),
('Chastain'), ('Williams'), ('Witherspoon'), ('Diaz'), ('Barrymore'),
('Fassbender'), ('Craig'), ('Crowe'), ('Hanks'), ('Firth'),
('Law'), ('McGregor'), ('Bloom'), ('Mortensen'), ('McKellen'),
('Hopkins'), ('Oldman'), ('Fiennes'), ('Rickman'), ('Stewart'),
('Connery'), ('Brosnan'), ('Neeson'), ('Butler'), ('Owen');

-- 100回繰り返してデータを複製
DELIMITER $$

DROP PROCEDURE IF EXISTS multiply_actors$$

CREATE PROCEDURE multiply_actors()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE original_count INT;
    
    -- 元のactor数を取得
    SELECT COUNT(*) INTO original_count FROM actor;
    
    WHILE i <= 99 DO
        -- 元のactorデータから複製し、名前をランダムに変更
        INSERT INTO actor (first_name, last_name, last_update)
        SELECT 
            (SELECT name FROM actor_first_names ORDER BY RAND() LIMIT 1) AS first_name,
            (SELECT name FROM actor_last_names ORDER BY RAND() LIMIT 1) AS last_name,
            NOW() AS last_update
        FROM actor
        WHERE actor_id <= original_count
        LIMIT original_count;
        
        SET i = i + 1;
        SELECT CONCAT('進捗: ', i, '/99 (', ROUND(i/99*100, 1), '%)') AS Progress;
        
        -- CPUへの負荷を軽減するため少し待機
        DO SLEEP(0.05);
    END WHILE;
    
    SELECT '処理完了！' AS Status;
END$$

DELIMITER ;

-- プロシージャを実行
CALL multiply_actors();

-- プロシージャを削除
DROP PROCEDURE IF EXISTS multiply_actors;

-- film_actorテーブルも複製（映画との関連を維持）
INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT 
    a.actor_id,
    fa_original.film_id,
    NOW()
FROM actor a
CROSS JOIN (
    SELECT DISTINCT film_id 
    FROM film_actor 
    WHERE actor_id <= 200
    ORDER BY RAND()
    LIMIT 5
) fa_original
WHERE a.actor_id > 200
  AND NOT EXISTS (
    SELECT 1 FROM film_actor fa2 
    WHERE fa2.actor_id = a.actor_id 
    AND fa2.film_id = fa_original.film_id
  )
LIMIT 100000;

-- 外部キー制約を再有効化
SET FOREIGN_KEY_CHECKS = 1;

-- 一時テーブルを削除
DROP TABLE IF EXISTS actor_first_names;
DROP TABLE IF EXISTS actor_last_names;

-- 結果を確認
SELECT COUNT(*) AS 'After: Actor count' FROM actor;
SELECT COUNT(*) AS 'After: Film-Actor relations' FROM film_actor;

-- インデックスの最適化を推奨
SELECT 'OPTIMIZE TABLE actor; OPTIMIZE TABLE film_actor; を実行することをお勧めします' AS Recommendation;
