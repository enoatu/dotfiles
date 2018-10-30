#!/usr/bin/env bash
set -exu

cd ~/dotfiles

# mysql
ln -sf ~/dotfiles/my.cnf ~/.my.cnf

# tmux
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf

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

ln -sf ~/dotfiles/vimfiles/vimrc ~/.vimrc
ln -sf ~/dotfiles/vimfiles/dein.toml ~/.dein.toml

printf "\e[30;42;1dotfiles setup completed\e[m\n"
