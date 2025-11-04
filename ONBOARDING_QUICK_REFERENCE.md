# Onboarding System - Quick Reference

## 📱 Testing the Onboarding Flow

### First Time Setup (Fresh Install)
1. Install the app on a device/emulator
2. Launch the app
3. You'll automatically see the welcome screen
4. Complete the 4-screen flow:
   - Welcome → Let's start
   - Role selection → Choose Forward/Defence/Goalie → Continue
   - Goal selection → Choose strength/speed/endurance → Continue
   - Plan preview → Start my first workout
5. You'll be taken to the home screen with your profile displayed

### Testing Again (After Completion)
To test the onboarding flow again, you need to clear the saved profile:

**Option 1: Clear App Data (Easiest)**
- Android: Settings → Apps → Hockey Gym → Storage → Clear Data
- iOS: Uninstall and reinstall the app

**Option 2: Using Dart Script**
```bash
# Edit test_onboarding.dart and uncomment the clearUserProfile() line
# Then run:
dart run test_onboarding.dart
```

**Option 3: From Flutter DevTools**
```dart
// In debug console:
final repo = ProviderContainer().read(onboardingRepositoryProvider);
await repo.clearUserProfile();
// Then hot restart the app
```

## 🔧 Accessing User Profile in Code

### Read the current profile:
```dart
// Using Riverpod provider (reactive)
final userProfile = ref.watch(userProfileStreamProvider);

userProfile.when(
  data: (profile) {
    if (profile != null) {
      print('Role: ${profile.role}');
      print('Goal: ${profile.goal}');
    }
  },
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

### Check onboarding status:
```dart
final hasCompleted = await ref.read(hasCompletedOnboardingProvider.future);
if (hasCompleted) {
  // User has completed onboarding
}
```

### Access repository directly:
```dart
final repo = ref.read(onboardingRepositoryProvider);
final profile = await repo.getUserProfile();
```

## 🎨 Customizing the Onboarding

### Update Text/Copy
Edit: `lib/features/onboarding/presentation/onboarding_strings.dart`

Example:
```dart
static const String welcomeTitle = 'Your Custom Title';
```

### Change Colors/Styling
The onboarding uses the existing theme:
- Edit: `lib/app/theme.dart`
- Colors used:
  - `AppTheme.backgroundColor` - Screen background
  - `AppTheme.surfaceColor` - Card backgrounds
  - `AppTheme.primaryColor` - Buttons
  - `AppTheme.accentColor` - Selected state, highlights

### Add/Remove Role or Goal Options
1. Add to enum in `lib/core/models/models.dart`:
```dart
enum PlayerRole {
  forward,
  defence,
  goalie,
  yourNewRole, // Add here
}
```

2. Add card in the respective screen:
```dart
OnboardingSelectableCard(
  title: 'Your New Role',
  subtitle: 'Description',
  icon: Icons.your_icon,
  isSelected: _selectedRole == PlayerRole.yourNewRole,
  onTap: () {
    setState(() {
      _selectedRole = PlayerRole.yourNewRole;
    });
  },
),
```

3. Update hub screen logic in `_buildUserProfileHeader()` if needed

## 🚀 Common Tasks

### Make a field optional in onboarding
If you want to skip role or goal selection:

1. Make the field nullable in `UserProfile`:
```dart
final PlayerRole? role; // Add ?
```

2. Update screens to allow skipping:
```dart
// Enable button without selection
onPressed: () => context.push('/next-screen'),
```

### Add a new screen to onboarding
1. Create screen file in `lib/features/onboarding/presentation/`
2. Add route in `lib/app/router.dart`:
```dart
GoRoute(
  path: '/onboarding/new-screen',
  name: 'onboarding-new-screen',
  builder: (context, state) => YourNewScreen(),
),
```
3. Update navigation flow in previous screen

### Change the "How it Works" sheet content
Edit the `_showHowItWorksSheet()` method in `plan_preview_screen.dart`

### Add animations/transitions
The screens already use `AnimatedContainer` for selection states.

To add page transitions:
```dart
GoRoute(
  path: '/onboarding/welcome',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      child: WelcomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  },
),
```

## 📊 Data Storage

- **Storage**: Hive (encrypted local database)
- **Box**: `HiveBoxes.profile`
- **Key**: `'user_profile'`
- **Location**: App documents directory
- **Encryption**: AES-256 (managed by SecureKeyService)

## 🐛 Troubleshooting

### Onboarding shows even after completion
- Check if `onboardingCompleted: true` in saved profile
- Verify Hive box is opened correctly
- Check for errors in console

### Navigation doesn't work
- Ensure all routes are registered in `router.dart`
- Check `extra` parameters are passed correctly
- Verify go_router version compatibility

### Profile not saving
- Check Hive initialization in `main.dart`
- Verify encryption key generation
- Check console for repository errors

### Home screen doesn't show profile
- Verify `userProfileStreamProvider` is watched
- Check if `.when()` handles all states
- Ensure profile is not null

## 📝 Notes

- The onboarding only runs once (on first launch)
- Profile is stored locally (no backend sync yet)
- Redirect logic prevents accessing onboarding after completion
- All screens support back navigation except Welcome
- Strings are centralized for easy localization
