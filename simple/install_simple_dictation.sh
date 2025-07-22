#!/bin/bash

# ========================
#!/bin/bash

# ========================
# 🇺🇸 INSTALLADOR DE DICTADO SIMPLE (solo inglés)
# ========================

# =======================
# 🔧 CONFIGURACIÓN GLOBAL (con soporte interactivo)
# =======================

to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

validate_bool() {
    case "$1" in
        true|false) return 0 ;;
        *) return 1 ;;
    esac
}

# Si no se pasan argumentos, preguntar al usuario
if [[ -z "$1" ]]; then
    read -rp "¿Deseas habilitar los sonidos? (true/false) [true]: " enable_sounds
    enable_sounds=${enable_sounds:-true}
    ENABLE_SOUNDS_GLOBAL="$(to_lower "$enable_sounds")"
else
    ENABLE_SOUNDS_GLOBAL="$(to_lower "$1")"
fi

if [[ -z "$2" ]]; then
    read -rp "¿Deseas habilitar el tic-tac para el modelo grande? (true/false) [true]: " enable_tictac
    enable_tictac=${enable_tictac:-true}
    ENABLE_TICTAC_GLOBAL="$(to_lower "$enable_tictac")"
else
    ENABLE_TICTAC_GLOBAL="$(to_lower "$2")"
fi



# Validación de valores
if ! validate_bool "$enable_sounds"; then
    echo "❌ Valor inválido para sonidos: '$enable_sounds'. Usa true o false."
    exit 1
fi

if ! validate_bool "$enable_tictac"; then
    echo "❌ Valor inválido para tic-tac: '$enable_tictac'. Usa true o false."
    exit 1
fi

ENABLE_SOUNDS_GLOBAL="$enable_sounds"
ENABLE_TICTAC_GLOBAL="$enable_tictac"

# Confirmación
echo "✅ Configuración seleccionada:"
echo "   ENABLE_SOUNDS_GLOBAL = $ENABLE_SOUNDS_GLOBAL"
echo "   ENABLE_TICTAC_GLOBAL = $ENABLE_TICTAC_GLOBAL"

# =======================
# 🗃️ Ruta de destino
# =======================
DEST="$HOME/.local/bin"
mkdir -p "$DEST"

# 🎤 1. Crear dictation-local.sh (solo inglés)
cat << 'EOF' | sed \
  -e "s|ENABLE_SOUNDS=ENABLE_SOUNDS_GLOBAL|ENABLE_SOUNDS=$ENABLE_SOUNDS_GLOBAL|" \
  -e "s|ENABLE_TICTAC=ENABLE_TICTAC_GLOBAL|ENABLE_TICTAC=$ENABLE_TICTAC_GLOBAL|" \
  > "$DEST/dictation-local.sh"
#!/bin/bash
ENABLE_SOUNDS=ENABLE_SOUNDS_GLOBAL
ENABLE_TICTAC=ENABLE_TICTAC_GLOBAL
MODEL_PATH="\$1"
AUDIO="/tmp/dictado.wav"
OUTPUT_TXT="\$AUDIO.txt"
DURACION="\$2"

# ✅ Validar parámetros obligatorios
if [[ -z "\$MODEL_PATH" || -z "\$DURACION" ]]; then
    echo "❌ Error: Parámetros faltantes. Uso: dictation-local.sh <modelo> <duración>"
    exit 1
fi
if ! [[ "$DURACION" =~ ^[0-9]+$ ]]; then
    echo "❌ Error: DURACION debe ser un número entero positivo."
    exit 1
fi
# 🎙️ Grabar audio en background
/usr/bin/arecord -f cd -d "$DURACION" "$AUDIO" &

if [[ "$ENABLE_SOUNDS" == "true" ]]; then
# 🔔 Sonar campanilla 1 segundo antes del final
( sleep $(( DURACION - 1 )); 
  /usr/bin/paplay "$HOME/Music/dong.wav" 2>/dev/null || /usr/bin/aplay "$HOME/Music/dong.wav" 2>/dev/null 
) &
# Esperar a que termine la grabación
wait
fi
THREADS=$(( $(/usr/bin/nproc) / 2 ))
[[ "$THREADS" -lt 1 ]] && THREADS=1
if [[ "$MODEL_PATH" == *"ggml-large-v3.bin" ]]; then
    THREADS=1  # Reduce carga para que el sistema tenga recursos para ding
