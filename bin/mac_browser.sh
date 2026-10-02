#!/bin/bash
set -eu

# 普段使いのプロファイルとは別インスタンスにして CDP のポートを開ける
PORT=9222
PROFILE_DIR="$HOME/.chrome-debug"
WAIT_MAX_SEC=15

if curl -s --max-time 2 "localhost:$PORT/json/version" >/dev/null; then
  echo "起動済み localhost:$PORT"
  exit 0
fi

open -na "Google Chrome" --args \
  --remote-debugging-port=$PORT \
  --user-data-dir="$PROFILE_DIR" \
  --profile-directory=Default \
  --no-first-run \
  --no-default-browser-check \
  --hide-crash-restore-bubble

WAITED_SEC=0
while [ $WAITED_SEC -lt $WAIT_MAX_SEC ]; do
  if curl -s --max-time 2 "localhost:$PORT/json/version" >/dev/null; then
    echo "起動した localhost:$PORT"
    exit 0
  fi
  sleep 1
  WAITED_SEC=$((WAITED_SEC + 1))
done

echo "$WAIT_MAX_SEC 秒待っても localhost:$PORT が応答しない"
exit 1
