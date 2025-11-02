#!/bin/bash
# Save this as check_urls.sh

INPUT_FILE="/storage/emulated/0/Download/1DMP/Settings/1DM_Data_2025-10-10-17-52-31/1dm+_hosts_&_filters.txt"
OUTPUT_FILE="url_analysis_summary.txt"

echo "URL | File Size | SHA256 Hash" > $OUTPUT_FILE
echo "--- | --- | ---" >> $OUTPUT_FILE

while read url; do
    if [ -n "$url" ]; then
        echo "Processing: $url"
        
        # Get file size
        size=$(curl -s -I "$url" | grep -i "content-length" | tail -1 | awk '{print $2}' | tr -d '\r')
        if [ -z "$size" ]; then
            size="Unknown"
        else
            size="${size} bytes"
        fi
        
        # Get file hash
        hash=$(curl -s -L "$url" | sha256sum | awk '{print $1}')
        if [ -z "$hash" ] || [ "$hash" = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]; then
            hash="Failed/Empty"
        fi
        
        echo "$url | $size | $hash" >> $OUTPUT_FILE
    fi
done < "$INPUT_FILE"

echo "Analysis complete. Results saved to $OUTPUT_FILE"
