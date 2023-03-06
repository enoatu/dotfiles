#!/usr/bin/env bash
set -u

DOTFILES="${HOME}/dotfiles"
PRIVATE_DOTFILES="${HOME}/dotfiles/private-dotfiles"
PRIVATE_REPO_URL="https://enoatu@github.com/enoatu/private-dotfiles.git"
ANYENV_DIR="${HOME}/.anyenv"
ANYENV="${ANYENV_DIR}/bin/anyenv"

main () {
    cd ${HOME}/dotfiles
    if [ -d ${PRIVATE_DOTFILES} ]; then
        rm -rf ${PRIVATE_DOTFILES}
    fi
    git clone ${PRIVATE_REPO_URL} ${PRIVATE_DOTFILES}
    echo '? (all or vim or zsh or tmux or git) '
    read answer
    case "$answer" in
    all)
        select_vim_setup_style
        setup_zsh
        setup_tmux
        setup_gitconfig
        ;;
    vim)
        select_vim_setup_style
        ;;
    zsh)
        setup_zsh
        ;;
    tmux)
        setup_tmux
        ;;
    git)
        setup_gitconfig
        ;;
    anyenv)
        setup_anyenv
        ;;
    *)
        printf "\e[30;42;1m exit\e[m\n"
        ;;
    esac

    printf "\e[30;42;1m dotfiles setup completed\e[m\n"
}

setup_zsh () {
    (
        cd ${DOTFILES}/zsh
        if [ ! -e ${DOTFILES}/zsh/fzf.zsh ]; then
            git clone https://github.com/junegunn/fzf.git ./fzf
            ./fzf/install --no-fish --no-bash
            mv ~/.fzf.zsh ${DOTFILES}/zsh/fzf.zsh
        fi
        # if [ ! -e ${DOTFILES}/node/.nodenv ]; then
        #     cd node
        #     git clone https://github.com/nodenv/nodenv.git ./nodenv
        #     cd .nodenv && src/configure && make -C src && cd ..
        #     ./nodenv install 16.8.0
        #     ./nodenv rehash
        #     yarn add zx
        # fi
        if [ ! -e ${DOTFILES}/zsh/zsh-autosuggestions.zsh ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions ./zsh-autosuggestions
            mv ./zsh-autosuggestions/zsh-autosuggestions.zsh ${DOTFILES}/zsh/zsh-autosuggestions.zsh
        fi
        ln -sf ${DOTFILES}/zsh/zshrc ~/.zshrc
        if [ ! -e ~/.zshrc.local ]; then
            ln -sf $PRIVATE_DOTFILES/zsh/zshrc.local ~/.zshrc.local
        else
            echo 'プロンプト反映しますか。 (y or n) '
            read zsh_answer
            case "$zsh_answer" in
            y)
                echo 'selected :1'
                ln -sf $PRIVATE_DOTFILES/zsh/zshrc.local ~/.zshrc.local
                printf "\e[30;42;1m zsh setup completed\e[m\n"
                ;;
            *)
                echo 'zsh setup canceled'
                ;;
            esac
       fi
    )
}

setup_tmux () {
    echo 'tmuxのセットアップスタイルを選択したください。 (1 or 2 or cancel) '
    echo '1: local環境'
    echo '2: リモート環境'
    echo '3: 踏み台環境'
    read tmux_answer
    case "$tmux_answer" in
    1)
        echo 'selected :1'
        ln -sf ~/dotfiles/tmux/tmux.local.conf ~/.tmux.conf
        ;;
    2)
        echo 'selected :2'
        ln -sf ~/dotfiles/tmux/tmux.remote.conf ~/.tmux.conf
        ;;
    3)
        echo 'selected :3'
        ln -sf ~/dotfiles/tmux/tmux.humidai.conf ~/.tmux.conf
        ;;
    *)
        echo 'tmux setup canceled'
        ;;
    esac
    printf "\e[30;42;1m tmux setup completed\e[m\n"
}

