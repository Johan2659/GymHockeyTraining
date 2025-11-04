#!/usr/bin/env python3
"""
Fix incorrectly classified tracksWeight values in hockey_exercises_database.dart
"""

# Read the file
with open('lib/data/datasources/hockey_exercises_database.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Define exercises that SHOULD track weight (currently false, but need to be true)
SHOULD_TRACK_WEIGHT = [
    'walking_lunge',
    'reverse_lunge', 
    'lateral_lunge',
    'split_squat',
    'split_squat_heavy',
    'single_leg_rdl',
    'goblet_squat',  # Definitely uses weight!
    'calf_raise',
    'standing_calf_raise',
    'dumbbell_row',
    'one_arm_dumbbell_row',
    'dumbbell_bench_press',
    'incline_dumbbell_press',
    'overhead_press',
    'arnold_press',
    'lateral_raise',
    'front_raise',
    'face_pulls',
    'shrugs',
    'bicep_curls',
    'hammer_curls',
    'tricep_extensions',
    'skull_crushers',
]

# Define exercises that should NOT track weight (currently true, but need to be false)
SHOULD_NOT_TRACK_WEIGHT = [
    'plank',
    'side_plank',
    'bird_dog',
    'dead_bug',
    'hollow_hold',
    'superman_hold',
    'push_up',
    'push_ups',
    'pull_up',
    'pull_ups',
    'chin_up',
    'chin_ups',
    'dips',
    'inverted_row',
    'pike_push_ups',
    'wall_sit',
    'glute_bridge',
    'single_leg_bridge',
    'leg_raise',
    'hanging_leg_raise',
]

def fix_tracks_weight(exercise_id, should_track):
    """Fix the tracksWeight value for a specific exercise."""
    # Pattern to match the exercise block
    pattern = f"'{exercise_id}': '''\\n{{[^}}]+\\n}}\\n''',"
    
    import re
    match = re.search(pattern, content, re.DOTALL)
    
    if match:
        exercise_block = match.group(0)
        # Check current value
        if '"tracksWeight": true' in exercise_block and not should_track:
            new_block = exercise_block.replace('"tracksWeight": true', '"tracksWeight": false')
            return content.replace(exercise_block, new_block)
        elif '"tracksWeight": false' in exercise_block and should_track:
            new_block = exercise_block.replace('"tracksWeight": false', '"tracksWeight": true')
            return content.replace(exercise_block, new_block)
    
    return content

# Apply fixes
new_content = content

print("Fixing exercises that SHOULD track weight:")
for exercise_id in SHOULD_TRACK_WEIGHT:
    old_content = new_content
    new_content = fix_tracks_weight(exercise_id, True)
    if old_content != new_content:
        print(f"  ✓ Fixed {exercise_id} -> true")

print("\nFixing exercises that should NOT track weight:")
for exercise_id in SHOULD_NOT_TRACK_WEIGHT:
    old_content = new_content
    new_content = fix_tracks_weight(exercise_id, False)
    if old_content != new_content:
        print(f"  ✓ Fixed {exercise_id} -> false")

# Write the file back
with open('lib/data/datasources/hockey_exercises_database.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("\n✅ Fixed all incorrectly classified exercises!")
