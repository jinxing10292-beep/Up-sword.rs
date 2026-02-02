# 검 강화 시스템 개선 사항

## 📋 추가된 기능들

### 1. 강화석 시스템 ⭐
**개념:** 다양한 등급의 강화석으로 성공률 증가

**구현 방법:**
```javascript
// shop.html 또는 items.html에 추가할 아이템들
const ENHANCEMENT_STONES = {
    'stone_basic': { 
        name: '기본 강화석', 
        icon: '💎',
        successBonus: 5,  // +5% 성공률
        price: 500,
        description: '성공률 +5%'
    },
    'stone_advanced': { 
        name: '고급 강화석', 
        icon: '💠',
        successBonus: 10,  // +10% 성공률
        price: 1500,
        description: '성공률 +10%'
    },
    'stone_premium': { 
        name: '프리미엄 강화석', 
        icon: '💫',
        successBonus: 20,  // +20% 성공률
        price: 5000,
        description: '성공률 +20%'
    }
};

// handleUpgrade() 함수에 추가
function applyEnhancementStone() {
    if (user.active_stone) {
        const stone = ENHANCEMENT_STONES[user.active_stone];
        rates.success += stone.successBonus;
        // 사용 후 제거
        user.active_stone = null;
    }
}
```

### 2. 축복/저주 방지 시스템 🛡️
**개념:** 실패 시 보호 효과

**구현 방법:**
```javascript
const PROTECTION_ITEMS = {
    'blessing_powder': {
        name: '축복의 가루',
        icon: '✨',
        effect: 'prevent_destroy',  // 파괴 방지
        price: 2000,
        description: '강화 실패 시 파괴 방지 (레벨 유지)'
    },
    'curse_prevention': {
        name: '저주 방지권',
        icon: '🔮',
        effect: 'prevent_downgrade',  // 하락 방지
        price: 1000,
        description: '강화 실패 시 레벨 하락 방지'
    },
    'safety_net': {
        name: '안전망',
        icon: '🪂',
        effect: 'return_to_safe',  // 안전 레벨로 복귀
        safeLevel: 10,
        price: 3000,
        description: '파괴 시 10강으로 복귀'
    }
};

// handleUpgrade()에서 파괴 처리 부분 수정
if (result === 'destroy') {
    if (user.active_protection === 'blessing_powder') {
        // 파괴 방지, 레벨 유지
        newLevel = currentLevel;
        message = "강화 실패! (축복의 가루로 파괴 방지)";
        user.active_protection = null;
    } else if (user.active_protection === 'safety_net') {
        // 10강으로 복귀
        newLevel = 10;
        message = "강화 실패! (안전망으로 10강 복귀)";
        user.active_protection = null;
    } else {
        // 기존 파괴 로직
        newLevel = 0;
        message = "강화 실패! (검 파괴)";
    }
}
```

### 3. 연속 강화 콤보 시스템 🔥
**개념:** 연속 성공 시 보너스 골드 지급

**구현 방법:**
```javascript
// 전역 변수 추가
let comboCount = 0;
let comboMultiplier = 1.0;

// handleUpgrade() 성공 시
if (result === 'success') {
    comboCount++;
    comboMultiplier = 1 + (comboCount * 0.1); // 10%씩 증가
    
    const bonusGold = Math.floor(upgradeCost * comboMultiplier);
    user.gold += bonusGold;
    
    message = `강화 성공! [+${newLevel}레벨] 🔥 ${comboCount}콤보! (+${bonusGold}G 보너스)`;
    
    // 콤보 UI 표시
    showComboEffect(comboCount);
} else {
    // 실패 시 콤보 초기화
    comboCount = 0;
    comboMultiplier = 1.0;
}

function showComboEffect(combo) {
    if (combo < 3) return; // 3콤보부터 표시
    
    const comboEl = document.createElement('div');
    comboEl.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-size: 48px;
        font-weight: 900;
        color: #ff6b6b;
        text-shadow: 0 0 20px rgba(255, 107, 107, 0.8);
        animation: comboAnim 1s ease-out;
        z-index: 1000;
        pointer-events: none;
    `;
    comboEl.textContent = `🔥 ${combo} COMBO! 🔥`;
    document.body.appendChild(comboEl);
    
    setTimeout(() => comboEl.remove(), 1000);
}
```

### 4. 강화 히스토리 UI 📊
**개념:** 최근 10번의 강화 결과 표시

**HTML 추가:**
```html
<!-- sword.html의 info-area 아래에 추가 -->
<div class="history-panel" style="margin: 20px; padding: 15px; background: #f8fafc; border-radius: 12px;">
    <h3 style="font-size: 14px; font-weight: 700; margin-bottom: 10px; color: #2d3748;">
        📊 최근 강화 기록
    </h3>
    <div id="enhanceHistory" style="display: flex; gap: 5px; flex-wrap: wrap;">
        <!-- 동적으로 추가됨 -->
    </div>
