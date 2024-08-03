#!/usr/bin/env zsh

set -ue

DOTFILES="${HOME}/dotfiles"
ADDITIONAL_DOTFILES=${ADDITIONAL_DOTFILES:-"${DOTFILES}/private-dotfiles"}
ADDITIONAL_REPO_BRANCH=${ADDITIONAL_REPO_BRANCH:-"main"}
ADDITIONAL_REPO_GITHUB_TOKEN=${ADDITIONAL_REPO_GITHUB_TOKEN:-""}
ADDITIONAL_REPO_URL=${ADDITIONAL_REPO_URL:-"https://${ADDITIONAL_REPO_GITHUB_TOKEN}@github.com/enoatu/private-dotfiles.git"}

# asdf
ASDF_VERSION="12.0.0"

# tool
BAT_VERSION="0.18.3"
DELTA_VERSION="0.16.5"
FD_VERSION="8.7.0"
NEOVIM_VERSION="0.9.5"
NODE_VERSION="18.16.0"
RIPGREP_VERSION="13.0.0"
RYE_VERSION="0.38.0"
TMUX_VERSION="3.2"

# runtime
PYTHON_VERSION="3.9.7"
RUBY_VERSION="3.2.1"
PERL_VERSION="5.30.0"
RUST_VERSION="1.55.0"

# -- もし実行ユーザーとdotfilesの所有者が異なる場合は権限を変更する linux docker 用
# if [ "$(whoami)" != "$(stat -c %U ${DOTFILES})" ]; then
#   sudo chown -R $(whoami) ${DOTFILES}
# fi
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
  echo 'Please exec "source ~${HOME}/.zshrc"'

  _print_complete
}

setup_git() {
  _print_start

  ln -sf ${DOTFILES}/git/gitconfig ${HOME}/.gitconfig
  ln -sf ${DOTFILES}/git/gitignore ${HOME}/.gitignore_global

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

  _install_asdf

  installs=(
    neovim@${NEOVIM_VERSION}
    nodejs@${NODE_VERSION}
    ripgrep@${RIPGREP_VERSION}
    rye@${RYE_VERSION}
  )
  # "perl ${PERL_VERSION}" # cpan Neovim::Ext
  # "ruby ${RUBY_VERSION}" # gem install neovim
  # "python ${PYTHON_VERSION}"
  # "rust ${RUST_VERSION}" #source "/Users/enotiru/.asdf/installs/rust/1.76.0/env" && rustup component add rust-src rust-analyzer
  _asdf_install $installs || _or_fail 'asdf install failed'

  if [ -e ${HOME}/.config/nvim ]; then
    rm -rf ${HOME}/.config/nvim
  fi
  mkdir -p ${HOME}/.config/nvim

  # ~/.asdf/.tool_versions (ローカルでないことに注意) に golang 1.21 など記載することでプラグインエラーを回避できる
  asdf local nodejs ${NODE_VERSION} # coc.nvim で使う
  npm install -g neovim zx yarn@1 # yarn = cocで使用

  # python
  rye config --set-bool behavior.global-python=true &&
  rye config --set-bool behavior.use-uv=true
  rye install pip | true
  ~/.rye/shims/pip install pynvim # neovim パッケージは古いので、pynvimを使う

  # for nvim
  ln -sf ${DOTFILES}/neovim/init.lua ${HOME}/.config/nvim/init.lua
  ln -sf ${DOTFILES}/neovim/lua ${HOME}/.config/nvim/lua
  ln -sf ${DOTFILES}/neovim/coc-settings.json ${HOME}/.config/nvim/coc-settings.json
  ln -sf ${DOTFILES}/neovim/lazy-lock.json ${HOME}/.config/nvim/lazy-lock.json
  ln -sf ${DOTFILES}/neovim/.editorconfig ${HOME}/.editorconfig
  cp ${DOTFILES}/neovim/lua/env.lua.sample ${DOTFILES}/neovim/lua/env.lua

  _print_complete
}

setup_tools() {
  _print_start
  (
    _install_asdf

    installs=(
      bat@${BAT_VERSION}
      delta@${DELTA_VERSION}@REPO_URL=https://github.com/pedropombeiro/asdf-delta.git
      fd@${FD_VERSION}
      nodejs@${NODE_VERSION}
      ripgrep@${RIPGREP_VERSION}
      rye@${RYE_VERSION}
      tmux@${TMUX_VERSION}@IF_NOT_EXISTS_COMMAND=tmux
    )
    _asdf_install $installs || _or_fail 'install failed'
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

_asdf_install() {
  # 引数を配列に変換
  for item in "$@"; do
    IFS='@' read -r name version option<<<"$item"
    echo "installing $name $version >>>>>>"
    REPO_URL=''
    if [ -n "$option" ]; then
      IFS='=' read -r option_key option_value<<<"$option"
      case $option_key in
        IF_NOT_EXISTS_COMMAND)
          if_not_exists_command=$option_value
          if [[ -n $(which $if_not_exists_command) ]]; then
            echo "$if_not_exists_command is already installed"
            continue
          fi
          ;;
        REPO_URL)
          REPO_URL=$option_value
          ;;
      esac
    fi
    asdf plugin add $name $REPO_URL
    asdf install $name $version
    asdf global $name $version
    echo "installed $name $version\n"
  done
}

_install_asdf() {
  if [ ! -e ${HOME}/.asdf ]; then
    git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf --branch v${ASDF_VERSION}
  else
    echo 'asdf is already installed'
  fi
  . ${HOME}/.asdf/asdf.sh
}

_print_start() {
  printf "\e[30;44;1mstart\e[m ${funcstack[2]}\n"
}

_print_complete() {
  printf "\e[30;42;1mcompleted\e[m ${funcstack[2]} \n\n"
}

_or_fail() {
  if [ $? -ne 0 ]; then
    printf "\e[30;41;1madditional_dotfiles failed\e[m $1 $* \n\n"
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
