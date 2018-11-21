#!/usr/bin/env bash
set -eu

main () {
    cd ~/dotfiles

    setup_zsh
    setup_mysql
    setup_tmux
    echo 'vimをセットアップしますか? (y or n) '
    read vim_answer
    case "$vim_answer" in
    y)
        select_vim_setup_style
        ;;
    *)
        ;;
    esac

    printf "\e[30;42;1m dotfiles setup completed\e[m\n"
}

setup_zsh () {
    ln -sf ~/dotfiles/zshrc ~/.zshrc
    if [ ! -e ~/.zshrc.local ]; then
        cp ~/dotfiles/zshrc.local ~/.zshrc.local
    fi
}

setup_mysql () {
    ln -sf ~/dotfiles/my.cnf ~/.my.cnf
}

setup_tmux () {
    ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
}

setup_gitconfig () {
    ln -sf ~/dotfiles/company/gitconfig ~/.gitconfig
}

select_vim_setup_style () {
    echo 'vimのセットアップスタイルを選択したください。 (1 or 2 or cansel) '
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
        echo 'vim setup canseled'
        ;;
    esac
}

setup_vim () {
    if [ -e ./vimfiles ]; then
        rm -rf ./vimfiles
    fi

    git clone https://github.com/enoatu/vimfiles.git

    cd ~/dotfiles/vimfiles

    sed -i '/let s:dein_dir/s/~\//~\/dotfiles\//' vimrc || sed -i "" '/let s:dein_dir/s/~\//~\/dotfiles\//' vimrc

    ln -sf ~/dotfiles/vimfiles/vimrc ~/.vimrc
    ln -sf ~/dotfiles/vimfiles/dein.toml ~/.dein.toml

    vim +:q

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

    cd ~/dotfiles/vimfiles/dein/repos/github.com/Shougo/dein.vim
    git checkout a80906f
    cd -

    printf "\e[30;42;1m vim setup for dotfiles completed \e[m\n"
    cd ~/dotfiles
}

setup_vim_only_vimrc () {
    if [ -e ./vimfiles/vimrc ]; then
        rm ./vimfiles/vimrc
    fi
    cd ~/dotfiles/vimfiles

    git fetch
    git checkout HEAD -- vimrc

    sed -i '/let s:dein_dir/s/~\//~\/dotfiles\//' vimrc || sed -i "" '/let s:dein_dir/s/~\//~\/dotfiles\//' vimrc
    ln -sf ~/dotfiles/vimfiles/vimrc ~/.vimrc
    cd -

}


main

exit 0
