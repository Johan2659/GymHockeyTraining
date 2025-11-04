#!/usr/bin/env python3
"""
Audit all strength exercises for correct tracksWeight values
"""
import re

with open('lib/data/datasources/hockey_exercises_database.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find all exercise blocks
pattern = r"'([a-z_0-9]+)': '''([^']*?)''',"
matches = re.findall(pattern, content, re.DOTALL)

print("STRENGTH EXERCISES - Checking tracksWeight logic:\n")
print("="*80)

issues = []

for exercise_id, exercise_json in matches:
    if '"category": "strength"' in exercise_json:
        has_tracks_weight = '"tracksWeight"' in exercise_json
        tracks_weight_value = 'true' in exercise_json and '"tracksWeight": true' in exercise_json
        
        # Extract name
        name_match = re.search(r'"name": "([^"]+)"', exercise_json)
        name = name_match.group(1) if name_match else exercise_id
        
        # Logic for what SHOULD track weight
        should_track = True
        
        # Bodyweight indicators
        if any(keyword in exercise_id.lower() or keyword in name.lower() for keyword in [
            'bodyweight', 'push_up', 'push-up', 'pull_up', 'pull-up', 
            'chin_up', 'dips', 'plank', 'bird_dog', 'dead_bug',
            'hollow', 'superman', 'wall_sit', 'inverted_row'
        ]):
            should_track = False
        
        # Jump/explosive movements (usually bodyweight)
        if 'jump' in exercise_id.lower() or 'jump' in name.lower():
            should_track = False
            
        # Check if it's wrong
        if has_tracks_weight:
            if should_track and not tracks_weight_value:
                print(f"❌ {exercise_id:35} -> FALSE (should be TRUE)")
                print(f"   Name: {name}")
                issues.append((exercise_id, 'false', 'true'))
            elif not should_track and tracks_weight_value:
                print(f"⚠️  {exercise_id:35} -> TRUE (should be FALSE)")
                print(f"   Name: {name}")
                issues.append((exercise_id, 'true', 'false'))
            else:
                print(f"✓  {exercise_id:35} -> {str(tracks_weight_value).upper()}")

print("\n" + "="*80)
print(f"\nFound {len(issues)} issues to fix")

if issues:
    print("\nFixes needed:")
    for ex_id, current, should_be in issues:
        print(f"  - {ex_id}: {current} -> {should_be}")
