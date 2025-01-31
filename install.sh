#!/usr/bin/env zsh

DOTFILES="${HOME}/dotfiles"
ZSH_INSTALLS=${DOTFILES}/zsh/installs
ADDITIONAL_DOTFILES=${ADDITIONAL_DOTFILES:-"${DOTFILES}/private-dotfiles"}
ADDITIONAL_REPO_BRANCH=${ADDITIONAL_REPO_BRANCH:-"main"}
ADDITIONAL_REPO_GITHUB_TOKEN=${ADDITIONAL_REPO_GITHUB_TOKEN:-""}
ADDITIONAL_REPO_URL=${ADDITIONAL_REPO_URL:-"https://${ADDITIONAL_REPO_GITHUB_TOKEN}@github.com/enoatu/private-dotfiles.git"}

# tool
BAT_VERSION="0.24.0"
DELTA_VERSION="0.18.2"
FD_VERSION="8.7.0"
NEOVIM_VERSION="0.9.5"
NODE_VERSION="18.16.0"
RIPGREP_VERSION="13.0.0"
RYE_VERSION="0.38.0"
TMUX_VERSION="3.2"
EZA_VERSION="0.20.10"

# runtime
PYTHON_VERSION="3.9.7"
RUBY_VERSION="3.2.1"
PERL_VERSION="5.30.0"
RUST_VERSION="1.84.0"

# 引数でsetupを個別に指定できるようにする
if [ $# -ne 0 ]; then
  for arg in "$@"; do
    case $arg in
      zsh)
        setup_zsh
        ;;
      git)
        setup_git
        ;;
      tmux)
        setup_tmux
        ;;
      neovim)
        setup_neovim
        ;;
      tools)
        setup_tools
        ;;
      additional)
        setup_additional_dotfiles
        ;;
      *)
        echo "invalid argument: $arg"
        ;;
    esac
  done
  exit 0
fi

main() {
  setup_zsh
  setup_git
  setup_tmux
  setup_neovim
  setup_tools
  setup_additional_dotfiles
  echo "done"
}

setup_zsh() {
  _print_start

  ln -sf ${DOTFILES}/zsh/zshrc ${HOME}/.zshrc
  _test_exists_files ${HOME}/.zshrc

  # starship
  if [ ! -e ${ZSH_INSTALLS}/starship ]; then
    curl -sS https://starship.rs/install.sh | BIN_DIR=${ZSH_INSTALLS} FORCE=true sh
    _test_exists_files ${ZSH_INSTALLS}/starship
  fi
  mkdir -p ${HOME}/.config
  ln -sf ${DOTFILES}/zsh/starship.toml ${HOME}/.config/starship.toml
  _test_exists_files ${HOME}/.config/starship.toml

  if [ ! -e $ZSH_INSTALLS/fzf.zsh ]; then
    (
      cd $ZSH_INSTALLS
      git clone https://github.com/junegunn/fzf.git ./fzf
      ./fzf/install --no-fish --no-bash --all
      mv ${HOME}/.fzf.zsh $ZSH_INSTALLS/fzf.zsh
      _test_exists_files $ZSH_INSTALLS/fzf.zsh
    )
  fi
  if [ ! -e $ZSH_INSTALLS/zsh-autosuggestions.zsh ]; then
    (
      cd $ZSH_INSTALLS
      git clone https://github.com/zsh-users/zsh-autosuggestions ./zsh-autosuggestions
      mv ./zsh-autosuggestions/zsh-autosuggestions.zsh $ZSH_INSTALLS/zsh-autosuggestions.zsh
      _test_exists_files $ZSH_INSTALLS/zsh-autosuggestions.zsh
    )
  fi
  if [ ! -e $ZSH_INSTALLS/fzf-tab ]; then
    (
      cd $ZSH_INSTALLS
      git clone https://github.com/Aloxaf/fzf-tab
      _test_exists_files $ZSH_INSTALLS/fzf-tab/fzf-tab.plugin.zsh
    )
  fi

  _install_mise

  if [ ! -e $ZSH_INSTALLS/mise.sh ]; then
    mise completion zsh > $ZSH_INSTALLS/mise.zsh
  fi

  echo 'Please exec "source ${HOME}/.zshrc"'

  _print_complete
}

