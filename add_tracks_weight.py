#!/usr/bin/env python3
"""
Script to add tracksWeight property to all exercises in hockey_exercises_database.dart
Adds based on exercise category and naming patterns.
"""

import re

# Read the file
with open('lib/data/datasources/hockey_exercises_database.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Categories that don't track weight (bodyweight only)
NO_WEIGHT_CATEGORIES = [
    '"conditioning"',
    '"warmup"',
    '"recovery"',
    '"flexibility"',
    '"balance"',
    '"technique"',
    '"agility"',
    '"speed"',
]

# Exercise name patterns that don't track weight
NO_WEIGHT_PATTERNS = [
    'bodyweight',
    'jump',
    'burpee',
    'plank',
    'push_up',
    'push-up',
    'pull_up',
    'pull-up',
    'intervals',
    'sprint',
    'skate',
    'stretch',
    'mobility',
    'foam_roll',
]

def should_track_weight(exercise_json):
    """Determine if an exercise should track weight based on its content."""
    
    # Check if tracksWeight already exists
    if '"tracksWeight"' in exercise_json:
        return None  # Skip, already has the property
    
    # Check category
    for cat in NO_WEIGHT_CATEGORIES:
        if f'"category": {cat}' in exercise_json:
            return False
    
    # Check exercise name/id patterns
    exercise_lower = exercise_json.lower()
    for pattern in NO_WEIGHT_PATTERNS:
        if pattern in exercise_lower:
            return False
    
    # Check for weighted variants (these DO track weight)
    if 'weighted_' in exercise_lower or '"weight"' in exercise_lower:
        return True
    
    # Default: strength/power exercises track weight
    if '"category": "strength"' in exercise_json or '"category": "power"' in exercise_json:
        return True
    
    # Core and prevention - typically bodyweight unless specified
    if '"category": "core"' in exercise_json or '"category": "prevention"' in exercise_json:
        return False
    
    return True  # Default to tracking weight

def add_tracks_weight_to_exercise(match):
    """Add tracksWeight property to an exercise JSON."""
    exercise_json = match.group(0)
    
    should_track = should_track_weight(exercise_json)
    
    if should_track is None:
        return exercise_json  # Already has tracksWeight
    
    # Find the last closing brace before the triple quote
    # We want to add the property before the closing }
    lines = exercise_json.split('\n')
    
    # Find the line with the closing brace
    for i in range(len(lines) - 1, -1, -1):
        if '}' in lines[i] and "'''" not in lines[i]:
            # Add comma to previous line if it doesn't have one
            if i > 0 and not lines[i-1].strip().endswith(','):
                lines[i-1] = lines[i-1].rstrip() + ','
            
            # Insert tracksWeight before closing brace
            indent = '  '
            lines.insert(i, f'{indent}"tracksWeight": {str(should_track).lower()}')
            break
    
    return '\n'.join(lines)

# Pattern to match exercise definitions
# Matches: 'exercise_id': '''{...}''',
pattern = r"'[a-z_0-9]+': '''[^']*''',"

# Replace all exercises
content = re.sub(pattern, add_tracks_weight_to_exercise, content, flags=re.DOTALL)

# Write the file back
with open('lib/data/datasources/hockey_exercises_database.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Successfully added tracksWeight to all exercises!")
print("📝 Review the changes and test the app.")
