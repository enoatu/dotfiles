#!/usr/bin/env bash
set -eu

cd ~/dotfiles

# mysql
ln -s ~/dotfiles/my.cnf ~/.my.cnf

# tmux
ln -s ~/dotfiles/tmux.cnf ~/.tmux.conf

# vim
git clone https://github.com/enoatu/vimfiles.git
./vimfiles/install.sh

