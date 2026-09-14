## Neovim 検証のコツ

### socket で操作する

```bash
find /var/folders -path '*/nvim.enotiru/*' -name 'nvim.*' -type s
nvim --server "$SOCK" --remote-expr 'execute("luafile /tmp/x.lua") . luaeval("_G._result")'
```

複数操作は luafile + `_G._result` で 1 コマンドにまとめる (1操作=数十ms)。**10秒超えたら設計を疑え**。

### やるな

- `--remote-send`: insert mode 中だとキーが文字として混入。代わりに `vim.cmd(...)` を luafile 経由で。
- `init` で `vim.lsp.config()`: lazy.nvim の runtimepath 反映前で `lsp/*.lua` の defaults と merge されない → `config` フィールドで呼べ。

### LSP のハマり

- `cmd` の `~` は展開されない → `vim.fn.expand()`
- `vim.lsp.enable` は filetypes 必須。全ファイル対応なら自前 `BufReadPost` autocmd で `vim.lsp.start`。

## 外部プラグインの install / build

信頼していない外部リポジトリやプラグインで依存インストールやビルドを走らせる前に、package.json の scripts と postinstall などの lifecycle hook、依存パッケージ、registry 設定を読んで不審な点が無いか確認する。postinstall は任意コードを実行できるので、承認を得ていても無確認では走らせない。