setup_gitconfig () {
    if [ ! -e $PRIVATE_DOTFILES/git ]; then
        echo "git config が存在しません。"
        return
    fi
    echo 'gitconfigのセットアップスタイルを選択してください。 (1 or 2 or 3 or cancel) '
    echo '1: my環境'
    echo '2: moove環境'
    echo '3: moove proxy環境'
    read git_answer
    case "$git_answer" in
    1)
        echo 'selected :1'
        ln -sf $PRIVATE_DOTFILES/git/gitconfig.my ~/.gitconfig
        ln -sf $PRIVATE_DOTFILES/git/gitignore ~/.gitignore_global
        ;;
    2)
        echo 'selected :2'
        ln -sf $PRIVATE_DOTFILES/git/gitconfig.moove ~/.gitconfig
        ln -sf $PRIVATE_DOTFILES/git/gitignore ~/.gitignore_global
        ;;
    3)
        echo 'selected :3'
        ln -sf $PRIVATE_DOTFILES/git/gitconfig.moove-proxy ~/.gitconfig
        ln -sf $PRIVATE_DOTFILES/git/gitignore ~/.gitignore_global
        ;;
    *)
        echo 'tmux setup canceled'
        ;;
    esac
    printf "\e[30;42;1m git setup completed\e[m\n"
}

select_vim_setup_style () {
    echo 'vimのセットアップスタイルを選択したください。 (1 or 2 or cancel) '
    echo '1: vimrc + プラグイン のセットアップ'
    echo '2: vimrc              のセットアップ'
    echo '3: new vim のセットアップ'
    read vim_plugin_answer
    case "$vim_plugin_answer" in
    1)
        echo 'selected :1'
        setup_vim
        ;;
    2)
        echo 'selected :2'
        setup_vim_only_vimrc
        ;;
    3)
        echo 'selected :3'
        setup_new_vim
        ;;
    *)
        echo 'vim setup canceled'
        ;;
    esac
}

