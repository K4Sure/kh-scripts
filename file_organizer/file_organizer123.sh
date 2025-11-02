#!/bin/bash
#
# file_organizer.sh – File Organizer with Duplicate Handling + Smart Renaming
# Version: v2.5.0
# Usage: org /path/to/folder
#

BASE_DIR="/storage/emulated/0/Download/Social Media"

# Check if GNU Parallel is available
check_parallel() {
    if ! command -v parallel &> /dev/null; then
        echo ">>> GNU Parallel not found. Installing..."
        if command -v pkg &> /dev/null; then
            pkg install parallel -y
        elif command -v apt &> /dev/null; then
            apt update && apt install parallel -y
        else
            echo ">>> Error: Cannot install GNU Parallel automatically."
            echo ">>> Please install manually: pkg install parallel"
            exit 1
        fi
    fi
}

# =====================
# AUTO-DETECT EXTRACTOR
# =====================
detect_extractor() {
    case "$target" in
        *Facebook*)  EXTRACTOR="Facebook" ;;
        *Instagram*) EXTRACTOR="Instagram" ;;
        *TikTok*)    EXTRACTOR="TikTok" ;;
        *YouTube*)   EXTRACTOR="YouTube" ;;
        *)           EXTRACTOR="Unknown" ;;
    esac
}

# =====================
# PARALLEL DUPLICATE CHECK FUNCTION
# =====================
check_duplicates() {
    echo ">>> Checking for duplicate files..."

    dupdir="$BASE_DIR/$EXTRACTOR/$EXTRACTOR Duplicates"
    mkdir -p "$dupdir"

    # Create temporary file for file list
    file_list=$(mktemp)
    
    # Find files and process with parallel
    find . -type f \( ! -name '.foldericon.png' ! -path '*/Insget/Insget Videos/*' ! -path '*/Insget/Insget Photos/*' \) -print0 > "$file_list"
    
    # Use parallel to compute MD5 hashes
    cat "$file_list" | parallel -0 -j+0 --progress --eta 'md5sum {}' 2>/dev/null \
    | sort \
    | awk -v dupdir="$dupdir" '
    {
        count[$1]++
        files[$1]=files[$1] "\n" $2
    }
    END {
        for (h in count) {
            if (count[h] > 1) {
                split(files[h], arr, "\n")
                n=0
                for (i in arr) {
                    if (arr[i] != "") {
                        if (n == 0) {
                            n++
                            continue
                        }
                        file=arr[i]
                        system("mv \"" file "\" \"" dupdir "\" > /dev/null 2>&1")
                    }
                }
            }
        }
    }'
    
    rm -f "$file_list"
}

# =====================
# PARALLEL RENAME / ORGANIZE FUNCTION (2-PASS)
# =====================
rename_files() {
    echo ">>> Renaming and organizing files..."

    shopt -s nullglob
    declare -A filegroups

    # ---- Pass 1: Count files per uploader/artist ----
    for f in *; do
        [ -f "$f" ] || continue
        ext="${f##*.}"

        case "$f" in
            *.jpg|*.jpeg|*.png|*.gif|*.webp)
                uploader=$(basename "$f" ".$ext")
                uploader=$(echo "$uploader" | sed 's/[[:space:]]/_/g' | sed 's/#.*//' | sed 's/[-0-9]*$//' | sed 's/_$//')
                key="PHOTO::$uploader"
                ;;
            *.mp4|*.mkv|*.avi|*.mov)
                uploader=$(basename "$f" ".$ext")
                uploader=$(echo "$uploader" | sed 's/[[:space:]]/_/g' | sed 's/#.*//' | sed 's/[-0-9]*$//' | sed 's/_$//')
                key="VIDEO::$uploader"
                ;;
            *.mp3|*.wav|*.m4a|*.aac|*.flac)
                artist=$(ffprobe -v error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$f" 2>/dev/null)
                [ -z "$artist" ] && artist=$(echo "$f" | cut -d'-' -f1)
                [ -z "$artist" ] && artist="Unknown"
                artist=$(echo "$artist" | sed 's/[[:space:]]/_/g')
                key="AUDIO::$artist"
                ;;
            *)
                continue
                ;;
        esac
        filegroups["$key"]=$((filegroups["$key"]+1))
    done

    # ---- Pass 2: Prepare file list for parallel processing ----
    file_list=$(mktemp)
    for f in *; do
        [ -f "$f" ] && echo "$f"
    done > "$file_list"

    # Process files in parallel
    export -f process_single_file
    export BASE_DIR EXTRACTOR
    declare -p filegroups > /tmp/filegroups.$$
    
    cat "$file_list" | parallel -j+0 --progress --eta process_single_file {} "$BASE_DIR" "$EXTRACTOR" /tmp/filegroups.$$
    
    rm -f "$file_list" /tmp/filegroups.$$
    shopt -u nullglob
}

