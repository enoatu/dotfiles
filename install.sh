#!/usr/bin/env bash
set -u

DOTFILES="${HOME}/dotfiles"
ADDITIONAL_DOTFILES=${ADDITIONAL_DOTFILES:-"${DOTFILES}/private-dotfiles"}
ADDITIONAL_REPO_URL=${ADDITIONAL_REPO_URL:-"https://enoatu@github.com/enoatu/private-dotfiles.git"}
ADDITIONAL_REPO_BRANCH=${ADDITIONAL_REPO_BRANCH:-"main"}
UNOFFICEIAL_NODE=${DOTFILES}/installs/node-v18.19.0-linux-x64-glibc-217/bin/node
UNOFFICEIAL_NPM=${DOTFILES}/installs/node-v18.19.0-linux-x64-glibc-217/bin/npm

# need
# curl tar git

# --no-test をつけるとテストをスキップする
is_exec_test=true
for OPT in "$@"; do
  case "$OPT" in
  '--no-test' | '-n')
    is_exec_test=false
    ;;
  *)
    ;;
  esac
done

main() {
  cd ${HOME}/dotfiles
  echo '? (all or nvim or zsh or tmux or git or tools or additional(a)) '
  read answer
  case "$answer" in
  all)
    setup_zsh
    setup_tools
    setup_neovim
    setup_tmux
    setup_additional_dotfiles
    ;;
  nvim)
    setup_neovim
    ;;
  zsh)
    setup_zsh
    ;;
  tmux)
    setup_tmux
    ;;
  tools)
    #setup_tools
    install_unofficial_node
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

setup_additional_dotfiles() {
  (
    if [ ! -e ${ADDITIONAL_DOTFILES} ]; then
     git clone ${ADDITIONAL_REPO_URL} ${ADDITIONAL_DOTFILES}
      if [ $? -ne 0 ]; then
        # sshキー作成
        if [ ! -e ${HOME}/.ssh/id_rsa && ! -e ${HOME}/.ssh/id_rsa.pub ]; then
          ssh-keygen -t rsa -b 4096
        fi
        cat ${HOME}/.ssh/id_rsa.pub
        echo '上記の公開鍵を、以下のURLに登録してください'
        echo 'https://github.com/settings/keys'
        echo '登録後、Enterを押してください'
        read
        git clone ${ADDITIONAL_REPO_URL} ${ADDITIONAL_DOTFILES}
      fi
      cd ${ADDITIONAL_DOTFILES}
      git checkout ${ADDITIONAL_REPO_BRANCH}
    fi
    cd ${ADDITIONAL_DOTFILES}
    ./install.sh
  )
}

setup_zsh() {
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
  $is_exec_test && test_zsh
  echo 'Please exec "source ~${HOME}/.zshrc"'
}

test_zsh() {
  echo '1. ~/.zshrcが存在するか'
  if [ ! -e ${HOME}/.zshrc ]; then
    echo 'zshrcが存在しません'
    exit 1
  fi
  echo 'ok'

  echo '2. zshがインストールされているか'
  if [ $(which zsh) == '' ]; then
    echo 'zshがインストールされていません'
    exit 1
  fi
  echo 'ok'

  echo '3. fzfがインストールされているか'
  if [ ! -e ${DOTFILES}/zsh/fzf.zsh ]; then
    echo 'fzfがインストールされていません'
    exit 1
  fi
  echo 'ok'

  echo '4. zsh-autosuggestionsがインストールされているか'
  if [ ! -e ${DOTFILES}/zsh/zsh-autosuggestions.zsh ]; then
    echo 'zsh-autosuggestionsがインストールされていません'
    exit 1
  fi
  echo 'ok'
}

setup_tmux() {
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
  $is_exec_test && test_tmux
  printf "\e[30;42;1m tmux setup completed\e[m\n"
}

