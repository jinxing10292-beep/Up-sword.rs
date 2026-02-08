# Verification Checklist - Complete Setup

## Database Setup (CRITICAL - Must Do First)
- [ ] Open Supabase Dashboard
- [ ] Go to SQL Editor
- [ ] Copy and paste the entire content of `DATABASE-COMPLETE-SETUP.sql`
- [ ] Execute the SQL script
- [ ] Verify all tables are created:
  - [ ] `profiles` (with battle_exp, battle_level, battle_coins, highest_dummy_defeated, has_macro)
  - [ ] `user_swords` (with created_at column)
  - [ ] `user_items`
  - [ ] `battle_history`
  - [ ] `roulette_history` (newly added)
- [ ] Verify RLS policies are enabled on all tables

## GM Page Setup
- [ ] Open `gm-login.html` and find `APPROVED_GM_EMAILS`
- [ ] Add your email address to the array
- [ ] Do the same in `gm.html`
- [ ] Test GM login with your email

## Feature Testing

### Sword Enhancement (sword.html)
- [ ] Load the page without errors
- [ ] Verify sword image displays
- [ ] Check enhancement cost and success rate display
- [ ] Attempt to enhance sword (should work if gold is available)
- [ ] Verify enhancement history shows results
- [ ] Test macro system (if you have macro purchased)

### Battle System (battle.html)
- [ ] Load battle page
- [ ] Select a dummy level (1-30)
- [ ] Start battle and complete it
- [ ] Verify battle history is saved
- [ ] Check that EXP and battle coins are awarded on victory
- [ ] Verify highest_dummy_defeated is updated

### Minigames
- [ ] **Tetris** (tetris-game-pro.html)
  - [ ] Play and complete game
  - [ ] Verify gold is saved after game ends
  - [ ] Check gold amount in profile

- [ ] **Dino** (dino-game.html)
  - [ ] Play and complete game
  - [ ] Verify gold is saved
  - [ ] Check gold amount in profile

- [ ] **Balance** (balance-game.html)
  - [ ] Play and complete game
  - [ ] Verify gold is saved
  - [ ] Check gold amount in profile

### Stock Trading (stock-trade.html)
- [ ] Load stock page
- [ ] Buy a stock
- [ ] Verify stock ownership is saved (reload page and check)
- [ ] Sell a stock
- [ ] Verify gold is updated correctly

### Roulette (roulette.html)
- [ ] Load roulette page
- [ ] Play roulette game
- [ ] Verify game result is saved in roulette_history
- [ ] Check roulette_history.html to see past games

### Inventory (inventory.html)
- [ ] Load inventory page
- [ ] Verify swords are displayed
- [ ] Check that sorting works

## Error Checking
- [ ] Open browser console (F12)
- [ ] Check for any JavaScript errors
- [ ] Verify no 404 errors for resources
- [ ] Check Network tab for failed API calls

## Performance
- [ ] All pages load within 2-3 seconds
- [ ] No lag when clicking buttons
- [ ] Animations are smooth

## Security
- [ ] Verify you can only see your own data
- [ ] Try accessing other users' data (should fail)
- [ ] Verify RLS policies are working

## Final Verification
- [ ] All features working as expected
- [ ] No console errors
- [ ] Data persists after page reload
- [ ] All calculations are correct (gold, EXP, etc.)

## If Issues Occur

### "Unexpected end of input" error
- ✅ FIXED - sword.html duplicate code removed

### "roulette_history table not found"
- ✅ FIXED - Table creation added to DATABASE-COMPLETE-SETUP.sql
- Action: Re-run the database setup SQL

### Gold not saving in minigames
- Check: Are all gold values using `Math.floor()`?
- Check: Is the database update query using `.select()` after `.update()`?
- Check: Are RLS policies enabled?

### Battle coins/EXP not updating
- Check: Is battle_coins column in profiles table?
- Check: Is battle_exp column in profiles table?
- Check: Are RLS policies set correctly?

### Stock state not persisting
- Check: Is localStorage being used?
- Check: Browser localStorage is enabled?
- Check: Are you using the same browser/device?

## Support
If you encounter any issues:
1. Check the browser console for error messages
2. Check the Network tab for failed API calls
3. Verify the database setup was completed
4. Check that RLS policies are enabled
5. Verify your email is in APPROVED_GM_EMAILS if accessing GM page
