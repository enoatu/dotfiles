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
-- nnoremap j gj
vim.keymap.set("n", "j", "gj")

-- nnoremap k gk
vim.keymap.set("n", "k", "gk")
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
vim.o.listchars = "tab:▸\\-,trail:◀,extends:>,precedes:<,nbsp:%"
-- vim.o.listchars:append "eol:↴"
-- "全角スペースをハイライト表示
-- function! ZenkakuSpace()
--     highlight ZenkakuSpace cterm=reverse ctermfg=DarkMagenta gui=reverse guifg=DarkMagenta
-- endfunction
-- if has('syntax')
--     augroup ZenkakuSpace
--         autocmd!
--         autocmd ColorScheme       * call ZenkakuSpace()
--         autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
--     augroup END
--     call ZenkakuSpace()
-- endif

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
vim.keymap.set({"n", "v"}, "<C-h>", "0")
-- "行末
vim.keymap.set({"n", "v"}, "<C-l>", "$")
vim.keymap.set("v", "<BS>", "<Del>")
vim.keymap.set("i", "<BS>", "<BS>")
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

-- cnoremap w!! w !sudo tee > /dev/null %<CR>
vim.keymap.set("c", "w!!", "w !sudo tee > /dev/null %<CR>")
-- "visualモードで選択してからのインデント調整で調整後に選択範囲を開放しない
-- vnoremap > >gv
vim.keymap.set("v", ">", ">gv")
-- vnoremap < <gv
vim.keymap.set("v", "<", "<gv")
-- "======================indent===================
-- "自動インデント
vim.o.smartindent = true
vim.o.autoindent = true
-- " Tab文字を半角スペースにする
vim.o.expandtab = true
local switchTab = 1
local switchTabMessage = "4スペ"

vim.cmd("set sw=4") -- shiftwidth
vim.cmd("set ts=4") -- tabstop
vim.keymap.set('n', '<C-o>', ':lua SwitchIndent()<CR>', { noremap = true })
function SwitchIndent()
  if switchTab == 1 then
    switchTab = 2
    vim.cmd("set expandtab")
    vim.cmd("set sw=2")
    vim.cmd("set ts=2")
    switchTabMessage = "2スペ"
  elseif switchTab == 2 then
    switchTab = 3
    vim.cmd("set noexpandtab")
    vim.cmd("set sw=4")
    vim.cmd("set ts=4")
    switchTabMessage = "タブ"
  elseif switchTab == 3 then
    switchTab = 1
    vim.cmd("set expandtab")
    vim.cmd("set sw=4")
    vim.cmd("set ts=4")
    switchTabMessage = "4スペ"
  end
  print("SwitchIndent: " .. switchTabMessage)
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- ステータスライン
  {
     "nvim-lualine/lualine.nvim",
     dependencies = {
       "nvim-tree/nvim-web-devicons"
     }
  },
  {
    "folke/tokyonight.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  {
     "github/copilot.vim",
     init = function()
       vim.keymap.set("i", "<silent><script><expr> <C-l>", 'copilot#Accept("<CR>")')
       vim.api.nvim_set_var("copilot_no_tab_map", "true")
     end,
  },
  -- インデント可視化
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      vim.opt.termguicolors = true

      vim.cmd [[highlight IndentBlanklineIndent1 guifg=#A32B26 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent2 guifg=#F0B01E gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent3 guifg=#016669 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent4 guifg=#936419 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent5 guifg=#14CDE6 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent6 guifg=#C678DD gui=nocombine]]
      vim.opt.list = true
      vim.opt.listchars:append "space:⋅"
      require("indent_blankline").setup {
        space_char_blankline = " ",
        char_highlight_list = {
            "IndentBlanklineIndent1",
            "IndentBlanklineIndent2",
            "IndentBlanklineIndent3",
            "IndentBlanklineIndent4",
            "IndentBlanklineIndent5",
            "IndentBlanklineIndent6",
        },
      }
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require'colorizer'.setup()
    end,
  },
  {
    "pechorin/any-jump.vim",
    init = function()
      vim.g.any_jump_window_width_ratio = 0.9
      vim.g.any_jump_window_height_ratio = 0.9
      vim.g.any_jump_max_search_results = 20
      -- Normal mode: Jump to definition under cursor
      vim.keymap.set("n", "<C-j>", ":AnyJump<CR>", { noremap = true })
      -- Visual mode: jump to selected text in visual mode
      vim.keymap.set("v", "<C-j>", ":AnyJumpVisual<CR>", { noremap = true })
      -- Normal mode: open previous opened file (after jump)
      vim.keymap.set("n", "<C-b>", ":AnyJumpBack<CR>")
     -- Normal mode: open last closed search window again
      vim.keymap.set("n", "<C-al>", ":AnyJumpLastResults<CR>")
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup()
    end,
  }
})


-- " 確定キーをTABからC-lに変更
-- copilot for nvim
-- lazyで動かない
-- 動かなくなったら copilot log で確認する(大体 入れなおせば直る)