test_tmux() {
  echo '1. ~/.tmux.confが存在するか'
  if [ ! -e ${HOME}/.tmux.conf ]; then
    echo 'tmux.confが存在しません'
    exit 1
  fi
  echo 'ok'

  echo '2. tmuxがインストールされているか'
  if [ "$(which tmux)" == '' ]; then
    echo 'tmuxがインストールされていません'
    exit 1
  fi
  echo 'ok'
}

setup_neovim() {
  if [ ! -e ${DOTFILES}/neovim/install/nvim ]; then
    if [ "$(uname)" == 'Darwin' ]; then
      echo "mac の場合は、ロゼッタを有効にしないでインストールを行うこと"
      curl -L -o tmp-nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-macos.tar.gz
    else
      curl -L -o tmp-nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    fi
    mkdir -p ${DOTFILES}/neovim/install
    tar xzf tmp-nvim.tar.gz --directory=${DOTFILES}/neovim/install
    find ${DOTFILES}/neovim/install -maxdepth 1 -mindepth 1 -type d | xargs -I{} mv {} ${DOTFILES}/neovim/install/nvim
    rm -rf tmp-nvim.tar.gz
  fi

  if [ -e ${HOME}/.config/nvim ]; then
    rm -rf ${HOME}/.config/nvim
  fi
  mkdir -p ${HOME}/.config/nvim

  # check in vim command line
  # :checkhealth

  setup_asdf

  # ~/.asdf/.tool_versions (ローカルでないことに注意) に golang 1.21 など記載することでプラグインエラーを回避できる

  install_rg

  # coc.nvim で使う
  asdf plugin-add nodejs
  (
    cd ${DOTFILES}/neovim
    asdf install nodejs 18.16.0
    $HOME/.asdf/installs/nodejs/18.16.0/bin/node -v
    if [ $? -ne 0 ]; then
      echo 'asdf で nodejsのインストールに失敗しました'
      echo 'nodejsをバイナリでインストールします'
      install_unofficial_node
      export PATH=$HOME/.asdf/installs/nodejs/18.19.0/bin:$PATH
    else
      echo 'asdf で nodejsのインストールに成功しました'
      asdf local nodejs 18.16.0
      export PATH=$HOME/.asdf/installs/nodejs/18.16.0/bin:$PATH
    fi

    # yarn = cocで使用
    npm install -g neovim zx yarn@1 @githubnext/github-copilot-cli

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
  )

  # for nvim
  ln -sf ${DOTFILES}/neovim/init.lua ${HOME}/.config/nvim/init.lua
  ln -sf ${DOTFILES}/neovim/lua ${HOME}/.config/nvim/lua
  ln -sf ${DOTFILES}/neovim/coc-settings.json ${HOME}/.config/nvim/coc-settings.json
  ln -sf ${DOTFILES}/neovim/lazy-lock.json ${HOME}/.config/nvim/lazy-lock.json
  ln -sf ${DOTFILES}/neovim/.editorconfig ${HOME}/.editorconfig
  cp ${DOTFILES}/neovim/lua/env.lua.sample ${DOTFILES}/neovim/lua/env.lua

  $is_exec_test && test_neovim
  printf "\e[30;42;1m new vim setup completed \e[m\n"
}

install_unofficial_node() {
  name='node-v18.19.0-linux-x64-glibc-217'
  if [ -e ${HOME}/.asdf/installs/nodejs/18.19.0 ]; then
    rm -rf ${HOME}/.asdf/installs/nodejs/18.19.0
  fi
  cd ${DOTFILES}/lib
  tar xzf ${name}.tar.gz --directory=${HOME}/.asdf/installs/nodejs/
  mv ${HOME}/.asdf/installs/nodejs/${name} ${HOME}/.asdf/installs/nodejs/18.19.0
  cd -
}

