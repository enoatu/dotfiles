#!/usr/bin/env bash

for file in `\find . -maxdepth 1 -name '*.snip'`; do
    ln -sf ~/dotfiles/vimfiles/snippets/$file ~/dotfiles/vimfiles/dein/.cache/.vimrc/.dein/neosnippets/$file
done

printf "\e[37;46;1msnippets set\e[m\n"
