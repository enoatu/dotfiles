#!/usr/bin/env bash
set -exu

cd ~/dotfiles

# mysql
if [ -e ~/.my.cnf ]; then
    rm ~/.my.cnf
    ln -s ~/dotfiles/my.cnf ~/.my.cnf
fi

# tmux
if [ -e ~/.tmux.conf ]; then
    rm ~/.tmux.conf
    ln -s ~/dotfiles/tmux.cnf ~/.tmux.conf
fi

# vim
if [ -e ./vimfiles ]; then
    rm -rf ./vimfiles
fi

git clone https://github.com/enoatu/vimfiles.git
cd vimfiles
chmod +x ./install.sh
./install.sh

# sed -i '/let s:dein_dir/s/~\//~\/dotfiles\//' vimrc
sed -i "" '/let s:dein_dir/s/~\//~\/dotfiles\//' vimrc
sed -i "" '/let s:toml/s/~\//~\/dotfiles\//' vimrc

if [ -e ~/.vimrc ]; then
    rm ~/.vimrc
fi

if [ -e ~/.dein.toml ]; then
    rm ~/.dein.toml
fi

ln -s ~/dotfiles/vimfiles/vimrc ~/.vimrc
ln -s ~/dotfiles/vimfiles/dein.toml ~/.dein.toml

vim +:q
printf "\e[30;42;1dotfiles setup completed\e[m\n"
