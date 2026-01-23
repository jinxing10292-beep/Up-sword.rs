# Design Document: Sword Enhancement System

## Overview

The Sword Enhancement System is a comprehensive feature set for a mobile web game that enables players to enhance swords, manage collections, view a compendium, and engage in player-versus-player battles. The system is built on HTML5/CSS3/JavaScript with Supabase as the backend, following a modular architecture that separates concerns into distinct layers: data persistence, business logic, and UI presentation.

The system manages 1,000 unique sword variants (40 common types × 21 levels + 10 hidden types × 21 levels) with dynamically generated names that become progressively more elaborate as enhancement levels increase. The system now includes advanced features such as an automated macro enhancement system and a rare hidden sword system with alternative currency mechanics.

## Architecture

### System Architecture

The system follows a three-tier architecture:

1. **Presentation Layer**: HTML5/CSS3/JavaScript frontend with responsive design
2. **Business Logic Layer**: Client-side JavaScript modules handling game mechanics
3. **Data Persistence Layer**: Supabase PostgreSQL database with real-time synchronization

### Technology Stack

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Backend**: Supabase (PostgreSQL + Auth + Real-time)
- **Styling**: Custom CSS with Pretendard font family
- **Icons**: Font Awesome 6.0.0
- **Data Format**: JSON for sword naming data

## Components and Interfaces

### Core Components

#### 1. Sword Enhancement Engine
- **Purpose**: Handles sword enhancement logic with probabilistic outcomes
- **Key Functions**:
  - `handleUpgrade()`: Main enhancement function with success/failure/destruction logic
  - `getEnhancementRates(level)`: Returns success/maintain/destroy percentages for each level
  - `determineEnhancementResult(rates)`: Probabilistic outcome determination
  - `getEnhancementCost(level)`: Calculates enhancement costs with 1% discount

#### 2. Sword Name Generator
- **Purpose**: Generates unique names for 1,000 sword variants
- **Key Functions**:
  - `getVariantName(weaponKey, level)`: Retrieves sword names from sword_names.json
  - Caching mechanism via `variantNameCache` Map for performance
  - Fallback naming for missing data

#### 3. Macro System Engine
- **Purpose**: Automated enhancement system for hands-free gameplay
- **Key Functions**:
  - `startMacro()`: Initiates automated enhancement to target level
  - `stopMacro()`: Halts macro execution
  - `runMacroStep()`: Executes single enhancement attempt with logging
  - `performMacroUpgrade()`: Core macro enhancement logic
  - `addMacroLog(message, type)`: Real-time logging system

#### 4. Hidden Sword System
- **Purpose**: Rare sword acquisition with alternative currency mechanics
- **Key Functions**:
  - `checkForHiddenSword()`: 1% probability check after sword events
  - Alternative enhancement costs using money (M) instead of gold (G)
  - Conversion rate: 1000G = 1M for hidden sword enhancements

#### 5. Shop System
- **Purpose**: Item and macro purchasing interface
- **Key Functions**:
  - `purchaseMacro()`: Special handling for macro purchase (100 billion gold)
  - Permanent ownership tracking via `has_macro` profile flag
  - Integration with enhancement items and protection scrolls

### Data Models

#### User Profile Schema
```javascript
{
  id: string,                    // Supabase user ID
  nickname: string,              // Display name
  gold: number,                  // Primary currency
  money: number,                 // Secondary currency for hidden swords
  current_sword_lvl: number,     // Current sword enhancement level (0-20)
  current_weapon_type: string,   // 'normal' or 'hidden'
  current_weapon_key: string,    // Weapon identifier (e.g., 'sword_01', 'hidden_sword_01')
  has_macro: boolean,            // Permanent macro ownership flag
  used_enhance_scroll: boolean   // Local tracking for enhancement scroll penalty
}
```

#### Sword Variant Schema
```javascript
{
  id: number,           // Unique identifier (1-1000)
  type: string,         // 'normal' or 'hidden'
  level: number,        // Enhancement level (0-20)
  name: string,         // Generated sword name
  rarity: string,       // 'common', 'rare', 'epic', 'legendary'
  description: string   // Flavor text
}
```

#### Enhancement Rates Configuration
```javascript
// Level-based enhancement probabilities
const enhancementRates = [
  { success: 85, maintain: 15, destroy: 0 },   // 0 → 1
  { success: 80, maintain: 20, destroy: 0 },   // 1 → 2
  // ... progressive difficulty increase
  { success: 5, maintain: 90, destroy: 5 }     // 19 → 20
];
```

## Macro System Architecture

### Macro Control Flow

1. **Purchase Validation**: Check `has_macro` flag and sufficient funds (100B gold)
2. **Target Setting**: User inputs desired enhancement level (1-20)
3. **Execution Loop**: Automated enhancement attempts with real-time logging
4. **Termination Conditions**: Target reached, sword destroyed, insufficient funds, or manual stop

### Macro State Management

```javascript
// Macro system state variables
let macroActive = false;        // Execution status
let macroInterval = null;       // Timeout reference for step execution
let macroTargetLevel = 10;      // User-defined target level
let macroLog = [];              // Enhancement attempt history
let hasMacro = false;           // Ownership status from profile
```

### Macro Logging System

