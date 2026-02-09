/**
 * Roulette System Configuration
 * TypeScript interfaces and constants for the improved roulette system
 */

// Configuration interfaces
export interface BettingLimits {
  maxSpecialBets: number;
  maxNumberBets: number;
}

export interface PayoutRates {
  numberBetMultiplier: number;
  specialBetMultipliers: {
    red: number;
    black: number;
    odd: number;
    even: number;
    high: number;
    low: number;
  };
}

export interface NumberRange {
  min: number;
  max: number;
}

export interface RouletteConfiguration {
  bettingLimits: BettingLimits;
  payoutRates: PayoutRates;
  numberRange: NumberRange;
}

// Betting models
export interface SpecialBet {
  type: 'red' | 'black' | 'odd' | 'even' | 'high' | 'low';
  amount: number;
}

export interface NumberBet {
  number: number; // 0-45
  amount: number;
}

export interface ValidationResult {
  isValid: boolean;
  message?: string;
}

// Configuration constants - Updated values per requirements
export const ROULETTE_CONFIG: RouletteConfiguration = {
  bettingLimits: {
    maxSpecialBets: 2,  // Changed from 3 to 2
    maxNumberBets: 3    // Changed from 5 to 3
  },
    payoutRates: {
    numberBetMultiplier: 70,  // Increased from 50 to 70 per request
    specialBetMultipliers: {
      red: 2,
      black: 2,
      odd: 2,
      even: 2,
      high: 2,
      low: 2
    }
  },
  numberRange: {
    min: 0,
    max: 45  // Changed from 36 to 45
  }
};

// Component interfaces
export interface BettingController {
  validateSpecialBets(bets: SpecialBet[]): ValidationResult;
  validateNumberBets(bets: NumberBet[]): ValidationResult;
  getMaxSpecialBets(): number;
  getMaxNumberBets(): number;
}

export interface PayoutCalculator {
  calculateNumberPayout(bet: NumberBet, winningNumber: number): number;
  getNumberPayoutRate(): number;
  calculateSpecialPayout(bet: SpecialBet, winningNumber: number): number;
}

export interface NumberGenerator {
  generateWinningNumber(): number;
  getNumberRange(): NumberRange;
  isValidNumber(number: number): boolean;
}

// Utility functions for configuration
export function getRouletteNumbers(): Record<number, 'red' | 'black' | 'green'> {
  const numbers: Record<number, 'red' | 'black' | 'green'> = { 0: 'green' };
  
  // Extended roulette numbers 1-45 with alternating red/black pattern
  // Following European roulette color pattern extended to 45
  const redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36, 37, 39, 41, 43, 45];
  
  for (let i = 1; i <= ROULETTE_CONFIG.numberRange.max; i++) {
    numbers[i] = redNumbers.includes(i) ? 'red' : 'black';
  }
  
  return numbers;
}

export function isHighNumber(number: number): boolean {
  // For 0-45 range, high numbers are 23-45 (approximately half)
  return number >= 23 && number <= 45;
}

export function isLowNumber(number: number): boolean {
  // For 0-45 range, low numbers are 1-22
  return number >= 1 && number <= 22;
}