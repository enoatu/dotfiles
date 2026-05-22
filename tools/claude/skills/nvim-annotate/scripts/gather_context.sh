#!/usr/bin/env bash
# 対象ファイルの設計コンテキストを 1 回の bash call で集約する。
# git log / git diff / 兄弟ファイル列挙 / 行数カウント をまとめて出力。
#
# Usage: gather_context.sh <absolute_target_path> [base_branch]
#   base_branch のデフォルトは develop
#
# 出力は markdown 風セクション。agent がそのまま読んで設計判断に使う。

set -euo pipefail

target="${1:-}"
base="${2:-develop}"
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

echo "## target"
echo "- path: $target"
echo "- lines: $(wc -l < "$target" | tr -d ' ')"
echo

echo "## recent commits touching this file"
git log --oneline -10 -- "$rel" 2>/dev/null | head -10 || echo "(no git history)"
echo

echo "## diff vs $base (stat)"
git diff --stat "$base"...HEAD -- "$rel" 2>/dev/null | head -10 || echo "(no diff)"
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
