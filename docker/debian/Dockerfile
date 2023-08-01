FROM ubuntu:22.04

WORKDIR /root

# コピペできるようにENVなど定義しない

# 1. default
# 2. asdf curl git
# 3. locales (for nvim), language-pack-jaがないとnvimが動かない
# 4. --python3-pip (for nvim) asdfビルドより早い-- バージョン差異が発生する

## -----need sudo-------
RUN \
    apt update && \
    apt-get update && \
    apt-get install -y zsh tar \
    curl git \
    locales language-pack-ja \
    python3-pip

# nvim locale error fix
RUN \
    locale-gen ja_JP.UTF-8 && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
## -----need sudo-------

# asdf install
RUN \
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0 && \
    echo '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc


# あらかじめ定義しておく
RUN \
    echo 'export PATH="$HOME/dotfiles/vim/usr/bin:$PATH"' >> ~/.bashrc && \
    echo 'export LC_ALL=ja_JP.UTF-8' >> ~/.bashrc && \
    echo 'export LANG=ja_JP.UTF-8' >> ~/.bashrc

RUN \
    mkdir -p ~/.config/nvim && \
    ln -sf ~/dotfiles/vim/vimrc ~/.config/nvim/init.vim && \
    ln -sf ~/dotfiles/private-dotfiles/vim/coc-settings.json ~/.config/nvim/coc-settings.json

# asdf plugin install
# nodejs (for coc.nvim)
#  ubuntu18.04では nodejs 18.16.0が動かなかったので
RUN ["/bin/bash", "-ci", " \
        source ~/.bashrc && \
        asdf plugin-add nodejs && \
        asdf install nodejs 17.9.1 && \
        asdf global nodejs 17.9.1 \
    "]
# python
#RUN \
#    asdf plugin-add python && \
#    asdf install python 3.9.7 && \
#    asdf global python 3.9.7
# ruby
#RUN \
#    asdf plugin-add ruby && \
#    asdf install ruby 3.0.2 && \
#    asdf global ruby 3.0.2


# neovim install
RUN \
    curl -LO https://github.com/neovim/neovim/releases/download/v0.9.1/nvim-linux64.tar.gz && \
    tar xzf nvim-linux64.tar.gz && \
    mkdir -p ~/dotfiles/vim && \
    mv nvim-linux64 ~/dotfiles/vim/usr && \
    rm -rf nvim-linux64.tar.gz

RUN \
    python3 -m pip install --user --upgrade pynvim
