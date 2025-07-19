#!/bin/bash

set -e

echo "📦 Installing dependencies..."
pip3 install --user vosk

echo "📁 Cloning nerd-dictation..."
git clone https://github.com/ideasman42/nerd-dictation.git

cd nerd-dictation
echo "⬇️ Downloading VOSK model..."
wget https://alphacephei.com/kaldi/models/vosk-model-small-en-us-0.15.zip
unzip vosk-model-small-en-us-0.15.zip

echo "📂 Moving model to ~/.config/nerd-dictation..."
mkdir -p ~/.config/nerd-dictation
mv vosk-model-small-en-us-0.15 ~/.config/nerd-dictation/model

echo "✅ nerd-dictation is ready."
