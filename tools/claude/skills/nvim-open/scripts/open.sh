#!/usr/bin/env bash
# 対象ファイルを同 tmux window の縦分割ペインで nvim で開く。
# Usage: open.sh <target> [target ...]
#   target は path もしくは path:line（line を付けるとその行へジャンプ）
# Exit: 0 = 成功 / 2 = 引数不正 or 全ファイル無し / 3 = tmux 外
#
# 同じ window では 1 つの nvim ペインを使い回す。
# 既にこの skill が開いた nvim が応答すれば各ファイルを新規タブで開き、ペインを増やさない。
# 応答しなければ縦分割で新しいペインを作り nvim を起動する。
#
# ペインでは cd してから対話 zsh を起動し、その中で nvim を実行する。
# こうすると zsh の PATH（rg や LSP、mise の nvim など）をそのまま継承でき、
# nvim 側に絶対パス等の設定を足さずに telescope の rg 等が動く。

set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "usage: $(basename "$0") <target> [target ...]   (target は path もしくは path:line)" >&2
  exit 2
fi
if [[ -z "${TMUX:-}" ]]; then
  echo "tmux の中で実行してください" >&2
  exit 3
fi

# 呼び出し元（claude code）自身のペインを基準にする。
# アクティブ window は別かもしれないので $TMUX_PANE で固定する
self_pane="${TMUX_PANE:-}"

# 引数を path と line に分け、絶対パス化して配列に積む
paths=()
lines=()
for raw in "$@"; do
  path="$raw"
  line=""
  if [[ "$raw" == *:* ]]; then
    suffix="${raw##*:}"
    if [[ "$suffix" =~ ^[0-9]+$ ]]; then
      path="${raw%:*}"
      line="$suffix"
    fi
  fi
  dir="$(dirname "$path")"
  abs="$(cd "$dir" 2>/dev/null && printf '%s/%s' "$PWD" "$(basename "$path")")"
  if [[ -z "$abs" || ! -e "$abs" ]]; then
    echo "skip (not found): $raw" >&2
    continue
  fi
  paths+=("$abs")
  lines+=("$line")
