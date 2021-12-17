#!/bin/sh
brew install git tmux gsed jq wget cmake gcc tree

# Font + icon Install for mac
git clone --branch=master --depth 1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
./install.sh
rm -fr nerd-fonts
# select iTerm2 > profile > NotoSansMono Nerd Font
