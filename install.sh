#!/usr/bin/env bash
set -u

DOTFILES="${HOME}/dotfiles"
ADDITIONAL_DOTFILES=${ADDITIONAL_DOTFILES:-"${DOTFILES}/private-dotfiles"}
ADDITIONAL_REPO_URL=${ADDITIONAL_REPO_URL:-"https://enoatu@github.com/enoatu/private-dotfiles.git"}
ADDITIONAL_REPO_BRANCH=${ADDITIONAL_REPO_BRANCH:-"main"}

# need
# curl tar git

main () {
    cd ${HOME}/dotfiles
    echo '? (all or nvim or zsh or tmux or git or additional(a)) '
    read answer
    case "$answer" in
    all)
        setup_zsh
        setup_neovim
        setup_tmux
        setup_additional_dotfiles
        echo 'Please exec "source ${HOME}/.zshrc"'
        ;;
    nvim)
        setup_neovim
        ;;
    zsh)
        setup_zsh
        echo 'Please exec "source ~${HOME}/.zshrc"'
        ;;
    tmux)
        setup_tmux
        ;;
    additional)
        ADDITIONAL_INSTALL_SELECT=1
        setup_additional_dotfiles
        ;;
    a)
        ADDITIONAL_INSTALL_SELECT=1
        setup_additional_dotfiles
        ;;
    *)
        printf "\e[30;42;1m exit\e[m\n"
        ;;
    esac

    printf "\e[30;42;1m dotfiles setup completed\e[m\n"
}

setup_additional_dotfiles () {
    (
        if [ ! -e ${ADDITIONAL_DOTFILES} ]; then
            git clone ${ADDITIONAL_REPO_URL} ${ADDITIONAL_DOTFILES}
            cd ${ADDITIONAL_DOTFILES}
            git checkout ${ADDITIONAL_REPO_BRANCH}
        fi
        cd ${ADDITIONAL_DOTFILES}
        ./install.sh
    )
}

setup_zsh () {
    (
        cd ${DOTFILES}/zsh
        if [ ! -e ${DOTFILES}/zsh/fzf.zsh ]; then
            git clone https://github.com/junegunn/fzf.git ./fzf
            ./fzf/install --no-fish --no-bash
            mv ${HOME}/.fzf.zsh ${DOTFILES}/zsh/fzf.zsh
        fi
        if [ ! -e ${DOTFILES}/zsh/zsh-autosuggestions.zsh ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions ./zsh-autosuggestions
            mv ./zsh-autosuggestions/zsh-autosuggestions.zsh ${DOTFILES}/zsh/zsh-autosuggestions.zsh
        fi
        ln -sf ${DOTFILES}/zsh/zshrc ${HOME}/.zshrc
    )
}

setup_tmux () {
    echo 'tmuxのセットアップスタイルを選択したください。 (1 or 2 or 3 or cancel) '
    echo '1: local環境'
    echo '2: リモート環境'
    echo '3: 踏み台環境'
    read tmux_answer
    case "$tmux_answer" in
    1)
        echo 'selected :1'
        ln -sf ${DOTFILES}/tmux/tmux.local.conf ${HOME}/.tmux.conf
        ;;
    2)
        echo 'selected :2'
        ln -sf ${DOTFILES}/tmux/tmux.remote.conf ${HOME}/.tmux.conf
        ;;
    3)
        echo 'selected :3'
        ln -sf ${DOTFILES}/tmux/tmux.humidai.conf ${HOME}/.tmux.conf
        ;;
    *)
        echo 'tmux setup canceled'
        ;;
    esac
    printf "\e[30;42;1m tmux setup completed\e[m\n"
}

setup_neovim () {
    if [ ! -e ${DOTFILES}/neovim/install/nvim ]; then
        if [ "$(uname)" == 'Darwin' ]; then
            curl -L -o tmp-nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-macos.tar.gz
        else
            curl -L -o tmp-nvim.tar.gz https://github.com/neovim/neovim/releases/download/v0.9.1/nvim-linux64.tar.gz
        fi
        mkdir -p ${DOTFILES}/neovim/install
        tar xzf tmp-nvim.tar.gz --directory=${DOTFILES}/neovim/install
        find ${DOTFILES}/neovim/install -maxdepth 1 -mindepth 1 -type d | xargs -I{} mv {} ${DOTFILES}/neovim/install/nvim
        rm -rf tmp-nvim.tar.gz
    fi
    rm -rf ${DOTFILES}/neovim/neo-dein

    if [ -e ${HOME}/.config/nvim ]; then
        rm -rf ${HOME}/.config/nvim
    fi
    mkdir -p ${HOME}/.config/nvim

    # check in vim command line
    # :checkhealth

    # check asdf
    if [ ! -e ${HOME}/.asdf ]; then
        git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf --branch v0.12.0
        . ${HOME}/.asdf/asdf.sh
    fi

    # coc.nvim で使う
    asdf plugin-add nodejs
    asdf install nodejs 16.8.0
    asdf global nodejs 16.8.0
    npm install -g neovim zx yarn@1

    # coc-snippets で使う
    #asdf plugin-add python
    #asdf install python 3.9.7
    #asdf global python 3.9.7

    # まだ不要
    # asdf plugin-add perl
    # asdf install perl 5.30.0
    # asdf global perl 5.30.0
    # exec $SHELL -l
    # cpan Neovim::Ext

    # まだ不要
    # asdf plugin-add ruby
    # asdf install ruby 3.2.1
    # asdf global ruby 3.2.1
    # exec $SHELL -l
    # gem install neovim

    # for nvim
    ln -sf ${DOTFILES}/neovim/init.lua ${HOME}/.config/nvim/init.lua
    ln -sf ${DOTFILES}/neovim/lua ${HOME}/.config/nvim/lua
    ln -sf ${DOTFILES}/neovim/coc-settings.json ${HOME}/.config/nvim/coc-settings.json
    ln -sf ${DOTFILES}/neovim/lazy-lock.json ${HOME}/.config/nvim/lazy-lock.json

    printf "\e[30;42;1m new vim setup completed \e[m\n"
}

main

exit 0
