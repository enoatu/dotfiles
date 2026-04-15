#!/usr/bin/env bash
# windowにclaudeがあれば状態を表示
# npx経由だとpane_current_commandがnpmeになる
PANES=$(tmux list-panes -t "$1" -F "#{pane_current_command} #{pane_id}" 2>/dev/null | awk '/^(claude|npm) /{print $2}')
[ -z "$PANES" ] && exit 0

RUNNING=0
for PANE in $PANES; do
    tmux capture-pane -t "$PANE" -p 2>/dev/null | tail -n20 | grep -qE "esc to interrupt|background tasks still running|· ↓ to manage| · thought for| · thinking|· ↓ [0-9]" && RUNNING=1
done

if [ "$RUNNING" -eq 1 ]; then
    echo "🏃"
else
    echo "✅"
fi
