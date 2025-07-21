#!/bin/bash

# ========= Smart nerd-dictation detection =========

# 1. Check in $HOME
if [ -x "$HOME/nerd-dictation/nerd-dictation" ]; then
  DICT_BIN="$HOME/nerd-dictation/nerd-dictation"

# 2. Check in project-relative path
elif [ -x "$(dirname "$(realpath "$0")")/../../nerd-dictation-related/nerd-dictation/nerd-dictation" ]; then
  DICT_BIN="$(dirname "$(realpath "$0")")/../../nerd-dictation-related/nerd-dictation/nerd-dictation"

# 3. Check global PATH
elif command -v nerd-dictation >/dev/null 2>&1; then
  DICT_BIN="$(command -v nerd-dictation)"

# 4. Not found
else
  notify-send "Voice Dictation Error" "❌ Could not locate nerd-dictation"
  echo "ERROR: nerd-dictation not found" >> "$HOME/.cache/rofi-dictation-error.log"
  exit 1
fi

# ========= Rofi menu =========

choice=$(echo -e "🎙️ Start dictation (standard)\n✋ Stop dictation\n🗣️ Fast dictation (no rephrase)\n⏸️ Suspend dictation\n▶️ Resume dictation\n❌ Cancel dictation\n🧠 Continuous mode\n🔇 Defer output (STDOUT)\n⏳ Timeout 5s\n🔊 Verbose\n🎯 Wayland: dotool" | rofi -dmenu -p "Voice Dictation")

case "$choice" in
"🎙️ Start dictation (standard)")
    # ✅ Add timeout so it ends automatically
    "$DICT_BIN" begin --punctuate-from-previous-timeout 1.0 \
      --full-sentence --numbers-as-digits \
      --output SIMULATE_INPUT \
      --timeout 2 \
      --delay-exit 1.5 &
    ;;
 

  "✋ Stop dictation")
    "$DICT_BIN" end
    ;;

   "🗣️ Fast dictation (no rephrase)")
    # 🚀 Minimal processing, faster response, fewer corrections
    "$DICT_BIN" begin \
      --output SIMULATE_INPUT \
      --numbers-as-digits \
      --timeout 2 \
      --delay-exit 0.2 &
    ;;

  "⏸️ Suspend dictation")
    "$DICT_BIN" suspend
    ;;

  "▶️ Resume dictation")
    "$DICT_BIN" resume
    ;;

  "❌ Cancel dictation")
    "$DICT_BIN" cancel
    ;;
    
  "🧠 Continuous mode")
    # ❌ Should NOT have timeout (continuous means stay on indefinitely)
    "$DICT_BIN" begin --punctuate-from-previous-timeout 1.0 \
      --full-sentence --numbers-as-digits \
      --output SIMULATE_INPUT \
      --delay-exit 1.5 \
      --continuous &
    ;;

  "🔇 Defer output (STDOUT)")
    # ✅ Defer mode usually meant to end automatically, add timeout
    "$DICT_BIN" begin --punctuate-from-previous-timeout 1.0 \
      --full-sentence --numbers-as-digits \
      --output STDOUT \
      --defer-output \
      --timeout 5 &
    ;;

  "⏳ Timeout 5s")
    # ✅ Already correct
    "$DICT_BIN" begin --punctuate-from-previous-timeout 1.0 \
      --full-sentence --numbers-as-digits \
      --output SIMULATE_INPUT \
      --timeout 5 \
      --delay-exit 1.5 &
    ;;

  "🔊 Verbose")
    # ✅ Add timeout for auto-stop + verbose for feedback
    "$DICT_BIN" begin --punctuate-from-previous-timeout 1.0 \
      --full-sentence --numbers-as-digits \
      --output SIMULATE_INPUT \
      --timeout 5 \
      --delay-exit 1.5 \
      --verbose 1 &
    ;;

  "🎯 Wayland: dotool")
    # ✅ Add timeout, Wayland-compatible input
    "$DICT_BIN" begin --punctuate-from-previous-timeout 1.0 \
      --full-sentence --numbers-as-digits \
      --output SIMULATE_INPUT \
      --simulate-input-tool DOTOOL \
      --timeout 5 \
      --delay-exit 1.5 &
    ;;

 
esac


