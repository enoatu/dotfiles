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

# pane_titleの先頭2バイトで実状態を推定する
# ブライユ点字(E2 A0..A3)=稼働中スピナー、記号(E2 9C xx)=完了や待機の印✳✻✽
# 空やその他は不明として返し、保存状態を保つ
title_kind() {
    local title=$1
    printf -v first_byte '%d' "'${title:0:1}" 2>/dev/null || first_byte=0
    printf -v second_byte '%d' "'${title:1:1}" 2>/dev/null || second_byte=0
    if [ "$first_byte" != 226 ]; then
        echo unknown
    elif [ "$second_byte" -ge 160 ] && [ "$second_byte" -le 163 ]; then
        echo spinner
    elif [ "$second_byte" = 156 ]; then
        echo symbol
    else
        echo unknown
    fi
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

    # pane_titleで実際の稼働を判断しフックの取りこぼしに勝たせる
    kind=$(title_kind "$title")
    if [ "$kind" = spinner ]; then
        # スピナーが出れば稼働中。赤や古いworkingの固着はここで解除する
        if [ "$state" != working ]; then
            state=working
            seen=1
            printf 'working 1\n' > "$state_file"
        fi
    elif [ "$kind" = symbol ] && [ "$state" = working ]; then
        # 完了印が出たworkingは完了とみなす
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
