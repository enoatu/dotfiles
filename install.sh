#!/usr/bin/env bash
set -e

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

sed -i '/let s:dein_dir/s/~\//~\/dotfiles\//' vimrc || sed -i "" '/let s:dein_dir/s/~\//~\/dotfiles\//' vimrc

ln -sf ~/dotfiles/vimfiles/vimrc ~/.vimrc
ln -sf ~/dotfiles/vimfiles/dein.toml ~/.dein.toml

vim +:q

mkdir -p dein/.cache/.vimrc/.dein/lib
cd ./dein/.cache/.vimrc/.dein/lib
git clone https://github.com/Shougo/vimproc.vim.git
cd vimproc.vim
make
if [ -e ./lib/vimproc_linux64.so ]; then
    ln -s vimproc.vim/lib/vimproc_linux64.so ..
elif [ -e ./lib/vimproc_mac.so ]; then
    ln -s vimproc.vim/lib/vimproc_mac.so .. #TODO
else
    printf "\e[37;41;1m Couldn't find vimproc.so \e[m\n"
    exit
fi

printf "\e[30;42;1m vim setup for dotfiles completed \e[m\n"

printf "\e[30;42;1m dotfiles setup completed\e[m\n"
