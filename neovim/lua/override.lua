local vim = vim
-- leader key
vim.g.mapleader = " "
-- バッファが編集中でもその他のファイルを開けるように
vim.o.hidden = true
-- 入力中のコマンドをステータスに表示する
vim.o.showcmd = true
vim.opt.undofile = true

-- yank後にクリップボードにもコピー
-- vim.keymap.set("n", "+", "<Cmd>let @+ = @@<CR>", { noremap = true, silent = true }
-- https://zenn.dev/anyakichi/articles/40d7464fdf0e31
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("YankSync", { clear = true }),
    pattern = "*",
    callback = function()
        vim.fn.setreg("+", vim.fn.getreg("@@"))
    end,
})

----  見た目系
-- 行番号を表示
vim.wo.number = true
-- 現在の行を強調表示
vim.wo.cursorline = true
--  現在の行を強調表示（縦）
vim.wo.cursorcolumn = true
--  行末の1文字先までカーソルを移動できるように
vim.o.virtualedit = "onemore"
-- TrueColor対応"
vim.o.termguicolors = true
-- ビープ音を可視化
vim.o.visualbell = true
-- 括弧入力時の対応する括弧を表示
vim.o.showmatch = true
-- ステータスラインを常に表示
vim.o.laststatus = 2
-- コマンドラインの補完
vim.o.wildmode = "list:longest"
-- タブ、空白、改行の可視化
vim.o.list = true
vim.o.listchars = "tab:▸▸,trail:◀,extends:>,precedes:<,nbsp:%"
-- 全角スペースをハイライト表示
vim.api.nvim_create_augroup("extra-whitespace", {})
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter" }, {
    group = "extra-whitespace",
    pattern = { "*" },
    command = [[call matchadd('ExtraWhitespace', '[\u200B\u3000]')]],
})
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
    group = "extra-whitespace",
    pattern = { "*" },
    command = [[highlight default ExtraWhitespace ctermbg=202 ctermfg=202 guibg=salmon]],
})

-- 検索系
-- 検索文字列が小文字の場合は大文字小文字を区別なく検索する
vim.o.ignorecase = true
-- 検索文字列に大文字が含まれている場合は区別して検索する
vim.o.smartcase = true
-- 検索文字列入力時に順次対象文字列にヒットさせる
vim.o.incsearch = true
-- 検索語をハイライト表示
vim.o.hlsearch = true

-- 操作系
-- 行頭
vim.keymap.set(
    { "n", "v" },
    "<C-h>",
    "^",
    { noremap = true, silent = true, desc = "非空白文字の行頭に移動" }
)
-- 行末
vim.keymap.set({ "n", "v" }, "<C-l>", "$", { noremap = true, silent = true, desc = "行末に移動" })

-- buffer list
vim.keymap.set({ "n", "v" }, "<C-K>", ":call BufferList()<CR>", { noremap = true, silent = true, desc = "BufferList" })

-- バッファの移動
vim.keymap.set({ "n", "v" }, "<C-q>", ":b #<CR>", { noremap = true, silent = true, desc = "前回のバッファに移動" })


-- 削除
vim.keymap.set("v", "<BS>", "<Del>", { noremap = true })
vim.keymap.set("i", "<BS>", "<BS>", { noremap = true })

-- 挿入モードーノーマルモード間移動を高速化
vim.o.ttimeoutlen = 10
vim.o.mouse = "a"
-- "ウィンドウの幅より長い行は折り返され、次の行に続けて表示される
-- vim.wo.wrap = true プラグインにより無効化されている
vim.o.matchtime = 1
vim.o.hidden = true
vim.o.whichwrap = "b,s,<,>,[,]"
-- vnoremap <silent> <C-p> "0p<CR>
-- vim.o.t_Co = 256

vim.keymap.set("c", "w!!", "w !sudo tee > /dev/null %<CR>", { noremap = true })
-- "visualモードで選択してからのインデント調整で調整後に選択範囲を開放しない
vim.keymap.set("v", ">", ">gv", { noremap = true })
vim.keymap.set("v", "<", "<gv", { noremap = true })

vim.opt.spelllang = { "en" }
vim.opt.splitright = false
vim.opt.splitbelow = true
vim.opt.relativenumber = false
vim.opt.wrap = true


-- Disable
vim.keymap.set({ "i", "n" }, "<esc>", "<esc>", { desc = "Escape and clear hlsearch" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
        vim.opt_local.autoindent = true
    end,
})

-- ログを出す
vim.cmd("set verbosefile=~/.cache/nvim/log")
vim.cmd("set verbose=3")