setup_git() {
  _print_start

  ln -sf ${DOTFILES}/git/gitconfig ${HOME}/.gitconfig
  _test_exists_files ${HOME}/.gitconfig

  _print_complete
}

setup_tmux() {
  _print_start

  # mac
  if [ "$(uname)" = 'Darwin' ]; then
    ln -sf ${DOTFILES}/tmux/tmux.local.conf ${HOME}/.tmux.conf
  else
    ln -sf ${DOTFILES}/tmux/tmux.server.conf ${HOME}/.tmux.conf
  fi

  _print_complete
}

setup_neovim() {
  _print_start

  _install_mise

  installs=(
    "neovim@${NEOVIM_VERSION}@CMD:nvim"
    "nodejs@${NODE_VERSION}@CMD:node"
    "ripgrep@${RIPGREP_VERSION}@CMD:rg"
    "rust@${RUST_VERSION}@CMD:rustup"
  )
  # "perl ${PERL_VERSION}" # cpan Neovim::Ext
  # "ruby ${RUBY_VERSION}" # gem install neovim
  # "python ${PYTHON_VERSION}"
  # "rust ${RUST_VERSION}" #source "$HOME/.local/share/shims/rust/1.76.0/env" && rustup component add rust-src rust-analyzer
  # cargo install \
  # erdtree \ # eza よりもはやい erd --level 1 --suppress-size --long --icons
  # dua-cli \ # dua -i . でディスク使用量を表示

  _mise_install $installs || fail 'mise install failed'

  mise use nodejs@${NODE_VERSION} # coc.nvim で使う
  npm install -g neovim zx yarn@1 # yarn = cocで使用

  _install_pip
  pip install pynvim # neovim パッケージは古いので、pynvimを使う

  cp ${DOTFILES}/neovim/lua/env.lua.sample ${DOTFILES}/neovim/lua/env.lua

  rm -rf ${HOME}/.config/nvim && mkdir -p ${HOME}/.config/nvim
  ln -sf ${DOTFILES}/neovim/init.lua ${HOME}/.config/nvim/init.lua
  ln -sf ${DOTFILES}/neovim/lua ${HOME}/.config/nvim/lua
  ln -sf ${DOTFILES}/neovim/coc-settings.json ${HOME}/.config/nvim/coc-settings.json
  ln -sf ${DOTFILES}/neovim/lazy-lock.json ${HOME}/.config/nvim/lazy-lock.json
  ln -sf ${DOTFILES}/neovim/.editorconfig ${HOME}/.editorconfig
  _test_exists_files \
    ${HOME}/.config/nvim/init.lua \
    ${HOME}/.config/nvim/lua \
    ${HOME}/.config/nvim/coc-settings.json \
    ${HOME}/.config/nvim/lazy-lock.json \
    ${HOME}/.editorconfig

  _print_complete
}

setup_tools() {
  _print_start
  (
    _install_mise

    installs=(
      "eza@${EZA_VERSION}@CMD:eza"
      "bat@${BAT_VERSION}@CMD:bat"
      "delta@${DELTA_VERSION}@CMD:delta"
      "fd@${FD_VERSION}@CMD:fd"
      "nodejs@${NODE_VERSION}@CMD:node"
      "ripgrep@${RIPGREP_VERSION}@CMD:rg"
      "rye@${RYE_VERSION}@CMD:rye"
      # "tmux@${TMUX_VERSION}@CMD:tmux,IF_NOT_EXISTS_COMMAND:tmux" alcolなどでtmuxが使われているので、tmuxはインストールしない
    )
    _mise_install $installs || fail 'install failed'

    _install_pip
    pip install trash-cli
    _test_exists_commands trash-put trash-empty trash-list trash-put trash-restore trash-rm
  )
  _print_complete
}

