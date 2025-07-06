import pandas as pd
import io

def generate_dart_localization_file(csv_data):
    """
    Generates a Dart file content with localization maps from CSV data.

    Args:
        csv_data (str): The CSV data as a string.

    Returns:
        str: The content of the Dart localization file.
    """
    df = pd.read_csv(io.StringIO(csv_data))

    keys = df['key'].tolist()
    language_columns = [col for col in df.columns if col != 'key']

    dart_content = ""

    for lang_col in language_columns:
        map_name = f"engTo{lang_col.capitalize()}"  # e.g., engToEn, engToHi
        dart_content += f"Map<String, String> {map_name} = {{\n"
        for index, row in df.iterrows():
            key = row['key']
            value = row[lang_col]
            # Escape single quotes in values if they exist
            formatted_value = value.replace("'", "\\'") if isinstance(value, str) else str(value)
            dart_content += f"  '{key}': '{formatted_value}',\n"
        dart_content += "};\n\n"

    return dart_content


# 1. Specify the path to your CSV file
csv_file_path = 'translation.csv'

# 2. Read the content of the CSV file into a string
try:
    with open(csv_file_path, 'r', encoding='utf-8') as file:
        csv_input = file.read()
except FileNotFoundError:
    print(f"Error: The file '{csv_file_path}' was not found. Please ensure it's in the correct directory.")
    csv_input = "" # Set to empty to avoid errors if file not found
except Exception as e:
    print(f"An error occurred while reading the file: {e}")
    csv_input = ""

# 3. Generate the Dart code using the content from your CSV file
if csv_input: # Only proceed if CSV content was successfully read
    dart_code_output = generate_dart_localization_file(csv_input)

    # 4. Save the generated Dart code to a file
    output_file_name = "language_maps.dart"
    with open(output_file_name, "w", encoding="utf-8") as f:
        f.write(dart_code_output)
    print(f"Dart localization file '{output_file_name}' generated successfully!")
else:
    print("Dart file generation skipped due to error in reading CSV.")