fi
# 🧠 Ejecutar modelo según tamaño
case "$(basename "$MODEL_PATH")" in
  ggml-large-v3.bin)
    if [[ "$ENABLE_SOUNDS" == "true" && "$ENABLE_TICTAC" == "true" ]]; then
      (paplay "$HOME/Music/watch-ticking.wav" 2>/dev/null || aplay "$HOME/Music/watch-ticking.wav" 2>/dev/null) &
      TICTAC_PID=$!
    fi
    # 📈 Precisión media-alta
    "$HOME"/whisper.cpp/build/bin/whisper-cli -m "$MODEL_PATH" -f "$AUDIO" -l en -otxt -t "$THREADS"
    ;;
  
  ggml-small.en.bin|ggml-medium.en.bin|ggml-base.en.bin)
    # ⚡ Modelos pequeños (base.en o small.en)
    "$HOME"/whisper.cpp/build/bin/whisper-cli -m "$MODEL_PATH" -f "$AUDIO" -l en -otxt -t "$THREADS"
    ;;
  
  *)
    notify-send -u critical "❌ Modelo no reconocido" \
      "🧠 '$(basename "$MODEL_PATH")'\nNo es uno de los modelos esperados.\nUsa: ggml-base.en.bin, ggml-small.en.bin o ggml-large-v3.bin."
    exit 1
    ;;
esac

# 🔇 Detener tic-tac si estaba activo
if [[ "$ENABLE_SOUNDS" == "true" && "$ENABLE_TICTAC" == "true" && -n "$TICTAC_PID" ]]; then
    kill "$TICTAC_PID" 2>/dev/null
    wait "$TICTAC_PID" 2>/dev/null
fi

# 📋 Verificar si hubo contenido válido
if [[ -s "$OUTPUT_TXT" ]]; then
    /usr/bin/xclip -selection clipboard < "$OUTPUT_TXT"
    /usr/bin/xdotool key --clearmodifiers ctrl+v
     # 🔔 Sonido de éxito (solo si hay algo que pegar)
    if [[ "$ENABLE_SOUNDS" == "true" ]]; then
      # 🎧 Esperar 0.3s para liberar el sistema antes de sonar
    (sleep 0.3; paplay "$HOME/Music/ding.wav" 2>/dev/null || aplay "$HOME/Music/ding.wav" 2>/dev/null) &
    fi
     
else
    notify-send -u normal "⚠️ Transcripción vacía" "No se detectó contenido para pegar."
fi

# 🧹 Limpieza final
/bin/rm -f "$AUDIO" "$OUTPUT_TXT"
EOF

# 🎛️ 2. Crear dictation.sh (menú simple con rofi)
cat > "$DEST/dictation.sh" << 'EOF'
#!/bin/bash

MODELDIR="$HOME/whisper.cpp/models"
declare -A MODELS
MODELS["3s - Small.en"]="$MODELDIR/ggml-small.en.bin|3"
MODELS["7s - Small.en"]="$MODELDIR/ggml-small.en.bin|7"
MODELS["7s - Large.en"]="$MODELDIR/ggml-large-v3.bin|7"
MODELS["14s - Small.en"]="$MODELDIR/ggml-small.en.bin|14"
MODELS["14s - Large.en"]="$MODELDIR/ggml-large-v3.bin|14"
MODELS["28s - Small.en"]="$MODELDIR/ggml-small.en.bin|28"
MODELS["28s - Large.en"]="$MODELDIR/ggml-large-v3.bin|28"
MODELS["56s - Small.en"]="$MODELDIR/ggml-small.en.bin|56"
MODELS["56s - Large.en"]="$MODELDIR/ggml-large-v3.bin|56"

chosen=$(echo -e "3s - Small.en\n7s - Small.en\n7s - Large.en\n14s - Small.en\n14s - Large.en\n28s - Small.en\n28s - Large.en\n56s - Small.en\n56s - Large.en\n❌ Cancelar" | rofi -dmenu -p "🇺🇸 Dictado en inglés (elige modelo y duración):")

[[ "$chosen" == "❌ Cancelar" || -z "$chosen" ]] && echo "Cancelado." && exit 1

entry="${MODELS[$chosen]}"
MODEL_PATH="${entry%%|*}"
DURACION="${entry##*|}"

if [[ ! -f "$MODEL_PATH" ]]; then
    notify-send -u critical "❌ Modelo no encontrado" "$MODEL_PATH"
    exit 1
fi

"$HOME/.local/bin/dictation-local.sh" "$MODEL_PATH" "$DURACION"
EOF

# ✅ Hacer ejecutables
chmod +x "$DEST/dictation-local.sh"
chmod +x "$DEST/dictation.sh"

# ✅ Mensaje final
echo "✅ Scripts de dictado simple instalados en $DEST:"
echo "   🟢 dictation.sh → menú interactivo con rofi"
echo "   🟢 dictation-local.sh → transcripción en inglés"
echo
echo "Puedes ejecutar con: dictation.sh"
echo "Asegúrate de tener ~/.local/bin en tu \$PATH"

