#!/bin/sh
# prefix+f から呼ばれ、右に分割した新しいペインで claude を起動する
# 分割元のペインで claude が開いていればその会話を fork し、なければ直近の会話を fork する

session_id=$(cat "/tmp/claude_session_ids/$HERDR_ACTIVE_PANE_ID" 2>/dev/null)
new_pane_id=$(herdr pane split "$HERDR_ACTIVE_PANE_ID" --direction right --cwd "$PWD" --focus | jq -r .result.pane.pane_id)

if [ -n "$session_id" ]; then
    exec herdr pane run "$new_pane_id" "exec claude --resume $session_id --fork-session"
fi

exec herdr pane run "$new_pane_id" "exec claude -c --fork-session"
