#!/bin/sh
cd /tmp
git clone https://github.com/neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo -ferror-limit=0
sudo make install
