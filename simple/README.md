# 🧠 Instalación de Dictado Local con Whisper.cpp

Este proyecto permite grabar tu voz por unos segundos, transcribir el audio con precisión usando modelos de [`whisper.cpp`](https://github.com/ggerganov/whisper.cpp), copiar el resultado al portapapeles, y pegarlo automáticamente con una tecla. Incluye dos versiones: **inglés** y **multilingüe**, con un menú gráfico (usando `rofi`) y lógica optimizada para rapidez o precisión.

---

## ✅ Requisitos previos

### 1. Instalar dependencias
```bash
sudo apt install build-essential cmake libfftw3-dev libasound2-dev \
    libpulse-dev libx11-dev xclip xdotool rofi libnotify-bin sox
```

> Asegúrate de tener sonido y grabación funcionando (ej. `arecord`).

---

## 📥 2. Clonar e instalar `whisper.cpp`
```bash
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp
make
```

---

## 🎙️ 3. Descargar modelos recomendados

Para uso en inglés:
```bash
cd models/
./download-ggml-model.sh medium.en
./download-ggml-model.sh small.en
./download-ggml-model.sh base.en
```

Para uso multilingüe:
```bash
cd models/
./download-ggml-model.sh medium
./download-ggml-model.sh small
./download-ggml-model.sh base
```

Los modelos se guardan en `~/whisper.cpp/models`.

---

## ⚙️ 4. Instalar scripts de dictado

### 📌 Versión en inglés
```bash
chmod +x install_simple_dictation.sh
./install_simple_dictation.sh
```

### 🌐 Versión multilingüe
```bash
chmod +x install_simple_dictation_multi.sh
./install_simple_dictation_multi.sh
```

Ambos scripts crearán dos archivos en `~/.local/bin`:
- `dictation.sh` → Menú con `rofi` para elegir modelo y duración.
- `dictation-local.sh` → Lógica de grabación, transcripción, copiado y pegado.

---

## 📋 5. Opciones del menú (via `rofi`)

Se ofrecen las siguientes combinaciones:

| Duración | Modelo  | Idioma |
|----------|---------|--------|
| 7s       | Grande / Mediano / Chico | Inglés / Multilingüe |
| 14s      | Grande / Mediano / Chico | Inglés / Multilingüe |
| 28s      | Grande / Mediano / Chico | Inglés / Multilingüe |
| 56s      | Grande / Mediano / Chico | Inglés / Multilingüe |

La precisión o velocidad depende del modelo:
- **Grande**: máxima precisión
- **Mediano / Chico**: prioriza velocidad

---

## 🧠 Optimizaciones y comportamiento

- Usa `nproc` para detectar núcleos y divide entre 2 para no sobrecargar CPU.
- Limpia automáticamente los archivos temporales (`/tmp/dictado.wav`).
- Usa `paplay` o `aplay` para emitir un **"ding"** antes y después.
- Copia la transcripción al portapapeles.
- Pega automáticamente con `xdotool`.

---

## 🧹 Borrar caché de `rofi` (opcional)

Si el menú no refleja los cambios:
```bash
rm ~/.local/share/rofi/history
rm ~/.cache/rofi*
killall rofi
```

---

## ▶️ Cómo ejecutar

Desde terminal o atajo:
```bash
dictation.sh
```

---

## 📌 Notas adicionales

- Asegúrate de que `~/.local/bin` esté en tu `$PATH`.
- Puedes editar el archivo `dictation.sh` si deseas agregar o quitar combinaciones de modelos y duración.
- Puedes usar `xdg-open ~/.local/bin` para acceder rápidamente a los scripts instalados.

---

## 📁 Estructura del sistema

```
.local/bin/
├── dictation.sh           # Menú rofi
├── dictation-local.sh     # Lógica de dictado
~/whisper.cpp/models/
├── ggml-base.en.bin
├── ggml-small.en.bin
├── ggml-medium.en.bin
└── ...otros modelos
```

---

## ✨ Créditos

Basado en [`whisper.cpp`](https://github.com/ggerganov/whisper.cpp) por Georgi Gerganov y adaptado con utilidades de Linux para productividad local.
