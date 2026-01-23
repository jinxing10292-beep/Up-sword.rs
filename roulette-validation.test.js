/**
 * Test suite for roulette special betting validation logic
 * Tests Requirements 1.1 and 1.2 for special betting limit enforcement
 */

// Mock DOM elements and functions for testing
const mockDOM = {
    selectedBets: [],
    ROULETTE_CONFIG: {
        bettingLimits: {
            maxSpecialBets: 2,
            maxNumberBets: 3
        },
        payoutRates: {
            numberBetMultiplier: 95,
            specialBetMultipliers: {
                red: 2, black: 2, odd: 2, even: 2, high: 2, low: 2
            }
        }
    },
    errorMessages: [],
    
    // Mock querySelector
    querySelector: function(selector) {
        return {
            classList: {
                add: () => {},
                remove: () => {},
                contains: () => false
            }
        };
    },
    
    // Mock showErrorMessage function
    showErrorMessage: function(message) {
        this.errorMessages.push(message);
    },
    
    // Implementation of toggleSpecialBet function from roulette.html
    toggleSpecialBet: function(betType) {
        const btn = this.querySelector(`[data-bet="${betType}"]`);
        const betIndex = this.selectedBets.findIndex(bet => bet.type === betType);
        
        if (betIndex >= 0) {
            // Remove existing bet
            this.selectedBets.splice(betIndex, 1);
            btn.classList.remove('selected');
        } else {
            // Validate special betting limit before adding new bet
            const specialBets = this.selectedBets.filter(bet => bet.type !== 'number');
            if (specialBets.length >= this.ROULETTE_CONFIG.bettingLimits.maxSpecialBets) {
                // Show appropriate error message and maintain current selections
                this.showErrorMessage(`특수 베팅은 최대 ${this.ROULETTE_CONFIG.bettingLimits.maxSpecialBets}개까지만 선택할 수 있습니다.`);
                return; // Prevent selection without adding the new bet
            }
            
            // Add new special bet
            this.selectedBets.push({ 
                type: betType, 
                payout: this.ROULETTE_CONFIG.payoutRates.specialBetMultipliers[betType] 
            });
            btn.classList.add('selected');
        }
    },
    
    // Reset function for testing
    reset: function() {
        this.selectedBets = [];
        this.errorMessages = [];
    }
};

// Test suite
function runTests() {
    console.log('🧪 Running Special Betting Validation Tests...\n');
    
    // Test 1: Requirement 1.1 - System allows maximum of 2 special bet selections
    console.log('Test 1: Maximum 2 special bet selections allowed');
    mockDOM.reset();
    
    // Add first special bet
    mockDOM.toggleSpecialBet('red');
    console.log(`After adding 'red': ${mockDOM.selectedBets.length} bets selected`);
    
    // Add second special bet
    mockDOM.toggleSpecialBet('odd');
    console.log(`After adding 'odd': ${mockDOM.selectedBets.length} bets selected`);
    
    // Verify exactly 2 bets are allowed
    const specialBets = mockDOM.selectedBets.filter(bet => bet.type !== 'number');
    if (specialBets.length === 2) {
        console.log('✅ PASS: System allows exactly 2 special bets');
    } else {
        console.log('❌ FAIL: System should allow exactly 2 special bets');
    }
    
    // Test 2: Requirement 1.2 - System prevents selection and displays message for 3rd bet
    console.log('\nTest 2: Prevention of 3rd special bet with error message');
    
    // Try to add third special bet
    mockDOM.toggleSpecialBet('high');
    
    // Check that third bet was not added
    const specialBetsAfter = mockDOM.selectedBets.filter(bet => bet.type !== 'number');
    if (specialBetsAfter.length === 2) {
        console.log('✅ PASS: System prevents 3rd special bet selection');
    } else {
        console.log('❌ FAIL: System should prevent 3rd special bet selection');
    }
    
    // Check that error message was displayed
    if (mockDOM.errorMessages.length > 0 && 
        mockDOM.errorMessages[0].includes('특수 베팅은 최대 2개까지만')) {
        console.log('✅ PASS: System displays appropriate error message');
    } else {
        console.log('❌ FAIL: System should display appropriate error message');
    }
    
    // Test 3: Requirement 1.4 - System maintains current selections when limit exceeded
    console.log('\nTest 3: Current selections maintained when limit exceeded');
    
    // Verify original bets are still selected
    const originalBets = mockDOM.selectedBets.map(bet => bet.type);
    if (originalBets.includes('red') && originalBets.includes('odd')) {
        console.log('✅ PASS: System maintains current selections');
    } else {
        console.log('❌ FAIL: System should maintain current selections');
    }
    
    // Test 4: Edge case - Removing and re-adding bets
    console.log('\nTest 4: Removing and re-adding special bets');
    mockDOM.reset();
    
    // Add 2 bets
    mockDOM.toggleSpecialBet('black');
    mockDOM.toggleSpecialBet('even');
    
    // Remove one bet
    mockDOM.toggleSpecialBet('black');
    
    // Should be able to add a different bet now
    mockDOM.toggleSpecialBet('low');
    
    const finalBets = mockDOM.selectedBets.filter(bet => bet.type !== 'number');
    if (finalBets.length === 2 && 
        finalBets.some(bet => bet.type === 'even') && 
        finalBets.some(bet => bet.type === 'low')) {
        console.log('✅ PASS: System correctly handles bet removal and re-addition');
    } else {
        console.log('❌ FAIL: System should handle bet removal and re-addition correctly');
    }
    
    // Test 5: Validation with mixed bet types
    console.log('\nTest 5: Special bet validation with number bets present');
    mockDOM.reset();
    
    // Add a number bet (should not affect special bet limit)
    mockDOM.selectedBets.push({ type: 'number', value: 7, payout: 95 });
    
    // Add 2 special bets
    mockDOM.toggleSpecialBet('red');
    mockDOM.toggleSpecialBet('odd');
    
    // Try to add 3rd special bet
    mockDOM.toggleSpecialBet('high');
    
    const mixedBetsSpecial = mockDOM.selectedBets.filter(bet => bet.type !== 'number');
    const mixedBetsNumber = mockDOM.selectedBets.filter(bet => bet.type === 'number');
    
    if (mixedBetsSpecial.length === 2 && mixedBetsNumber.length === 1) {
        console.log('✅ PASS: Special bet validation works correctly with number bets present');
    } else {
        console.log('❌ FAIL: Special bet validation should work correctly with number bets present');
    }
    
    console.log('\n🏁 Test Suite Complete');
}

// Run the tests
runTests();