#!/usr/bin/env bash
# 対象ファイルの設計コンテキストを 1 回の bash call で集約する。
# git log / git diff / 兄弟ファイル列挙 / 行数カウント をまとめて出力。
#
# Usage: gather_context.sh <absolute_target_path> [base_branch]
#   base_branch 省略時は現在のブランチの派生元を自動検出する
#   (upstream → 親ブランチ推定 → origin/HEAD → main/master/develop の順)
#
# 出力は markdown 風セクション。agent がそのまま読んで設計判断に使う。

set -euo pipefail

target="${1:-}"
base="${2:-}"
if [[ -z "$target" ]]; then
  echo "usage: $(basename "$0") <absolute_target_path> [base_branch]" >&2
  exit 2
fi
if [[ ! -f "$target" ]]; then
  echo "target not found: $target" >&2
  exit 1
fi

cd "$(git -C "$(dirname "$target")" rev-parse --show-toplevel 2>/dev/null || dirname "$target")"
rel="$(realpath --relative-to="$PWD" "$target" 2>/dev/null || python3 -c "import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))" "$target" "$PWD")"

current="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

# base 未指定なら現在ブランチの派生元を推定する
detect_base() {
  # 1. 追跡先 upstream (例: origin/feature-x)
  local upstream
  upstream="$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || true)"
  if [[ -n "$upstream" && "$upstream" != "$current" ]]; then
    echo "$upstream"; return
  fi
  # 2. show-branch から親ブランチを推定 (現在ブランチ自身は除外)
  local parent
  parent="$(git show-branch -a 2>/dev/null \
    | grep '\*' \
    | grep -v " $current\$" \
    | head -1 \
    | sed -E 's/.*\[([^]~^]+).*/\1/' || true)"
  if [[ -n "$parent" && "$parent" != "$current" ]]; then
    echo "$parent"; return
  fi
  # 3. リモートのデフォルトブランチ (origin/HEAD)
  local origin_head
  origin_head="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [[ -n "$origin_head" && "$origin_head" != "$current" ]]; then
    echo "$origin_head"; return
  fi
  # 4. 慣習的なベースブランチを存在順に
  local cand
  for cand in main master develop; do
    if [[ "$cand" != "$current" ]] && git rev-parse --verify --quiet "$cand" >/dev/null; then
      echo "$cand"; return
    fi
  done
}

if [[ -z "$base" ]]; then
  base="$(detect_base)"
fi

echo "## target"
echo "- path: $target"
echo "- lines: $(wc -l < "$target" | tr -d ' ')"
echo

echo "## recent commits touching this file"
git log --oneline -10 -- "$rel" 2>/dev/null | head -10 || echo "(no git history)"
echo

if [[ -z "$base" ]]; then
  echo "## diff vs base (stat)"
  echo "(派生元ブランチを特定できず: current=$current のみ)"
else
  echo "## diff vs $base (派生元, stat)"
  diff_out="$(git diff --stat "$base"...HEAD -- "$rel" 2>/dev/null | head -10 || true)"
  echo "${diff_out:-(no diff)}"
fi
echo

echo "## sibling files (same directory)"
ls "$(dirname "$target")" 2>/dev/null | grep -v '__pycache__' | head -15
echo

echo "## suggested base candidates (same suffix, e.g. *_management_view.py)"
target_name="$(basename "$target")"
# 末尾 2 トークン (_x_y.py) を抽出して同 suffix のファイルを並べる
suffix="$(echo "$target_name" | grep -oE '_[a-z]+_[a-z]+\.py$' || true)"
if [[ -n "$suffix" ]]; then
  ls "$(dirname "$target")" 2>/dev/null \
    | grep -E "${suffix}\$" \
    | grep -v "^${target_name}\$" \
    | head -5 || true
fi
exit 0