</div>
```

**JavaScript:**
```javascript
let enhanceHistory = [];

function addToHistory(result) {
    enhanceHistory.unshift(result); // 맨 앞에 추가
    if (enhanceHistory.length > 10) {
        enhanceHistory.pop(); // 10개 초과 시 제거
    }
    renderHistory();
}

function renderHistory() {
    const historyEl = document.getElementById('enhanceHistory');
    historyEl.innerHTML = enhanceHistory.map(result => {
        const color = result === 'success' ? '#48bb78' : 
                     result === 'destroy' ? '#f56565' : '#cbd5e0';
        const icon = result === 'success' ? '✓' : 
                    result === 'destroy' ? '✗' : '−';
        
        return `
            <div style="
                width: 30px;
                height: 30px;
                background: ${color};
                color: white;
                border-radius: 6px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: 16px;
            ">${icon}</div>
        `;
    }).join('');
}

// handleUpgrade()에서 호출
addToHistory(result);
```

### 5. 이벤트 타임 시스템 ⏰
**개념:** 특정 시간대 성공률 2배

**구현 방법:**
```javascript
function isEventTime() {
    const now = new Date();
    const hour = now.getHours();
    
    // 이벤트 시간: 12시~13시, 20시~21시
    return (hour >= 12 && hour < 13) || (hour >= 20 && hour < 21);
}

function getEventMultiplier() {
    return isEventTime() ? 2.0 : 1.0;
}

// handleUpgrade()에서 성공률 계산 시
if (isEventTime()) {
    rates.success *= 2;
    rates.success = Math.min(rates.success, 100); // 최대 100%
    
    // 이벤트 표시
    showEventBanner();
}

function showEventBanner() {
    const banner = document.getElementById('eventBanner');
    if (!banner) {
        const newBanner = document.createElement('div');
        newBanner.id = 'eventBanner';
        newBanner.style.cssText = `
            position: fixed;
            top: 10px;
            left: 50%;
            transform: translateX(-50%);
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 10px 20px;
            border-radius: 20px;
            font-weight: 700;
            z-index: 1000;
            animation: pulse 2s infinite;
        `;
        newBanner.textContent = '⚡ 이벤트 타임! 성공률 2배! ⚡';
        document.body.appendChild(newBanner);
    }
}
```

### 6. 개선된 애니메이션 ✨
**개념:** 더 화려한 강화 이펙트

**CSS 추가:**
```css
@keyframes successGlow {
    0% { 
        filter: drop-shadow(0 0 0 rgba(72, 187, 120, 0));
        transform: scale(1);
    }
    50% { 
        filter: drop-shadow(0 0 30px rgba(72, 187, 120, 1));
        transform: scale(1.1);
    }
    100% { 
        filter: drop-shadow(0 0 0 rgba(72, 187, 120, 0));
        transform: scale(1);
    }
}

@keyframes failShake {
    0%, 100% { transform: translateX(0); }
    10%, 30%, 50%, 70%, 90% { transform: translateX(-10px); }
    20%, 40%, 60%, 80% { transform: translateX(10px); }
}

