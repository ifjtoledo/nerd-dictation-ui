#!/bin/bash

# ========= Configuration =========
ROOT_DIR="$(dirname "$(realpath "$0")")/../.."

SCRIPT_PATH="$ROOT_DIR/ui-app/scripts/dictation-rofi.sh"
ICON_PATH="$ROOT_DIR/ui-app/icons/dictation-rofi.png"
TEMPLATE_PATH="$ROOT_DIR/ui-app/desktop/dictation-rofi.desktop.in"
DESKTOP_OUT="$HOME/.local/share/applications/dictation-rofi.desktop"
BIN_NAME="init-nerd-dictation"
BIN_TARGET="$HOME/.local/bin/$BIN_NAME"
ICON_NAME="dictation-rofi"  # without extension

# ========= Dependencies =========
echo "📦 Ensuring dependencies..."
if ! command -v rofi >/dev/null 2>&1; then
    echo "Installing rofi..."
    sudo apt update && sudo apt install -y rofi
fi

# ========= Ensure PATH =========
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "⚠️ ~/.local/bin is not in your PATH. Adding it temporarily."
    echo "💡 Add it permanently with: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
    export PATH="$HOME/.local/bin:$PATH"
fi

# ========= Prepare folders =========
mkdir -p "$HOME/.local/share/icons"
mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.local/bin"

# ========= Install icon =========
cp "$ICON_PATH" "$HOME/.local/share/icons/$ICON_NAME.png"

# ========= Install desktop entry =========
sed \
  -e "s|__SCRIPT_PATH__|$SCRIPT_PATH|g" \
  -e "s|__ICON_PATH__|$ICON_NAME|g" \
  "$TEMPLATE_PATH" > "$DESKTOP_OUT"

# ========= Install launcher alias =========
cp "$SCRIPT_PATH" "$BIN_TARGET"
chmod +x "$SCRIPT_PATH" "$BIN_TARGET"

# ========= Final message =========
echo ""
echo "✅ Installed desktop entry to $DESKTOP_OUT"
echo "🚀 You can now run '$BIN_NAME' from any terminal"
echo "🎙️ Or launch 'Voice Dictation' from your app menu"

