#!/usr/bin/env zsh
set -eu

DOTFILES="${DOTFILES:-${HOME}/dotfiles}"
ADDITIONAL_DOTFILES="${ADDITIONAL_DOTFILES:-${DOTFILES}/private-dotfiles}"
ADDITIONAL_REPO_BRANCH="${ADDITIONAL_REPO_BRANCH:-main}"
ADDITIONAL_REPO_GITHUB_TOKEN="${ADDITIONAL_REPO_GITHUB_TOKEN:-}"
ADDITIONAL_REPO_URL="${ADDITIONAL_REPO_URL:-https://${ADDITIONAL_REPO_GITHUB_TOKEN}@github.com/enoatu/private-dotfiles.git}"

# mise を入れて有効化する
[ -e "${HOME}/.local/bin/mise" ] || curl https://mise.run | sh
eval "$(${HOME}/.local/bin/mise activate)"

# private-dotfiles を取得する
if [ ! -e "${ADDITIONAL_DOTFILES}" ]; then
  git clone "${ADDITIONAL_REPO_URL}" "${ADDITIONAL_DOTFILES}"
  git -C "${ADDITIONAL_DOTFILES}" checkout "${ADDITIONAL_REPO_BRANCH}"
fi
git -C "${ADDITIONAL_DOTFILES}" pull

# mise の設定を conf.d に置く
mkdir -p "${HOME}/.config/mise/conf.d"
ln -sf "${DOTFILES}/mise/dotfiles.toml"            "${HOME}/.config/mise/conf.d/00_public.toml"
ln -sf "${ADDITIONAL_DOTFILES}/mise/dotfiles.toml" "${HOME}/.config/mise/conf.d/01_private.toml"
ln -sf "${DOTFILES}/mise/tools.toml"               "${HOME}/.config/mise/conf.d/02_tools.toml"
ln -sf "${DOTFILES}/mise/tasks.toml"               "${HOME}/.config/mise/conf.d/03_tasks.toml"

# neovim は asdf プラグイン経由で入れる
mise plugins add neovim https://github.com/richin13/asdf-neovim.git 2>/dev/null || true

mise install
mise run setup
mise dotfiles apply --force

# private-dotfiles 側の crontab や mcp を設定する
"${ADDITIONAL_DOTFILES}/install.sh"

echo done
