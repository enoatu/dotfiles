#!/usr/bin/env bash
# windowにclaudeがあれば状態を色ドットで表示する
# 状態はClaude Codeのhookが /tmp/claude_state_<pane_id> に書く
# モデル略号は statusline.py が /tmp/claude_model_<pane_id> に書く
# 第2引数はそのウィンドウを今見ているか(1=選択中)。見たら未読を既読にする
set -u
export LC_ALL=C
window_id=$1
window_active=${2:-0}

color_working='#f1fa8c'
color_blocked='#ff5555'
color_done='#8be9fd'
color_idle='#50fa7b'
color_unknown='#6272a4'

# 稼働中はpane_titleの先頭がブライユ点字スピナー
# UTF-8で E2 A0..A3 xx なので先頭バイト226かつ2バイト目160..163で判別する
is_spinner_title() {
    local title=$1
    printf -v first_byte '%d' "'${title:0:1}" 2>/dev/null || first_byte=0
    printf -v second_byte '%d' "'${title:1:1}" 2>/dev/null || second_byte=0
    [ "$first_byte" = 226 ] && [ "$second_byte" -ge 160 ] && [ "$second_byte" -le 163 ]
}

segments=""
while IFS="$(printf '\t')" read -r command pane title; do
    case "$command" in
        claude|npm|node) ;;
        *) continue ;;
    esac

    key=$(printf '%s' "$pane" | tr -c 'A-Za-z0-9' '_')
    state_file="/tmp/claude_state_$key"
    model_file="/tmp/claude_model_$key"

    state=unknown
    seen=1
    if [ -f "$state_file" ]; then
        read -r state seen < "$state_file"
    fi

    # workingのままStopフックが来なかった時の保険
    # スピナーが消えていれば完了とみなす
    if [ "$state" = working ] && ! is_spinner_title "$title"; then
        state=idle
        seen=1
        [ "$window_active" = 1 ] || seen=0
        printf 'idle %s\n' "$seen" > "$state_file"
    fi

    # 選択中のウィンドウを見たら未読(ティール)を既読(緑)にする
    if [ "$window_active" = 1 ] && [ "$state" = idle ] && [ "$seen" = 0 ]; then
        printf 'idle 1\n' > "$state_file"
        seen=1
    fi

    # 未読(青)とblocked(赤)だけ大きい丸で目立たせる
    glyph=●
    case "$state" in
        working) color=$color_working ;;
        blocked) color=$color_blocked; glyph=⬤ ;;
        idle)
            if [ "$seen" = 0 ]; then
                color=$color_done; glyph=⬤
            else
                color=$color_idle
            fi
            ;;
        *) color=$color_unknown ;;
    esac

    model=""
    [ -f "$model_file" ] && model=$(cat "$model_file")

    dot="#[fg=$color]$glyph#[fg=default]"
    if [ -n "$model" ]; then
        segments="$segments $dot $model"
    else
        segments="$segments $dot"
    fi
done < <(tmux list-panes -t "$window_id" -F "#{pane_current_command}$(printf '\t')#{pane_id}$(printf '\t')#{pane_title}" 2>/dev/null)

printf '%s' "${segments# }"
