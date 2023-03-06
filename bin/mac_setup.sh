#!/bin/sh
# install homebrew
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | sh

brew install git tmux gsed ggrep jq wget cmake gcc tree ripgrep colordiff git-delta vips openexr

# Font + icon Install for mac
git clone --branch=master --depth 1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
./install.sh
rm -fr nerd-fonts
# select iTerm2 > profile > NotoSansMono Nerd Font

# docker desktop install
sudo curl -L https://download.docker.com/mac/stable/Docker.dmg -o /tmp/Docker.dmg
sudo hdiutil attach /tmp/Docker.dmg
sudo cp -r /Volumes/Docker/Docker.app /Applications
sudo hdiutil detach /Volumes/Docker
rm /tmp/Docker.dmg


# install asdf version manager
git clone https://github.com/asdf/asdf.git ~/.asdf --branch v0.8.0
echo -e '

. $HOME/.asdf/asdf.sh' >> ~/.zshrc
echo -e '

. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc
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
