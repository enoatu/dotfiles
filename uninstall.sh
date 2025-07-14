#!/usr/bin/env bash

set -e

unlink ~/.zshrc ~/.tmux.conf ~/.gitignore_global ~/.gitconfig
rm -rf ~/.config/coc ~/.config/nvim

mise uninstall -a
