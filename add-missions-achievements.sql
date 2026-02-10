-- 미션 및 업적 데이터 추가

-- 1. missions 테이블에 필요한 컬럼 추가
ALTER TABLE missions ADD COLUMN IF NOT EXISTS key VARCHAR(100) UNIQUE;
ALTER TABLE missions ADD COLUMN IF NOT EXISTS name VARCHAR(200);
ALTER TABLE missions ADD COLUMN IF NOT EXISTS title VARCHAR(200);
ALTER TABLE missions ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE missions ADD COLUMN IF NOT EXISTS condition_type VARCHAR(100);
ALTER TABLE missions ADD COLUMN IF NOT EXISTS condition_value INTEGER;
ALTER TABLE missions ADD COLUMN IF NOT EXISTS target INTEGER DEFAULT 1 NOT NULL;
ALTER TABLE missions ADD COLUMN IF NOT EXISTS target_value INTEGER DEFAULT 1 NOT NULL;
ALTER TABLE missions ADD COLUMN IF NOT EXISTS reward_gold INTEGER DEFAULT 0 NOT NULL;
ALTER TABLE missions ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true NOT NULL;
ALTER TABLE missions ADD COLUMN IF NOT EXISTS mission_type VARCHAR(50) DEFAULT 'daily' NOT NULL;

-- 2. achievements 테이블에 필요한 컬럼 추가
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS key VARCHAR(100) UNIQUE;
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS name VARCHAR(200);
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS title VARCHAR(200);
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS condition_type VARCHAR(100);
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS condition_value INTEGER;
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS target INTEGER DEFAULT 1 NOT NULL;
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS target_value INTEGER DEFAULT 1 NOT NULL;
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true NOT NULL;

-- 3. user_missions 테이블에 필요한 컬럼 추가
ALTER TABLE user_missions ADD COLUMN IF NOT EXISTS progress INTEGER DEFAULT 0 NOT NULL;
ALTER TABLE user_missions ADD COLUMN IF NOT EXISTS completed BOOLEAN DEFAULT false NOT NULL;
ALTER TABLE user_missions ADD COLUMN IF NOT EXISTS claimed BOOLEAN DEFAULT false NOT NULL;

-- 4. user_achievements 테이블에 필요한 컬럼 추가
ALTER TABLE user_achievements ADD COLUMN IF NOT EXISTS progress INTEGER DEFAULT 0 NOT NULL;
ALTER TABLE user_achievements ADD COLUMN IF NOT EXISTS unlocked BOOLEAN DEFAULT false NOT NULL;
ALTER TABLE user_achievements ADD COLUMN IF NOT EXISTS completed BOOLEAN DEFAULT false NOT NULL;

