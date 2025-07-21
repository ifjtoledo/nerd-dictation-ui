#!/bin/bash

# ========================
# 🌍 INSTALLADOR DE DICTADO MULTILINGÜE
# ========================

DEST="$HOME/.local/bin"
mkdir -p "$DEST"

# 🎤 1. Crear dictation-local.sh (transcripción multilingüe)
cat > "$DEST/dictation-local.sh" << 'EOF'
#!/bin/bash

AUDIO="/tmp/dictado.wav"
OUTPUT_TXT="$AUDIO.txt"
MODEL_PATH="$1"
DURACION="$2"
THREADS=$(( $(/usr/bin/nproc) / 2 ))
[[ "$THREADS" -lt 1 ]] && THREADS=1


/usr/bin/arecord -f cd -d "$DURACION" "$AUDIO"

/usr/bin/paplay "$HOME/Music/dong.wav" 2>/dev/null || /usr/bin/aplay "$HOME/Music/dong.wav" 2>/dev/null

if [[ "$MODEL_PATH" == *"ggml-medium.bin" ]]; then
  # 🎯 Modelo grande: máxima precisión
  "$HOME"/whisper.cpp/build/bin/whisper-cli \
    -m "$MODEL_PATH" \
    -f "$AUDIO" \
    -otxt \
    -t "$THREADS" \
    -l auto
else
  # ⚡ Modelos rápido: chico o mediano
  "$HOME"/whisper.cpp/build/bin/whisper-cli \
    -m "$MODEL_PATH" \
    -f "$AUDIO" \
    -otxt \
    -t "$THREADS" \
    -bo 1 \
    -bs 1 \
    -l auto
fi

/usr/bin/cat "$OUTPUT_TXT" | /usr/bin/xclip -selection clipboard
#/usr/bin/paplay "$HOME/Music/ding.wav" 2>/dev/null || /usr/bin/aplay "$HOME/Music/ding.wav" 2>/dev/null
/usr/bin/xdotool key --clearmodifiers ctrl+v
/bin/rm -f "$AUDIO" "$OUTPUT_TXT"
EOF

# 🎛️ 2. Crear dictation.sh (menú interactivo con rofi)
cat > "$DEST/dictation.sh" << 'EOF'
#!/bin/bash

MODELDIR="$HOME/whisper.cpp/models"
declare -A MODELS
MODELS["7s - Chico"]="$MODELDIR/ggml-base.bin|7"
MODELS["7s - Mediano"]="$MODELDIR/ggml-small.bin|7"
MODELS["7s - Grande"]="$MODELDIR/ggml-medium.bin|7"
MODELS["14s - Chico"]="$MODELDIR/ggml-base.bin|14"
MODELS["14s - Mediano"]="$MODELDIR/ggml-small.bin|14"
MODELS["14s - Grande"]="$MODELDIR/ggml-medium.bin|14"
MODELS["28s - Chico"]="$MODELDIR/ggml-base.bin|28"
MODELS["28s - Mediano"]="$MODELDIR/ggml-small.bin|28"
MODELS["28s - Grande"]="$MODELDIR/ggml-medium.bin|28"
MODELS["56s - Chico"]="$MODELDIR/ggml-base.bin|56"
MODELS["56s - Mediano"]="$MODELDIR/ggml-small.bin|56"
MODELS["56s - Grande"]="$MODELDIR/ggml-medium.bin|56"

chosen=$(echo -e "7s - Chico\n7s - Mediano\n7s - Grande\n14s - Chico\n14s - Mediano\n14s - Grande\n28s - Chico\n28s - Mediano\n28s - Grande\n56s - Chico\n56s - Mediano\n56s - Grande\n❌ Cancelar" | rofi -dmenu -p "🌍 Elige duración y modelo (multilingüe):")

[[ "$chosen" == "❌ Cancelar" || -z "$chosen" ]] && echo "Cancelado." && exit 1

entry="${MODELS[$chosen]}"
MODEL_PATH="${entry%%|*}"
DURACION="${entry##*|}"

if [[ ! -f "$MODEL_PATH" ]]; then
    echo "❌ Modelo no encontrado: $MODEL_PATH"
    exit 1
fi

"$HOME/.local/bin/dictation-local.sh" "$MODEL_PATH" "$DURACION"
EOF

# ✅ Hacer ejecutables
chmod +x "$DEST/dictation-local.sh"
chmod +x "$DEST/dictation.sh"

# ✅ Mensaje final
echo "✅ Scripts multilingües instalados en $DEST:"
echo "   🟢 dictation.sh → menú interactivo con rofi"
echo "   🟢 dictation-local.sh → transcripción multilingüe"
echo
echo "Puedes ejecutar con: dictation.sh"
echo "Asegúrate de tener ~/.local/bin en tu \$PATH"

