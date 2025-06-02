#!/bin/bash

# Define the base directory
base_dir="$HOME"

# List all files and directories (names only for display)
echo "Files and directories in $base_dir:"
items=("$base_dir"/*)     # Array of full paths
names=("${items[@]##*/}") # Extract just the names

# Use select to display only the names
select name in "${names[@]}"; do
    if [[ -n "$name" ]]; then
        # Map the name back to the full path
        choice="$base_dir/$name"

        if [ -d "$choice" ]; then
            echo "You selected the directory: $choice"
            break
        elif [ -f "$choice" ]; then
            echo "You selected a file. Please select a directory."
        else
            echo "Invalid choice. Try again."
        fi
    else
        echo "Invalid choice. Try again."
    fi
done

# Use the selected directory in your script
echo "Proceeding with the directory: $choice"
