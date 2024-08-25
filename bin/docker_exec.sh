#!/bin/bash

# Docker コンテナのリストを取得して fzf に渡す
CONTAINER_ID=$(docker ps --format "{{.ID}}: {{.Names}}" | fzf --height 40% --border --ansi | awk -F: '{print $1}')

# 選択されたコンテナに exec で接続
if [ -n "$CONTAINER_ID" ]; then
  # 検索するシェルのリスト
  SHELLS=("/bin/bash" "/bin/zsh" "/bin/ash" "/bin/sh")

  # 利用可能なシェルを見つける
  for SHELL in "${SHELLS[@]}"; do
    if docker exec "$CONTAINER_ID" $SHELL -c "exit" >/dev/null 2>&1; then
      docker exec -it "$CONTAINER_ID" $SHELL
      exit 0
    fi
  done
  echo "対応するシェルが見つかりませんでした。"
else
  echo "コンテナが選択されませんでした。"
fi
