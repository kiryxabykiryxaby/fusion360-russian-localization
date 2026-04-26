#!/bin/bash
# Install Russian localization into Fusion 360 (macOS)
# Sources: ./files/ru-RU, ./files/ru-html, ./files/ru-html.html, ./files/russian_ru.xml
#
# IMPORTANT: this script intentionally does NOT call codesign.
# Re-signing the bundle would break Identity Manager IPC handshake → login fails.
# We only add resources; the original Autodesk Mach-O signature stays intact.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FILES="$SCRIPT_DIR/files"
WEBDEPLOY="$HOME/Library/Application Support/Autodesk/webdeploy/production"

# 1) Sanity checks
if [ ! -d "$FILES/ru-RU" ] || [ ! -d "$FILES/ru-html" ] || [ ! -f "$FILES/russian_ru.xml" ]; then
  echo "❌ Missing translation files in $FILES"
  echo "   Make sure the script is run from the repo root."
  exit 1
fi

if [ ! -d "$WEBDEPLOY" ]; then
  echo "❌ Fusion 360 install not found:"
  echo "   $WEBDEPLOY"
  echo "   Install Fusion from https://www.autodesk.com/products/fusion-360 first."
  exit 1
fi

if pgrep -fq "Autodesk Fusion"; then
  echo "❌ Fusion 360 is running. Quit it (Cmd+Q) and re-run this script."
  exit 1
fi

# 2) Find the active webdeploy hash directory (40-char hex)
HASH=$(ls "$WEBDEPLOY" 2>/dev/null | grep -E '^[a-f0-9]{40}$' | head -1)
if [ -z "$HASH" ]; then
  echo "❌ Could not find a Fusion build directory in $WEBDEPLOY"
  exit 1
fi

APP="$WEBDEPLOY/$HASH/Autodesk Fusion.app/Contents"
if [ ! -d "$APP" ]; then
  echo "❌ Fusion bundle not found at $APP"
  exit 1
fi

echo "→ Fusion build: $HASH"
echo "→ Bundle root:  $APP"
echo ""

# 3) Copy ru-RU into StringTable
TARGET_STRINGTABLE="$APP/Libraries/Neutron/StringTable/ru-RU"
mkdir -p "$TARGET_STRINGTABLE"
cp "$FILES/ru-RU/"*.xml "$TARGET_STRINGTABLE/"
echo "✓ ru-RU StringTable: $(ls "$TARGET_STRINGTABLE" | wc -l | tr -d ' ') files"

# 4) Copy ru-html into Help
TARGET_HELP="$APP/Libraries/Applications/CAM360/NeuCAM/UI/NeuCAMUI/Resources/Help"
mkdir -p "$TARGET_HELP"
cp -R "$FILES/ru-html" "$TARGET_HELP/"
cp "$FILES/ru-html.html" "$TARGET_HELP/"
echo "✓ CAM Help: $(ls "$TARGET_HELP/ru-html" | wc -l | tr -d ' ') files"

# 5) Copy russian_ru.xml into Translations
TARGET_TRANS="$APP/Libraries/Applications/CAM360/Data/Translations"
mkdir -p "$TARGET_TRANS"
cp "$FILES/russian_ru.xml" "$TARGET_TRANS/"
echo "✓ CAM Translations: russian_ru.xml installed"

echo ""
echo "🎉 Готово!"
echo ""
echo "Запустите Fusion 360. Если интерфейс не на русском:"
echo "  Preferences → General → User Language → Russian → Restart"
