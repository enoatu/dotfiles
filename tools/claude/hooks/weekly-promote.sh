#!/usr/bin/env bash
#
# 週次メモリ昇格: 直近7日間の決定ログと feedback メモリを分析し、
# 繰り返しパターンを昇格する
#

set -euo pipefail

CLAUDE_BIN=$(command -v claude || echo "${HOME}/.local/bin/claude")
PROMPT=$(cat <<'EOF'
週次メモリ昇格タスクを実行してください。

## 手順

1. `~/.claude/memory/` 配下の `decisions-*.md` ファイルから今週分（直近7日間）を読み込む
2. `~/.claude/projects/` 配下の各プロジェクトの `memory/` にある feedback メモリ（`feedback_*.md`）を全て読み込む
3. 以下のパターンを分析する:
   - decisions ログで繰り返し出現するテーマや判断基準
   - feedback メモリの pain_count が増加しているもの
4. 繰り返しパターンが見つかった場合:
   - 該当する feedback メモリの pain_count をインクリメント
   - pain_count >= 3 のものは `memory/evolution.md` のプロトコルに従い CLAUDE.md に昇格
5. 新しいパターンが見つかった場合:
   - 適切なプロジェクトの memory に新規 feedback メモリとして記録（pain_count: 0）
6. 処理結果をサマリーとして出力する
EOF
)

"${CLAUDE_BIN}" -p "${PROMPT}" \
  --allowedTools "Read,Write,Edit,Glob,Grep,Bash(find:*),Bash(date:*),Bash(ls:*)" \
  --max-turns 15 \
  >> "${HOME}/.claude/memory/weekly-promote.log" 2>&1


