---
name: nvim-open
description: コード調査中に対象ファイルを同じ tmux window の縦分割ペインで nvim で開く skill。colorscheme やプラグインなど通常起動と同じ設定が読み込まれた状態で開き、2 回目以降は同じペインを使い回してペインを増やさない。ユーザーが調査対象をすぐ目で追えるようにするのが目的。
---

# nvim-open

## 目的

調査中に「この xxxx見て」となった対象を、ユーザーの画面で nvim で開く。
同じ tmux window に縦分割ペインを 1 つ作り、そこで開く。設定が全部効いた状態で開く。

## スクリプト（`scripts/` 配下）

| script | 用途 |
|---|---|
| `open.sh <target> [target ...]` | 対象を縦分割ペインの nvim で開く。複数指定可。1 回で完結 |

## 使い方

```bash
bash $HOME/.claude/skills/nvim-open/scripts/open.sh <target> [target ...]
```

- `target` は `path` もしくは `path:line` 形式（`line` を付けるとその行へジャンプ）
- `path` は相対でも絶対でもよい（スクリプトが絶対パス化する）
- 複数指定すると先頭ファイルでペインを開き、残りは同じ nvim にタブで開く
- 存在しないパスは skip して残りを開く

```bash
# 例
open.sh src/main.rs
open.sh src/main.rs:42
open.sh src/a.rs:42 src/b.rs lib/c.rs:10
```

## 挙動

- 開く先は **claude code 自身がいる window**（`$TMUX_PANE` 基準）。アクティブ window が別でもそちらには開かない
- **git リポジトリ（submodule 含む）ごとに 1 ペイン**を使い回す
  - ファイルの所属を `git rev-parse --show-toplevel` で判定する。submodule は独自の toplevel を返すので別ペインになる
  - 1 回の呼び出しで複数リポジトリのファイルを渡すと、リポジトリごとにペインが分かれて開く
  - 同じリポジトリの 2 ファイル目以降は新規タブで開き、ペインを増やさない
  - 初回は縦分割（`tmux split-window -h`）で新しいペインを作り nvim を起動する
- nvim は **ペインで cd してから対話 zsh を起動し、その中で実行**する
  - zsh の PATH（rg や LSP、mise の nvim など）をそのまま継承するので、nvim 設定に絶対パス等を足さずに telescope の rg 等が動く
  - 非対話シェルだと rg が PATH に無く、system の古い nvim を拾って lazy.nvim も動かないので必ず対話 zsh を経由する
- socket とペイン id を `/tmp/claude-nvim/<session>_<window>__<repo>.{sock,pane}` に決め打ちで持つ
- 全ての nvim RPC 呼び出しに `timeout` を付けており、固まらない

## 設計メモ

- socket の pid は tmux ペインの shell ではなく nvim 子プロセスの pid なので、pid マッチでの socket 特定は当てにしない。代わりに決め打ち socket パスで起動して再利用判定する
- ファイル本体は一切変更しない

## 注意

- tmux の中で実行すること（外だと exit 3）
- 明示起動のみ
