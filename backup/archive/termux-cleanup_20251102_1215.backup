#!/data/data/com.termux/files/usr/bin/bash
# termux-cleanup.sh
# Script to identify and optionally remove large packages in Termux

echo "📦 Checking installed packages and their sizes..."
echo

# List packages with installed size (KB), sorted largest first
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 30 | column -t

echo
echo "Above are your 30 largest installed packages (size in KB)."
echo "You can choose which ones to uninstall."

while true; do
    read -p "Enter a package name to uninstall (or 'q' to quit): " pkg
    if [ "$pkg" = "q" ]; then
        echo "✅ Cleanup session ended."
        break
    fi
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "Removing $pkg..."
        apt remove -y "$pkg"
        apt autoremove -y
        echo "➡️  $pkg removed."
    else
        echo "⚠️  Package '$pkg' not found."
    fi
done
