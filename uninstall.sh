#!/usr/bin/env bash

set -e

unlink ~/.zshrc ~/.tmux.conf ~/.gitignore_global ~/.gitconfig
rm -rf ~/.config/coc ~/.config/nvim

list=`asdf plugin list`
echo $list
echo "Do you want to uninstall all asdf plugins? [y/n]"
read answer
case "$answer" in
y)

  rm -rf ~/.asdf
  echo "rm -rf ~/.asdf done"
  ;;
*)
  echo "Skip uninstalling asdf plugins"
  ;;
esac
