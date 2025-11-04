# How to Reset All User Data

You have **two easy options** to delete all user data and start fresh with onboarding:

## Option 1: Use the Delete Account Button (Recommended)

This is the easiest way and uses the built-in functionality:

1. **Launch the app**
2. **Navigate to Profile/Settings** (tap the Profile icon in the bottom navigation)
3. Scroll down to the **Actions** section
4. Tap **"Delete Account"** (red button at the bottom)
5. **Confirm twice** (there are two confirmation dialogs for safety)
6. The app will **delete all data** including:
   - User profile settings
   - All training programs and progress
   - Exercise performance history
   - Progress journal entries
   - All Hive storage boxes
7. **Restart the app** to see the onboarding flow from scratch

## Option 2: Delete Hive Data Folder Manually

If Option 1 doesn't work for some reason:

### On Windows:
1. **Close the app completely**
2. Navigate to: `%USERPROFILE%\AppData\Local\gymhockeytraining\`
3. Delete the entire folder (or just the subfolders inside)
4. **Restart the app**

### On Android:
1. Go to **Settings → Apps → GymHockeyTraining**
2. Tap **Storage**
3. Tap **Clear Data** (this will reset everything)
4. **Restart the app**

### On iOS:
1. **Delete and reinstall the app** (iOS doesn't allow direct data access)

---

## What Gets Deleted?

When you delete your account, ALL of the following data is permanently removed:

✅ **User Profile** (role, units, language, theme preferences)  
✅ **Active Programs** (current program, week, session progress)  
✅ **Training History** (completed sessions, exercises)  
✅ **Exercise Performance** (all sets, reps, weights recorded)  
✅ **Progress Journal** (XP, streaks, milestones)  
✅ **Performance Analytics** (category progress, weekly stats)  

---

## Testing the Full Flow

After deleting all data:

1. ✅ **Onboarding** - You'll see the initial setup screens
2. ✅ **First Program Selection** - Choose your first training program
3. ✅ **First Session** - Complete exercises and track performance
4. ✅ **Progress Tracking** - View XP, streaks, and analytics
5. ✅ **All Stats** - Everything starts from zero

---

## Developer Notes

The delete account functionality is implemented in:
- `lib/features/profile/application/profile_controller.dart` - `deleteAccount()` method
- `lib/features/profile/presentation/profile_screen.dart` - UI with double confirmation
- `lib/core/persistence/persistence_service.dart` - `clearAll()` method
- All Hive boxes defined in `lib/core/storage/hive_boxes.dart` are cleared

---

**Ready to test the full experience? Use Option 1 above! 🚀**
