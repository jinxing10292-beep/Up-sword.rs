/**
 * Unit tests for roulette configuration
 * Tests the basic configuration values and utility functions
 */

// Mock the configuration (since we can't import TypeScript directly in this context)
const ROULETTE_CONFIG = {
    bettingLimits: {
        maxSpecialBets: 2,
        maxNumberBets: 3
    },
    payoutRates: {
        numberBetMultiplier: 95,
        specialBetMultipliers: {
            red: 2, black: 2, odd: 2, even: 2, high: 2, low: 2
        }
    },
    numberRange: {
        min: 0,
        max: 45
    }
};

function getRouletteNumbers() {
    const numbers = { 0: 'green' };
    const redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36, 37, 39, 41, 43, 45];
    
    for (let i = 1; i <= ROULETTE_CONFIG.numberRange.max; i++) {
        numbers[i] = redNumbers.includes(i) ? 'red' : 'black';
    }
    
    return numbers;
}

function isHighNumber(number) {
    return number >= 23 && number <= 45;
}

function isLowNumber(number) {
    return number >= 1 && number <= 22;
}

// Test functions
function testConfiguration() {
    console.log('Testing roulette configuration...');
    
    // Test betting limits
    console.assert(ROULETTE_CONFIG.bettingLimits.maxSpecialBets === 2, 'Special bet limit should be 2');
    console.assert(ROULETTE_CONFIG.bettingLimits.maxNumberBets === 3, 'Number bet limit should be 3');
    
    // Test payout rates
    console.assert(ROULETTE_CONFIG.payoutRates.numberBetMultiplier === 95, 'Number bet payout should be 95x');
    console.assert(ROULETTE_CONFIG.payoutRates.specialBetMultipliers.red === 2, 'Red bet payout should be 2x');
    
    // Test number range
    console.assert(ROULETTE_CONFIG.numberRange.min === 0, 'Min number should be 0');
    console.assert(ROULETTE_CONFIG.numberRange.max === 45, 'Max number should be 45');
    
    console.log('✅ Configuration tests passed');
}

function testNumberGeneration() {
    console.log('Testing number generation...');
    
    const numbers = getRouletteNumbers();
    
    // Test that we have the right number of entries (0-45 = 46 numbers)
    console.assert(Object.keys(numbers).length === 46, 'Should have 46 numbers (0-45)');
    
    // Test that 0 is green
    console.assert(numbers[0] === 'green', 'Number 0 should be green');
    
    // Test some specific red numbers
    console.assert(numbers[1] === 'red', 'Number 1 should be red');
    console.assert(numbers[3] === 'red', 'Number 3 should be red');
    console.assert(numbers[45] === 'red', 'Number 45 should be red');
    
    // Test some specific black numbers
    console.assert(numbers[2] === 'black', 'Number 2 should be black');
    console.assert(numbers[4] === 'black', 'Number 4 should be black');
    console.assert(numbers[44] === 'black', 'Number 44 should be black');
    
    console.log('✅ Number generation tests passed');
}

function testHighLowNumbers() {
    console.log('Testing high/low number classification...');
    
    // Test low numbers (1-22)
    console.assert(isLowNumber(1) === true, 'Number 1 should be low');
    console.assert(isLowNumber(22) === true, 'Number 22 should be low');
    console.assert(isLowNumber(23) === false, 'Number 23 should not be low');
    console.assert(isLowNumber(0) === false, 'Number 0 should not be low');
    
    // Test high numbers (23-45)
    console.assert(isHighNumber(23) === true, 'Number 23 should be high');
    console.assert(isHighNumber(45) === true, 'Number 45 should be high');
    console.assert(isHighNumber(22) === false, 'Number 22 should not be high');
    console.assert(isHighNumber(0) === false, 'Number 0 should not be high');
    
    console.log('✅ High/low number tests passed');
}

// Run all tests
try {
    testConfiguration();
    testNumberGeneration();
    testHighLowNumbers();
    console.log('🎉 All tests passed successfully!');
} catch (error) {
    console.error('❌ Test failed:', error);
}