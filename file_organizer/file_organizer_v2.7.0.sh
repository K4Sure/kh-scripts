#!/bin/bash
#
# file_organizer.sh – File Organizer with Duplicate Handling + Smart Renaming
# Version: v2.7.0
# Usage: org /path/to/folder
#

BASE_DIR="/storage/emulated/0/Download/Social Media"

# =====================
# AUTO-DETECT EXTRACTOR
# =====================
detect_extractor() {
    # First check folder path
    case "$target" in
        *Facebook*)   EXTRACTOR="Facebook" ;;
        *Instagram*)  EXTRACTOR="Instagram" ;;
        *TikTok*)     EXTRACTOR="TikTok" ;;
        *YouTube*)    EXTRACTOR="YouTube" ;;
        *Pinterest*)  EXTRACTOR="Pinterest" ;;
        *)            EXTRACTOR="Unknown" ;;
    esac
    
    # If still unknown, check filenames for Pinterest URLs
    if [ "$EXTRACTOR" = "Unknown" ]; then
        for file in *; do
            if [[ -f "$file" ]]; then
                case "$file" in
                    *pinimg.com*|*pinterest.com*|*pin.it*|*pinterest.*)
                        EXTRACTOR="Pinterest"
                        break
                        ;;
                esac
            fi
        done
    fi
}

# =====================
# DUPLICATE CHECK FUNCTION
# =====================
check_duplicates() {
    echo ">>> Checking for duplicate files..."

    dupdir="$BASE_DIR/$EXTRACTOR/$EXTRACTOR Duplicates"
    mkdir -p "$dupdir"

    find . -type f ! -name '.foldericon.png' -print0 \
    | xargs -0 md5sum \
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
                        system("mv \"" file "\" \"" dupdir "\"")
                        print "Moved duplicate: " file " -> " dupdir
                    }
                }
            }
        }
    }'
}

# =====================
# PINTEREST FILENAME CLEANER
# =====================
clean_pinterest_name() {
    local name="$1"
    
    # Remove Pinterest URL patterns and parameters
    name=$(echo "$name" | sed -E '
        s/_[0-9a-f]{32}//g;           # Remove MD5 hashes
        s/-[0-9]+x[0-9]+//g;          # Remove dimensions like -236x354
        s/_pin[0-9]+//g;              # Remove pin numbers
        s/_[0-9]+_//g;                # Remove numeric sequences
        s/\.com[0-9]*//g;             # Remove .com and trailing numbers
        s/[0-9]+_//g;                 # Remove leading numbers with underscore
        s/^[0-9]+//g;                 # Remove leading numbers
        s/_$//g;                      # Remove trailing underscore
        s/__+/_/g;                    # Replace multiple underscores with single
    ')
    
    # Extract meaningful parts from Pinterest URLs
    if [[ "$name" =~ pinimg\.com.*[A-Za-z] ]]; then
        # Try to extract descriptive parts after the last slash or before parameters
        name=$(echo "$name" | sed -E 's/.*\/([^\/?]+).*/\1/')
    fi
    
    # If name became empty after cleaning, use a default
    if [ -z "$name" ] || [ "$name" = "." ] || [ "$name" = ".." ]; then
        name="Pinterest_Pin"
    fi
    
    echo "$name"
}

# =====================
# RENAME / ORGANIZE FUNCTION (2-PASS)
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
                if [ "$EXTRACTOR" = "Pinterest" ]; then
                    uploader=$(clean_pinterest_name "$uploader")
                else
                    uploader=$(echo "$uploader" | sed 's/[[:space:]]/_/g' | sed 's/#.*//' | sed 's/[-0-9]*$//' | sed 's/_$//')
                fi
                key="PHOTO::$uploader"
                ;;
            *.mp4|*.mkv|*.avi|*.mov)
                uploader=$(basename "$f" ".$ext")
                if [ "$EXTRACTOR" = "Pinterest" ]; then
                    uploader=$(clean_pinterest_name "$uploader")
                else
                    uploader=$(echo "$uploader" | sed 's/[[:space:]]/_/g' | sed 's/#.*//' | sed 's/[-0-9]*$//' | sed 's/_$//')
                fi
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

    # ---- Pass 2: Rename and move files ----
    declare -A counters

    for f in *; do
        [ -f "$f" ] || continue
        ext="${f##*.}"
        newname="$f"

        case "$f" in
            # =====================
            # PHOTOS
            # =====================
            *.jpg|*.jpeg|*.png|*.gif|*.webp)
                uploader=$(basename "$f" ".$ext")
                if [ "$EXTRACTOR" = "Pinterest" ]; then
                    uploader=$(clean_pinterest_name "$uploader")
                else
                    uploader=$(echo "$uploader" | sed 's/[[:space:]]/_/g' | sed 's/#.*//' | sed 's/[-0-9]*$//' | sed 's/_$//')
                fi
                
                key="PHOTO::$uploader"

                counters["$key"]=$((counters["$key"]+1))
                newname=$(printf "%s_%03d.%s" "$uploader" "${counters["$key"]}" "$ext")

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
                if [ "$EXTRACTOR" = "Pinterest" ]; then
                    uploader=$(clean_pinterest_name "$uploader")
                else
                    uploader=$(echo "$uploader" | sed 's/[[:space:]]/_/g' | sed 's/#.*//' | sed 's/[-0-9]*$//' | sed 's/_$//')
                fi
                
                key="VIDEO::$uploader"

                counters["$key"]=$((counters["$key"]+1))
                newname=$(printf "%s_%03d.%s" "$uploader" "${counters["$key"]}" "$ext")

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
        mv -n "$f" "$outdir/$newname"
        echo "Moved: $f -> $outdir/$newname"
    done

    shopt -u nullglob
}

# =====================
# CLEAN EMPTY FOLDERS
# =====================
clean_empty_dirs() {
    echo ">>> Cleaning empty uploader folders..."
    find "$BASE_DIR/$EXTRACTOR" -type d -empty -delete
}

# =====================
# MAIN SCRIPT
# =====================
main() {
    target="$*"
    [ -z "$target" ] && target="."   # default = current dir if no arg

    cd "$target" || { echo "Error: cannot cd to $target"; exit 1; }

    detect_extractor
    echo ">>> Extractor detected: $EXTRACTOR"

    check_duplicates   # Step 1: Handle duplicates first
    rename_files       # Step 2: Organize + Rename
    clean_empty_dirs   # Step 3: Remove empty folders
    echo ">>> All done! (file_organizer.sh v2.7.0)"
}

main "$@"
