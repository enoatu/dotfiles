#!/usr/bin/env bash
# windowにclaudeがあれば状態を表示
PANES=$(tmux list-panes -t "$1" -F "#{pane_current_command} #{pane_id}" | awk '/^claude /{print $2}')
[ -z "$PANES" ] && exit 0

RUNNING=0
for PANE in $PANES; do
    LAST=$(tmux capture-pane -t "$PANE" -p 2>/dev/null | grep -v '^$' | tail -1)
    case "$LAST" in
        *"esc to interrupt"*|*"background tasks still running"*) RUNNING=1 ;;
    esac
done

if [ "$RUNNING" -eq 1 ]; then
    echo "🏃"
else
    echo "✅"
fi
