#!/bin/sh
# prefix+f から呼ばれ、分割した新しいペインで claude を起動する
# 分割元のペインで claude が開いていればその会話を fork し、なければ直近の会話を fork する

session_id=$(tmux show-options -pqv -t "$1" @claude_session_id 2>/dev/null)

if [ -n "$session_id" ]; then
    exec claude --resume "$session_id" --fork-session
fi

exec claude -c --fork-session
