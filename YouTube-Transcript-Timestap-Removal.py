import re


def remove_timestamp_lines(input_file, output_file):
    pattern = re.compile(r'\b(?:\d{1,2}:)?\d{2}:\d{2}\b|\b\d{1,2}:\d{2}\b')

    with open(input_file, 'r', encoding='utf-8') as infile, open(output_file, 'w', encoding='utf-8') as outfile:
        for line in infile:
            if not pattern.search(line):
                outfile.write(line)


# Replace with your input file name
input_filename = '/Users/anthony/Desktop/Line/VIDEO TITLE.txt'
output_filename = "output.txt"  # Replace with your desired output file name

remove_timestamp_lines(input_filename, output_filename)
print(f"Processed file saved as {output_filename}")
