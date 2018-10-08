#!/usr/bin/env bash
set -eux

cd ~/dotfiles/vimfiles
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

chmod +x aftercare.sh
./aftercare.sh
