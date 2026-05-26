#!/usr/bin/env bash
#
# SessionEnd Hook: 会話中の意思決定を自動記録する
#
# Claude Code は SessionEnd hook の stdin に以下の JSON を渡す:
#   { "session_id": "...", "transcript_path": "...", "cwd": "...", "hook_event_name": "SessionEnd" }
#

set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
DECISIONS_DIR="${CLAUDE_DIR}/memory"
mkdir -p "${DECISIONS_DIR}"

# stdin から hook JSON を取得して transcript_path を抽出
input=$(cat)
transcript_path=$(printf '%s' "${input}" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('transcript_path', ''))
except Exception:
    pass
")

[[ -z "${transcript_path}" ]] && exit 0
[[ -f "${transcript_path}" ]] || exit 0

# transcript から決定パターンを含む行を抽出
decisions=$(python3 - "${transcript_path}" <<'PY'
import json, re, sys

path = sys.argv[1]
patterns = re.compile(r'決定:|→|【決定】|方針:|結論:|採用:|確定:')

results = []
try:
    with open(path) as f:
        for line in f:
            try:
                obj = json.loads(line)
            except Exception:
                continue
            msg = obj.get('message')
            if not isinstance(msg, dict):
                continue
            content = msg.get('content')
            texts = []
            if isinstance(content, str):
                texts.append(content)
            elif isinstance(content, list):
                for item in content:
                    if isinstance(item, dict) and item.get('type') == 'text':
                        t = item.get('text', '')
                        if t:
                            texts.append(t)
            for t in texts:
                for sub in t.split('\n'):
                    sub = sub.strip()
                    if sub and patterns.search(sub):
                        results.append(sub)
except Exception:
    sys.exit(0)

# 重複排除しつつ順序維持、直近 10 件
seen = set()
unique = []
for r in results:
    if r not in seen:
        seen.add(r)
        unique.append(r)

for r in unique[-10:]:
    print(r)
PY
)

[[ -z "${decisions}" ]] && exit 0

# 日付付きで記録
date_str=$(date +%Y-%m-%d)
output_file="${DECISIONS_DIR}/decisions-${date_str}.md"

if [[ ! -f "${output_file}" ]]; then
  echo "# 意思決定ログ ${date_str}" > "${output_file}"
  echo "" >> "${output_file}"
fi

echo "## $(date +%H:%M)" >> "${output_file}"
echo "${decisions}" >> "${output_file}"
echo "" >> "${output_file}"