done
if [[ ${#paths[@]} -eq 0 ]]; then
  echo "開けるファイルがありません" >&2
  exit 2
fi

# mise バイナリを探す（RPC client 用 nvim の解決に使う。shell function ではなく実体が必要）
mise_bin=""
for cand in "$HOME/.local/bin/mise" /usr/local/bin/mise /usr/bin/mise; do
  [[ -x "$cand" ]] && { mise_bin="$cand"; break; }
done

# ペイン起動に使う対話シェル
user_shell="${SHELL:-/bin/zsh}"

# 各ファイルが属する git リポジトリの root を求める。
# submodule は独自の toplevel を返すので、これでグループ分けすればペインが分かれる
groups=()
for idx in "${!paths[@]}"; do
  root="$(git -C "$(dirname "${paths[$idx]}")" rev-parse --show-toplevel 2>/dev/null || true)"
  [[ -z "$root" ]] && root="_norepo_"
  groups+=("$root")
done

session="$(tmux display-message -p -t "$self_pane" '#{session_name}')"
window="$(tmux display-message -p -t "$self_pane" '#{window_index}')"
state_dir="/tmp/claude-nvim"
mkdir -p "$state_dir"
# window とリポジトリごとに socket とペイン id を決め打ちで持つ
key="$(printf '%s_%s' "$session" "$window" | tr -c 'A-Za-z0-9_.-' '_')"

server_alive() {
  [[ -S "$sock" ]] && timeout 5 "$nvim_client" --server "$sock" --remote-expr '1' >/dev/null 2>&1
}

# 起動直後は socket 生成まで数秒かかるので応答を待つ
wait_server() {
  for _ in $(seq 1 40); do
    server_alive && return 0
    sleep 0.25
  done
  return 1
}

# 既存 nvim に新規タブで開いて指定行へ飛ぶ
open_in_server() {
  local abs="$1" line="$2"
  timeout 5 "$nvim_client" --server "$sock" --remote-tab "$abs" >/dev/null 2>&1 || true
  [[ -n "$line" ]] && timeout 5 "$nvim_client" --server "$sock" --remote-expr "cursor($line, 1)" >/dev/null 2>&1 || true
}

# リポジトリ（root）ごとに 1 ペインを使い回して開く
open_group() {
  local root="$1"; shift
  local idxs=("$@")
  local first_idx="${idxs[0]}"

  # group ごとに socket とペイン id を分ける
  local gkey sock pane_file gdir label nvim_client resolved pane_id launch_cmd
  gkey="$(printf '%s' "$root" | tr -c 'A-Za-z0-9_.-' '_')"
  sock="$state_dir/${key}__${gkey}.sock"
  pane_file="$state_dir/${key}__${gkey}.pane"
  if [[ "$root" == "_norepo_" ]]; then
    # git 管理外は cd せず呼び出し元（claude）の場所のまま開く
    gdir="$(tmux display-message -p -t "$self_pane" '#{pane_current_path}')"
    label="(no repo)"
  else
    # git リポジトリ（submodule 含む）はその root に cd して開く
    gdir="$root"
    label="$(basename "$root")"
  fi

  # RPC client 用 nvim を group の場所で mise 解決する（起動した server へ接続する用）
  nvim_client="nvim"
  if [[ -n "$mise_bin" ]]; then
    resolved="$(cd "$gdir" && timeout 8 "$mise_bin" which nvim 2>/dev/null)" || resolved=""
    [[ -x "$resolved" ]] && nvim_client="$resolved"
  fi

  if server_alive; then
    local idx
    for idx in "${idxs[@]}"; do
      open_in_server "${paths[$idx]}" "${lines[$idx]}"
    done
    [[ -f "$pane_file" ]] && tmux select-pane -t "$(cat "$pane_file")" 2>/dev/null || true
    echo "reused [$label]: ${#idxs[@]} file(s)"
    return 0
  fi

  # 古い socket を掃除し、縦分割の新しいペインで先頭ファイルを開く。
  # cd してから対話 zsh を起動し、その中で nvim を exec する（PATH を継承させる）
  rm -f "$sock"
  launch_cmd="$user_shell -i -c 'cd \"$gdir\" && exec nvim --listen \"$sock\" +${lines[$first_idx]:-1} -- \"${paths[$first_idx]}\"'"
  pane_id="$(tmux split-window -h -t "$self_pane" -P -F '#{pane_id}' -c "$gdir" "$launch_cmd")"
  printf '%s' "$pane_id" > "$pane_file"

  # 残りのファイルは socket 起動を待ってからタブで開く
  if [[ "${#idxs[@]}" -gt 1 ]]; then
    if wait_server; then
      local idx
      for idx in "${idxs[@]:1}"; do
        open_in_server "${paths[$idx]}" "${lines[$idx]}"
      done
    else
      echo "warn: nvim 起動待ちタイムアウト [$label]。先頭以外は未オープン" >&2
    fi
  fi
  echo "opened [$label]: ${#idxs[@]} file(s) in pane $pane_id"
}

# root のユニーク集合ごとに、所属するファイルをまとめて開く
uniq_roots=()
for root in "${groups[@]}"; do
  found=""
  if [[ ${#uniq_roots[@]} -gt 0 ]]; then
    for seen in "${uniq_roots[@]}"; do
      [[ "$seen" == "$root" ]] && { found=1; break; }
    done
  fi
  [[ -z "$found" ]] && uniq_roots+=("$root")
done

for root in "${uniq_roots[@]}"; do
  idxs=()
  for idx in "${!paths[@]}"; do
    [[ "${groups[$idx]}" == "$root" ]] && idxs+=("$idx")
  done
  open_group "$root" "${idxs[@]}"
done
