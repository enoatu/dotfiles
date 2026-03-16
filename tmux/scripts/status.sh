#!/usr/bin/env bash
# windowにclaudeがあれば状態を表示
WINDOW="$1"

while read -r CMD PANE; do
    [ "$CMD" = "claude" ] || continue

    LAST=$(tmux capture-pane -t "$PANE" -p 2>/dev/null | grep -v '^$' | tail -1)

    if echo "$LAST" | grep -qE "esc to interrupt|background tasks still running"; then
        echo "🏃"
    else
        echo "✅"
    fi
    exit 0
done < <(tmux list-panes -t "$WINDOW" -F "#{pane_current_command} #{pane_id}")