-- #テーマ
-- #addじゃないと動かない
-- [[plugins]]
-- repo = 'rakr/vim-one'
-- hook_add = '''
-- filetype plugin indent on
-- 
-- syntax enable
-- colorscheme one
-- 
-- " tmux
-- set t_8b=[48;2;%lu;%lu;%lum
-- set t_8f=[38;2;%lu;%lu;%lum
-- 
-- let g:airline_theme = 'one'
-- " powerline enable(最初に設定しないとダメ)
-- let g:airline_powerline_fonts = 1
-- " タブバーをかっこよく
-- let g:airline#extensions#tabline#enabled = 1
-- " 選択行列の表示をカスタム(デフォルトだと長くて横幅を圧迫するので最小限に)
-- let g:airline_section_z = airline#section#create(['windowswap', '%3p%% ', 'linenr', ':%3v'])
-- " gitのHEADから変更した行の+-を非表示(vim-gitgutterの拡張)
-- let g:airline#extensions#hunks#enabled = 0
-- '''
-- 
-- # インデント表示
-- [[plugins]]
-- repo = 'Yggdroot/indentLine'
-- hook_add = '''
-- autocmd BufNewFile,BufRead,BufEnter * :let g:indentLine_setConceal = (&ft=='json' ? 0 : 1)
-- '''
-- #
-- 
-- # 括弧に別々の色を付ける
-- [[plugins]]
-- repo = 'luochen1990/rainbow'
-- hook_add = '''
--     let g:rainbow_active = 1
-- '''
-- 
-- # rgb
-- [[plugins]]
-- repo = 'lilydjwg/colorizer'
-- 
-- #:Gdiffと打つとHEADと現在の状態を比較できる
-- #:Glog = git log
-- #:Gdiff コミット番号でそのdiffをとれる
-- #:Gread HEAD^^:%
-- #:Gblameでコミット詳細みれる
-- #:Gstatus = git status
-- #:Gwrite [path]
-- #:Gcommit
-- #:Gdiff [fugitive-revision]
-- #:Gedit [fugitive-revision]
-- #:Gmove [destination]
-- #:Gremove
-- #:Glog [args]
-- #:Gpush [args]
-- #:Gfetch [args]
-- #:Gmerge [args]
-- #:Gpull [args]
-- [[plugins]]
-- repo = 'tpope/vim-fugitive'
-- # github/gitlab token必要なので考える
-- #[[plugins]]
-- #repo = 'tpope/vim-rhubarb'
-- [[plugins]]
-- repo = 'shumphrey/fugitive-gitlab.vim'
-- 
-- # bufferlist(lazyではできない)
-- [[plugins]]
-- #repo = '~/MyDevelopment/vim-bufferlist'
-- repo = 'enoatu/vim-bufferlist'
-- hook_add = '''
-- let g:BufferListMaxWidth = 100
-- map <C-k> :call BufferList()<CR>
-- '''
-- 
-- #gitで管理してる場合、左側に差分を表示
-- [[plugins]]
-- repo = 'airblade/vim-gitgutter'
-- hook_add = '''
-- "画面をガタガタ言わせない
-- set signcolumn=yes
-- 
-- "タイピング終了後すぐに反映する
-- set updatetime=200
-- 
-- "master
-- let s:switchGutter=1
-- noremap m :call SwitchGutter()<CR>
-- function! SwitchGutter()
--     if (s:switchGutter == 1)
--         let g:gitgutter_diff_base = 'origin/main'
--         let s:switchGutter=2
--         echo "switchGutter: origin/main"
--     elseif (s:switchGutter == 2)
--         let g:gitgutter_diff_base = 'origin/dev'
--         let s:switchGutter=3
--         echo "switchGutter: origin/dev"
--     elseif (s:switchGutter == 3)
--         echo "switchGutter: デフォルト"
--         let s:switchGutter=4
--         let g:gitgutter_diff_base = ''
--     elseif (s:switchGutter == 4)
--         echo "switchGutter: origin/master"
--         let s:switchGutter=5
--         let g:gitgutter_diff_base = 'origin/master'
--     elseif (s:switchGutter == 5)
--         echo "switchGutter: origin/staging"
--         let s:switchGutter=1
--         let g:gitgutter_diff_base = 'origin/staging'
--     endif
--     :GitGutterAll
-- endfunction
-- '''
-- 
-- ###################################lazy#############################
-- 
-- # easy align
-- [[plugins]]
-- repo = 'junegunn/vim-easy-align'
-- lazy = true
-- hook_add = '''
-- xmap ga <Plug>(EasyAlign)
-- nmap ga <Plug>(EasyAlign)
-- '''
-- 
-- # インデントの位置を直す
-- [[plugins]]
-- repo = "pangloss/vim-javascript"
-- lazy = true
-- 
-- # fで検索後移動できるようにする
-- [[plugins]]
-- repo = 'rhysd/clever-f.vim'
-- lazy = true
-- 
-- # 定義ジャンプ
-- [[plugins]]
-- repo = 'pechorin/any-jump.vim'
-- lazy = true
-- hook_add = '''
-- let g:any_jump_window_width_ratio  = 0.9
-- let g:any_jump_window_height_ratio = 0.9
-- let g:any_jump_max_search_results = 20
-- " Normal mode: Jump to definition under cursor
-- nnoremap <C-j> :AnyJump<CR>
-- 
-- " Visual mode: jump to selected text in visual mode
-- xnoremap <C-j> :AnyJumpVisual<CR>
-- 
-- " Normal mode: open previous opened file (after jump)
-- nnoremap <C-b> :AnyJumpBack<CR>
-- 
-- " Normal mode: open last closed search window again
-- "nnoremap <C-al> :AnyJumpLastResults<CR>
-- '''

