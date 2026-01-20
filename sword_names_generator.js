// 검 이름 생성기 - 1,000개의 검 이름 생성 (40 일반 × 21 레벨 + 10 히든 × 21 레벨)

const COMMON_SWORD_TYPES = [
  '철검', '강철검', '청동검', '은검', '금검',
  '불의검', '얼음검', '번개검', '바람검', '대지검',
  '빛의검', '어둠의검', '신성검', '저주검', '영혼검',
  '용검', '악마검', '천사검', '마법검', '고대검',
  '전설의검', '신비검', '운명검', '시간검', '공간검',
  '혼돈검', '질서검', '생명검', '죽음검', '재생검',
  '파괴검', '창조검', '균형검', '무한검', '영원검',
  '승리검', '패배검', '희망검', '절망검', '진실검'
];

const HIDDEN_SWORD_TYPES = [
  '신의검', '악마의검', '용왕검', '시간의검', '차원검',
  '절대검', '무한검', '영원검', '운명검', '초월검'
];

// 레벨별 이름 생성 패턴
function generateCommonSwordNames(baseType, typeIndex) {
  const levels = [
    `${baseType}`,
    `강화된 ${baseType}`,
    `더욱 강화된 ${baseType}`,
    `매우 강화된 ${baseType}`,
    `극도로 강화된 ${baseType}`,
    `${baseType}의 진화`,
    `${baseType}의 완전한 진화`,
    `${baseType}의 궁극의 진화`,
    `${baseType}의 신비로운 진화`,
    `${baseType}의 신성한 진화`,
    `${baseType}의 전설적 진화`,
    `${baseType}의 신화적 진화`,
    `${baseType}의 초월적 진화`,
    `${baseType}의 절대적 진화`,
    `${baseType}의 무한한 진화`,
    `${baseType}의 영원한 진화`,
    `${baseType}의 운명적 진화`,
    `${baseType}의 차원 초월 진화`,
    `${baseType}의 우주적 진화`,
    `${baseType}의 절대 신성 진화`,
    `${baseType}의 최종 초월 진화`
  ];
  return levels;
}

function generateHiddenSwordNames(baseType, typeIndex) {
  const levels = [
    `[HIDDEN] ${baseType}`,
    `[HIDDEN] 각성된 ${baseType}`,
    `[HIDDEN] 깨어난 ${baseType}`,
    `[HIDDEN] 해방된 ${baseType}`,
    `[HIDDEN] 완전히 해방된 ${baseType}`,
    `[HIDDEN] ${baseType}의 진정한 모습`,
    `[HIDDEN] ${baseType}의 완전한 각성`,
    `[HIDDEN] ${baseType}의 절대 각성`,
    `[HIDDEN] ${baseType}의 신비한 각성`,
    `[HIDDEN] ${baseType}의 신성한 각성`,
    `[HIDDEN] ${baseType}의 전설적 각성`,
    `[HIDDEN] ${baseType}의 신화적 각성`,
    `[HIDDEN] ${baseType}의 초월적 각성`,
    `[HIDDEN] ${baseType}의 절대적 각성`,
    `[HIDDEN] ${baseType}의 무한한 각성`,
    `[HIDDEN] ${baseType}의 영원한 각성`,
    `[HIDDEN] ${baseType}의 운명적 각성`,
    `[HIDDEN] ${baseType}의 차원 초월 각성`,
    `[HIDDEN] ${baseType}의 우주적 각성`,
    `[HIDDEN] ${baseType}의 절대 신성 각성`,
    `[HIDDEN] ${baseType}의 최종 초월 각성`
  ];
  return levels;
}

function generateAllSwordNames() {
  const allSwords = [];
  let id = 1;

  // 일반 검 생성 (40 × 21 = 840개)
  COMMON_SWORD_TYPES.forEach((type, typeIndex) => {
    const names = generateCommonSwordNames(type, typeIndex);
    names.forEach((name, index) => {
      const level = index;
      const rarity = level <= 5 ? 'common' : level <= 10 ? 'uncommon' : level <= 15 ? 'rare' : level <= 19 ? 'epic' : 'legendary';
      allSwords.push({
        id: id++,
        type: 'normal',
        baseType: type,
        level: level,
        name: name,
        rarity: rarity,
        description: `${type} 강화 레벨 ${level}`
      });
    });
  });

  // 히든 검 생성 (10 × 21 = 210개)
  HIDDEN_SWORD_TYPES.forEach((type, typeIndex) => {
    const names = generateHiddenSwordNames(type, typeIndex);
    names.forEach((name, index) => {
      const level = index;
      const rarity = level <= 5 ? 'rare' : level <= 10 ? 'epic' : level <= 15 ? 'legendary' : level <= 19 ? 'mythic' : 'transcendent';
      allSwords.push({
        id: id++,
        type: 'hidden',
        baseType: type,
        level: level,
        name: name,
        rarity: rarity,
        description: `[HIDDEN] ${type} 각성 레벨 ${level}`
      });
    });
  });

  return allSwords;
}

// 생성 및 출력
const swords = generateAllSwordNames();
console.log(`총 ${swords.length}개의 검이 생성되었습니다.`);
console.log('처음 10개:', swords.slice(0, 10));
console.log('마지막 10개:', swords.slice(-10));

// JSON 형식으로 저장
const swordData = {
  totalCount: swords.length,
  commonCount: 40 * 21,
  hiddenCount: 10 * 21,
  swords: swords
};

// Node.js 환경에서 파일로 저장
if (typeof require !== 'undefined') {
  const fs = require('fs');
  fs.writeFileSync('sword_names.json', JSON.stringify(swordData, null, 2));
  console.log('sword_names.json 파일이 생성되었습니다.');
}

// 브라우저 환경에서 다운로드
if (typeof window !== 'undefined') {
  window.SWORD_DATA = swordData;
  console.log('SWORD_DATA가 window 객체에 저장되었습니다.');
}

module.exports = swordData;
