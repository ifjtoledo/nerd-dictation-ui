#!/bin/bash
# Detect root of the project (2 levels above this script)
ROOT_DIR="$(dirname "$(realpath "$0")")/../.."

SCRIPT_PATH="$ROOT_DIR/ui-app/scripts/dictation-rofi.sh"
ICON_PATH="$ROOT_DIR/ui-app/icons/dictation-rofi.png"
TEMPLATE_PATH="$ROOT_DIR/ui-app/desktop/dictation-rofi.desktop.in"
DESKTOP_OUT="$HOME/.local/share/applications/dictation-rofi.desktop"

# Ensure dependencies
echo "📦 Ensuring dependencies..."
if ! command -v rofi >/dev/null 2>&1; then
    echo "Installing rofi..."
    sudo apt update && sudo apt install -y rofi
fi

# Make script executable
chmod +x "$SCRIPT_PATH"

# Copy icon
mkdir -p "$HOME/.local/share/icons"
cp "$ICON_PATH" "$HOME/.local/share/icons/"

# Generate .desktop entry with correct paths
mkdir -p "$HOME/.local/share/applications"
sed "s|__SCRIPT_PATH__|$SCRIPT_PATH|g; s|__ICON_PATH__|$HOME/.local/share/icons/$(basename "$ICON_PATH")|g" "$TEMPLATE_PATH" > "$DESKTOP_OUT"

echo "✅ Installed desktop entry to $DESKTOP_OUT"
echo "🎙️ You can now launch 'Voice Dictation' from your application menu."
