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

# Validación de valores booleanos
if ! validate_bool "$ENABLE_SOUNDS_GLOBAL"; then
    echo "❌ Valor inválido para sonidos: '$ENABLE_SOUNDS_GLOBAL'. Usa true o false."
    exit 1
fi

if ! validate_bool "$ENABLE_TICTAC_GLOBAL"; then
    echo "❌ Valor inválido para tic-tac: '$ENABLE_TICTAC_GLOBAL'. Usa true o false."
    exit 1
fi

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
AUDIO="/tmp/dictado.wav"
OUTPUT_TXT="$AUDIO.txt" 
MODEL_PATH="$1"
DURACION="$2"
ENABLE_SOUNDS=ENABLE_SOUNDS_GLOBAL
ENABLE_TICTAC=ENABLE_TICTAC_GLOBAL

# Garantizar limpieza de archivos
trap "rm -f '$AUDIO' '$OUTPUT_TXT'" EXIT

# Validación de parámetros
if [[ -z "$MODEL_PATH" || -z "$DURACION" ]]; then
    echo "❌ Error: Parámetros faltantes. Uso: dictation-local.sh <modelo> <duración>"
    exit 1
fi
if ! [[ "$DURACION" =~ ^[0-9]+$ ]]; then
    echo "❌ Error: DURACION debe ser un número entero positivo."
    exit 1
fi

# Configuración de hilos
THREADS=$(( $(nproc) / 2 ))
[[ "$THREADS" -lt 1 ]] && THREADS=1

# Grabar audio
arecord -f cd -d "$DURACION" "$AUDIO" &
RECORD_PID=$!

# Sonido de pre-finalización (si dura >1s)
if [[ "$ENABLE_SOUNDS" == "true" ]] && (( DURACION > 1 )); then
    ( sleep $(( DURACION - 1 )); 
        paplay "$HOME/Music/dong.wav" 2>/dev/null || aplay "$HOME/Music/dong.wav" 2>/dev/null 
    ) &
fi

wait $RECORD_PID
# ===============================
# 🧹 Función de limpieza
# ===============================
cleanup() {
    if [[ -n "$TICTAC_PID" ]]; then
        echo "🧹 Terminando sonido tic-tac PID=$TICTAC_PID"
        pkill -g "$TICTAC_PID" 2>/dev/null   # Mata a todo el grupo
        wait "$TICTAC_PID" 2>/dev/null
    fi
}
trap cleanup EXIT INT TERM

# Procesamiento por modelo
case "$(basename "$MODEL_PATH")" in
    ggml-large-v3.bin)
        # Configuración especial para modelo grande con tic-tac
         if [[ "$ENABLE_TICTAC" == "true" ]]; then
            setsid bash -c '
                while true; do
                    aplay "$HOME/Music/watch-ticking.wav" 2>/dev/null || break
                    sleep 1
                done
            ' &
            TICTAC_PID=$!
        fi

        "$HOME"/whisper.cpp/build/bin/whisper-cli -m "$MODEL_PATH" -f "$AUDIO" -l en -otxt -t "$THREADS" | tee /tmp/whisper.log
        ;;

    ggml-small.en.bin|ggml-base.en.bin)
        # Modelos pequeños/medianos (multilenguaje)
         "$HOME"/whisper.cpp/build/bin/whisper-cli -m "$MODEL_PATH" -f "$AUDIO" -l en -otxt -t "$THREADS" | tee /tmp/whisper.log
        ;;

    *)
        notify-send "❌ Modelo no reconocido" "Usa: ggml-base.en.bin, ggml-small.en.bin o ggml-large-v3.bin"
        exit 1
        ;;
esac
echo "=== RUTAS ==="
echo "Audio: $AUDIO"
echo "Salida: $OUTPUT_TXT"
echo "=== ARCHIVOS TEMPORALES ==="
ls -lh "/tmp/dictado"*
# Procesar resultado
if [[ -s "$OUTPUT_TXT" ]]; then
    xclip -selection clipboard < "$OUTPUT_TXT"
    xdotool key ctrl+v
    
    if [[ "$ENABLE_SOUNDS" == "true" ]]; then
        (paplay "$HOME/Music/ding.wav" 2>/dev/null || aplay "$HOME/Music/ding.wav" 2>/dev/null) &
    fi
else
    notify-send "⚠️ Transcripción vacía" "No se detectó contenido"
fi

# 🧹 Limpieza final
/bin/rm -f "$AUDIO" "$OUTPUT_TXT"
EOF
chmod +x "$DEST/dictation-local.sh"

# 🎛️ 2. Crear dictation.sh (menú simple con rofi)
cat > "$DEST/dictation.sh" << 'EOF'
#!/bin/bash

MODELDIR="$HOME/whisper.cpp/models"
declare -A MODELS
MODELS["3s - Small.en"]="$MODELDIR/ggml-small.en.bin|3"
MODELS["7s - Small.en"]="$MODELDIR/ggml-small.en.bin|7"
MODELS["14s - Small.en"]="$MODELDIR/ggml-small.en.bin|14"
MODELS["28s - Small.en"]="$MODELDIR/ggml-small.en.bin|28"
MODELS["56s - Small.en"]="$MODELDIR/ggml-small.en.bin|56"
MODELS["7s - Large.en"]="$MODELDIR/ggml-large-v3.bin|7"
MODELS["14s - Large.en"]="$MODELDIR/ggml-large-v3.bin|14"
MODELS["28s - Large.en"]="$MODELDIR/ggml-large-v3.bin|28"
MODELS["56s - Large.en"]="$MODELDIR/ggml-large-v3.bin|56"
chosen=$(echo -e "3s - Small.en\n7s - Small.en\n14s - Small.en\n28s - Small.en\n56s - Small.en\n7s - Large.en\n14s - Large.en\n28s - Large.en\n56s - Large.en\n❌ Cancelar" | rofi -dmenu -p "🇺🇸 Dictado en inglés (elige modelo y duración):")

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

# ✅ Hacer ejecutable
chmod +x "$DEST/dictation.sh"

# ✅ Mensaje final
echo "✅ Scripts de dictado simple instalados en $DEST:"
echo "   🟢 dictation.sh → menú interactivo con rofi"
echo "   🟢 dictation-local.sh → transcripción en inglés"
echo
echo "Puedes ejecutar con: dictation.sh"
echo "Asegúrate de tener ~/.local/bin en tu \$PATH"

