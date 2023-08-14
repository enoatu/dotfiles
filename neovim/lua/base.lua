vim.scriptencoding = "utf-8"
vim.o.fileencodings = "utf-8,iso-2022-jp,euc-jp,sjis"
vim.o.fileformats = "unix,dos,mac"
--  "文字コードをUFT-8に設定
vim.o.fenc = "utf-8"
--  " バックアップファイルを作らない
vim.o.backup = false
--  " スワップファイルを作らない
vim.o.swapfile = false
--  " 編集中のファイルが変更されたら自動で読み直す
vim.o.autoread = true
--  " バッファが編集中でもその他のファイルを開けるように
vim.o.hidden = true
--  " 入力中のコマンドをステータスに表示する
vim.o.showcmd = true
--  " 見た目系
--  " 行番号を表示
vim.wo.number = true
--  " 現在の行を強調表示
vim.wo.cursorline = true
--  " 現在の行を強調表示（縦）
vim.wo.cursorcolumn = true
--  " 行末の1文字先までカーソルを移動できるように
vim.o.virtualedit = "onemore"
-- "検索した文字をハイライトする
vim.o.hls = true
-- "TrueColor対応"
vim.o.termguicolors = true

-- " ビープ音を可視化
vim.o.visualbell = true
-- " 括弧入力時の対応する括弧を表示
vim.o.showmatch = true
-- " ステータスラインを常に表示
vim.o.laststatus = 2
-- " コマンドラインの補完
vim.o.wildmode = "list:longest"
-- " 折り返し時に表示行単位での移動できるようにする
vim.keymap.set("n", "j", "gj, { noremap = true }")

vim.keymap.set("n", "k", "gk", { noremap = true })
-- " diff時 set wrapをデフォルトに
-- autocmd FilterWritePre * if &diff | setlocal wrap< | endif
-- TODO
-- vim.api.nvim_command("autocmd WinEnter * if &diff | set wrap | endif")
-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- nnoremap <Leader>d :Gdiff<CR>:windo set wrap<CR>
vim.keymap.set("n", "<Leader>d", ":Gdiff<CR>:windo set wrap<CR>")
-- "タブ、空白、改行の可視化
vim.o.list = true
vim.o.listchars = "tab:▸▸,trail:◀,extends:>,precedes:<,nbsp:%"
-- "全角スペースをハイライト表示
vim.api.nvim_create_augroup('extra-whitespace', {})
vim.api.nvim_create_autocmd({'VimEnter', 'WinEnter'}, {
  group = 'extra-whitespace',
  pattern = {'*'},
  command = [[call matchadd('ExtraWhitespace', '[\u200B\u3000]')]]
})
vim.api.nvim_create_autocmd({'ColorScheme'}, {
  group = 'extra-whitespace',
  pattern = {'*'},
  command = [[highlight default ExtraWhitespace ctermbg=202 ctermfg=202 guibg=salmon]]
})
-- " 検索系
-- " 検索文字列が小文字の場合は大文字小文字を区別なく検索する
vim.o.ignorecase = true
-- " 検索文字列に大文字が含まれている場合は区別して検索する
vim.o.smartcase = true
-- " 検索文字列入力時に順次対象文字列にヒットさせる
vim.o.incsearch = true
-- " 検索語をハイライト表示
vim.o.hlsearch = true
-- "行頭
vim.keymap.set({"n", "v"}, "<C-h>", "0", { noremap = true })
-- "行末
vim.keymap.set({"n", "v"}, "<C-l>", "$", { noremap = true })
vim.keymap.set("v", "<BS>", "<Del>", { noremap = true })
vim.keymap.set("i", "<BS>", "<BS>", { noremap = true })
-- " 挿入モードーノーマルモード間移動を高速化
vim.o.ttimeoutlen = 10
vim.o.mouse = "a"
-- " ウィンドウの幅より長い行は折り返され、次の行に続けて表示される
vim.o.wrap = true
vim.o.number = true
vim.o.clipboard = "unnamed"
vim.o.showmatch = true
vim.o.matchtime = 1
vim.o.matchpairs = "<:>"
vim.o.hidden = true
vim.o.whichwrap = "b,s,<,>,[,]"
-- vnoremap <silent> <C-p> "0p<CR>
vim.o.t_Co = 256

vim.keymap.set("c", "w!!", "w !sudo tee > /dev/null %<CR>", { noremap = true })
-- "visualモードで選択してからのインデント調整で調整後に選択範囲を開放しない
vim.keymap.set("v", ">", ">gv", { noremap = true })
vim.keymap.set("v", "<", "<gv", { noremap = true })
