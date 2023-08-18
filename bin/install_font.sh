#!/bin/env bash

# Install fonts
if [ "$(uname)" == "Darwin" ]; then
  cd ~/Library/Fonts && curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  mkdir -p ~/.local/share/fonts
  cd ~/.local/share/fonts && curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf
fi

# その後に 「Droid Sans Nerd Font Complete」をターミナルのフォントに設定する
