#!/bin/bash

set -euo pipefail # Exit on error, undefined variable, or pipe failure

# --- Configuration ---
DEFAULT_BITRATE="192k"
DEFAULT_MUSIC_DIR="/music"
DEFAULT_APP_DIR="/app"
DEFAULT_EXCLUDE_FILE_NAME="exclude_paths.list"

# --- Read Environment Variables ---
BITRATE="${BITRATE:-$DEFAULT_BITRATE}"
MUSIC_DIR="${MUSIC_DIR:-$DEFAULT_MUSIC_DIR}"
APP_DIR="${APP_DIR:-$DEFAULT_APP_DIR}"
EXCLUDE_FILE_NAME="${EXCLUDE_FILE_NAME:-$DEFAULT_EXCLUDE_FILE_NAME}"
EXCLUDE_FILE_PATH="${APP_DIR}/${EXCLUDE_FILE_NAME}"

# --- Helper Functions ---
log_info() {
    echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log_warn() {
    echo "[WARN] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $1" >&2
}

# --- Main Script ---
log_info "Starting FLAC to Opus conversion script."
log_info "Bitrate: $BITRATE"
log_info "Music directory: $MUSIC_DIR"
log_info "Exclusion file path: $EXCLUDE_FILE_PATH (from EXCLUDE_FILE_NAME: $EXCLUDE_FILE_NAME)"

if [ ! -d "$MUSIC_DIR" ]; then
    log_error "Music directory '$MUSIC_DIR' not found. Mount your music library to this path."
    exit 1
fi

cd "$MUSIC_DIR" || { log_error "Failed to change directory to '$MUSIC_DIR'."; exit 1; }
log_info "Changed working directory to $(pwd)"

# Base find arguments
# -mindepth 2: As per your original script, processes files in subdirectories, not the root of MUSIC_DIR.
find_args=("."; "-mindepth"; "2"; "-type"; "f"; "-name"; "*.flac")

if [ -f "$EXCLUDE_FILE_PATH" ]; then
    log_info "Applying exclusions from $EXCLUDE_FILE_PATH"
    while IFS= read -r line; do
        # Trim leading/trailing whitespace
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        # Skip empty lines or comments
        if [[ -z "$line" || "$line" == \#* ]]; then
            continue
        fi
        
        # Ensure path starts with ./ for find's -path predicate when searching from .
        # Example: if line is "EVA OST/*", it becomes "./EVA OST/*"
        local_path_pattern="$line"
        if [[ "$local_path_pattern" != "./"* ]]; then
            local_path_pattern="./$local_path_pattern"
        fi

        log_info "Excluding pattern: ${local_path_pattern}"
        find_args+=("-not"; "-path"; "${local_path_pattern}")
    done < "$EXCLUDE_FILE_PATH"
else
    log_warn "Exclusion file '$EXCLUDE_FILE_PATH' not found. No paths will be excluded."
fi

# Subshell script for -exec
# $1 will be BITRATE, subsequent arguments ($@) will be file paths
exec_script='
    BITRATE_FOR_CONVERSION="$1" 
    shift # Remove bitrate from argument list, remaining are files
    for filepath do
        dir=$(dirname "$filepath")
        # Get filename without .flac extension
        filename_no_ext=$(basename "$filepath" .flac) 
        output_file="$dir/$filename_no_ext.opus"

        echo "[CONVERT] Converting: \"$filepath\" to \"$output_file\" with bitrate $BITRATE_FOR_CONVERSION"
        if ffmpeg -nostdin -loglevel error -i "$filepath" -c:a libopus -b:a "$BITRATE_FOR_CONVERSION" "$output_file"; then
            echo "[SUCCESS] Converted: \"$filepath\". Removing original."
            rm "$filepath"
        else
            echo "[FAILURE] Error converting: \"$filepath\". Original not removed."
        fi
    done
'
# Add the -exec part to find_args
# "bash_exec_script" is a placeholder for $0 in the subshell
find_args+=("-exec"; "bash"; "-c"; "$exec_script"; "bash_exec_script"; "$BITRATE"; "{}"; "+")

log_info "Starting find and convert process..."
# Execute the find command
if ! find "${find_args[@]}"; then
    log_warn "The find command may have encountered issues with some files."
    # The script continues due to set -e not being triggered by find's exec returning non-zero for some items
fi

log_info "Conversion process finished."

log_info "Listing folders that might still contain FLAC files (if any were skipped, failed, or newly added):"
# This command might find nothing if all FLACs are converted.
if find . -type f -name "*.flac" -printf '%h\n' 2>/dev/null | sort -u | grep -q '.'; then
    find . -type f -name "*.flac" -printf '%h\n' | sort -u
else
    log_info "No FLAC files found after conversion attempt."
fi

log_info "Script finished successfully."
