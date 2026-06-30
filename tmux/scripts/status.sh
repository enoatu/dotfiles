#!/usr/bin/env bash
# windowにclaudeがあれば状態を表示
# 完了行は「✻ Cogitated for 2m 9s」のように "for Ns" 形式
# 実行中行は「✻ Researching… (4m 2s · ↓ 8.9k tokens · thought for 51s)」のように "… (Ns" 形式
# 過去の実行中スピナー行が画面に残るケースを誤検出しないよう、入力プロンプト ❯ の直前の領域だけ見る
PANES=$(tmux list-panes -t "$1" -F "#{pane_current_command} #{pane_id}" 2>/dev/null | awk '/^(claude|npm|node) /{print $2}')
[ -z "$PANES" ] && exit 0

RUNNING=0
# fork(サブエージェント)行の署名。プロンプト下の ◯ で始まる行を集める
FORKSIG=""
for PANE in $PANES; do
    CAP=$(tmux capture-pane -t "$PANE" -p 2>/dev/null)
    PROMPT_LINE=$(printf '%s\n' "$CAP" | grep -n '^❯' | tail -1 | cut -d: -f1)
    if [ -z "$PROMPT_LINE" ]; then
        # 入力プロンプトが見当たらない（起動中、modal表示中など）は判定保留
        continue
    fi
    # 入力プロンプトの直前15行 = スピナー行＋タスクリストが収まる範囲
    AREA=$(printf '%s\n' "$CAP" | sed -n "1,$((PROMPT_LINE - 1))p" | tail -n15)
    printf '%s\n' "$AREA" | grep -qE "… \(([0-9]+m )?[0-9]+s|background tasks still running|Press Ctrl-C again|esc to interrupt" && RUNNING=1
    # プロンプト下の fork ツリーは稼働中だけ経過時間が増える。行をそのまま署名に足す
    FORK_LINES=$(printf '%s\n' "$CAP" | sed -n "$((PROMPT_LINE + 1)),\$p" | grep '◯')
    FORKSIG="$FORKSIG|$PANE:$FORK_LINES"
done

# fork のカウンタが前回(約1秒前)から変化していれば実行中とみなす
SNAP="/tmp/tmux_claude_fork_$(printf '%s' "${TMUX}_$1" | tr -c 'A-Za-z0-9' '_')"
PREV=$(cat "$SNAP" 2>/dev/null)
printf '%s' "$FORKSIG" > "$SNAP"
if printf '%s' "$FORKSIG" | grep -q '◯' && [ "$FORKSIG" != "$PREV" ]; then
    RUNNING=1
fi

if [ "$RUNNING" -eq 1 ]; then
    echo "🏃"
else
    echo "✅"
fi
