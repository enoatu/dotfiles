#!/usr/bin/env bash

# マージとオプションでプッシュを自動化するスクリプト
# 使用方法: ./merge_and_push.sh [-p] <parent_branch> <child_branch1> <child_branch2> ...

# 初期化
PUSH=false

# オプション解析
while getopts ":p" opt; do
  case $opt in
    p)
      PUSH=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# オプションの数だけ引数をシフト
shift $((OPTIND - 1))

# 引数が足りない場合はエラー
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 [-p] <parent_branch> <child_branch1> <child_branch2> ..."
  exit 1
fi

# 親ブランチ
PARENT_BRANCH=$1

# 子ブランチリスト
CHILD_BRANCHES=("${@:2}")

# 現在のブランチを記録
CURRENT_BRANCH=$(git branch --show-current)

# 親ブランチから順にマージと必要に応じてプッシュを実行
for BRANCH in "${CHILD_BRANCHES[@]}"; do
  echo "Checkout to $BRANCH..."
  git checkout "$BRANCH" || { echo "Failed to checkout to $BRANCH"; exit 1; }

  echo "Merging $PARENT_BRANCH into $BRANCH..."
  git merge "$PARENT_BRANCH" --no-edit || { echo "Merge conflict occurred in $BRANCH"; exit 1; }

  # pushオプションが指定されている場合のみプッシュ
  if $PUSH; then
    echo "Pushing $BRANCH..."
    git push || { echo "Failed to push $BRANCH"; exit 1; }
  fi

  # 次のループの親ブランチを更新
  PARENT_BRANCH=$BRANCH
done

# 元のブランチに戻る
git checkout "$CURRENT_BRANCH"
echo "All branches merged${PUSH:+ and pushed} successfully."
