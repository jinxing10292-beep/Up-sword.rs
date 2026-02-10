-- 미션 및 업적 데이터 추가

-- 1. missions 테이블에 key 컬럼 추가 (없는 경우)
ALTER TABLE missions ADD COLUMN IF NOT EXISTS key VARCHAR(100) UNIQUE;

-- 2. achievements 테이블에 key 컬럼 추가 (없는 경우)
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS key VARCHAR(100) UNIQUE;

-- 3. 인덱스 추가 (성능 최적화)
CREATE INDEX IF NOT EXISTS idx_missions_key ON missions(key);
CREATE INDEX IF NOT EXISTS idx_missions_active ON missions(active);
CREATE INDEX IF NOT EXISTS idx_achievements_key ON achievements(key);
CREATE INDEX IF NOT EXISTS idx_achievements_active ON achievements(active);
CREATE INDEX IF NOT EXISTS idx_user_missions_user_mission ON user_missions(user_id, mission_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_achievement ON user_achievements(user_id, achievement_id);

-- 4. 미션 데이터 삽입
INSERT INTO missions (key, title, description, target, reward_gold, active) VALUES
('enhance_success', '강화 성공', '검을 1회 강화 성공하세요', 1, 1000, true),
('enhance_10', '강화 10회', '검을 10회 강화 성공하세요', 10, 10000, true),
('enhance_50', '강화 50회', '검을 50회 강화 성공하세요', 50, 50000, true),
('enhance_100', '강화 100회', '검을 100회 강화 성공하세요', 100, 100000, true),
('defeat_dummy', '허수아비 격파', '허수아비를 1회 격파하세요', 1, 500, true),
('defeat_dummy_10', '허수아비 10회 격파', '허수아비를 10회 격파하세요', 10, 5000, true),
('defeat_dummy_50', '허수아비 50회 격파', '허수아비를 50회 격파하세요', 50, 25000, true),
('pvp_win', 'PvP 승리', 'PvP에서 1회 승리하세요', 1, 2000, true),
('pvp_win_10', 'PvP 10회 승리', 'PvP에서 10회 승리하세요', 10, 20000, true)
ON CONFLICT (key) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    target = EXCLUDED.target,
    reward_gold = EXCLUDED.reward_gold,
    active = EXCLUDED.active;

-- 5. 업적 데이터 삽입
INSERT INTO achievements (key, title, description, target, active) VALUES
('enhance_success', '첫 강화', '검을 처음으로 강화하세요', 1, true),
('enhance_10', '강화 마스터', '검을 10강까지 강화하세요', 1, true),
('enhance_15', '강화 전문가', '검을 15강까지 강화하세요', 1, true),
('enhance_20', '강화 신', '검을 20강까지 강화하세요', 1, true),
('defeat_dummy', '전투 입문', '첫 허수아비를 격파하세요', 1, true),
('defeat_dummy_10', '전투 숙련자', '허수아비를 10회 격파하세요', 10, true),
('defeat_dummy_50', '전투 마스터', '허수아비를 50회 격파하세요', 50, true),
('defeat_dummy_100', '전투의 신', '허수아비를 100회 격파하세요', 100, true),
('pvp_win', 'PvP 입문', 'PvP에서 첫 승리를 거두세요', 1, true),
('pvp_win_10', 'PvP 숙련자', 'PvP에서 10회 승리하세요', 10, true),
('pvp_win_50', 'PvP 마스터', 'PvP에서 50회 승리하세요', 50, true),
('hidden_sword', '히든 검 수집가', '히든 검을 획득하세요', 1, true),
('collection_10', '검 수집가', '10개의 검을 수집하세요', 10, true),
('collection_50', '검 컬렉터', '50개의 검을 수집하세요', 50, true),
('collection_100', '검 마스터', '100개의 검을 수집하세요', 100, true)
ON CONFLICT (key) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    target = EXCLUDED.target,
    active = EXCLUDED.active;

-- 6. 업적 마일스톤 데이터 삽입
INSERT INTO achievement_milestones (milestone_count, reward_gold, reward_money) VALUES
(5, 10000, 10),
(10, 25000, 25),
(15, 50000, 50),
(20, 100000, 100),
(30, 250000, 250),
(50, 500000, 500)
ON CONFLICT (milestone_count) DO UPDATE SET
    reward_gold = EXCLUDED.reward_gold,
    reward_money = EXCLUDED.reward_money;

-- 7. 주석 추가
COMMENT ON COLUMN missions.key IS '미션 고유 키 (코드에서 참조)';
COMMENT ON COLUMN missions.active IS '활성화 여부';
COMMENT ON COLUMN achievements.key IS '업적 고유 키 (코드에서 참조)';
COMMENT ON COLUMN achievements.active IS '활성화 여부';
