# Session Player Fix Summary

## Problem
The session_player_screen.dart was showing "Error loading exercises: Exercises not found" because it was constructing incorrect session IDs.

## Root Cause
1. **Session ID Mismatch**: The session player was building session IDs like `week1_session1`, but the actual session IDs in the AttackerProgramData are formatted as `attacker_w1_s1`, `attacker_w1_s2`, etc.

2. **Legacy vs New Program**: The old legacy sessions used exercise IDs with `ex_` prefix (like `ex_warmup_skate`), while the new attacker program uses proper exercise names from HockeyExercisesDatabase (like `dynamic_warmup_ramp`, `back_squat`, etc.)

## Changes Made

### 1. Fixed Session ID Construction (`session_player_screen.dart`)
**Before:**
```dart
final sessionId = 'week${weekNum}_session$sessionNum';
```

**After:**
```dart
// Build session ID based on program format (attacker_w1_s1)
final sessionId = 'attacker_w${weekNum}_s$sessionNum';
```

**Location:** Lines 617-636

### 2. Fixed Week/Session Display in Title
**Before:**
```dart
Text('Week ${widget.week} • Session ${widget.session}')
```

**After:**
```dart
Text('Week ${int.parse(widget.week) + 1} • Session ${int.parse(widget.session) + 1}')
```

**Location:** Lines 75-89
**Reason:** The route parameters are 0-based but should display as 1-based

### 3. Fixed Session Logging
**Before:**
```dart
final week = int.tryParse(widget.week) ?? 1;
final session = int.tryParse(widget.session.replaceAll('week${week}_session', '')) ?? 1;
```

**After:**
```dart
final week = int.tryParse(widget.week) ?? 0;
final session = int.tryParse(widget.session) ?? 0;
```

**Location:** Lines 45-61
**Reason:** Use raw 0-based values for logging

### 4. Updated Session Source (`local_session_source.dart`)

#### Added Support for New Attacker Program
```dart
// Handle new attacker program
if (programId == 'hockey_attacker_2025') {
  return await AttackerProgramData.getAllSessions();
}
```

**Location:** Lines 201-226

#### Added Week-Specific Session Filtering
```dart
// For new attacker program, filter by attacker_w{week}_
if (programId == 'hockey_attacker_2025') {
  final weekNum = week + 1; // Convert 0-based to 1-based
  final weekSessions = allSessions
      .where((session) => session.id.startsWith('attacker_w${weekNum}_'))
      .toList();
  return weekSessions;
}
```

**Location:** Lines 228-261

## Data Architecture

### Programs
- **New:** `hockey_attacker_2025` → Uses AttackerProgramData
- **Legacy:** `hockey_attacker_v1` → Uses old static JSON

### Sessions
- **New Format:** `attacker_w1_s1`, `attacker_w1_s2`, `attacker_w1_s3`, etc.
  - Week: 1-5 (1-based in ID)
  - Session: 1-3 (1-based in ID)
  - Source: `attacker_program_data.dart`
  
- **Legacy Format:** `week1_session1`, `week1_session2`, etc.
  - Source: Static JSON in `local_session_source.dart`

### Exercises
- **Source:** `hockey_exercises_database.dart`
- **Count:** 100+ exercises with proper categorization
- **IDs:** `back_squat`, `deadlift`, `bench_press`, `dynamic_warmup_ramp`, etc.

## Data Flow

```
1. Hub Screen → Navigate to /session/hockey_attacker_2025/0/0
                                    ↓ (week 0, session 0)
                                    
2. Session Player Screen receives parameters:
   - programId: 'hockey_attacker_2025'
   - week: '0'
   - session: '0'
                                    ↓
                                    
3. _sessionProvider constructs sessionId:
   - weekNum = 0 + 1 = 1
   - sessionNum = 0 + 1 = 1
   - sessionId = 'attacker_w1_s1'
                                    ↓
                                    
4. SessionRepository.getById('attacker_w1_s1')
                                    ↓
                                    
5. LocalSessionSource checks if starts with 'attacker_w' ✓
                                    ↓
                                    
6. AttackerProgramData.getSessionById('attacker_w1_s1')
   Returns Session with exercise blocks
                                    ↓
                                    
7. For each exercise block:
   _exerciseProvider(block.exerciseId)
                                    ↓
                                    
8. ExerciseRepository.getById(exerciseId)
                                    ↓
                                    
9. LocalExerciseSource.getExerciseById(exerciseId)
                                    ↓
                                    
10. HockeyExercisesDatabase.getExerciseById(exerciseId)
    Returns Exercise with all details
```

## Current Architecture Compliance

✅ **SSOT (Single Source of Truth)**
- Static data in datasources (exercises, programs, sessions)
- Dynamic data in Hive storage (user progress, state)

✅ **Data Persistence**
- Exercise database: Static JSON in dart files
- Program definitions: Static JSON in dart files
- User state: Persisted in Hive

✅ **Repository Pattern**
- Domain repositories define interfaces
- Repository implementations use datasources
- Clean separation of concerns

## Testing Status

✅ All session IDs match between AttackerProgramData and session player
✅ All exercise IDs match between AttackerProgramData and HockeyExercisesDatabase
✅ No linter errors (only minor warnings about deprecated methods)
✅ Data flow verified through code inspection

## Next Steps

The session player should now work correctly with the attacker program. When you:
1. Start the hockey_attacker_2025 program
2. Click "Start Next Session" from the hub
3. It will properly load the session and all exercises

## Minor Linting Warnings (Non-Critical)

- 6 info-level warnings about deprecated `withOpacity` method (should use `withValues()`)
- 2 info-level warnings about missing curly braces in if statements

These can be fixed later as they don't affect functionality.

