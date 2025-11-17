-- ============================================
-- Customerデータを実在の人物名をモデルに100倍に増やすスクリプト
-- ============================================
-- 元のcustomer数: 599件
-- 増加後: 59,900件
-- ============================================

USE sakila;

-- 一時的に外部キー制約を無効化
SET FOREIGN_KEY_CHECKS = 0;

-- 現在のcustomer数を確認
SELECT COUNT(*) AS 'Before: Customer count' FROM customer;

-- customer_idをINT型に変更（SMALLINT上限65535対策）
ALTER TABLE customer 
  MODIFY COLUMN customer_id INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- 実在の人物のファーストネーム（多様性を持たせる）
DROP TABLE IF EXISTS customer_first_names;
CREATE TABLE customer_first_names (
    name VARCHAR(50)
);

INSERT INTO customer_first_names (name) VALUES
('James'), ('John'), ('Robert'), ('Michael'), ('William'),
('David'), ('Richard'), ('Joseph'), ('Thomas'), ('Charles'),
('Mary'), ('Patricia'), ('Jennifer'), ('Linda'), ('Barbara'),
('Elizabeth'), ('Susan'), ('Jessica'), ('Sarah'), ('Karen'),
('Daniel'), ('Matthew'), ('Anthony'), ('Mark'), ('Donald'),
('Steven'), ('Paul'), ('Andrew'), ('Joshua'), ('Kenneth'),
('Kevin'), ('Brian'), ('George'), ('Edward'), ('Ronald'),
('Timothy'), ('Jason'), ('Jeffrey'), ('Ryan'), ('Jacob'),
('Nancy'), ('Betty'), ('Margaret'), ('Sandra'), ('Ashley'),
('Dorothy'), ('Kimberly'), ('Emily'), ('Donna'), ('Michelle'),
('Carol'), ('Amanda'), ('Melissa'), ('Deborah'), ('Stephanie'),
('Rebecca'), ('Laura'), ('Sharon'), ('Cynthia'), ('Kathleen'),
('Christopher'), ('Eric'), ('Stephen'), ('Jonathan'), ('Larry'),
('Justin'), ('Scott'), ('Brandon'), ('Frank'), ('Benjamin'),
('Gregory'), ('Raymond'), ('Samuel'), ('Patrick'), ('Alexander'),
('Jack'), ('Dennis'), ('Jerry'), ('Tyler'), ('Aaron'),
('Helen'), ('Amy'), ('Shirley'), ('Angela'), ('Anna'),
('Brenda'), ('Pamela'), ('Nicole'), ('Ruth'), ('Katherine'),
('Samantha'), ('Christine'), ('Catherine'), ('Virginia'), ('Debra'),
('Rachel'), ('Carolyn'), ('Janet'), ('Maria'), ('Heather'),
('Diane'), ('Julie'), ('Joyce'), ('Victoria'), ('Kelly');

-- 実在の人物のラストネーム
DROP TABLE IF EXISTS customer_last_names;
CREATE TABLE customer_last_names (
    name VARCHAR(50)
);

