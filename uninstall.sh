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
if [ -e ~/vimfiles ]; then
    cd ~/vimfiles
    ./uninstall.sh
    rm -rf ~/vimfiles
fi
