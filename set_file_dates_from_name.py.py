import os
import re
import time
from datetime import datetime

# Since home directory path format can vary based on OS, os.path.expanduser is used to direct to home directory
FOLDER_PATH = os.path.expanduser('~/Desktop/memories')

# Regex to extract date from filenames like YYYY-MM-DD_rest.ext
date_regex = re.compile(r'^(\d{4})-(\d{2})-(\d{2})')


def update_timestamps(folder):
    # For every file within the folder
    for file in os.listdir(folder):
        match = date_regex.match(file)

        if not match:
            print(f"Skipped (no date): {file}")
            continue

        # Map a year. month, and day variable to the regex groups values (apply int() to each string).
        # Groups are declared through the (), so year it group 1 and so on...
        year, month, day = map(int, match.groups())

        # Make a datetime object using the mapped int values
        # These objects can be used by time.mktime
        date_obj = datetime(year, month, day)

        # Function that converts datetime obj into a UNIX timestamp since the epoch
        timestamp = time.mktime(date_obj.timetuple())

        # Save a filepath variable combining the folder and file name (upper_dir/directory/file.jpg)
        filepath = os.path.join(folder, file)

        try:
            # ps.utime: "Set the access and modified times of the file specified by path."
            # Set current file at 'filepath' access time and modficiation time to what is specified in the filename
            os.utime(filepath, (timestamp, timestamp))
            print(f"Updated: {file} creation date to {date_obj.date()}")
        except Exception as e:
            print(f"Failed to update {file}: {e}")


update_timestamps(FOLDER_PATH)
