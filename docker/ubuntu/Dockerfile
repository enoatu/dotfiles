FROM ubuntu:22.04

# なぜか ubuntuでnvimが動かない
# docker run -it --rm ubuntu:22.04 /bin/bash
# apt update && apt install -y neovim && nvim
# E970: Failed to initialize lua interpreter/root
# Vim: Finished.
# これは docker run -it --rm ubuntu:24.04 /bin/bash でも発生。そのため放置する

WORKDIR /root

# コピペできるようにENVなど定義しない

# 1. default
# 2. mise curl git
# 3. locales (for nvim), language-pack-jaがないとnvimが動かない
# 4. unzip, wget(masonで必要)
# 5. tmux あったら嬉しい

## -----need sudo-------
RUN \
  apt update && \
  apt-get install -y zsh tar \
  curl git \
  locales language-pack-ja \
  unzip wget \
  tmux

# 1.change shell (rootユーザーのものが変わるため注意する
# 2.nvim locale error fix
RUN \
  chsh -s /usr/bin/zsh && \
  locale-gen ja_JP.UTF-8 && \
  localedef -f UTF-8 -i ja_JP ja_JP.UTF-8

# dotfilesをクローンしてインストール
RUN git clone https://github.com/enoatu/dotfiles.git && \
    cd dotfiles && \
    ADDITIONAL_REPO_GITHUB_TOKEN="" ./install.sh
