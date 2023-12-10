local vim = vim
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
-- "TrueColor対応"
vim.o.termguicolors = true

-- " ビープ音を可視化
vim.o.visualbell = true
-- " 括弧入力時の対応する括弧を表示
-- vim.o.showmatch = true
-- " ステータスラインを常に表示
vim.o.laststatus = 2
-- " コマンドラインの補完
vim.o.wildmode = "list:longest"
-- " 折り返し時に表示行単位での移動できるようにする
-- vim.keymap.set("n", "j", "gj", { noremap = true, desc="jをgjに置き換える" })
--
-- vim.keymap.set("n", "k", "gk", { noremap = true })
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
vim.keymap.set({ "n", "v" }, "<C-h>", "0", { noremap = true, silent = true, desc = "行頭に移動" })
-- "行末
vim.keymap.set({ "n", "v" }, "<C-l>", "$", { noremap = true, silent = true, desc = "行末に移動" })

vim.keymap.set({ "n", "v" }, "<leader><S-h>", "<C-w>h", { desc = "Go to left window", noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader><S-j>", "<C-w>j", { desc = "Go to lower window", noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader><S-k>", "<C-w>k", { desc = "Go to upper window", noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader><S-l>", "<C-w>l", { desc = "Go to right window", noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>d", "<C-w>c", { desc = "Close current window", noremap = true, silent = true })

vim.keymap.set("v", "<BS>", "<Del>", { noremap = true })
vim.keymap.set("i", "<BS>", "<BS>", { noremap = true })
-- " 挿入モードーノーマルモード間移動を高速化
vim.o.ttimeoutlen = 10
vim.o.mouse = "a"
-- " ウィンドウの幅より長い行は折り返され、次の行に続けて表示される
-- vim.wo.wrap = true プラグインにより無効化されている
vim.o.number = true
vim.o.showmatch = true
vim.o.matchtime = 1
vim.o.hidden = true
vim.o.whichwrap = "b,s,<,>,[,]"
-- vnoremap <silent> <C-p> "0p<CR>
vim.o.t_Co = 256

vim.keymap.set("c", "w!!", "w !sudo tee > /dev/null %<CR>", { noremap = true })
-- "visualモードで選択してからのインデント調整で調整後に選択範囲を開放しない
vim.keymap.set("v", ">", ">gv", { noremap = true })
vim.keymap.set("v", "<", "<gv", { noremap = true })

-- 優先

--------------
local opt = vim.opt

-- opt.autowrite = true -- Enable auto write
-- opt.clipboard = "unnamedplus" -- Sync with system clipboard
-- opt.completeopt = "menu,menuone,noselect"
-- opt.conceallevel = 3 -- Hide * markup for bold and italic
-- opt.confirm = true -- Confirm to save changes before exiting modified buffer
-- opt.cursorline = true -- Enable highlighting of the current line
-- opt.expandtab = true -- Use spaces instead of tabs
-- opt.formatoptions = "jcroqlnt" -- tcqj
-- opt.grepformat = "%f:%l:%c:%m"
-- opt.grepprg = "rg --vimgrep"
-- opt.ignorecase = true -- Ignore case
-- opt.inccommand = "nosplit" -- preview incremental substitute
-- opt.laststatus = 0
-- opt.list = true -- Show some invisible characters (tabs...
-- opt.mouse = "a" -- Enable mouse mode
-- opt.number = true -- Print line number
-- opt.pumblend = 10 -- Popup blend
-- opt.pumheight = 10 -- Maximum number of entries in a popup
-- opt.relativenumber = true -- Relative line numbers
-- opt.scrolloff = 4 -- Lines of context
-- opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
-- opt.shiftround = true -- Round indent
-- opt.shiftwidth = 2 -- Size of an indent
-- opt.shortmess:append({ W = true, I = true, c = true })
-- opt.showmode = false -- Dont show mode since we have a statusline
-- opt.sidescrolloff = 8 -- Columns of context
-- opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
-- opt.smartcase = true -- Don't ignore case with capitals
-- opt.smartindent = true -- Insert indents automatically
-- opt.spelllang = { "en" }
-- opt.splitbelow = true -- Put new windows below current
-- opt.splitright = true -- Put new windows right of current
-- opt.tabstop = 2 -- Number of spaces tabs count for
-- opt.termguicolors = true -- True color support
-- opt.timeoutlen = 300
-- opt.undofile = true
-- opt.undolevels = 10000
-- opt.updatetime = 200 -- Save swap file and trigger CursorHold
-- opt.wildmode = "longest:full,full" -- Command-line completion mode
-- opt.winminwidth = 5 -- Minimum window width
-- opt.wrap = false -- Disable line wrap

-- Fix markdown indentation settings
-- vim.g.markdown_recommended_style = 0
--
-- local function augroup(name)
--   return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
-- end
--
-- -- Check if we need to reload the file when it changed
-- vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
--   group = augroup("checktime"),
--   command = "checktime",
-- })
--
-- -- Highlight on yank
-- vim.api.nvim_create_autocmd("TextYankPost", {
--   group = augroup("highlight_yank"),
--   callback = function()
--     vim.highlight.on_yank()
--   end,
-- })
--
-- -- resize splits if window got resized
-- vim.api.nvim_create_autocmd({ "VimResized" }, {
--   group = augroup("resize_splits"),
--   callback = function()
--     local current_tab = vim.fn.tabpagenr()
--     vim.cmd("tabdo wincmd =")
--     vim.cmd("tabnext " .. current_tab)
--   end,
-- })
--
-- -- go to last loc when opening a buffer
-- vim.api.nvim_create_autocmd("BufReadPost", {
--   group = augroup("last_loc"),
--   callback = function()
--     local exclude = { "gitcommit" }
--     local buf = vim.api.nvim_get_current_buf()
--     if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
--       return
--     end
--     local mark = vim.api.nvim_buf_get_mark(buf, '"')
--     local lcount = vim.api.nvim_buf_line_count(buf)
--     if mark[1] > 0 and mark[1] <= lcount then
--       pcall(vim.api.nvim_win_set_cursor, 0, mark)
--     end
--   end,
-- })

-- close some filetypes with <q>
-- vim.api.nvim_create_autocmd("FileType", {
--     group = augroup("close_with_q"),
--     pattern = {
--         "PlenaryTestPopup",
--         "help",
--         "lspinfo",
--         "man",
--         "notify",
--         "qf",
--         "spectre_panel",
--         "startuptime",
--         "tsplayground",
--         "neotest-output",
--         "checkhealth",
--         "neotest-summary",
--         "neotest-output-panel",
--     },
--     callback = function(event)
--         vim.bo[event.buf].buflisted = false
--         vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
--     end,
-- })

-- wrap and check for spell in text filetypes
-- vim.api.nvim_create_autocmd("FileType", {
--     group = augroup("wrap_spell"),
--     pattern = { "gitcommit", "markdown" },
--     callback = function()
--         vim.opt_local.wrap = true
--         vim.opt_local.spell = true
--     end,
-- })
--
-- -- Auto create dir when saving a file, in case some intermediate directory does not exist
-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
--     group = augroup("auto_create_dir"),
--     callback = function(event)
--         if event.match:match("^%w%w+://") then
--             return
--         end
--         local file = vim.loop.fs_realpath(event.match) or event.match
--         vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
--     end,
-- })
--
-- if vim.fn.has("nvim-0.9.0") == 1 then
--     opt.splitkeep = "screen"
--     opt.shortmess:append({ C = true })
-- end
--
-- -- This file is automatically loaded by lazyvim.config.init
-- local Util = require("lazyvim.util")
--
-- local function map(mode, lhs, rhs, opts)
--   local keys = require("lazy.core.handler").handlers.keys
--   ---@cast keys LazyKeysHandler
--   -- do not create the keymap if a lazy keys handler exists
--   if not keys.active[keys.parse({ lhs, mode = mode }).id] then
--     opts = opts or {}
--     opts.silent = opts.silent ~= false
--     if opts.remap and not vim.g.vscode then
--       opts.remap = nil
--     end
--     vim.keymap.set(mode, lhs, rhs, opts)
--   end
-- end
--
-- -- better up/down
-- map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
--
-- -- Move to window using the <ctrl> hjkl keys
-- map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
-- map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
-- map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
-- map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })
--
-- -- Resize window using <ctrl> arrow keys
-- map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
-- map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
-- map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
-- map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
--
-- -- Move Lines
-- map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
-- map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
-- map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
-- map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
-- map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
-- map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })
--
-- -- buffers
-- if Util.has("bufferline.nvim") then
--   map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
--   map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
--   map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
--   map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
-- else
--   map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
--   map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
--   map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
--   map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
-- end
-- map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
-- map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
--
-- -- Clear search with <esc>
-- map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })
--
-- -- Clear search, diff update and redraw
-- -- taken from runtime/lua/_editor.lua
-- map(
--   "n",
--   "<leader>ur",
--   "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
--   { desc = "Redraw / clear hlsearch / diff update" }
-- )
--
-- -- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
-- map("n", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
-- map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
-- map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
-- map("n", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
-- map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
-- map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
--
-- -- Add undo break-points
-- map("i", ",", ",<c-g>u")
-- map("i", ".", ".<c-g>u")
-- map("i", ";", ";<c-g>u")
--
-- -- save file
-- map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
--
-- --keywordprg
-- map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })
--
-- -- better indenting
-- map("v", "<", "<gv")
-- map("v", ">", ">gv")
--
-- -- lazy
-- map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
--
-- -- new file
-- map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })
--
-- map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
-- map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })
--
-- if not Util.has("trouble.nvim") then
--   map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
--   map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })
-- end
--
-- -- stylua: ignore start
--
-- -- toggle options
-- map("n", "<leader>uf", require("lazyvim.plugins.lsp.format").toggle, { desc = "Toggle format on Save" })
-- map("n", "<leader>us", function() Util.toggle("spell") end, { desc = "Toggle Spelling" })
-- map("n", "<leader>uw", function() Util.toggle("wrap") end, { desc = "Toggle Word Wrap" })
-- map("n", "<leader>ul", function() Util.toggle_number() end, { desc = "Toggle Line Numbers" })
-- map("n", "<leader>ud", Util.toggle_diagnostics, { desc = "Toggle Diagnostics" })
-- local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
-- map("n", "<leader>uc", function() Util.toggle("conceallevel", false, {0, conceallevel}) end, { desc = "Toggle Conceal" })
-- if vim.lsp.inlay_hint then
--   map("n", "<leader>uh", function() vim.lsp.inlay_hint(0, nil) end, { desc = "Toggle Inlay Hints" })
-- end
--
-- -- lazygit
-- map("n", "<leader>gg", function() Util.float_term({ "lazygit" }, { cwd = Util.get_root(), esc_esc = false, ctrl_hjkl = false }) end, { desc = "Lazygit (root dir)" })
-- map("n", "<leader>gG", function() Util.float_term({ "lazygit" }, {esc_esc = false, ctrl_hjkl = false}) end, { desc = "Lazygit (cwd)" })
--
-- -- quit
-- map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
--
-- -- highlights under cursor
-- if vim.fn.has("nvim-0.9.0") == 1 then
--   map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
-- end
--
-- -- LazyVim Changelog
-- map("n", "<leader>L", Util.changelog, {desc = "LazyVim Changelog"})
--
-- -- floating terminal
-- local lazyterm = function() Util.float_term(nil, { cwd = Util.get_root() }) end
-- map("n", "<leader>ft", lazyterm, { desc = "Terminal (root dir)" })
-- map("n", "<leader>fT", function() Util.float_term() end, { desc = "Terminal (cwd)" })
-- map("n", "<c-/>", lazyterm, { desc = "Terminal (root dir)" })
-- map("n", "<c-_>", lazyterm, { desc = "which_key_ignore" })
--
-- -- Terminal Mappings
-- map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
-- map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
-- map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
-- map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
-- map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
-- map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
-- map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })
--
-- -- windows
-- map("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
-- map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
-- map("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
-- map("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
-- map("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
-- map("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })
--
-- -- tabs
-- map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
-- map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
-- map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
-- map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
-- map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
-- map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

opt.autowrite = true
opt.spelllang = { "ja" }
opt.splitright = false
opt.relativenumber = false
opt.wrap = true

-- Disable
vim.keymap.set({ "i", "n" }, "<esc>", "<esc>", { desc = "Escape and clear hlsearch" })
vim.keymap.set({ "i", "n" }, "<C-K>", ":call BufferList()<CR>", { desc = "BufferList", noremap = true, silent = true })
vim.keymap.set({ "i", "n" }, "<C-j>", ":AnyJump<CR>", { desc = "AnyJump", noremap = true, silent = true })
