#!/bin/bash
# Production Optimization Script
# Run this to complete the logger migration for remaining files

echo "🔧 Starting Production Optimization..."

# Files to update (add AppLogger import and replace Logger())
FILES=(
  "lib/data/repositories_impl/session_repository_impl.dart"
  "lib/data/repositories_impl/progress_repository_impl.dart"
  "lib/data/repositories_impl/program_state_repository_impl.dart"
  "lib/data/repositories_impl/program_repository_impl.dart"
  "lib/data/repositories_impl/profile_repository_impl.dart"
  "lib/data/repositories_impl/exercise_repository_impl.dart"
  "lib/data/repositories_impl/exercise_performance_repository_impl.dart"
  "lib/features/programs/application/program_management_controller.dart"
  "lib/data/datasources/goalie_program_data.dart"
  "lib/data/datasources/local_exercise_performance_source.dart"
  "lib/data/datasources/local_exercise_source.dart"
  "lib/data/datasources/extras/bonus_challenges.dart"
  "lib/data/datasources/extras/express_workouts.dart"
  "lib/data/datasources/extras/mobility_recovery.dart"
  "lib/data/datasources/local_session_source.dart"
  "lib/data/datasources/referee_program_data.dart"
  "lib/data/datasources/local_program_source.dart"
  "lib/data/datasources/local_extras_source.dart"
  "lib/data/datasources/extras_database.dart"
  "lib/data/datasources/hockey_exercises_database.dart"
  "lib/data/datasources/attacker_program_data.dart"
  "lib/data/datasources/defender_program_data.dart"
)

for FILE in "${FILES[@]}"; do
  if [ -f "$FILE" ]; then
    echo "📝 Updating $FILE..."
    
    # Replace Logger import with AppLogger import
    sed -i "s/import 'package:logger\/logger.dart';/import '..\/..\/core\/logging\/logger_config.dart';/g" "$FILE"
    
    # For datasources, adjust the path
    sed -i "s/import 'package:logger\/logger.dart';/import '..\/..\/..\/core\/logging\/logger_config.dart';/g" "$FILE"
    
    # Replace Logger() with AppLogger.getLogger()
    sed -i "s/static final _logger = Logger();/static final _logger = AppLogger.getLogger();/g" "$FILE"
  else
    echo "⚠️  File not found: $FILE"
  fi
done

echo "✅ Logger migration complete!"
echo ""
echo "Next steps:"
echo "1. Run 'flutter analyze' to check for any issues"
echo "2. Test the app in debug mode"
echo "3. Build release APK: flutter build apk --release"
echo "4. Test on physical device"
