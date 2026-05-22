#!/usr/bin/env bash
# nvim socket に lua ファイルを :luafile で読み込ませ、注入後の extmark 件数を返す。
#
# Usage: inject.sh <socket> <lua_file>
# Exit: 0 = 成功 (件数を stdout に出力) / 1 = 注入失敗 / 2 = 引数不正

set -euo pipefail

sock="${1:-}"
lua_file="${2:-}"
if [[ -z "$sock" || -z "$lua_file" ]]; then
  echo "usage: $(basename "$0") <socket> <lua_file>" >&2
  exit 2
fi
[[ -S "$sock" ]] || { echo "socket not found: $sock" >&2; exit 1; }
[[ -f "$lua_file" ]] || { echo "lua file not found: $lua_file" >&2; exit 1; }

# 通常モードに戻して luafile 実行（挿入モード中だと :luafile が文字列化する）
nvim --server "$sock" --remote-send "<C-\\><C-N>:luafile $lua_file<CR>" >/dev/null 2>&1 || {
  echo "luafile send failed" >&2
  exit 1
}

# nvim 側で extmark 描画が走るまで待つ
sleep 0.2

count="$(nvim --server "$sock" --remote-expr \
  "luaeval('#vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace(\"nvim_annotate\"), 0, -1, {})')" \
  2>/dev/null || echo 0)"

count="${count//[^0-9]/}"
echo "${count:-0}"
[[ "${count:-0}" -gt 0 ]]
