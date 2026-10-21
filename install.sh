#!/usr/bin/env bash
# Install or upgrade the widget for the current user (Plasma 6).
set -euo pipefail
cd "$(dirname "$0")"

ID="com.github.rifkiaz.macosbattery"

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "kpackagetool6 not found. Install it first:" >&2
    echo "  openSUSE:     sudo zypper install kf6-kpackage" >&2
    echo "  Fedora:       sudo dnf install kf6-kpackage" >&2
    echo "  Arch:         sudo pacman -S kpackage" >&2
    echo "  Debian/Ubuntu/KDE neon: sudo apt install kpackagetool6" >&2
    exit 1
fi

if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -q "$ID"; then
    kpackagetool6 --type Plasma/Applet --upgrade package
else
    kpackagetool6 --type Plasma/Applet --install package
fi

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/plasmashell/qmlcache"
if [ -d "$CACHE" ]; then
    rm -rf "$CACHE"
fi

echo
echo "Done. Right-click the panel or desktop > Add Widgets… and search for \"macOS Battery\"."
echo "If you upgraded an existing copy, restart Plasma to reload it:"
echo "  systemctl --user restart plasma-plasmashell"
