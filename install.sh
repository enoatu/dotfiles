#!/usr/bin/env bash
set -eu

main () {
    cd ~/dotfiles
    echo '? (all or vim or zsh or mysql or tmux or git) '
    read answer
    case "$answer" in
    all)
        select_vim_setup_style
        setup_zsh
        setup_mysql
        setup_tmux
        setup_gitconfig
        ;;
    vim)
        select_vim_setup_style
        ;;
    zsh)
        setup_zsh
        ;;
    mysql)
        setup_mysql
        ;;
    tmux)
        setup_tmux
        ;;
    git)
        setup_gitconfig
        ;;
    *)
        printf "\e[30;42;1m exit\e[m\n"
        ;;
    esac

    printf "\e[30;42;1m dotfiles setup completed\e[m\n"
}

setup_zsh () {
    ln -sf ~/dotfiles/zsh/zshrc ~/.zshrc
    if [ ! -e ~/.zshrc.local ]; then
        ln -sf ~/dotfiles/zsh/zshrc.local ~/.zshrc.local
    else
        echo 'プロンプト反映しますか。 (y or n) '
        read zsh_answer
        case "$zsh_answer" in
        y)
            echo 'selected :1'
            ln -sf ~/dotfiles/zsh/zshrc.local ~/.zshrc.local
            printf "\e[30;42;1m zsh setup completed\e[m\n"
            ;;
        *)
            echo 'zsh setup canceled'
            ;;
        esac
   fi
}

setup_mysql () {
    ln -sf ~/dotfiles/mysql/my.cnf ~/.my.cnf
    printf "\e[30;42;1m mysql setup completed\e[m\n"
}

setup_tmux () {
    echo 'tmuxのセットアップスタイルを選択したください。 (1 or 2 or cancel) '
    echo '1: local環境'
    echo '2: リモート環境'
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
    *)
        echo 'tmux setup canceled'
        ;;
    esac
    printf "\e[30;42;1m tmux setup completed\e[m\n"
}

setup_gitconfig () {
    echo 'gitconfigのセットアップスタイルを選択したください。 (1 or 2 or 3 or cancel) '
    echo '1: my環境'
    echo '2: moove環境'
    echo '3: moove proxy環境'
    read git_answer
    case "$git_answer" in
    1)
        echo 'selected :1'
        ln -sf ~/dotfiles/git/gitconfig.my ~/.gitconfig
        ;;
    2)
        echo 'selected :2'
        ln -sf ~/dotfiles/git/gitconfig.moove ~/.gitconfig
        ;;
    3)
        echo 'selected :3'
        ln -sf ~/dotfiles/git/gitconfig.moove.proxy ~/.gitconfig
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
    *)
        echo 'vim setup canceled'
        ;;
    esac
}

setup_vim () {
    cd ~/dotfiles/vim
    ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
    ln -sf ~/dotfiles/vim/dein.toml ~/.dein.toml
    vim +:q
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
main

exit 0
