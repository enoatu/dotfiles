#!/usr/bin/env zsh

DOTFILES="${DOTFILES:-${HOME}/dotfiles}"
ZSH_INSTALLS=${DOTFILES}/zsh/installs
ADDITIONAL_DOTFILES=${ADDITIONAL_DOTFILES:-"${DOTFILES}/private-dotfiles"}
ADDITIONAL_REPO_BRANCH=${ADDITIONAL_REPO_BRANCH:-"main"}
ADDITIONAL_REPO_GITHUB_TOKEN=${ADDITIONAL_REPO_GITHUB_TOKEN:-""}
ADDITIONAL_REPO_URL=${ADDITIONAL_REPO_URL:-"https://${ADDITIONAL_REPO_GITHUB_TOKEN}@github.com/enoatu/private-dotfiles.git"}

# tool
BAT_VERSION="0.24.0"
DELTA_VERSION="0.18.2"
FD_VERSION="8.7.0"
NEOVIM_VERSION="0.11.6"
NODE_VERSION="23.10.0"
NODE_VERSION_FOR_COC="18.16.0"
RIPGREP_VERSION="13.0.0"
RYE_VERSION="0.38.0"
ZELLIJ="0.43.1"
EZA_VERSION="0.20.10"
BUN_VERSION="1.1.8"

# runtime
GCLOUD_VERSION="latest"
GO_VERSION="latest"
PYTHON_VERSION="3.12.2"
RUBY_VERSION="3.2.1"
PERL_VERSION="5.30.0"
RUST_VERSION="1.84.0"

_print_start() {
  printf "\e[30;44;1mstart\e[m ${funcstack[2]}\n"
}

_print_complete() {
  printf "\e[30;42;1mcompleted\e[m ${funcstack[2]} \n\n"
}

fail() {
  printf "\e[30;41;1mfailed\e[m $* \n\n"
  exit 1
}

_test_exists_files() {
  for file in "$@"; do
    # -e でファイルの存在を確認（シンボリックリンクも含む）
    [[ -e $file ]] || fail "$file file is not found"
  done
}

_test_exists_commands() {
  for command in "$@"; do
    type $command >/dev/null 2>&1 || fail "$command command is not found"
  done
}

_install_mise() {
  if [ ! -e ${HOME}/.local/bin/mise ]; then
    curl https://mise.run | sh
  else
    mise self-update
    echo 'mise is already installed and updated'
  fi
}

_install_pip() {
  (
    _install_mise

    installs=(
      "python@${PYTHON_VERSION}@CMD:python"
      "rye@${RYE_VERSION}@CMD:rye"
    )
    _mise_install $installs || fail 'install failed'
    # pip
    rye config --set-bool behavior.global-python=true && rye config --set-bool behavior.use-uv=true
    rye install pip || true
    # 一時的に追加
    export PATH="$HOME/.rye/tools/pip/bin:$PATH"
    _test_exists_commands pip
  )
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
      done
      if [[ $should_continue == true ]]; then
        continue
      fi
    fi
    mise install ${name}@${version} || fail "install ${name}@${version} failed"
    mise use -g ${name}@${version}
    # 実行ファイルの確認
    if [[ -n $cmd ]]; then
      _test_exists_commands $cmd
    fi
  done
}

# セットアップ関数の定義
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

  (
    cd $DOTFILES/neovim
    mise use nodejs@${NODE_VERSION_FOR_COC} # coc.nvim で使う
    npm install -g neovim yarn@1 # yarn = cocで使用
  )

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
      "go@${GO_VERSION}@CMD:go"
      "gcloud@${GCLOUD_VERSION}@CMD:gcloud"
      "eza@${EZA_VERSION}@CMD:eza"
      "bat@${BAT_VERSION}@CMD:bat"
      "delta@${DELTA_VERSION}@CMD:delta"
      "fd@${FD_VERSION}@CMD:fd"
      "nodejs@${NODE_VERSION}@CMD:node"
      "ripgrep@${RIPGREP_VERSION}@CMD:rg"
      "rye@${RYE_VERSION}@CMD:rye"
      "bun@${BUN_VERSION}@CMD:bun"
      "zellij@${ZELLIJ}@CMD:zellij"
      # "tmux@${TMUX_VERSION}@CMD:tmux,IF_NOT_EXISTS_COMMAND:tmux" alcolなどでtmuxが使われているので、tmuxはインストールしない
    )
    _mise_install $installs || fail 'install failed'

    _install_pip
    pip install trash-cli
    _test_exists_commands trash-put trash-empty trash-list trash-put trash-restore trash-rm

    # claude設定ファイルのリンク作成
    if [ -f ${DOTFILES}/tools/claude/settings.json ]; then
      mkdir -p ${HOME}/.claude
      ln -sf ${DOTFILES}/tools/claude/settings.json ${HOME}/.claude/settings.json
    fi

    npm install -g zx
    _test_exists_commands zx
  )
  _print_complete
}

setup_additional_dotfiles() {
  _print_start
  (
    if [ ! -e ${ADDITIONAL_DOTFILES} ]; then
      git clone ${ADDITIONAL_REPO_URL} ${ADDITIONAL_DOTFILES} || fail "Failed to clone additional dotfiles repository"
      cd ${ADDITIONAL_DOTFILES}
      git checkout ${ADDITIONAL_REPO_BRANCH}
    fi
    cd ${ADDITIONAL_DOTFILES}
    git pull
    ./install.sh
  )
  _print_complete
}

main() {
  setup_zsh
  setup_git
  setup_tmux
  setup_neovim
  setup_tools
  setup_ai_clients
  setup_additional_dotfiles
  echo "done"
}

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

# 引数がない場合はmain関数を実行
main
