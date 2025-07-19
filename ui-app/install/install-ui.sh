#!/bin/bash

# Detect root of the project (2 levels above this script)
ROOT_DIR="$(dirname "$(realpath "$0")")/../.."

SCRIPT_PATH="$ROOT_DIR/ui-app/scripts/dictation-rofi.sh"
ICON_PATH="$ROOT_DIR/ui-app/icons/dictation-rofi.png"
TEMPLATE_PATH="$ROOT_DIR/ui-app/desktop/dictation-rofi.desktop.in"
DESKTOP_OUT="$HOME/.local/share/applications/dictation-rofi.desktop"
BIN_NAME="init-nerd-dictation"
BIN_TARGET="$HOME/.local/bin/$BIN_NAME"

# Ensure dependencies
echo "📦 Ensuring dependencies..."
if ! command -v rofi >/dev/null 2>&1; then
    echo "Installing rofi..."
    sudo apt update && sudo apt install -y rofi
fi

# Ensure local bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "⚠️ ~/.local/bin is not in your PATH. Adding it temporarily."
    echo "💡 Add it permanently with: echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc"
    export PATH="$HOME/.local/bin:$PATH"
fi

# Make script executable
chmod +x "$SCRIPT_PATH"

# Copy icon
mkdir -p "$HOME/.local/share/icons"
cp "$ICON_PATH" "$HOME/.local/share/icons/"

# Generate .desktop entry
mkdir -p "$HOME/.local/share/applications"
sed "s|__SCRIPT_PATH__|$SCRIPT_PATH|g; s|__ICON_PATH__|$HOME/.local/share/icons/$(basename "$ICON_PATH")|g" "$TEMPLATE_PATH" > "$DESKTOP_OUT"

# Install global launcher script
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_PATH" "$BIN_TARGET"
chmod +x "$BIN_TARGET"

echo ""
echo "✅ Installed desktop entry to $DESKTOP_OUT"
echo "🚀 You can now run 'init-nerd-dictation' from any terminal"
echo "🎙️ Or launch 'Voice Dictation' from your app menu"

