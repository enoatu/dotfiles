#!/bin/sh
# prefix+f から呼ばれ、分割した新しいペインで claude を起動する
# 分割元のペインで claude が開いていればその会話を fork し、なければ直近の会話を fork する

session_id=$(cat "/tmp/claude_session_ids_$(id -u)/$1" 2>/dev/null)
# /tmp はほかのユーザーも書けるので、中身が 0-9 と a-f とハイフンだけのときにセッション ID とする
case "$session_id" in
    *[!0-9a-f-]*) session_id= ;;
esac

if [ -n "$session_id" ]; then
    exec claude --resume "$session_id" --fork-session
fi

exec claude -c --fork-session
