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

# execute() で luafile を同期実行する。--remote-send はモード/タイミング依存で
# 不発になることがあるため使わない。成功時は空文字、失敗時はエラー文字列が返る。
# nvim の --remote-expr は版によって結果を stderr に出すため 2>&1 で取り込む
err="$(nvim --server "$sock" --remote-expr "execute('luafile $lua_file')" 2>&1 || true)"
if [[ -n "$err" ]]; then
  echo "luafile error: $err" >&2
  exit 1
fi

count="$(nvim --server "$sock" --remote-expr \
  "luaeval('#vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace(\"nvim_annotate\"), 0, -1, {})')" \
  2>&1 || echo 0)"

count="${count//[^0-9]/}"
echo "${count:-0}"
[[ "${count:-0}" -gt 0 ]]