INSERT INTO customer_last_names (name) VALUES
('Smith'), ('Johnson'), ('Williams'), ('Brown'), ('Jones'),
('Garcia'), ('Miller'), ('Davis'), ('Rodriguez'), ('Martinez'),
('Hernandez'), ('Lopez'), ('Gonzalez'), ('Wilson'), ('Anderson'),
('Thomas'), ('Taylor'), ('Moore'), ('Jackson'), ('Martin'),
('Lee'), ('Perez'), ('Thompson'), ('White'), ('Harris'),
('Sanchez'), ('Clark'), ('Ramirez'), ('Lewis'), ('Robinson'),
('Walker'), ('Young'), ('Allen'), ('King'), ('Wright'),
('Scott'), ('Torres'), ('Nguyen'), ('Hill'), ('Flores'),
('Green'), ('Adams'), ('Nelson'), ('Baker'), ('Hall'),
('Rivera'), ('Campbell'), ('Mitchell'), ('Carter'), ('Roberts'),
('Gomez'), ('Phillips'), ('Evans'), ('Turner'), ('Diaz'),
('Parker'), ('Cruz'), ('Edwards'), ('Collins'), ('Reyes'),
('Stewart'), ('Morris'), ('Morales'), ('Murphy'), ('Cook'),
('Rogers'), ('Gutierrez'), ('Ortiz'), ('Morgan'), ('Cooper'),
('Peterson'), ('Bailey'), ('Reed'), ('Kelly'), ('Howard'),
('Ramos'), ('Kim'), ('Cox'), ('Ward'), ('Richardson'),
('Watson'), ('Brooks'), ('Chavez'), ('Wood'), ('James'),
('Bennett'), ('Gray'), ('Mendoza'), ('Ruiz'), ('Hughes'),
('Price'), ('Alvarez'), ('Castillo'), ('Sanders'), ('Patel'),
('Myers'), ('Long'), ('Ross'), ('Foster'), ('Jimenez');

-- メールドメイン
DROP TABLE IF EXISTS email_domains;
CREATE TABLE email_domains (
    domain VARCHAR(50)
);

INSERT INTO email_domains (domain) VALUES
('gmail.com'), ('yahoo.com'), ('hotmail.com'), ('outlook.com'),
('icloud.com'), ('aol.com'), ('mail.com'), ('protonmail.com');

-- 100回繰り返してデータを複製
DELIMITER $$

DROP PROCEDURE IF EXISTS multiply_customers$$

CREATE PROCEDURE multiply_customers()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE original_count INT;
    DECLARE new_first_name VARCHAR(50);
    DECLARE new_last_name VARCHAR(50);
    DECLARE new_email VARCHAR(100);
    DECLARE email_domain VARCHAR(50);
    
    -- 元のcustomer数を取得
    SELECT COUNT(*) INTO original_count FROM customer;
    
    WHILE i <= 99 DO
        -- 元のcustomerデータから複製し、名前とメールをランダムに変更
        INSERT INTO customer (
            first_name,
            last_name,
            email,
            active,
            create_date,
            last_update
        )
        SELECT 
            (SELECT name FROM customer_first_names ORDER BY RAND() LIMIT 1) AS first_name,
            (SELECT name FROM customer_last_names ORDER BY RAND() LIMIT 1) AS last_name,
            LOWER(CONCAT(
                (SELECT name FROM customer_first_names ORDER BY RAND() LIMIT 1),
                '.',
                (SELECT name FROM customer_last_names ORDER BY RAND() LIMIT 1),
                FLOOR(RAND() * 1000),
                '@',
                (SELECT domain FROM email_domains ORDER BY RAND() LIMIT 1)
            )) AS email,
            CASE WHEN RAND() < 0.95 THEN 1 ELSE 0 END AS active,
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) AS create_date,
            NOW() AS last_update
        FROM customer
        WHERE customer_id <= original_count
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
CALL multiply_customers();

-- プロシージャを削除
DROP PROCEDURE IF EXISTS multiply_customers;

-- 外部キー制約を再有効化
SET FOREIGN_KEY_CHECKS = 1;

-- 一時テーブルを削除
DROP TABLE IF EXISTS customer_first_names;
DROP TABLE IF EXISTS customer_last_names;
DROP TABLE IF EXISTS email_domains;

-- 結果を確認
SELECT COUNT(*) AS 'After: Customer count' FROM customer;
SELECT COUNT(*) AS 'Active customers' FROM customer WHERE active = 1;
SELECT COUNT(*) AS 'Inactive customers' FROM customer WHERE active = 0;

-- インデックスの最適化を推奨
SELECT 'OPTIMIZE TABLE customer; を実行することをお勧めします' AS Recommendation;
