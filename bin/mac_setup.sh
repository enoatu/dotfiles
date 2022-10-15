#!/bin/sh
brew install git tmux gsed ggrep jq wget cmake gcc tree ripgrep colordiff git-delta vips openexr

# Font + icon Install for mac
git clone --branch=master --depth 1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
./install.sh
rm -fr nerd-fonts
# select iTerm2 > profile > NotoSansMono Nerd Font
