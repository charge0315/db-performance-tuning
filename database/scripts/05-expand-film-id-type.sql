-- ============================================
-- film_idをSMALLINTからINTに変更して100,000件対応
-- ============================================

USE sakila;

-- 外部キー制約を一時的に無効化
SET FOREIGN_KEY_CHECKS = 0;

-- film_actorテーブルのfilm_idカラムを変更
ALTER TABLE film_actor 
  MODIFY COLUMN film_id INT UNSIGNED NOT NULL;

-- filmテーブルのfilm_idカラムを変更
ALTER TABLE film 
  MODIFY COLUMN film_id INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- 外部キー制約を再有効化
SET FOREIGN_KEY_CHECKS = 1;

SELECT 'film_idをINT UNSIGNEDに変更しました。最大値: 4,294,967,295' AS Status;

