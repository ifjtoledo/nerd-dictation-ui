# 🧠 nerd-dictation-ui

A graphical and productivity-oriented interface for [nerd-dictation](https://github.com/ideasman42/nerd-dictation), designed to reduce friction and provide an intuitive voice dictation experience on Linux systems.

This wrapper is focused on **Pop!_OS and GNOME environments**, leveraging the power of [Rofi](https://github.com/davatorium/rofi) to provide a clean, interactive command menu to control dictation. No advanced setup, no manual file copying — just install and use.

---

## 🚀 What this does

- Wraps `nerd-dictation` in a visual menu with **Rofi**
- Adds a desktop launcher (`Voice Dictation`) to your GNOME app grid
- Lets you start, pause, resume, or cancel dictation with zero terminal interaction
- Keeps everything clean, relative, and self-contained — no hardcoded paths

---

## 🧰 Requirements

| Component         | Role                                       |
|------------------|--------------------------------------------|
| Python 3 + pip   | To install `vosk`, the speech backend      |
| nerd-dictation   | Main engine (installed automatically)      |
| Rofi             | Menu launcher (installed automatically)    |
| VOSK model       | Language recognition data (auto-downloaded)|

---

## ⚙️ Installation

### 1. Clone the repository

```bash
git clone https://github.com/YOUR-USERNAME/nerd-dictation-ui.git
cd nerd-dictation-ui
```

### 2. Install the backend tools and language model

```bash
./nerd-dictation-related/install/install.sh
```

This installs:

* `vosk` via `pip`
* `nerd-dictation` (cloned)
* VOSK English model (small)
* Moves the model to `~/.config/nerd-dictation/model`

### 3. Install the UI interface

```bash
./ui-app/install/install-ui.sh
```

This will:

* Automatically install `rofi` if it's missing
* Copy and register the `.desktop` entry (menu icon)
* Copy the icon into your local theme
* Register everything with relative paths, so you can move the repo if needed
* Ensure execution permissions are set automatically

---

## 🎙️ Usage

After installation:

* Press `Super` (Windows key) and search for **Voice Dictation**
* Use the menu to:

  * Start dictation
  * Pause/resume
  * Cancel
  * Choose alternate modes (continuous, defer output, etc.)

The Rofi menu is **keyboard-first and very fast**.

---

## 📋 Rofi Menu Options Explained

| Option                      | What it does                                                                 |
|----------------------------|------------------------------------------------------------------------------|
| 🎙️ **Start dictation (standard)** | Starts dictation with recommended defaults: punctuation, full sentence casing, number formatting. |
| 🧠 **Continuous mode**         | Keeps dictation active continuously without reprocessing chunks. Useful for long sessions. |
| 🔇 **Defer output (STDOUT)**    | Captures text silently and prints to STDOUT instead of simulating typing. Requires terminal capture. |
| ⏳ **Timeout 5s**              | Automatically stops listening after 5 seconds of silence. Useful for short inputs. |
| 🔊 **Verbose**                | Shows feedback in terminal/log for actions taken (start, stop, etc.). Helpful for debugging. |
| 🎯 **Wayland: dotool**         | Uses `dotool` for simulating input, compatible with Wayland. Choose if `xdotool` fails. |
| ✋ **Stop dictation**          | Ends current dictation session and injects the transcribed text if `SIMULATE_INPUT` is used. |
| ⏸️ **Suspend dictation**       | Temporarily pauses audio capture without ending the session. Can be resumed later. |
| ▶️ **Resume dictation**        | Resumes a previously suspended session. |
| ❌ **Cancel dictation**        | Aborts dictation without injecting any text. Use if you changed your mind. |

---

## 🔧 Notes

* **Rofi will be installed automatically** on Debian-based systems (Pop!_OS, Ubuntu, etc.)
* The system uses `SIMULATE_INPUT` mode by default to type directly into your focused window
* All file references are made **relative to the repository root** using `realpath`, so no hardcoding needed
* All permissions and desktop entries are set up for you — no need to `chmod` or move files manually

---

## 📚 Project Structure

```
nerd-dictation-ui/
├── nerd-dictation-related/
│   ├── docs/
│   │   └── first-steps.md
│   └── install/
│       └── install.sh          # Installs backend and VOSK model
└── ui-app/
    ├── config/
    ├── desktop/
    │   └── dictation-rofi.desktop.in   # Template with placeholders
    ├── docs/
    ├── icons/
    │   └── dictation-rofi.png
    ├── install/
    │   └── install-ui.sh       # Handles UI integration
    └── scripts/
        └── dictation-rofi.sh   # Core Rofi interface
```

---

## 🧪 Tested on

* Pop!_OS 22.04 and 24.04
* GNOME Shell
* Wayland and X11
* Python 3.10+

---

## 📄 License

MIT License — use freely, modify, and share.

---

## 🙌 Credits

* [ideasman42](https://github.com/ideasman42) for `nerd-dictation`
* [VOSK API](https://alphacephei.com/vosk/)
* Rofi by [davatorium](https://github.com/davatorium/rofi)

---

> “The goal is peace of mind and flow — speak, and your system listens.”
