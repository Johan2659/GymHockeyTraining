# Production Optimization Script (PowerShell)
# Run this to complete the logger migration for remaining files

Write-Host "🔧 Starting Production Optimization..." -ForegroundColor Cyan

# Files to update
$files = @(
    "lib\data\repositories_impl\session_repository_impl.dart",
    "lib\data\repositories_impl\progress_repository_impl.dart",
    "lib\data\repositories_impl\program_state_repository_impl.dart",
    "lib\data\repositories_impl\program_repository_impl.dart",
    "lib\data\repositories_impl\profile_repository_impl.dart",
    "lib\data\repositories_impl\exercise_repository_impl.dart",
    "lib\data\repositories_impl\exercise_performance_repository_impl.dart",
    "lib\features\programs\application\program_management_controller.dart",
    "lib\data\datasources\goalie_program_data.dart",
    "lib\data\datasources\local_exercise_performance_source.dart",
    "lib\data\datasources\local_exercise_source.dart",
    "lib\data\datasources\extras\bonus_challenges.dart",
    "lib\data\datasources\extras\express_workouts.dart",
    "lib\data\datasources\extras\mobility_recovery.dart",
    "lib\data\datasources\local_session_source.dart",
    "lib\data\datasources\referee_program_data.dart",
    "lib\data\datasources\local_program_source.dart",
    "lib\data\datasources\local_extras_source.dart",
    "lib\data\datasources\extras_database.dart",
    "lib\data\datasources\hockey_exercises_database.dart",
    "lib\data\datasources\attacker_program_data.dart",
    "lib\data\datasources\defender_program_data.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "📝 Updating $file..." -ForegroundColor Yellow
        
        $content = Get-Content $file -Raw
        
        # Replace Logger import based on file location
        if ($file -match "repositories_impl" -or $file -match "application") {
            $content = $content -replace "import 'package:logger/logger.dart';", "import '../../core/logging/logger_config.dart';"
        } elseif ($file -match "extras\\") {
            $content = $content -replace "import 'package:logger/logger.dart';", "import '../../../core/logging/logger_config.dart';"
        } else {
            $content = $content -replace "import 'package:logger/logger.dart';", "import '../../core/logging/logger_config.dart';"
        }
        
        # Replace Logger() with AppLogger.getLogger()
        $content = $content -replace "static final _logger = Logger\(\);", "static final _logger = AppLogger.getLogger();"
        
        Set-Content $file $content -NoNewline
    } else {
        Write-Host "⚠️  File not found: $file" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ Logger migration complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run 'flutter analyze' to check for any issues"
Write-Host "2. Test the app in debug mode"
Write-Host "3. Build release APK: flutter build apk --release"
Write-Host "4. Test on physical device"
