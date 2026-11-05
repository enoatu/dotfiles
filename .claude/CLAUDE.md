## dotfiles と private-dotfiles の考え方

作業の前に次を読み、この考え方に合うように変更する。

- @../README.md
- @../private-dotfiles/README.md

## Neovim 検証のコツ

### socket で操作する

```bash
# Linux
find /run/user/$(id -u) -name 'nvim.*' -type s
# macOS
find /var/folders -path "*/nvim.$USER/*" -name 'nvim.*' -type s
nvim --server "$SOCK" --remote-expr 'execute("luafile /tmp/x.lua") . luaeval("_G._result")'
```

複数の操作は luafile と `_G._result` で1つのコマンドにまとめる。

1回の操作には数十 ms かかる。

検証に10秒より長くかかったら、操作の分け方を見直す。

### やらないこと

- `--remote-send` は使わない
  - insert mode のときに、キーが文字としてバッファに入る
  - 代わりに luafile で `vim.cmd(...)` を実行する
- `init` で `vim.lsp.config()` を実行しない
  - lazy.nvim が runtimepath を追加する前なので、`lsp/*.lua` の既定値と合わさらない
  - lazy.nvim でプラグインごとに書く `config` 関数の中で実行する

### LSP で気をつけること

- `cmd` に書いた `~` は展開されないので、`vim.fn.expand()` で展開する
- `vim.lsp.enable` には filetypes が要る
  - すべてのファイルで使うときは、自分で `BufReadPost` の autocmd を作り、`vim.lsp.start` を実行する

## 外部プラグインの install と build

信頼していない外部リポジトリやプラグインで依存のインストールやビルドを実行する前に、次のものにおかしなところがないかを確かめる。

- package.json の scripts
- postinstall などの lifecycle hook
- 依存パッケージ
- registry の設定

postinstall は任意のコードを実行できるので、承認をもらっていても、確かめずには実行しない。