- **Real-time Updates**: Live display of enhancement attempts
- **Event Types**: Success (green), Failure (red), Destruction (orange), Info (blue)
- **Timestamp Tracking**: Each log entry includes precise timing
- **Log Rotation**: Maximum 100 entries with automatic cleanup

## Hidden Sword System Architecture

### Trigger Mechanism

Hidden swords activate with 1% probability after:
- Sword destruction during enhancement
- Sword sale transaction
- Sword storage to inventory

### Hidden Sword Properties

- **Currency**: Uses money (M) instead of gold (G)
- **Conversion Rate**: 1000G = 1M for enhancement costs
- **Variants**: 3 different hidden sword types (hidden_sword_01, 02, 03)
- **Bonus**: Immediate 100M reward upon acquisition
- **Visual Indicator**: "[HIDDEN]" prefix in sword names

### Implementation Details

```javascript
// Hidden sword probability check
if (Math.random() < 0.01) {
  // Select random hidden sword variant (1-3)
  const variant = Math.floor(Math.random() * 3) + 1;
  const hiddenKey = `hidden_sword_${String(variant).padStart(2,'0')}`;
  
  // Award bonus and set hidden sword
  user.money += 100;
  user.current_weapon_type = 'hidden';
  user.current_weapon_key = hiddenKey;
}
```

## Error Handling

### Enhancement Safety Measures

1. **Level Protection**: Prevents level regression except during destruction
2. **Currency Validation**: Ensures sufficient funds before enhancement attempts
3. **State Locking**: `isUpgrading` flag prevents concurrent enhancement operations
4. **Database Consistency**: Atomic updates with error rollback

### Macro Error Handling

1. **Insufficient Funds**: Automatic termination with clear messaging
2. **Database Errors**: Graceful failure with user notification
3. **State Recovery**: Proper cleanup of intervals and flags on errors
4. **User Interruption**: Clean stop functionality with state preservation

## Testing Strategy

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Correctness Properties

### Correctness Properties

#### Property 1: Sword Name Generation Consistency
*For any* sword type and enhancement level combination, generating the name multiple times should always produce identical results
**Validates: Requirements 1.4**

#### Property 2: Enhancement Level Progression
*For any* sword at level L < 20, successful enhancement should result in level L+1, failed enhancement should maintain level L, and destruction should reset to level 0
**Validates: Requirements 1.2, 1.3**

#### Property 3: Macro Target Achievement
*For any* macro execution with sufficient funds, the macro should continue until either the target level is reached, the sword is destroyed, funds are exhausted, or manual stop is triggered
**Validates: Requirements 6.4, 6.6, 6.7, 6.8**

#### Property 4: Hidden Sword Probability Consistency
*For any* sword destruction, sale, or storage event, there should be exactly a 1% probability of triggering the hidden sword acquisition with 100M reward
**Validates: Requirements 7.1, 7.2, 7.6**

#### Property 5: Hidden Sword Currency System
*For any* hidden sword enhancement, the system should use money (M) at conversion rate ceiling(gold_cost / 1000) and deduct from money balance instead of gold
**Validates: Requirements 7.3, 7.5**

#### Property 6: Data Persistence Consistency
*For any* game state change (sword enhancement, inventory update, battle conclusion), the changes should be immediately persisted to the database
**Validates: Requirements 4.6, 5.1, 5.3, 5.4**

#### Property 7: Macro Ownership Persistence
*For any* user who purchases the macro for 100 billion gold, the `has_macro` flag should remain true permanently and the macro control panel should be displayed
**Validates: Requirements 6.2, 6.3**

#### Property 8: Required Information Display
*For any* sword displayed in UI (compendium, inventory, enhancement), all required fields (name, type, level, ID) should be present and correctly formatted
**Validates: Requirements 2.2, 4.2, 7.4**

#### Property 9: Macro Logging Completeness
*For any* macro enhancement attempt, exactly one log entry should be created with timestamp, appropriate message, and correct type classification (success/fail/destroy/info)
**Validates: Requirements 6.5**

#### Property 10: Sword Variant Uniqueness
*For all* 1,000 sword variants, each should have a unique ID and the total count should be exactly 1,000 with proper type distribution (840 normal + 160 hidden)
**Validates: Requirements 1.1, 1.7**

### Testing Approach

**Dual Testing Strategy**:
- **Unit Tests**: Verify specific examples, edge cases, and error conditions
- **Property Tests**: Verify universal properties across all inputs using a property-based testing library

**Property-Based Testing Configuration**:
- **Library**: Use fast-check for JavaScript property-based testing
- **Iterations**: Minimum 100 iterations per property test
- **Test Tags**: Each property test tagged with format: **Feature: sword-enhancement-system, Property {number}: {property_text}**

**Unit Testing Focus**:
- Macro purchase validation with insufficient funds
- Hidden sword trigger edge cases (exactly 1% probability)
- Enhancement rate boundary conditions (level 0 and level 20)
- Database error recovery scenarios
- UI state synchronization after page visibility changes

**Integration Testing**:
- End-to-end macro execution from purchase to completion
- Hidden sword acquisition and subsequent enhancement flow
- Cross-page data synchronization (shop → sword enhancement)
- Real-time logging display updates during macro execution