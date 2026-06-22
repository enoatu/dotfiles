#!/usr/bin/env bash
# 対象ファイルを開いている nvim socket を 1 つ標準出力に返す。
#
# Usage: find_socket.sh <absolute_target_path>
# Exit: 0 = 見つかった (socket を stdout に出力) / 1 = 見つからず / 2 = 引数不正
#
# 優先順位:
#   1. 対象ファイルが current buffer かつ 同 tmux window の socket
#   2. 対象ファイルが current buffer の socket（window 不問）
#   3. 対象ファイルがロード済み buffer の socket（window 不問）
#   4. なし → 終了コード 1
#
# 同 tmux window は「同じ作業文脈」のヒントとして使うのみで、ハード条件にはしない。
# 1 ペインで nvim を切り替えながら使うケースなど、PID マッチが外れる構成があるため。

set -euo pipefail

target_abs="${1:-}"
if [[ -z "$target_abs" ]]; then
  echo "usage: $(basename "$0") <absolute_target_path>" >&2
  exit 2
fi

# 同 tmux window のペイン PID を集める（advisory）
pane_pids=""
if command -v tmux >/dev/null 2>&1 && tmux display-message -p '' >/dev/null 2>&1; then
  session="$(tmux display-message -p '#{session_name}')"
  window="$(tmux display-message -p '#{window_index}')"
  pane_pids="$(tmux list-panes -t "$session:$window" \
    -F '#{pane_pid} #{pane_current_command}' \
    | awk '$2 ~ /nvim/ {print $1}' | tr '\n' ' ')"
fi

# socket 列挙 (mac / Linux 両対応)
candidates=()
for root in "${TMPDIR:-/tmp}" /tmp /run/user /private/var/folders; do
  [[ -d "$root" ]] || continue
  while IFS= read -r s; do
    candidates+=("$s")
  done < <(find "$root" -maxdepth 5 -name 'nvim*' -type s 2>/dev/null)
done

if [[ ${#candidates[@]} -eq 0 ]]; then
  exit 1
fi

is_same_window() {
  local sock="$1"
  [[ -z "$pane_pids" ]] && return 1
  local sock_pid
  sock_pid="$(basename "$sock" | sed -E 's/nvim\.([0-9]+)\..*/\1/')"
  for pid in $pane_pids; do
    [[ "$pid" == "$sock_pid" ]] && return 0
  done
  return 1
}

best_window_current=""
best_current=""
best_loaded=""

for sock in "${candidates[@]}"; do
  # nvim の --remote-expr は版によって結果を stderr に出す (v0.7.x 等) ため
  # 2>&1 で取り込む。接続失敗時はエラー文字列が入るが target と一致しないので無害
  info="$(nvim --server "$sock" --remote-expr \
    'json_encode({"current": expand("%:p"), "bufs": map(getbufinfo({"buflisted":1}), "v:val.name")})' \
    2>&1 || true)"
  [[ -z "$info" ]] && continue

  # JSON のスペース有無に依存しないよう、current の値だけ抜き取って文字列比較
  cur="$(printf '%s' "$info" | sed -n 's/.*"current":[[:space:]]*"\([^"]*\)".*/\1/p')"
  if [[ "$cur" == "$target_abs" ]]; then
    if is_same_window "$sock"; then
      best_window_current="$sock"
      break
    fi
    [[ -z "$best_current" ]] && best_current="$sock"
    continue
  fi

  if [[ -z "$best_loaded" && "$info" == *"$target_abs"* ]]; then
    best_loaded="$sock"
  fi
done

if [[ -n "$best_window_current" ]]; then
  echo "$best_window_current"
  exit 0
fi
if [[ -n "$best_current" ]]; then
  echo "$best_current"
  exit 0
fi
if [[ -n "$best_loaded" ]]; then
  echo "$best_loaded"
  exit 0
fi
exit 1
