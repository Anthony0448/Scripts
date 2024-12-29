DEFAULT_DIR="/home/opc"

# Ensure that the specified version directory does exist
while true; do
    # Get the current version of the modpack to know which directory to back up
    echo "Enter the current modpack version i.g. ($DEFAULT_DIR/Server-Files-2.11) is 2.11"
    read currentVersion

    # -d checks if specified path is a directory
    if [ -d "$DEFAULT_DIR/Server-Files-$currentVersion" ]; then
        echo "Directory exists"
        break
    else
        echo "$DEFAULT_DIR/Server-Files-$currentVersion does not exist"
    fi
done

# Line break
echo

while true; do
    # Prompt the download link for the new server files
    echo "Enter the direct download link for the new server files:"
    read url

    # Grabs filetype and stores as variable
    linkFileType=$(basename "$url")

    # Check if the file has a .zip extension
    if [[ "$linkFileType" == *.zip ]]; then
        echo "The file is a zip file. Downloading..."

        # The -P $DEFAULT_DIR specifies the destination directory ($DEFAULT_DIR) for the downloaded file.
        # The "$url" specifies the file to be downloaded from the given URL.
        # This ensures that the .zip file is saved directly into $DEFAULT_DIR, with its original filename.
        wget -P $DEFAULT_DIR "$url"

        # stop the loop
        break
    else
        echo "The file is not a zip file. Enter a zip file."

        echo
    # End of if statement
    fi
    # End of while loop
done

# Make a backup of the old version and store it in the backups directory

echo "Creating backup for $DEFAULT_DIR/Server-Files-$currentVersion"
# -a is archive, so it copies directoties and their permissions
# -v is verbose to print out each file that is copied to terminal
rsync -av --progress $DEFAULT_DIR/Server-Files-$currentVersion/ $DEFAULT_DIR/Backups/Server-Files-$currentVersion-Backup/

echo
echo "Backup complete! Stored in $DEFAULT_DIR/Backups/Server-Files-$currentVersion-Backup/"

# Get the version number of the new file
newVersion=$(echo "$url" | grep -oP 'Server-Files-\K[0-9]+\.[0-9]+(?=\.zip)')

echo "Unzipping..."
# The unzip command already makes a directory with the contents with the extraction, so just put it in ~
# -q is quiet
# -o overrides the prompt to confirm with sudo
sudo unzip -qo $DEFAULT_DIR/Server-Files-$newVersion.zip -d $DEFAULT_DIR/
# pv $DEFAULT_DIR/Server-Files-$newVersion.zip | unzip -q -d $DEFAULT_DIR/Server-Files-$newVersion/

# Delete zip since folder now exists
sudo rm -rf $DEFAULT_DIR/Server-Files-$newVersion.zip

# -r recursive
# -u overwrites existing files undonditionally
# /*: Ensures only the contents of the specified directories are copied, not the directories themselves.
cp -ru $DEFAULT_DIR/Server-Files-$currentVersion/{world,local,server.properties,eula.txt,journeymap,user_jvm_args.txt,whitelist.json} $DEFAULT_DIR/Server-Files-$newVersion/

# Remove the old version folder after copy completed
rm -rf $DEFAULT_DIR/Server-Files-$currentVersion

echo "DONE!"
