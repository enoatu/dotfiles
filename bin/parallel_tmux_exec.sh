#!/bin/bash

unset TMUX
# 新しいtmuxセッションの名前
SESSION_NAME="parallel_session"

# コマンドが指定されているか確認
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <command1> <command2> ... <commandN>"
  exit 1
fi

if tmux has-session -t $SESSION_NAME 2>/dev/null; then
  tmux kill-session -t $SESSION_NAME
fi

tmux new-session -d -s $SESSION_NAME

# 最初のウィンドウのインデックスを取得
FIRST_WINDOW=$(tmux list-windows -t $SESSION_NAME -F "#{window_index}" | head -n 1)

# 最初のコマンドを最初のペインで実行
tmux send-keys -t $SESSION_NAME:$FIRST_WINDOW.0 "$1" C-m

index=1
# 2つ目以降のコマンドを水平分割で実行
for cmd in "${@:2}"; do
  tmux split-window -v -t $SESSION_NAME:$FIRST_WINDOW.$((index - 1))
  tmux send-keys -t $SESSION_NAME:$FIRST_WINDOW.$index "$cmd" C-m
  # Re-layout panes to be equally sized
  tmux select-layout -t $SESSION_NAME tiled
  index=$((index + 1))
done

tmux attach-session -t $SESSION_NAME
