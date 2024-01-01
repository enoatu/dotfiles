FROM debian:buster-20230703

WORKDIR /root

# コピペできるようにENVなど定義しない

# 1. default
# 2. asdf curl git
# 3. locales (for nvim), language-pack-jaがないとnvimが動かない
# 4. tmux あったら嬉しい
# 5. build-essential coc-snippets が pythonを使用していて、pythonのビルドのために必要

## -----need sudo-------
RUN \
    apt update && \
    apt-get update && \
    apt-get install -y zsh tar \
    curl git \
    locales language-pack-ja \
    tmux \
    build-essential

# nvim locale error fix
RUN \
    locale-gen ja_JP.UTF-8 && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
# clone dotfiles
#RUN \
#    git clone https://github.com/enoatu/dotfiles.git && \
#    cd dotfiles && \
#    ./install.sh