@keyframes destroyExplode {
    0% { 
        opacity: 1;
        transform: scale(1) rotate(0deg);
    }
    50% {
        opacity: 0.5;
        transform: scale(1.5) rotate(180deg);
    }
    100% { 
        opacity: 0;
        transform: scale(0) rotate(360deg);
    }
}

.success-effect {
    animation: successGlow 1s ease-out;
}

.fail-effect {
    animation: failShake 0.5s ease-out;
}

.destroy-effect {
    animation: destroyExplode 1s ease-out;
}
```

**JavaScript:**
```javascript
function playEnhanceAnimation(result) {
    const img = document.getElementById('s-img');
    
    // 기존 애니메이션 제거
    img.className = 'sword-img';
    
    // 새 애니메이션 추가
    setTimeout(() => {
        if (result === 'success') {
            img.classList.add('success-effect');
            createParticles('success');
        } else if (result === 'destroy') {
            img.classList.add('destroy-effect');
            createParticles('destroy');
        } else {
            img.classList.add('fail-effect');
        }
    }, 10);
}

function createParticles(type) {
    const colors = type === 'success' ? 
        ['#48bb78', '#38a169', '#2f855a'] : 
        ['#f56565', '#e53e3e', '#c53030'];
    
    for (let i = 0; i < 20; i++) {
        const particle = document.createElement('div');
        particle.style.cssText = `
            position: fixed;
            width: 10px;
            height: 10px;
            background: ${colors[Math.floor(Math.random() * colors.length)]};
            border-radius: 50%;
            pointer-events: none;
            z-index: 1000;
            left: 50%;
            top: 50%;
        `;
        
        document.body.appendChild(particle);
        
        const angle = (Math.PI * 2 * i) / 20;
        const velocity = 100 + Math.random() * 100;
        const tx = Math.cos(angle) * velocity;
        const ty = Math.sin(angle) * velocity;
        
        particle.animate([
            { transform: 'translate(0, 0)', opacity: 1 },
            { transform: `translate(${tx}px, ${ty}px)`, opacity: 0 }
        ], {
            duration: 1000,
            easing: 'cubic-bezier(0, 0.5, 0.5, 1)'
        }).onfinish = () => particle.remove();
    }
}
```

## 🎯 통합 구현 순서

1. **shop.html에 새 아이템 추가** (강화석, 보호 아이템)
2. **user_items 테이블에 새 아이템 타입 추가**
3. **sword.html의 handleUpgrade() 함수 수정**
4. **히스토리 UI 추가**
5. **이벤트 타임 체크 로직 추가**
6. **애니메이션 CSS 추가**

## 📝 데이터베이스 스키마 추가

```sql
-- user_items 테이블에 새 아이템 추가 (이미 있다면 스킵)
-- 강화석
INSERT INTO items (item_id, name, description, price, category) VALUES
('stone_basic', '기본 강화석', '성공률 +5%', 500, 'enhancement'),
('stone_advanced', '고급 강화석', '성공률 +10%', 1500, 'enhancement'),
('stone_premium', '프리미엄 강화석', '성공률 +20%', 5000, 'enhancement');

-- 보호 아이템
INSERT INTO items (item_id, name, description, price, category) VALUES
('blessing_powder', '축복의 가루', '파괴 방지', 2000, 'protection'),
('curse_prevention', '저주 방지권', '레벨 하락 방지', 1000, 'protection'),
('safety_net', '안전망', '파괴 시 10강 복귀', 3000, 'protection');

-- profiles 테이블에 컬럼 추가
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS active_stone TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS active_protection TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS combo_count INTEGER DEFAULT 0;
```

## 🎨 UI 개선 제안

1. **강화 버튼 위에 활성 아이템 표시**
2. **콤보 카운터 실시간 표시**
3. **이벤트 타임 배너**
4. **강화 히스토리 그래프**
5. **성공률 시각화 (프로그레스 바)**

이 문서를 참고하여 단계적으로 구현하시면 됩니다!