-- 5. 인덱스 추가 (성능 최적화)
CREATE INDEX IF NOT EXISTS idx_missions_key ON missions(key);
CREATE INDEX IF NOT EXISTS idx_missions_active ON missions(active);
CREATE INDEX IF NOT EXISTS idx_achievements_key ON achievements(key);
CREATE INDEX IF NOT EXISTS idx_achievements_active ON achievements(active);
CREATE INDEX IF NOT EXISTS idx_user_missions_user_mission ON user_missions(user_id, mission_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_achievement ON user_achievements(user_id, achievement_id);

-- 6. 미션 데이터 삽입
INSERT INTO missions (key, name, title, description, condition_type, condition_value, target, target_value, reward_gold, active, mission_type) VALUES
('enhance_success', '강화 성공', '강화 성공', '검을 1회 강화 성공하세요', 'enhance', 1, 1, 1, 1000, true, 'daily'),
('enhance_10', '강화 10회', '강화 10회', '검을 10회 강화 성공하세요', 'enhance', 10, 10, 10, 10000, true, 'weekly'),
('enhance_50', '강화 50회', '강화 50회', '검을 50회 강화 성공하세요', 'enhance', 50, 50, 50, 50000, true, 'achievement'),
('enhance_100', '강화 100회', '강화 100회', '검을 100회 강화 성공하세요', 'enhance', 100, 100, 100, 100000, true, 'achievement'),
('defeat_dummy', '허수아비 격파', '허수아비 격파', '허수아비를 1회 격파하세요', 'defeat_dummy', 1, 1, 1, 500, true, 'daily'),
('defeat_dummy_10', '허수아비 10회 격파', '허수아비 10회 격파', '허수아비를 10회 격파하세요', 'defeat_dummy', 10, 10, 10, 5000, true, 'weekly'),
('defeat_dummy_50', '허수아비 50회 격파', '허수아비 50회 격파', '허수아비를 50회 격파하세요', 'defeat_dummy', 50, 50, 50, 25000, true, 'achievement'),
('pvp_win', 'PvP 승리', 'PvP 승리', 'PvP에서 1회 승리하세요', 'pvp_win', 1, 1, 1, 2000, true, 'daily'),
('pvp_win_10', 'PvP 10회 승리', 'PvP 10회 승리', 'PvP에서 10회 승리하세요', 'pvp_win', 10, 10, 10, 20000, true, 'weekly')
ON CONFLICT (key) DO UPDATE SET
    name = EXCLUDED.name,
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    condition_type = EXCLUDED.condition_type,
    condition_value = EXCLUDED.condition_value,
    target = EXCLUDED.target,
    target_value = EXCLUDED.target_value,
    reward_gold = EXCLUDED.reward_gold,
    active = EXCLUDED.active,
    mission_type = EXCLUDED.mission_type;

-- 7. 업적 데이터 삽입
INSERT INTO achievements (key, name, title, description, condition_type, condition_value, target, target_value, active) VALUES
('enhance_success', '첫 강화', '첫 강화', '검을 처음으로 강화하세요', 'enhance', 1, 1, 1, true),
('enhance_10', '강화 마스터', '강화 마스터', '검을 10강까지 강화하세요', 'enhance_level', 10, 1, 1, true),
('enhance_15', '강화 전문가', '강화 전문가', '검을 15강까지 강화하세요', 'enhance_level', 15, 1, 1, true),
('enhance_20', '강화 신', '강화 신', '검을 20강까지 강화하세요', 'enhance_level', 20, 1, 1, true),
('defeat_dummy', '전투 입문', '전투 입문', '첫 허수아비를 격파하세요', 'defeat_dummy', 1, 1, 1, true),
('defeat_dummy_10', '전투 숙련자', '전투 숙련자', '허수아비를 10회 격파하세요', 'defeat_dummy', 10, 10, 10, true),
('defeat_dummy_50', '전투 마스터', '전투 마스터', '허수아비를 50회 격파하세요', 'defeat_dummy', 50, 50, 50, true),
('defeat_dummy_100', '전투의 신', '전투의 신', '허수아비를 100회 격파하세요', 'defeat_dummy', 100, 100, 100, true),
('pvp_win', 'PvP 입문', 'PvP 입문', 'PvP에서 첫 승리를 거두세요', 'pvp_win', 1, 1, 1, true),
('pvp_win_10', 'PvP 숙련자', 'PvP 숙련자', 'PvP에서 10회 승리하세요', 'pvp_win', 10, 10, 10, true),
('pvp_win_50', 'PvP 마스터', 'PvP 마스터', 'PvP에서 50회 승리하세요', 'pvp_win', 50, 50, 50, true),
('hidden_sword', '히든 검 수집가', '히든 검 수집가', '히든 검을 획득하세요', 'hidden_sword', 1, 1, 1, true),
('collection_10', '검 수집가', '검 수집가', '10개의 검을 수집하세요', 'collection', 10, 10, 10, true),
('collection_50', '검 컬렉터', '검 컬렉터', '50개의 검을 수집하세요', 'collection', 50, 50, 50, true),
('collection_100', '검 마스터', '검 마스터', '100개의 검을 수집하세요', 'collection', 100, 100, 100, true)
ON CONFLICT (key) DO UPDATE SET
    name = EXCLUDED.name,
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    condition_type = EXCLUDED.condition_type,
    condition_value = EXCLUDED.condition_value,
    target = EXCLUDED.target,
    target_value = EXCLUDED.target_value,
    active = EXCLUDED.active;

-- 8. 업적 마일스톤 데이터 삽입
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

-- 9. 주석 추가
COMMENT ON COLUMN missions.key IS '미션 고유 키 (코드에서 참조)';
COMMENT ON COLUMN missions.target IS '목표 달성 수치';
COMMENT ON COLUMN missions.target_value IS '목표 값 (target과 동일, NOT NULL 제약)';
COMMENT ON COLUMN missions.reward_gold IS '보상 골드';
COMMENT ON COLUMN missions.active IS '활성화 여부';
COMMENT ON COLUMN missions.mission_type IS '미션 타입 (daily, weekly, achievement)';
COMMENT ON COLUMN achievements.key IS '업적 고유 키 (코드에서 참조)';
COMMENT ON COLUMN achievements.target IS '목표 달성 수치';
COMMENT ON COLUMN achievements.target_value IS '목표 값 (target과 동일, NOT NULL 제약)';
COMMENT ON COLUMN achievements.active IS '활성화 여부';
COMMENT ON COLUMN user_missions.progress IS '현재 진행도';
COMMENT ON COLUMN user_missions.completed IS '완료 여부';
COMMENT ON COLUMN user_missions.claimed IS '보상 수령 여부';
COMMENT ON COLUMN user_achievements.progress IS '현재 진행도';
COMMENT ON COLUMN user_achievements.unlocked IS '잠금 해제 여부';
COMMENT ON COLUMN user_achievements.completed IS '완료 여부 (호환성)';
