FROM ubuntu:18.04

WORKDIR /root

# コピペできるようにENVなど定義しない

# 1. default
# 2. asdf curl git
# 3. locales (for nvim), language-pack-jaがないとnvimが動かない
# 4. unzip, wget(masonで必要)
# 5. tmux あったら嬉しい

## -----need sudo-------
RUN \
    apt update && \
    apt-get update && \
    apt-get install -y zsh tar \
    curl git \
    locales language-pack-ja \
    unzip wget \
    tmux

# 1.change shell
# 2.nvim locale error fix
RUN \
    chsh -s /usr/bin/zsh && \
    locale-gen ja_JP.UTF-8 && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