setup_additional_dotfiles() {
  _print_start
  (
    if [ ! -e ${ADDITIONAL_DOTFILES} ]; then
      git clone ${ADDITIONAL_REPO_URL} ${ADDITIONAL_DOTFILES}
      cd ${ADDITIONAL_DOTFILES}
      git checkout ${ADDITIONAL_REPO_BRANCH}
    fi
    cd ${ADDITIONAL_DOTFILES}
    git pull
    ./install.sh
  )
  _print_complete
}

_mise_install() {
  # 引数を配列に変換
  for item in "$@"; do
    IFS='@' read -r name version opts<<<"$item"
    echo "installing $name $version >>>>>>"
    repo_url=''
    cmd=''
    if_not_exists_command=''
    if [[ -n $opts ]]; then
      option_list=()
      while [[ $opts ]]; do
        IFS=',' read -r opt rest <<< "$opts"
        option_list+=("$opt")
        opts=$rest
      done
      should_continue=false
      for opt in "${option_list[@]}"; do
        IFS=':'
        read -r option_key option_value <<<"$opt"
        case $option_key in
          CMD)
            cmd=$option_value
            ;;
          REPO_URL) # 使っていない @REPO_URLで指定できる
            repo_url=$option_value
            ;;
          IF_NOT_EXISTS_COMMAND)
            if type $option_value >/dev/null 2>&1; then
              echo "$option_value is already installed"
              should_continue=true
              break
            fi
            ;;
        esac
        IFS=','
      done
      IFS='@'
      [[ $should_continue == true ]] && continue
    fi
    mise use --global $name@$version --yes
    _test_exists_commands $cmd
    echo "installed $name $version\n"
  done
}

_install_mise() {
  if [ ! -e ${HOME}/.local/bin/mise ]; then
    curl https://mise.run | sh
  else
    echo 'mise is already installed'
  fi

  # mise にパスを通す等
  eval "$(${HOME}/.local/bin/mise activate zsh)"
  # 一時的に追加
  export PATH="${HOME}/.local/share/mise/shims:$PATH"
  # 補完のために必要
  mise use -g usage
  # 一時的に追加
  _test_exists_files ${HOME}/.local/bin/mise
}

_install_pip() {
  if type pip >/dev/null 2>&1; then
    echo 'pip is already installed'
    return
  fi

  _install_mise
  installs=(
    "rye@${RYE_VERSION}@CMD:rye"
  )
  _mise_install $installs || fail 'install failed'
  # pip
  rye config --set-bool behavior.global-python=true && rye config --set-bool behavior.use-uv=true
  rye install pip || true
  # 一時的に追加
  export PATH="$HOME/.rye/tools/pip/bin:$PATH"
  _test_exists_commands pip
}

_test_exists_files() {
  for file in "$@"; do
    # -s で中身があるかどうかも確認している
    [[ -s $file ]] || fail "$file file is not found"
  done
}

_test_exists_commands() {
  for command in "$@"; do
    type $command >/dev/null 2>&1 || fail "$command command is not found"
  done
}

_print_start() {
  printf "\e[30;44;1mstart\e[m ${funcstack[2]}\n"
}

_print_complete() {
  printf "\e[30;42;1mcompleted\e[m ${funcstack[2]} \n\n"
}

fail() {
  if [ $? -ne 0 ]; then
    printf "\e[30;41;1mfailed\e[m $1 $* \n\n"
    exit 1
  fi
}