setup_vim () {
    cd ${DOTFILES}/vim
    echo ''
    echo '[入っているvim]'
    echo $(vim --version | head -n5)
    echo ''
    VIM=vim
    ispython=$(vim --version | grep '\+python')
    if [ -n "$ispython" ]; then
        echo ''
        echo 'pythonインターフェイスが使用できないvimを使用しています。'
        echo ''
    fi
    echo 'vimの環境をえらんでください。 (1 or 2 or cancel) '
    echo '1: neocomplete+neosnippets+neosnippets環境(簡単に使える補完)'
    echo '2: TabNine環境(ディープラーニングを使用した高度な補完)'
    echo '   (dotfiles以下に環境を構築します)'
    read vim_answer2
    case "$vim_answer2" in
    1)
        echo 'selected :1'
        rm -rf ${DOTFILES}/vim/dein
        rm -rf ${DOTFILES}/vim/.local
        ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
        ln -sf ~/dotfiles/vim/dein.toml.neocomplete ~/.dein.toml
        ;;
    2)
        echo 'selected :2'
        if [ -n "$ispython" ]; then
            echo ''
            echo 'pythonインターフェイスが使用できないvimを使用しています。'
            echo ''
            echo 'vimの環境をえらんでください。 (1 or 2 or cancel) '
            echo '1: neocomplete+neosnippets+neosnippets環境(簡単に使える補完)'
            echo '2: TabNine環境(ディープラーニングを使用した高度な補完)'
            echo '   (vim をインストールしてdotfiles以下に環境を構築します)'
            read vim_answer3
            case "$vim_answer3" in
            1)
                echo 'selected :1'
                rm -rf ${DOTFILES}/vim/dein
                rm -rf ${DOTFILES}/vim/.local
                ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
                ln -sf ~/dotfiles/vim/dein.toml.neocomplete ~/.dein.toml
                ;;
            2)
                rm -rf ${DOTFILES}/vim/dein
                rm -rf ${DOTFILES}/vim/.local
                ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
                ln -sf ~/dotfiles/vim/dein.toml.youcompleteme ~/.dein.toml
                PYTHON_VER=3.7.2
                if [ ! -e $ANYENV_DIR ]; then
                    setup_anyenv
                fi
                PYENV="${ANYENV_DIR}/envs/pyenv/bin/pyenv"
                if [ ! -e $PYENV ]; then
                    $ANYENV install pyenv
                    $PYENV install $PYTHON_VER
                    $PYENV global $PYTHON_VER
                    $PYENV rehash
                fi
                if [ ! -e vim-8.1.2152 ]; then
                    wget https://github.com/vim/vim/archive/v8.1.2152.tar.gz
                    tar -xvf v8.1.2152.tar.gz
                fi
                rm -rf ${DOTFILES}/vim/share
                rm -rf ${DOTFILES}/vim/bin
                cd vim-8.1.2152
                ./configure --prefix=${DOTFILES}/vim \
                    --localstatedir=${DOTFILES}/vim \
                    --with-features=normal \
                    --enable-gpm \
                    --enable-acl \
                    --enable-multibyte \
                    --enable-cscope \
                    --enable-netbeans \
                    --enable-perlinterp \
                    --enable-pythoninterp \
                    --enable-python3interp \
                    --enable-rubyinterp \
                    --enable-luainterp
                make
                make install
                isExistPath=$(grep 'alias vim' ${HOME}/.zshrc.local)
                if [ ! -n "$isExistPath" ]; then
                    echo "alias vim=${DOTFILES}/vim/bin/vim"         >> ${HOME}/.zshrc.local
                    echo "alias view=${DOTFILES}/vim/bin/view"       >> ${HOME}/.zshrc.local
                    echo "alias vimdiff=${DOTFILES}/vim/bin/vimdiff" >> ${HOME}/.zshrc.local
                fi
                cd ..
                VIM="${DOTFILES}/vim/bin/vim"
                rm -rf ${DOTFILES}/v8*
                rm -rf ${DOTFILES}/vim-8.1.2152
                ;;
            *)
                echo 'vim setup canceled'
                return 0
                ;;
            esac
        fi
    esac
    $VIM +:q
    if [ ! -e ./dein/.cache/.vimrc/.dein/lib/vimproc.vim ]; then
      mkdir -p dein/.cache/.vimrc/.dein/lib
      cd ./dein/.cache/.vimrc/.dein/lib
      git clone https://github.com/Shougo/vimproc.vim.git
      cd vimproc.vim
      make
      if [ -e ./lib/vimproc_linux64.so ]; then
          ln -s vimproc.vim/lib/vimproc_linux64.so ..
      elif [ -e ./lib/vimproc_mac.so ]; then
          ln -s vimproc.vim/lib/vimproc_mac.so .. #TODO
      else
          printf "\e[37;41;1m Couldn't find vimproc.so \e[m\n"
          exit
      fi
    fi

    cd ~/dotfiles/vim/dein/repos/github.com/Shougo/dein.vim
    git checkout a80906f
    cd -

    printf "\e[30;42;1m vim setup completed \e[m\n"
    cd ~/dotfiles
}

setup_anyenv() {
    git clone https://github.com/riywo/anyenv $ANYENV_DIR
    echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.zshrc.local
    $ANYENV init
    $ANYENV install --init -y
}

setup_vim_only_vimrc () {
    if [ -e ./vim/vimrc ]; then
        rm ./vim/vimrc
    fi
    cd ~/dotfiles/vim

    git fetch
    git checkout HEAD -- vimrc

    sed -i '/let s:dein_dir/s/~\//~\/dotfiles\//' vimrc || sed -i "" '/let s:dein_dir/s/~\//~\/dotfiles\//' vimrc
    ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
    cd -
    printf "\e[30;42;1m vim setup completed \e[m\n"
}

setup_new_vim () {
    rm -rf ${DOTFILES}/vim/neo-dein

    if [ -e ~/.config/nvim ]; then
        rm -rf ~/.config/nvim
    fi
    mkdir -p ~/.config/nvim
    if [ -e ~/.vim ]; then
        rm -rf ~/.vim
    fi
    mkdir -p ~/.vim

    # for nvim
    ln -sf ~/dotfiles/vim/vimrc ~/.config/nvim/init.vim
    if [ -e $PRIVATE_DOTFILES/vim/coc-settings.json ]; then
      ln -sf $PRIVATE_DOTFILES/vim/coc-settings.json ~/.config/nvim/coc-settings.json
    fi
    # for vim
    ln -sf ~/dotfiles/vim/vimrc ~/.vimrc

    printf "\e[30;42;1m new vim setup completed \e[m\n"
}
main

exit 0
