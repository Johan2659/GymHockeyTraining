# Onboarding Updates - Auto-Start Program & Referee Role

## Changes Made

### 1. ✅ Added Referee Role to Onboarding

**Updated Files:**
- `lib/core/models/models.dart` - Added `referee` to `PlayerRole` enum
- `lib/features/onboarding/presentation/role_selection_screen.dart` - Added Referee card
- `lib/features/hub/presentation/hub_screen.dart` - Added Referee case in role display
- `lib/features/onboarding/presentation/onboarding_strings.dart` - Added Referee strings

**Referee Card Details:**
- Title: "Referee"
- Subtitle: "Endurance & agility"
- Icon: `Icons.sports`

### 2. ✅ Auto-Start Program Based on Role

**What Changed:**
The onboarding flow now automatically selects and starts the appropriate program based on the player's role. When the user completes onboarding by tapping "Start my first workout", the app:

1. Saves the user profile (role + goal)
2. **Automatically starts the corresponding program:**
   - Forward → `hockey_attacker_2025`
   - Defence → `hockey_defender_2025`
   - Goalie → `hockey_goalie_2025`
   - Referee → `hockey_referee_2025`
3. Navigates to home screen

**Updated File:**
- `lib/features/onboarding/presentation/plan_preview_screen.dart`
  - Added `_getProgramIdForRole()` method to map roles to program IDs
  - Updated `_completeOnboarding()` to call `startProgramActionProvider`

**Benefits:**
- ✅ No need to select program from Programs screen
- ✅ User immediately sees their active program on Hub screen
- ✅ Ready to start first workout right away
- ✅ Seamless onboarding experience

### 3. What the User Sees Now

**Onboarding Flow:**
1. Welcome screen → "Let's start"
2. Role selection → Choose Forward/Defence/Goalie/Referee (now 4 options!)
3. Goal selection → Choose strength/speed/endurance
4. Plan preview → "Start my first workout"
5. **🎉 Automatically redirected to Hub with program ready to go!**

**Hub Screen:**
- Shows user profile header with role and goal
- **Active program is already selected** (no "Choose your program" needed)
- User can immediately tap into their first session

## Role-to-Program Mapping

| Player Role | Program ID | Program Name |
|------------|-----------|--------------|
| Forward | `hockey_attacker_2025` | Attacker Program |
| Defence | `hockey_defender_2025` | Defender Program |
| Goalie | `hockey_goalie_2025` | Goalie Program |
| Referee | `hockey_referee_2025` | Referee Program |

## Testing

### To Test the Complete Flow:

1. Clear app data (or use `test_onboarding.dart`)
2. Launch app → Welcome screen appears
3. Complete onboarding:
   - Select a role (e.g., Forward)
   - Select a goal (e.g., Strength)
   - Tap "Start my first workout"
4. **Verify on Hub screen:**
   - Profile header shows "Forward" role
   - "Current Program" card displays the Attacker program
   - Ready to start Week 1, Day 1

### Error Handling

The implementation includes graceful error handling:
- If profile save fails → Shows error, stays on onboarding
- If program start fails → Shows warning but completes onboarding (user can manually select program later)
- User still gets to home screen even if program start has issues

## Code Quality

✅ No compilation errors  
✅ Follows existing architecture patterns  
✅ Uses existing providers (`startProgramActionProvider`)  
✅ Maintains error handling and logging  
✅ All roles properly mapped to programs  

## What Was Removed

❌ **Removed unnecessary complexity:**
- Users no longer need to navigate to Programs screen
- No "Choose your program" step after onboarding
- Program is pre-selected based on their role

This makes the onboarding → first workout flow much more streamlined! 🏒