# bash -c "$(curl -fsSL https://raw.githubusercontent.com/aaamoon/copilot-gpt4-service/master/shells/get_copilot_token.sh)"
#
# install_github_copilot_cli() {
#   if [ ! -e ${DOTFILES}/installs/gh ]; then
#     (
#       cd ${DOTFILES}/installs
#       git clone --depth=1 https://github.com/cli/cli.git gh-cli
#       cd gh-cli
#       make
#       make install prefix=${DOTFILES}/installs/gh-temp
#       cd ..
#       mv gh-temp/bin/gh .
#       rm -rf gh-temp gh-cli
#     )
#     ${DOTFILES}/installs/gh auth login
#     ${DOTFILES}/installs/gh extension install github/gh-copilot
#     alias sg="gh copilot suggest -t shell"
#   fi
# }

# install_chat() {
#   if [ ! -e ${DOTFILES}/installs/copilot-gpt4-service ]; then
#     (
#       cd ${DOTFILES}/installs
#       git clone https://github.com/aaamoon/copilot-gpt4-service
#       cd copilot-gpt4-service
#       docker-compose build
#       #bash -c "$(curl -fsSL https://raw.githubusercontent.com/aaamoon/copilot-gpt4-service/master/shells/get_copilot_token.sh)"
#       echo "write TOKEN, docker-compose up -d"
#     )
#   fi
# }

# install_delta() {
#   url=''
#   if [ "$(uname)" == 'Darwin' ]; then
#     url='https://github.com/dandavison/delta/releases/download/0.16.5/delta-0.16.5-x86_64-apple-darwin.tar.gz'
#   else
#     url='https://github.com/dandavison/delta/releases/download/0.16.5/delta-0.16.5-x86_64-unknown-linux-gnu.tar.gz'
#   fi
#   install_binary_from_tar_gz $url delta
# }
#
# install_rg() {
#   url=''
#   if [ "$(uname)" == 'Darwin' ]; then
#     url='https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-apple-darwin.tar.gz'
#     install_binary_from_tar_gz $url rg
#   else
#     (
#       url='https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz'
#       TMPDIR=$(mktemp -d)
#       cd $TMPDIR
#       curl -L -o - $url | tar zxf - --strip-component=1
#       mv rg ${DOTFILES}/installs/
#     )
#   fi
# }

# install_fd() {
#   url=''
#   if [ "$(uname)" == 'Darwin' ]; then
#     url='https://github.com/sharkdp/fd/releases/download/v8.7.0/fd-v8.7.0-x86_64-apple-darwin.tar.gz'
#   else
#     url=https://github.com/sharkdp/fd/releases/download/v8.7.0/fd-v8.7.0-x86_64-unknown-linux-gnu.tar.gz
#   fi
#   install_binary_from_tar_gz $url fd
# }
#
# install_binary_from_tar_gz() {
#   url=$1
#   name=$2
#   # delete tmp-${name}.tar.gz ${DOTFILES}/${name}-bin
#   if [ -e tmp-${name}.tar.gz ]; then
#     rm -rf tmp-${name}.tar.gz ${DOTFILES}/${name}-bin
#   fi
#   if [ -e ${DOTFILES}/${name}-bin ]; then
#     rm -rf ${DOTFILES}/${name}-bin
#   fi
#   if [ ! -e ${DOTFILES}/installs/${name} ]; then
#     mkdir -p ${DOTFILES}/${name}-bin
#     curl -L -o tmp-${name}.tar.gz $url
#     tar xzf tmp-${name}.tar.gz --directory=${DOTFILES}/${name}-bin
#     # ディレクトリ名が変わるので、ディレクトリ名を取得して移動する
#     find ${DOTFILES}/${name}-bin -maxdepth 1 -mindepth 1 -type d | xargs -I{} mv {}/${name} ${DOTFILES}/installs
#     rm -rf tmp-${name}.tar.gz ${DOTFILES}/${name}-bin
#   else # すでにインストール済みの場合
#     echo ${name} 'is already installed'
#   fi
# }

main

exit 0
