#!/usr/bin/env zsh
set -eu

DOTFILES="${DOTFILES:-${HOME}/dotfiles}"
ADDITIONAL_DOTFILES="${ADDITIONAL_DOTFILES:-${DOTFILES}/private-dotfiles}"
ADDITIONAL_REPO_BRANCH="${ADDITIONAL_REPO_BRANCH:-main}"
ADDITIONAL_REPO_GITHUB_TOKEN="${ADDITIONAL_REPO_GITHUB_TOKEN:-}"
# private は既定では取得しない。token がある時だけ https で取得する
ADDITIONAL_REPO_URL="${ADDITIONAL_REPO_URL:-https://${ADDITIONAL_REPO_GITHUB_TOKEN}@github.com/enoatu/private-dotfiles.git}"

# mise を入れて有効化する
[ -e "${HOME}/.local/bin/mise" ] || curl https://mise.run | sh
eval "$(${HOME}/.local/bin/mise activate)"

# 公開設定を conf.d に置いてツールとタスクと symlink を反映する
mkdir -p "${HOME}/.config/mise/conf.d"
ln -sf "${DOTFILES}/mise/dotfiles.toml" "${HOME}/.config/mise/conf.d/00_public.toml"
ln -sf "${DOTFILES}/mise/tools.toml"    "${HOME}/.config/mise/conf.d/02_tools.toml"
ln -sf "${DOTFILES}/mise/tasks.toml"    "${HOME}/.config/mise/conf.d/03_tasks.toml"

mise plugins add neovim https://github.com/richin13/asdf-neovim.git 2>/dev/null || true
mise install
mise run setup
mise dotfiles apply --force

# private-dotfiles は token がある時だけ取得する。既にあれば反映する
if [ ! -e "${ADDITIONAL_DOTFILES}" ] && [ -n "$ADDITIONAL_REPO_GITHUB_TOKEN" ]; then
  git clone "${ADDITIONAL_REPO_URL}" "${ADDITIONAL_DOTFILES}" \
    && git -C "${ADDITIONAL_DOTFILES}" checkout "${ADDITIONAL_REPO_BRANCH}" \
    || echo "private-dotfiles を取得できませんでした。公開分のみ反映しました"
fi
if [ -e "${ADDITIONAL_DOTFILES}/mise/dotfiles.toml" ]; then
  git -C "${ADDITIONAL_DOTFILES}" pull || true
  ln -sf "${ADDITIONAL_DOTFILES}/mise/dotfiles.toml" "${HOME}/.config/mise/conf.d/01_private.toml"
  mise dotfiles apply --force
  "${ADDITIONAL_DOTFILES}/install.sh"
fi

echo done
