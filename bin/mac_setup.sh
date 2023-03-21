#!/bin/sh
# install homebrew
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile
#eval "$(/opt/homebrew/bin/brew shellenv)"

# brew install git tmux gsed ggrep jq wget cmake gcc tree ripgrep colordiff git-delta vips openexr nvim yarn asdf
# 
# # Font + icon Install for mac
# git clone --branch=master --depth 1 https://github.com/ryanoasis/nerd-fonts.git
# cd nerd-fonts
# ./install.sh
# rm -fr nerd-fonts
# select iTerm2 > profile > NotoSansMono Nerd Font

# restore history
# cp -rf private-dotfiles/zsh/backup_history ~/.zsh_history

# docker desktop install

# install asdf version manager
git clone https://github.com/asdf/asdf.git ~/.asdf --branch v0.8.0
echo ' . /opt/homebrew/opt/asdf/libexec/asdf.sh' >> ~/.zprofile

source ~/.zshrc

# install asdf plugins
asdf plugin-add nodejs
asdf plugin-add golang

# install vscode
brew install --cask visual-studio-code
# install vscode plugins
code --install-extension ms-vscode.go

# install iterm2
brew install --cask iterm2

# install GIPHY CAPTURE
# install Clippy
# install Dropbox
# install tailscale
# install microsoft edge
# install firefox
# install Google日本語入力
