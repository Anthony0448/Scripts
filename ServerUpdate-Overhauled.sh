#!/bin/bash

# Exit on error (-e), undefined variables (-u), and pipe failures (-o pipefail)
# -e: Exit immediately if a command exits with non-zero status
# -u: Treat unset variables as an error when substituting
# -o pipefail: Return value of a pipeline is the status of the last command to exit with non-zero status
set -euo pipefail

# Constants
DEFAULT_DIR="$HOME"                       # Use user's home directory instead of hardcoded path
BACKUP_DIR="$DEFAULT_DIR/Backups"         # Directory for storing backups
LOG_FILE="$DEFAULT_DIR/server_update.log" # Log file for tracking operations

# Logging function: Timestamps and logs messages to both console and log file
log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')      # Get current timestamp
    echo "[$timestamp] $1" | tee -a "$LOG_FILE" # -a flag appends to log file
}

# Error handling function: Logs error and exits with status 1
handle_error() {
    log "ERROR: $1"
    exit 1
}

# URL validation function: Checks if URL starts with http:// or https://
validate_url() {
    local url=$1
    if [[ ! $url =~ ^https?:// ]]; then # =~ operator for regex matching
        handle_error "Invalid URL format: $url"
    fi
}

# Main script starts here
log "Starting server update process"

# Create backup directory if it doesn't exist
# -p flag: Create parent directories if needed
mkdir -p "$BACKUP_DIR" || handle_error "Failed to create backup directory"
log "Backup directory verified at $BACKUP_DIR"

# List available directories
log "Scanning directories in $DEFAULT_DIR"
items=("$DEFAULT_DIR"/*)  # Array of all items in directory
names=("${items[@]##*/}") # Extract just the names without path

# Check if any directories were found
if [ ${#names[@]} -eq 0 ]; then # ${#names[@]} gets array length
    handle_error "No directories found in $DEFAULT_DIR"
fi

# Interactive directory selection
echo "Select the server directory you would like to update:"
select name in "${names[@]}"; do
    if [[ -n "$name" ]]; then # -n tests if string is non-empty
        old_version_dir="$DEFAULT_DIR/$name"
        
        if [ -d "$old_version_dir" ]; then # -d tests if path is a directory
            log "Selected directory: $old_version_dir"
            break
        else
            echo "Invalid selection. Please select a directory."
        fi
    else
        echo "Invalid selection. Please try again."
    fi
done

# URL input and validation loop
while true; do
    echo "Enter the direct download link for the new server files:"
    read -r url # -r prevents backslash escaping
    validate_url "$url"

    url_filename=$(basename "$url")         # Extract filename from URL
    if [[ "$url_filename" == *.zip ]]; then # Check if file is a zip
        log "Downloading zip file: $url_filename"
        wget -P "$DEFAULT_DIR" "$url" || handle_error "Download failed for URL: $url" # -P specifies download directory
        break
    else
        echo "Error: Only .zip files are supported. Please provide a valid zip file URL."
    fi
done

# Create backup with timestamp
current_date=$(date +%m-%d_%H-%M_%Y) # Format: MM-DD_HH-MM_YYYY
backup_path="$BACKUP_DIR/$(basename "$old_version_dir")_$current_date"

# Create backup using rsync
# -a flag: Archive mode (preserves permissions, timestamps, etc.)
log "Creating backup at $backup_path"
rsync -a "$old_version_dir"/ "$backup_path"/ || handle_error "Backup failed"

# Verify backup was created
if [ ! -d "$backup_path" ]; then # -d tests if path is a directory
    handle_error "Backup directory was not created successfully"
fi
log "Backup completed successfully"

# Extract new server files
# -q flag: Quiet mode (suppresses output)
log "Extracting new server files"
unzip -q "$DEFAULT_DIR/$url_filename" -d "$DEFAULT_DIR" || handle_error "Failed to extract zip file"
rm -f "$DEFAULT_DIR/$url_filename" # -f flag: Force removal without prompting
log "Removed downloaded zip file"

# Copy server data to new version
# -r flag: Recursive copy
# -u flag: Update (only copy if source is newer than destination)
new_server_dir="$DEFAULT_DIR/$(basename "$url_filename" .zip)"
log "Copying server data to new version"
cp -ru "$old_version_dir"/{world,local,server.properties,eula.txt,journeymap,user_jvm_args.txt,whitelist.json,ops.json} "$new_server_dir" || handle_error "Failed to copy server data"

# Remove old version
# -r flag: Recursive removal
# -f flag: Force removal without prompting
log "Removing old version directory"
rm -rf "$old_version_dir"

# Start the server
log "Starting server"
chmod +x "$new_server_dir/startserver.sh" # Make start script executable
"$new_server_dir/startserver.sh"

log "Server update process completed successfully"
