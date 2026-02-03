# GM 페이지 보안 설정 가이드

## 🔒 구현된 보안 기능

### 1. Supabase Authentication
- 이메일/비밀번호 기반 인증
- 승인된 이메일만 GM 페이지 접근 가능
- 세션 기반 인증 (1시간 자동 만료)

### 2. 다층 보안 체크
- ✅ Supabase 세션 검증
- ✅ 승인된 이메일 화이트리스트
- ✅ 세션 타임아웃 (1시간)
- ✅ 주기적 세션 유효성 검사 (5분마다)

---

## 📋 설정 방법

### Step 1: Supabase에서 GM 계정 생성

1. **Supabase Dashboard** 접속
   - https://supabase.com/dashboard

2. **Authentication > Users** 메뉴로 이동

3. **"Add user"** 버튼 클릭

4. GM 계정 정보 입력:
   ```
   Email: your-email@example.com
   Password: 강력한 비밀번호 (최소 8자)
   Auto Confirm User: ✅ 체크 (이메일 인증 생략)
   ```

5. **Create user** 클릭

### Step 2: 코드에 이메일 추가

**gm-login.html** 파일 수정:
```javascript
const APPROVED_GM_EMAILS = [
    'your-email@example.com',  // ← 여기에 본인 이메일 입력
    'admin@codetbase.com'
];
```

**gm.html** 파일도 동일하게 수정:
```javascript
const APPROVED_GM_EMAILS = [
    'your-email@example.com',  // ← 여기에 본인 이메일 입력
    'admin@codetbase.com'
];
```

### Step 3: Supabase RLS 정책 설정 (선택사항, 강력 권장)

Supabase Dashboard > SQL Editor에서 실행:

```sql
-- 1. profiles 테이블 RLS 활성화
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 2. GM 이메일만 모든 데이터 조회/수정 가능
CREATE POLICY "GM can view all profiles"
ON profiles FOR SELECT
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'your-email@example.com',
    'admin@codetbase.com'
  )
);

CREATE POLICY "GM can update all profiles"
ON profiles FOR UPDATE
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'your-email@example.com',
    'admin@codetbase.com'
  )
);

-- 3. 일반 사용자는 자기 데이터만 조회 가능
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id);
```

### Step 4: 추가 보안 설정 (선택사항)

#### A. 이메일 인증 강제
Supabase Dashboard > Authentication > Settings:
- **Enable email confirmations**: ON

#### B. 비밀번호 정책 강화
- **Minimum password length**: 12
- **Require uppercase**: ON
- **Require lowercase**: ON
- **Require numbers**: ON
- **Require special characters**: ON

#### C. Rate Limiting
Supabase Dashboard > Authentication > Rate Limits:
- **Login attempts**: 5 per hour

---

## 🚀 사용 방법

### 로그인
1. `gm-login.html` 페이지 접속
2. Supabase에 등록한 이메일/비밀번호 입력
3. 로그인 성공 시 자동으로 `gm.html`로 이동

### 로그아웃
- GM 페이지 우측 상단 "로그아웃" 버튼 클릭
- 자동으로 세션 종료 및 로그인 페이지로 이동

### 세션 만료
- 로그인 후 1시간 경과 시 자동 로그아웃
- 5분마다 세션 유효성 자동 체크

---

## 🛡️ 보안 강화 팁

### 1. 환경 변수 사용 (GitHub에 올릴 때)
현재 Supabase URL과 Key가 코드에 하드코딩되어 있습니다.
GitHub에 올릴 때는 별도 설정 파일로 분리하세요:

**supabase-config.js** (이미 있음):
```javascript
const SUPABASE_CONFIG = {
    url: 'https://blkghenrfizqjfigvkql.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
};
```

**.gitignore**에 추가:
```
supabase-config.js
```

### 2. IP 화이트리스트 (Supabase Pro 이상)
특정 IP에서만 접근 가능하도록 제한

### 3. 2FA (Two-Factor Authentication)
Supabase에서 2FA 활성화 (Pro 플랜)

### 4. 로그 모니터링
Supabase Dashboard > Logs에서 의심스러운 접근 확인

---

## ⚠️ 주의사항

1. **APPROVED_GM_EMAILS 목록 관리**
   - 퇴사자/권한 해제 시 즉시 목록에서 제거
   - 정기적으로 목록 검토

2. **비밀번호 관리**
   - 강력한 비밀번호 사용 (12자 이상, 특수문자 포함)
   - 정기적으로 비밀번호 변경
   - 비밀번호 관리자 사용 권장

3. **세션 관리**
   - 공용 PC에서는 반드시 로그아웃
   - 브라우저 시크릿 모드 사용 권장

4. **GitHub 업로드 시**
   - 절대 Supabase Service Role Key는 업로드 금지
   - Anon Key만 사용 (현재 코드는 안전)
   - 민감한 이메일 주소는 환경 변수로 관리

---

## 🔍 테스트 방법

### 1. 정상 로그인 테스트
```
1. gm-login.html 접속
2. 등록된 이메일/비밀번호 입력
3. gm.html로 정상 이동 확인
```

### 2. 비인가 접근 테스트
```
1. 로그인 없이 gm.html 직접 접속
   → gm-login.html로 리다이렉트 확인
   
2. 승인되지 않은 이메일로 로그인 시도
   → "승인되지 않은 이메일" 에러 확인
```

### 3. 세션 만료 테스트
```
1. 로그인 후 1시간 대기
2. 페이지 새로고침
   → 자동 로그아웃 및 로그인 페이지 이동 확인
```

---

## 📞 문제 해결

### "Supabase 라이브러리가 로드되지 않았습니다"
- 인터넷 연결 확인
- CDN 주소 확인: `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.39.0`

### "승인되지 않은 이메일입니다"
- APPROVED_GM_EMAILS 목록에 이메일 추가 확인
- 대소문자 정확히 일치하는지 확인

### "Invalid login credentials"
- Supabase Dashboard에서 계정 생성 확인
- 비밀번호 정확히 입력
- 이메일 인증 완료 확인 (Auto Confirm 체크했는지)

### RLS 정책 오류
- Supabase Dashboard > SQL Editor에서 정책 확인
- 정책 삭제 후 재생성

---

## 📊 보안 수준 비교

| 항목 | 이전 (admin.html) | 현재 (gm.html) |
|------|------------------|----------------|
| 인증 방식 | 프롬프트 비밀번호 | Supabase Auth |
| 비밀번호 저장 | 코드에 평문 | Supabase 암호화 |
| 세션 관리 | 없음 | 1시간 자동 만료 |
| 권한 관리 | 없음 | 이메일 화이트리스트 |
| DB 보안 | 없음 | RLS 정책 (선택) |
| 공격 방어 | ❌ 취약 | ✅ 강화됨 |

---

## 🎯 다음 단계 (추가 보안)

1. **API Rate Limiting 구현**
   - 과도한 요청 차단

2. **활동 로그 기록**
   - GM의 모든 수정 내역 저장

3. **알림 시스템**
   - 의심스러운 접근 시 이메일/슬랙 알림

4. **백업 시스템**
   - 데이터 수정 전 자동 백업

5. **감사 로그**
   - 누가, 언제, 무엇을 수정했는지 추적
