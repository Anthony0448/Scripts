#!/bin/bash

DEFAULT_DIR="/home/opc"
BACKUP_DIR="$DEFAULT_DIR/Backups"

# List all files and directories (names only for display)
echo "Files and directories in $DEFAULT_DIR:"
items=("$DEFAULT_DIR"/*)  # Array of full paths
names=("${items[@]##*/}") # Extract just the names

echo "Select the server directory you would like to update:"

# Use select to display only the names
select name in "${names[@]}"; do
    if [[ -n "$name" ]]; then
        # Map the name back to the full path
        oldVersionDirectory="$DEFAULT_DIR/$name"

        # If directory
        if [ -d "$oldVersionDirectory" ]; then
            echo "You selected the directory: $oldVersionDirectory"
            break
        # If file
        elif [ -f "$oldVersionDirectory" ]; then
            echo "You selected a file. Please select a directory."
        else
            echo "Invalid oldVersionDirectory. Try again."
        fi
    else
        echo "Invalid oldVersionDirectory. Try again."
    fi
done

# Use the selected directory in your script
echo "Proceeding with the directory: $oldVersionDirectory"

# Line break
echo

while true; do
    # Prompt the download link for the new server files
    echo "Enter the direct download link for the new server files:"
    read -r url
    echo

    # Grabs file download as name. Name of download
    urlFileName=$(basename "$url")

    # Check if the file has a .zip extension
    if [[ "$urlFileName" == *.zip ]]; then
        echo "The file is a zip file. Downloading..."

        # The -P $DEFAULT_DIR specifies the destination directory ($DEFAULT_DIR) for the downloaded file.
        # The "$url" specifies the file to be downloaded from the given URL.
        # This ensures that the .zip file is saved directly into $DEFAULT_DIR, with its original filename.
        # Has check for error downloading
        wget -P "$DEFAULT_DIR" "$url" || {
            echo "Download failed for URL: $url. Exiting script."
            exit 1
        }

        # Check if the zip file exists
        if [ ! -f "$DEFAULT_DIR/$urlFileName" ]; then
            echo "Zip file does not exist. Check link or code :("
        else
            echo "Zip file successfully downloaded and found!"
            # Stop the loop. Zip exists
            break
        fi
    else
        echo "The file is not a zip file. Enter a zip file."

        echo
    # End of if statement
    fi
    # End of while loop
done

# Create a backup in the Backups directory

# Append current date date to the directory to not overwrite old directories just in case + adds date reference
# Get current date and time in YYYY-MM-DD_HH-MM format
current_date=$(date +%Y-%m-%d_%H-%M)

# Old directory name
# ServerFiles-: Matches the literal string ServerFiles-.
# [0-9]*: Matches any number of digits for the major version.
# \.: Matches a literal dot (.).
# [0-9]*: Matches any number of digits for the minor version.
# The -o option in grep stands for "only matching". When used, it tells grep to output only the parts of the input that match the specified regular expression, rather than the entire line that contains the match.
oldDirectoryName=$(echo "$oldVersionDirectory" | grep -o "ServerFiles-[0-9]*\.[0-9]*")

echo "Creating a backup of $oldVersionDirectory in $BACKUP_DIR/""$oldDirectoryName""_$current_date/"
echo "Copying..."

sudo rsync -a "$oldVersionDirectory"/ $BACKUP_DIR/"$oldDirectoryName"_"$current_date"/

# If the directory does not exist...exit
if [ ! -d $BACKUP_DIR/"$oldDirectoryName"_"$current_date" ]; then
    echo "Backup does not exist! Exiting..."

    exit 1
else
    echo
    # Double quote bs to prevent error in echo
    echo "Backup complete! Stored in $BACKUP_DIR/""$oldDirectoryName""_""$current_date"""
fi

# At this point the zip should be downloaded and the backup should be made
# Proceed with extraction and moving files

# newVersionNum=$(echo "$url" | grep -oP 'ServerFiles-\K[0-9]+\.[0-9]+(?=\.zip)')

echo "Unzipping..."

# The unzip command already makes a directory with the contents with the extraction.
# -q is quiet
# -o overrides the prompt to confirm with sudo
# Last part removes the .zip
sudo unzip -q "$DEFAULT_DIR/$urlFileName" -d "$DEFAULT_DIR/"

sudo cp -ru "$oldVersionDirectory"/{world,local,server.properties,eula.txt,journeymap,user_jvm_args.txt,whitelist.json} "$DEFAULT_DIR/$(basename "$urlFileName" .zip)"
