#!/usr/bin/env zsh

DOTFILES="${DOTFILES:-${HOME}/dotfiles}"
ADDITIONAL_DOTFILES="${ADDITIONAL_DOTFILES:-${DOTFILES}/private-dotfiles}"
ADDITIONAL_REPO_BRANCH="${ADDITIONAL_REPO_BRANCH:-main}"
# light はシェルと neovim だけ入れる軽量版
INSTALL_TYPE="${INSTALL_TYPE:-full}"

# mise を入れて有効化する
[ -e "${HOME}/.local/bin/mise" ] || curl https://mise.run | sh
eval "$(${HOME}/.local/bin/mise activate)"

# 公開設定を conf.d に置いてツールとタスクと symlink を反映する
mkdir -p "${HOME}/.config/mise/conf.d"
ln -sf "${DOTFILES}/mise/dotfiles.toml" "${HOME}/.config/mise/conf.d/00_public.toml"
ln -sf "${DOTFILES}/mise/tools.toml"    "${HOME}/.config/mise/conf.d/02_tools.toml"
ln -sf "${DOTFILES}/mise/tasks.toml"    "${HOME}/.config/mise/conf.d/03_tasks.toml"
if [ "$INSTALL_TYPE" = "full" ]; then
  ln -sf "${DOTFILES}/mise/tools-full.toml" "${HOME}/.config/mise/conf.d/05_tools_full.toml"
fi

mise plugins add neovim https://github.com/richin13/asdf-neovim.git 2>/dev/null || true
mise install
if [ "$INSTALL_TYPE" = "full" ]; then
  mise run setup
else
  mise run setup-zsh
fi
mise dotfiles apply --force --yes

# private-dotfiles は token を貼り付けた時だけ取得と更新をする
# token は .git/config に残さない
read -s "ADDITIONAL_REPO_GITHUB_TOKEN?private-dotfiles の GitHub の token を貼り付ける(空なら取得と更新をしない): "
echo
if [ -n "$ADDITIONAL_REPO_GITHUB_TOKEN" ]; then
  # private-dotfiles は dotfiles と同じ GitHub アカウントに置く
  DOTFILES_REPO_URL=$(git -C "${DOTFILES}" remote get-url origin)
  GITHUB_ACCOUNT="${${DOTFILES_REPO_URL%/*}##*[/:]}"
  ADDITIONAL_REPO_URL="https://github.com/${GITHUB_ACCOUNT}/private-dotfiles.git"
  GITHUB_AUTH_HEADER="Authorization: Basic $(printf 'x-access-token:%s' "$ADDITIONAL_REPO_GITHUB_TOKEN" | base64 | tr -d '\n')"
  if [ -e "${ADDITIONAL_DOTFILES}" ]; then
    git -C "${ADDITIONAL_DOTFILES}" -c http.extraHeader="${GITHUB_AUTH_HEADER}" pull origin "${ADDITIONAL_REPO_BRANCH}"
  elif [ "$INSTALL_TYPE" = "full" ]; then
    git -c http.extraHeader="${GITHUB_AUTH_HEADER}" clone -b "${ADDITIONAL_REPO_BRANCH}" "${ADDITIONAL_REPO_URL}" "${ADDITIONAL_DOTFILES}"
  else
    # 軽量版は他の人も見られるサーバーに入れるので、自分だけのもの(claude/)は中身をダウンロードしない
    git -c http.extraHeader="${GITHUB_AUTH_HEADER}" clone --filter=blob:none --sparse -b "${ADDITIONAL_REPO_BRANCH}" "${ADDITIONAL_REPO_URL}" "${ADDITIONAL_DOTFILES}" \
      && git -C "${ADDITIONAL_DOTFILES}" -c http.extraHeader="${GITHUB_AUTH_HEADER}" sparse-checkout set --no-cone '/*' '!/claude/'
  fi
fi
if [ -e "${ADDITIONAL_DOTFILES}/mise/dotfiles.toml" ]; then
  ln -sf "${ADDITIONAL_DOTFILES}/mise/tasks.toml"    "${HOME}/.config/mise/conf.d/04_private_tasks.toml"
  if [ "$INSTALL_TYPE" = "full" ]; then
    # 軽量版は claude/ がなくリンクの作り元がそろわないので、通常版だけリンクする
    ln -sf "${ADDITIONAL_DOTFILES}/mise/dotfiles.toml" "${HOME}/.config/mise/conf.d/01_private.toml"
    mise run setup-private
  else
    mise run setup-zshrc-local
  fi
  mise dotfiles apply --force --yes
fi

if command -v crit >/dev/null 2>&1; then
  crit install claude-code
fi

echo done
