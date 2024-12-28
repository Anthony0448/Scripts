# Ensure that the specified version directory does exist
while true; do
    # Get the current version of the modpack to know which directory to back up
    echo "Enter the current modpack version i.g. (/home/opc/Server-Files-2.11) is 2.11"
    read currentVersion

    # -d checks if specified path is a directory
    if [ -d "/home/opc/Server-Files-$currentVersion" ]; then
        echo "Directory exists"
        break
    else
        echo "/home/opc/Server-Files-$currentVersion does not exist"
    fi
done

echo "Creating backup for /home/opc/Server-Files-$currentVersion"
# -a is archive, so it copies directoties and their permissions
# -v is verbose to print out each file that is copied to terminal
rsync -av --progress /home/opc/Server-Files-$currentVersion/ /home/opc/Backups/Server-Files-$currentVersion-Backup/

echo
echo "Backup complete! Stored in /home/opc/Backups/Server-Files-$currentVersion-Backup/"

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
        
        wget -P /home/opc/ "$url"

    # stop the loop
        break
    else
        echo "The file is not a zip file. Enter a zip file."

        echo
    # End of if statement
    fi
# End of while loop
done

# Get the version number of the new file
newVersion=$(echo "$url" | grep -oP 'Server-Files-\K[0-9]+\.[0-9]+(?=\.zip)')

echo "Unzipping..."
# The unzip command already makes a directory with the contents with the extraction, so just put it in ~
sudo unzip -qo /home/opc/Server-Files-$newVersion.zip -d  /home/opc/
# pv /home/opc/Server-Files-$newVersion.zip | unzip -q -d /home/opc/Server-Files-$newVersion/

# Delete zip since folder now exists
sudo rm -rf /home/opc/Server-Files-$newVersion.zip

# -r recursive
# -u overwrites existing files undonditionally
# /*: Ensures only the contents of the specified directories are copied, not the directories themselves.
cp -ru /home/opc/Server-Files-$newVersion/{mods,config,libraries,defaultconfigs,packmenu} /home/opc/Server-Files-$currentVersion/

# Remove the unzipped folder after copy completed
rm -rf /home/opc/Server-Files-$newVersion

# Rename now updated server directory to updated version
mv /home/opc/Server-Files-$currentVersion /home/opc/Server-Files-$newVersion