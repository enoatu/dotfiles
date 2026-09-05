#!/usr/bin/env bash
# windowにclaudeがあれば状態を色ドットで表示する
# 状態はClaude Codeのhookが /tmp/claude_state_<pane_id> に書く
# 第2引数はそのウィンドウを今見ているか(1=選択中)。見たら未読を既読にする
set -u
export LC_ALL=C

readonly WINDOW_ID=$1
readonly WINDOW_ACTIVE=${2:-0}

readonly COLOR_WORKING='#f1fa8c'
readonly COLOR_BLOCKED='#ff5555'
readonly COLOR_DONE='#8be9fd'
readonly COLOR_IDLE='#50fa7b'
readonly COLOR_UNKNOWN='#6272a4'

readonly TAB=$'\t'

state_file_of() {
    local pane_key
    pane_key=$(printf '%s' "$1" | tr -c 'A-Za-z0-9' '_')
    echo "/tmp/claude_state_$pane_key"
}

list_panes() {
    tmux list-panes -t "$1" -F "#{pane_current_command}$TAB#{pane_id}" 2>/dev/null
}

# 保存状態を選択状況で補正する。必要ならファイルも直す
# 返り値は "state seen"
resolve_state() {
    local state_file=$1
    local state=unknown seen=1
    [ -f "$state_file" ] && read -r state seen < "$state_file"

    # 選択中のウィンドウを見たら未読(青)を既読(緑)にする
    if [ "$WINDOW_ACTIVE" = 1 ] && [ "$state" = idle ] && [ "$seen" = 0 ]; then
        seen=1
        printf 'idle 1\n' > "$state_file"
    fi

    echo "$state $seen"
}

state_to_color() {
    local state=$1 seen=$2
    case "$state" in
        working) echo "$COLOR_WORKING" ;;
        blocked) echo "$COLOR_BLOCKED" ;;
        idle)
            if [ "$seen" = 0 ]; then
                echo "$COLOR_DONE"
            else
                echo "$COLOR_IDLE"
            fi
            ;;
        *) echo "$COLOR_UNKNOWN" ;;
    esac
}

# 入力待ち(赤)と完了未読(青)は大きい丸で目立たせる。どの丸も幅2で揃うので移動でずれない
state_to_glyph() {
    local state=$1 seen=$2
    case "$state" in
        blocked) echo ⬤ ;;
        idle)
            if [ "$seen" = 0 ]; then
                echo ⬤
            else
                echo ●
            fi
            ;;
        *) echo ● ;;
    esac
}

dots=""
while IFS="$TAB" read -r command pane; do
    case "$command" in
        claude|npm|node) ;;
        *) continue ;;
    esac

    read -r state seen <<< "$(resolve_state "$(state_file_of "$pane")")"
    color=$(state_to_color "$state" "$seen")
    glyph=$(state_to_glyph "$state" "$seen")
    dots="$dots#[fg=$color]$glyph#[fg=default]"
done < <(list_panes "$WINDOW_ID")

# 名前の前に置くので末尾に空白を足す。claudeが無ければ空文字
[ -n "$dots" ] && printf '%s ' "$dots"
