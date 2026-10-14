#!/bin/sh
# 今のペインを分割して、新しいペインのIDを返す
# claude のペインなら claude が作業している worktree で開き、それ以外は今のディレクトリで開く
# 使い方 split-pane.sh right|down

cwd=$(cat "/tmp/claude_cwds/$HERDR_ACTIVE_PANE_ID" 2>/dev/null)
[ -d "$cwd" ] || cwd=$PWD

"$HERDR_BIN_PATH" pane split "$HERDR_ACTIVE_PANE_ID" --direction "$1" --cwd "$cwd" --focus | jq -r .result.pane.pane_id
