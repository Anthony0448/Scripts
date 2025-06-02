#!/bin/bash

DEFAULT_DIR="$HOME"

# List all files and directories (names only for display)
echo "Files and directories in $DEFAULT_DIR:"
items=("$DEFAULT_DIR"/*)  # Array of full paths
names=("${items[@]##*/}") # Extract just the names

echo "Select the server directory you would like to backup:"

# Use select to display only the names
select name in "${names[@]}"; do
    if [[ -n "$name" ]]; then
        # Map the name back to the full path
        selectedDirectory="$DEFAULT_DIR/$name"

        # If directory
        if [ -d "$selectedDirectory" ]; then
            echo "You selected the directory: $selectedDirectory"
            break
        # If file
        elif [ -f "$selectedDirectory" ]; then
            echo "You selected a file. Please select a directory."
        else
            echo "Invalid selectedDirectory. Try again."
        fi
    else
        echo "Invalid selectedDirectory. Try again."
    fi
done

# Use the selected directory in your script
echo "Proceeding with the directory: $selectedDirectory"

current_date=$(date +%m-%d_%H-%M_%Y)

# Double quote I guess.
sudo rsync -av "$selectedDirectory/" """$selectedDirectory""_""$current_date""/"

echo "Done! Backup created at ""$selectedDirectory""_""$current_date"""
