#!/usr/bin/env bash
set -eu

# mysql
if [ -e ~/.my.cnf ]; then
    unlink ~/.my.cnf
fi

# tmux
if [ -e ~/.tmux.conf ]; then
    unlink ~/.tmux.conf
fi

# vim
if [ -e ~/dotfiles/vimfiles ]; then
    cd ~/dotfiles/vimfiles
    chmod +x ./uninstall.sh
    ./uninstall.sh
    cd ~/dotfiles
    rm -rf ./vimfiles
fi

printf "\e[30;42;1mdotfiles uninstalled completed \e[m\n"
