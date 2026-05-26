#!/bin/sh
# claude の Stop hook
# 発動した tmux window が非アクティブなときだけ ntfy.sh に通知する

[ -z "$TMUX_PANE" ] && exit 0

active=$(tmux display -t "$TMUX_PANE" -p '#{window_active}' 2>/dev/null)
[ "$active" = "1" ] && exit 0

win=$(tmux display -t "$TMUX_PANE" -p '#{window_name}' 2>/dev/null)
cwd_base=$(basename "${CLAUDE_PROJECT_DIR:-$PWD}")

curl -fsS -m 5 \
  -H "Title: $cwd_base" \
  -d "claude done in window: $win" \
  https://ntfy.sh/enotiruclaude >/dev/null 2>&1

exit 0
