-- SQL: add `rarity` column to `user_swords` if missing
-- Run this in your database console if you want the `rarity` column present.

ALTER TABLE IF EXISTS user_swords
ADD COLUMN IF NOT EXISTS rarity VARCHAR(50);

-- Optionally set a default based on sword level/type using an UPDATE statement:
-- UPDATE user_swords SET rarity = CASE WHEN weapon_type = 'hidden' THEN 'legendary' WHEN sword_level >= 15 THEN 'epic' WHEN sword_level >= 10 THEN 'rare' ELSE 'common' END;
