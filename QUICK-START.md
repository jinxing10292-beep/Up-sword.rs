# Quick Start Guide

## 🚀 Get Started in 3 Steps

### Step 1: Database Setup (5 minutes)
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **SQL Editor**
4. Click **New Query**
5. Copy entire content from `DATABASE-COMPLETE-SETUP.sql`
6. Paste into the editor
7. Click **Run**
8. Wait for completion (should see green checkmark)

### Step 2: Configure GM Access (2 minutes)
1. Open `gm-login.html` in editor
2. Find line with `APPROVED_GM_EMAILS = [`
3. Add your email: `['your-email@example.com']`
4. Do the same in `gm.html`
5. Save both files

### Step 3: Test Everything (10 minutes)
1. Open `home.html` in browser
2. Log in with your account
3. Test each feature:
   - Click "검 강화" → Try enhancing a sword
   - Click "배틀" → Fight a dummy
   - Click "미니게임" → Play Tetris/Dino/Balance
   - Click "주식" → Buy/sell stocks
   - Click "룰렛" → Play roulette

## ✅ What Should Work

| Feature | Status | Notes |
|---------|--------|-------|
| Sword Enhancement | ✅ | PvE with dummy targets |
| Battle System | ✅ | Earn EXP and battle coins |
| Minigames | ✅ | Earn gold |
| Stock Trading | ✅ | State persists |
| Roulette | ✅ | History saved |
| Inventory | ✅ | View collected swords |
| GM Page | ✅ | Email authentication |

## ⚠️ If Something Breaks

### "Unexpected end of input" error
- ✅ Already fixed in sword.html

### "roulette_history table not found"
- ✅ Already fixed in DATABASE-COMPLETE-SETUP.sql
- Action: Re-run the SQL script

### Gold not saving
- Check: Did you run DATABASE-COMPLETE-SETUP.sql?
- Check: Are RLS policies enabled?
- Check: Open browser console (F12) for errors

### Can't access GM page
- Check: Is your email in APPROVED_GM_EMAILS?
- Check: Did you save the file?

## 📞 Support

If you encounter issues:
1. Check browser console (F12) for error messages
2. Check Network tab for failed API calls
3. Verify DATABASE-COMPLETE-SETUP.sql was run
4. Check that RLS policies are enabled in Supabase

## 📚 Documentation

- `VERIFICATION-CHECKLIST.md` - Detailed testing guide
- `SESSION-SUMMARY.md` - What was fixed
- `LATEST-FIXES.md` - Quick reference
- `PRD.md` - Full feature documentation