test_neovim() {
  echo '1. ~/.config/nvim/init.luaが存在するか'
  if [ ! -e ${HOME}/.config/nvim/init.lua ]; then
    echo 'init.luaが存在しません'
    exit 1
  fi
  echo 'ok'

  echo '2. nvimがインストールされているか'
  if [ "$(which nvim)" == '' ]; then
    echo 'nvimがインストールされていません'
    exit 1
  fi
  echo 'ok'

  echo '3. neovimを実行して、:checkhealthが正常に動作するか'
  nvim -c ':checkhealth'
  echo 'ok'
}

setup_tools() {
  install_delta
  install_rg
  install_fd
  $is_exec_test && test_tools
}

test_tools() {
  echo '1. deltaがインストールされているか'
  if [ ! -e ${DOTFILES}/installs/delta ]; then
    echo 'deltaがインストールされていません'
    exit 1
  fi
  echo 'ok'

  echo '2. rgがインストールされているか'
  if [ ! -e ${DOTFILES}/installs/rg ]; then
    echo 'rgがインストールされていません'
    exit 1
  fi
  echo 'ok'

  echo '3. fdがインストールされているか'
  if [ ! -e ${DOTFILES}/installs/fd ]; then
    echo 'fdがインストールされていません'
    exit 1
  fi
  echo 'ok'
}

install_delta() {
  url=''
  if [ "$(uname)" == 'Darwin' ]; then
    url='https://github.com/dandavison/delta/releases/download/0.16.5/delta-0.16.5-x86_64-apple-darwin.tar.gz'
  else
    url='https://github.com/dandavison/delta/releases/download/0.16.5/delta-0.16.5-x86_64-unknown-linux-gnu.tar.gz'
  fi
  install_binary_from_tar_gz $url delta
}

install_rg() {
  url=''
  if [ "$(uname)" == 'Darwin' ]; then
    url='https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-apple-darwin.tar.gz'
    install_binary_from_tar_gz $url rg
  else
    (
      url='https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz'
      TMPDIR=$(mktemp -d)
      cd $TMPDIR
      wget -O - $url | tar zxf - --strip-component=1
      mv rg ${DOTFILES}/installs/
    )
  fi
}

install_fd() {
  url=''
  if [ "$(uname)" == 'Darwin' ]; then
    url='https://github.com/sharkdp/fd/releases/download/v8.7.0/fd-v8.7.0-x86_64-apple-darwin.tar.gz'
  else
    url=https://github.com/sharkdp/fd/releases/download/v8.7.0/fd-v8.7.0-x86_64-unknown-linux-gnu.tar.gz
  fi
  install_binary_from_tar_gz $url fd
}

install_binary_from_tar_gz() {
  url=$1
  name=$2
  # delete tmp-${name}.tar.gz ${DOTFILES}/${name}-bin
  if [ -e tmp-${name}.tar.gz ]; then
    rm -rf tmp-${name}.tar.gz ${DOTFILES}/${name}-bin
  fi
  if [ -e ${DOTFILES}/${name}-bin ]; then
    rm -rf ${DOTFILES}/${name}-bin
  fi
  if [ ! -e ${DOTFILES}/installs/${name} ]; then
    mkdir -p ${DOTFILES}/${name}-bin
    curl -L -o tmp-${name}.tar.gz $url
    tar xzf tmp-${name}.tar.gz --directory=${DOTFILES}/${name}-bin
    # ディレクトリ名が変わるので、ディレクトリ名を取得して移動する
    find ${DOTFILES}/${name}-bin -maxdepth 1 -mindepth 1 -type d | xargs -I{} mv {}/${name} ${DOTFILES}/installs
    rm -rf tmp-${name}.tar.gz ${DOTFILES}/${name}-bin
  else # すでにインストール済みの場合
    echo ${name} 'is already installed'
  fi
}


setup_asdf() {
  if [ ! -e ${HOME}/.asdf ]; then
    git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf --branch v0.12.0
  else
    echo 'asdf is already installed'
  fi
  . ${HOME}/.asdf/asdf.sh
}

main

exit 0
