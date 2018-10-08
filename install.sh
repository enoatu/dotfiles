#!/usr/bin/env bash
set -eu

cd ~/dotfiles

# mysql
if [ -e ~/.my.cnf ]; then
    rm ~/.my.cnf
    ln -s ~/dotfiles/my.cnf ~/.my.cnf
fi

# tmux
if [ -e ~/.my.tmux.conf ]; then
    rm ~/.my.tmux.conf
    ln -s ~/dotfiles/tmux.cnf ~/.tmux.conf
fi

# vim
git clone https://github.com/enoatu/vimfiles.git
cd vimfiles
chmod +x ./install.sh
./install.sh

if [ -e ./vimfiles ]; then
    rm -rf ./vimfiles
fi

sed -i '/let s:dein_dir/s/~\//~\/dotfiles\//' vimrc
ln -s ~/dotfiles/vimfiles/vimrc ~/.vimrc

printf "\e[30;42;1dotfiles setup completed\e[m\n"
