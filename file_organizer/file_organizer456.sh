#!/bin/bash
#
# file_organizer.sh – File Organizer with Duplicate Handling + Smart Renaming
# Version: v2.5.0
# Usage: org /path/to/folder
#

BASE_DIR="/storage/emulated/0/Download/Social Media"

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
                uploader=$(echo "$uploader" | sed 's/[[:space:]]/_/g' | sed 's/#.*//' | sed 's/[-0-9]*$//' | sed 's/_$//')
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
                uploader=$(echo "$uploader" | sed 's/[[:space:]]/_/g' | sed 's/#.*//' | sed 's/[-0-9]*$//' | sed 's/_$//')
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
    echo ">>> All done! (file_organizer.sh v2.5.0)"
}

main "$@"

