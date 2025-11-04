import re
import json

# Read the file
file_path = r'd:\flutter_projects\GymHockeyTraining\lib\data\datasources\hockey_exercises_database.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Function to update youtube query based on exercise name
def update_youtube_query(match):
    exercise_json = match.group(0)
    
    try:
        # Extract the JSON content
        json_start = exercise_json.find('{')
        json_end = exercise_json.rfind('}') + 1
        json_str = exercise_json[json_start:json_end]
        
        # Parse JSON
        exercise_data = json.loads(json_str)
        
        # Get exercise name and create new youtube query
        exercise_name = exercise_data.get('name', '')
        if exercise_name:
            # Create new youtube query: exercise name + hockey
            new_query = f"{exercise_name.lower()} hockey"
            
            # Update the youtubeQuery in the original string
            updated_json = re.sub(
                r'"youtubeQuery"\s*:\s*"[^"]*"',
                f'"youtubeQuery": "{new_query}"',
                exercise_json
            )
            
            print(f"Updated: {exercise_name} -> {new_query}")
            return updated_json
        
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
        return exercise_json
    
    return exercise_json

# Pattern to match each exercise definition (from opening ''' to closing ''')
pattern = r"'''[^']*?{[^}]*?}[^']*?'''"

# Replace all matches
updated_content = re.sub(pattern, update_youtube_query, content, flags=re.DOTALL)

# Write back to file
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(updated_content)

print("\n✓ Successfully updated all YouTube queries!")
print(f"File updated: {file_path}")