# Function to process single file (used by parallel)
process_single_file() {
    local f="$1"
    local BASE_DIR="$2"
    local EXTRACTOR="$3"
    local filegroups_file="$4"
    
    # Source the filegroups array
    source "$filegroups_file" 2>/dev/null
    
    [ -f "$f" ] || return 0
    ext="${f##*.}"
    newname="$f"

    case "$f" in
        # =====================
        # PHOTOS
        # =====================
        *.jpg|*.jpeg|*.png|*.gif|*.webp)
            uploader=$(basename "$f" ".$ext")
            uploader=$(echo "$uploader" | sed 's/[[:space:]]/_/g' | sed 's/#.*//' | sed 's/[-0-9]*$//' | sed 's/_$//')
            key="PHOTO::$uploader"

            # Use a lock file for counter to avoid race conditions
            lock_file="/tmp/counter_${key}.lock"
            (
                flock -x 200
                if [ -f "/tmp/counter_${key}" ]; then
                    counter=$(cat "/tmp/counter_${key}")
                    counter=$((counter + 1))
                else
                    counter=1
                fi
                echo "$counter" > "/tmp/counter_${key}"
            ) 200>"$lock_file"

            newname=$(printf "%s_%03d.%s" "$uploader" "$counter" "$ext")

            if [ "${filegroups[$key]}" -gt 1 ]; then
                outdir="$BASE_DIR/$EXTRACTOR/$EXTRACTOR Photos/${uploader} Photos"
            else
                outdir="$BASE_DIR/$EXTRACTOR/$EXTRACTOR Photos/${EXTRACTOR} Mix Photos"
            fi
            ;;
        # =====================
        # VIDEOS
        # =====================
        *.mp4|*.mkv|*.avi|*.mov)
            uploader=$(basename "$f" ".$ext")
            uploader=$(echo "$uploader" | sed 's/[[:space:]]/_/g' | sed 's/#.*//' | sed 's/[-0-9]*$//' | sed 's/_$//')
            key="VIDEO::$uploader"

            # Use a lock file for counter to avoid race conditions
            lock_file="/tmp/counter_${key}.lock"
            (
                flock -x 200
                if [ -f "/tmp/counter_${key}" ]; then
                    counter=$(cat "/tmp/counter_${key}")
                    counter=$((counter + 1))
                else
                    counter=1
                fi
                echo "$counter" > "/tmp/counter_${key}"
            ) 200>"$lock_file"

            newname=$(printf "%s_%03d.%s" "$uploader" "$counter" "$ext")

            if [ "${filegroups[$key]}" -gt 1 ]; then
                outdir="$BASE_DIR/$EXTRACTOR/$EXTRACTOR Videos/${uploader} Videos"
            else
                outdir="$BASE_DIR/$EXTRACTOR/$EXTRACTOR Videos/${EXTRACTOR} Mix Videos"
            fi
            ;;
        # =====================
        # AUDIOS
        # =====================
        *.mp3|*.wav|*.m4a|*.aac|*.flac)
            artist=$(ffprobe -v error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$f" 2>/dev/null)
            track=$(ffprobe -v error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$f" 2>/dev/null)

            if [ -z "$artist" ]; then
                if [[ "$f" == *-* ]]; then
                    artist=$(echo "$f" | cut -d'-' -f1)
                    track=$(basename "$f" ".$ext" | cut -d'-' -f2-)
                else
                    artist="Unknown"
                    track=$(basename "$f" ".$ext")
                fi
            fi
            [ -z "$track" ] && track=$(basename "$f" ".$ext")

            artist=$(echo "$artist" | sed 's/[[:space:]]/_/g')
            newname="${artist} — ${track}.${ext}"

            key="AUDIO::$artist"
            if [ "${filegroups[$key]}" -gt 1 ]; then
                outdir="$BASE_DIR/$EXTRACTOR/$EXTRACTOR Audios/${artist} Audios"
            else
                outdir="$BASE_DIR/$EXTRACTOR/$EXTRACTOR Audios/${EXTRACTOR} Mix Audios"
            fi
            ;;
        # =====================
        # OTHERS
        # =====================
        *)
            outdir="$BASE_DIR/$EXTRACTOR/$EXTRACTOR Others"
            ;;
    esac

    mkdir -p "$outdir"
    mv -n "$f" "$outdir/$newname" > /dev/null 2>&1
}

# =====================
# CLEAN EMPTY FOLDERS
# =====================
clean_empty_dirs() {
    echo ">>> Cleaning empty uploader folders..."
    find "$BASE_DIR/$EXTRACTOR" -type d -empty \
        -not -path "$BASE_DIR/Instagram/Insget/Insget Videos" \
        -not -path "$BASE_DIR/Instagram/Insget/Insget Photos" \
        -delete > /dev/null 2>&1
    
    # Clean up temporary counter files
    rm -f /tmp/counter_* /tmp/filegroups.*
}

# =====================
# MAIN SCRIPT
# =====================
main() {
    target="$*"
    [ -z "$target" ] && target="."   # default = current dir if no arg

    cd "$target" || { echo "Error: cannot cd to $target"; exit 1; }

    # Check for GNU Parallel
    check_parallel

    detect_extractor
    echo ">>> Extractor detected: $EXTRACTOR"
    echo ">>> Using GNU Parallel for faster processing..."

    check_duplicates   # Step 1: Handle duplicates first
    rename_files       # Step 2: Organize + Rename
    clean_empty_dirs   # Step 3: Remove empty folders
    echo ">>> All done! (file_organizer.sh v2.5.0 with GNU Parallel)"
}

main "$@"
