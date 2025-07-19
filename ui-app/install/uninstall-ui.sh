#!/bin/bash

echo "🧼 Uninstalling nerd-dictation UI integration..."

# Rutas relevantes
DESKTOP_FILE="$HOME/.local/share/applications/dictation-rofi.desktop"
ICON_FILE="$HOME/.local/share/icons/dictation-rofi.png"
BIN_FILE="$HOME/.local/bin/init-nerd-dictation"

# Eliminar .desktop
if [ -f "$DESKTOP_FILE" ]; then
    rm "$DESKTOP_FILE"
    echo "🗑️ Removed desktop entry"
fi

# Eliminar icono
if [ -f "$ICON_FILE" ]; then
    rm "$ICON_FILE"
    echo "🗑️ Removed icon"
fi

# Eliminar binario launcher
if [ -f "$BIN_FILE" ]; then
    rm "$BIN_FILE"
    echo "🗑️ Removed command alias"
fi

echo "✅ nerd-dictation UI uninstalled."

