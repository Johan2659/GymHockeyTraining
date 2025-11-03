# Extras Presentation Widgets

This directory contains reusable widget components for the Extra Session Player feature.

## Architecture Overview

The extra session player has been refactored to follow clean architecture principles:

### Main Screen
- **`extra_session_player_screen.dart`**: Main screen managing the session state and navigation

### Widget Components

#### 1. IntervalTimerWidget (`interval_timer_widget.dart`)
A modern circular timer for interval-based exercises.

**Features:**
- Work/Rest phase visualization
- Pause/Resume/Stop controls
- Responsive sizing for different screen sizes
- Custom painter for circular progress
- Visual feedback with colors (Green for work, Orange for rest)

**Usage:**
```dart
IntervalTimerWidget(
  exercise: exercise,
  onStart: () => _startTimer(),
  isActive: _isTimerActive,
  isPaused: _isTimerPaused,
  isWorkPhase: _isWorkPhase,
  currentPhaseSeconds: _currentPhaseSeconds,
  workDuration: _workDuration,
  restDuration: _restDuration,
  onPause: () => _pauseTimer(),
  onResume: () => _resumeTimer(),
  onStop: () => _stopTimer(),
)
```

#### 2. SetsTrackerWidget (`sets_tracker_widget.dart`)
Displays and manages set completion tracking.

**Features:**
- Visual set completion status
- Interactive set pills
- Active set indicator during timer
- Animated state transitions

**Usage:**
```dart
SetsTrackerWidget(
  totalSets: exercise.sets,
  completedSets: _completedSets,
  currentActiveSet: _currentActiveSet,
  isTimerActive: _isTimerActive,
  isWorkPhase: _isWorkPhase,
  onToggleSet: (setIndex) => _toggleSet(setIndex),
)
```

#### 3. ExerciseCardWidget (`exercise_card_widget.dart`)
Complete exercise card combining all exercise information.

**Features:**
- Exercise header with number and completion status
- Exercise details (sets, reps/duration, rest)
- Placeholder indicator
- Responsive layout (compact vs expanded)
- Integrates timer and sets tracker

**Layout Modes:**
- **Compact** (height < 660px): Scrollable layout for smaller screens
- **Expanded** (height >= 660px): Fixed layout with centered timer

## Benefits of This Architecture

### 1. **Separation of Concerns**
- Each widget has a single responsibility
- Easy to understand and maintain
- Clear widget hierarchy

### 2. **Reusability**
- Widgets can be used independently
- Easy to test in isolation
- Can be reused in other features if needed

### 3. **Layout Flexibility**
- Responsive design built-in
- Easier to modify spacing and positioning
- No more mystery spacing issues

### 4. **Maintainability**
- Changes to timer don't affect sets tracker
- Easy to add new features
- Clear file organization

### 5. **Performance**
- Smaller widget rebuilds
- Better widget tree optimization
- Reduced unnecessary rebuilds

## File Structure

```
widgets/
├── README.md                      # This file
├── interval_timer_widget.dart     # Timer component
├── sets_tracker_widget.dart       # Sets tracking component
└── exercise_card_widget.dart      # Complete exercise card
```

## State Management

State is managed in the parent `ExtraSessionPlayerScreen`:
- Timer state (active, paused, phase, seconds)
- Set completion tracking
- Page navigation
- Session completion

Widgets receive state via props and communicate via callbacks.

## Design Patterns Used

1. **Composition over Inheritance**: Small, focused widgets composed together
2. **Unidirectional Data Flow**: State flows down, events flow up
3. **Single Responsibility**: Each widget does one thing well
4. **Responsive Design**: Adapts to different screen sizes

## Future Improvements

Potential enhancements:
- Add video player integration for exercise demos
- Add sound/haptic feedback for timer
- Add exercise history tracking
- Add alternative exercise suggestions
- Add rest timer between exercises

