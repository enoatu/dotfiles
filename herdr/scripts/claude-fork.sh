#!/bin/sh
# prefix+f から呼ばれ、右に分割した新しいペインで claude を起動する
# 分割元のペインで claude が開いていればその会話を fork し、なければ直近の会話を fork する

session_id=$(cat "/tmp/claude_session_ids_$(id -u)/$HERDR_ACTIVE_PANE_ID" 2>/dev/null)
# /tmp はほかのユーザーも書けるので、中身が 0-9 と a-f とハイフンだけのときにセッション ID とする
case "$session_id" in
    *[!0-9a-f-]*) session_id= ;;
esac
new_pane_id=$(~/dotfiles/herdr/scripts/split-pane.sh right)

if [ -n "$session_id" ]; then
    exec "$HERDR_BIN_PATH" pane run "$new_pane_id" "claude --resume $session_id --fork-session"
fi

exec "$HERDR_BIN_PATH" pane run "$new_pane_id" "claude -c --fork-session"
