---
name: nvim-annotate
description: ほぼ1行ベースで「なぜそのコードを書いたか」を説明する skill。可能なら、その説明を同 tmux ウィンドウで開かれている neovim の実バッファに virt_lines で inline 注釈として注入し、ユーザーが画面切替なしに把握できるようにする。背景は、ユーザーが他者にコードの意図を伝えられるようにすること。
---

# nvim-annotate

## 目的

ユーザーが書いた / 受け取ったコードについて、**「なぜこの行をこう書いたか」「何をベースにしたか」** を 1 行ベースで言語化して nvim の virt_lines に注入する。

## 提供スクリプト（`scripts/` 配下）

| script | 用途 |
|---|---|
| `gather_context.sh <abs> [base_branch]` | 設計コンテキスト（commits / diff / 兄弟 / ベース候補）を 1 call で出力 |
| `find_socket.sh <abs>` | 対象を開いている nvim socket を返す（無ければ exit 1）|
| `inject.sh <socket> <lua>` | `:luafile` 実行 + extmark 件数 stdout |

## 手順

### 1. 入力受け取り + 1 度きりの調査

- ユーザー入力パスが相対なら **CWD と素朴に join**（CWD 末尾と入力先頭が同名でも短縮しない。例: CWD=`.../src`、入力=`src/app/...` → `.../src/src/app/...`）
- 対象を `Read`
- セッション履歴に設計判断が無ければ **`gather_context.sh` を 1 回だけ呼ぶ**（個別 `git log` / `git diff` は呼ばない）
- ベース候補が出たら **1 ファイルだけ** Read（参照を広げない）

### 2. 注釈設計

各注釈の構造:

- **何をしている**（1 行）
- **【ベース】**（既存ファイルがあれば: `file.py:Lxx と同型` まで具体的に）
- **【差分】**（ベースとの差異理由）
- **★ なぜ**（設計判断の核）

ベース由来 / 差分 / なぜが無い行は注釈不要（自明な行は読めば分かる）。

**件数目安**（output token の最大ノブ）:

| 行数 | 件数 |
|---|---|
| < 100 | 8〜12 |
| 100〜200 | 12〜18 |
| 200〜300 | 15〜22 |
| > 300 | 18〜25 |

**配置**: 長い関数は内部にも注釈を散らす（直下 5〜10 行が射程の目安）。

**書式**: 日本語、1 行 80 文字以内、★ で重要度強調、行番号レンジ表記は書かない（位置で判る）。

### 3. lua 出力

```bash
mkdir -p /tmp/nvim-annotate && rm -f /tmp/nvim-annotate/inject_<basename>.lua
```

を 1 回流してから `Write`（既存 lua があると Write tool が Read 必須エラーを返すため、先に消す）。

ファイル構造（**フッタ部は以下をそのまま貼る。別ファイル参照はしない**）:

```lua
local target_abs = '<絶対パス>'
local annotations = {
  { 1, { '【このファイル全体】 …', '【ベース】 …' } },
  { 12, { '★ なぜ: …' } },
  -- ...
}

local ns = vim.api.nvim_create_namespace('nvim_annotate')
local hl = 'Comment'
for _, b in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(b)
      and vim.api.nvim_buf_get_name(b) == target_abs then
    vim.api.nvim_buf_clear_namespace(b, ns, 0, -1)
    for _, a in ipairs(annotations) do
      local lines = a[2]
      -- 1 行かつ表示幅 50 以下の短い注釈は行末にシャドウ表示、
      -- それ以外（多行 / 長文）は上に virt_lines として展開
      if #lines == 1 and vim.fn.strdisplaywidth(lines[1]) <= 50 then
        vim.api.nvim_buf_set_extmark(b, ns, a[1] - 1, 0, {
          virt_text = { { '  ' .. lines[1], hl } },
          virt_text_pos = 'eol',
        })
      else
        local virt = {}
        for _, txt in ipairs(lines) do
          table.insert(virt, { { txt, hl } })
        end
        vim.api.nvim_buf_set_extmark(b, ns, a[1] - 1, 0, {
          virt_lines = virt,
          virt_lines_above = true,
        })
      end
    end
    break
  end
end
```

**注釈の書き方ヒント**: 短い 1 行で済む「★ なぜ」系は自動的に行末シャドウになる。多行の「ベース＋差分＋なぜ」をまとめた重い注釈は従来通り上に出る。

### 4. 注入

```bash
SOCK="$(bash /Users/enotiru/.claude/skills/nvim-annotate/scripts/find_socket.sh <abs>)" \
  && bash /Users/enotiru/.claude/skills/nvim-annotate/scripts/inject.sh "$SOCK" /tmp/nvim-annotate/inject_<basename>.lua
```

extmark 件数が annotations 件数と一致すれば成功。

- `find_socket.sh` が exit 1 → markdown `/tmp/nvim-annotate/<basename>_explain.md` 出力でフォールバック（vsplit は禁止）
- **Write 直後の Read で中身確認しない**

### 5. 報告

注入件数と操作 Tip を簡潔に:

- 消す: `:lua vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_create_namespace('nvim_annotate'), 0, -1)`
- 再注入: `:luafile /tmp/nvim-annotate/inject_<basename>.lua`

## 注意

- ファイル本体は変更しない（virt_lines は仮想テキスト）
- annotations 行番号は 1-indexed
- 明示起動のみ
