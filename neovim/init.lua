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
vim.o.listchars = "tab:▸▸,trail:◀,extends:>,precedes:<,nbsp:%"
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
vim.keymap.set('n', '<C-i>', ':lua SwitchIndent()<CR>', { noremap = true })
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
  -- vim.ui.selectなどを装飾する
  {
    'stevearc/dressing.nvim',
    opts = {
      input = {
        relative = "win",
      },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          changedelete = { text = '≃' },
        },
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl      = true, -- Toggle with `:Gitsigns toggle_numhl`
        linehl     = true, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff  = true, -- Toggle with `:Gitsigns toggle_word_diff`
        current_line_blame = true,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk)
          map('n', '<leader>hr', gs.reset_hunk)
          map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
          map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hR', gs.reset_buffer)
          map('n', '<leader>hp', gs.preview_hunk)
          map('n', '<leader>hb', function() gs.blame_line{full=true} end)
          map('n', '<leader>tb', gs.toggle_current_line_blame)
          map('n', '<leader>hd', gs.diffthis)
          map('n', '<leader>hD', function() gs.diffthis('~') end)
          map('n', '<leader>td', gs.toggle_deleted)

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      }
    end,
  },
  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "e",
          normal_cur = "es",
          normal_line = "yS",
          normal_cur_line = "ySS",
          visual = "S",
          visual_line = "gS",
          delete = "ds",
          change = "cs",
        }
      })
    end,
  },
  {
    "tpope/vim-fugitive", -- vimscript
    opt = {},
  },
  {
    "enoatu/vim-bufferlist", -- vimscript
    init = function()
      vim.g.BufferListMaxWidth = 100
      vim.keymap.set("n", "<C-k>", ":call BufferList()<CR>", { noremap = true })
    end,
  },
  {
    "github/copilot.vim",
    init = function()
      -- 確定キーをTABからC-lに変更
      vim.keymap.set("i", "<silent><script><expr> <C-l>", 'copilot#Accept("<CR>")')
      -- 動かなくなったら copilot log で確認する(大体 入れなおせば直る)
      vim.api.nvim_set_var("copilot_no_tab_map", "true")
    end,
  },
  {
    "neoclide/coc.nvim",
    init = function()
      -- インストール時実行
      -- call coc#util#install()
      -- coc-snippets を使用する場合は以下実行
      -- pip install pynvim
      -- 定義ジャンプ
      vim.keymap.set('n', 'gd', '<Plug>(coc-definition)', { silent = true })
      -- 型定義ジャンプ
      vim.keymap.set('n', 'gt', '<Plug>(coc-type-definition)', { silent = true })
      -- grep
      vim.keymap.set('n', 'gr', '<Plug>(coc-references)', { silent = true })
      -- 情報表示
      function coc_show_documentation()
        if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
          vim.cmd('execute "h " . expand("<cword>")')
        elseif vim.fn['coc#rpc#ready']() then
          vim.fn.CocActionAsync('doHover')
        else
          vim.cmd('execute "!" . &keywordprg . " " . expand("<cword>")')
        end
      end
      vim.keymap.set('n', 'K', ':lua coc_show_documentation()<CR>', { silent = true })
      -- コードアクション(全て)
      vim.keymap.set('n', 'cc', '<Plug>(coc-codeaction)', { silent = true })
      -- コードアクション(特定操作)
      vim.keymap.set('x', 'cd', '<Plug>(coc-codeaction-selected)', { silent = true })
      vim.keymap.set('n', 'cd', '<Plug>(coc-codeaction-selected)', { silent = true })
      -- 現在の行の問題にAutoFixを適用する
      vim.keymap.set('n', 'cq', '<Plug>(coc-fix-current)', { silent = true })
      -- 選択したコードをフォーマットする
      vim.keymap.set('x', 'cf', '<Plug>(coc-format-selected)', { silent = true })
      vim.keymap.set('n', 'cf', '<Plug>(coc-format-selected)', { silent = true })
      -- :Format all
      vim.cmd('command! -nargs=0 Format :call CocAction("format")')
      -- :ORでインポートの整理（不要なインポートの削除、並べ替えなど）
      vim.cmd('command! -nargs=0 OR :call CocActionAsync("runCommand", "editor.action.organizeImport")')
      -- すべての診断情報を表示
      vim.keymap.set('n', 'dg', ':CocList diagnostics<CR>', { silent = true })
      -- [dと]dを使用して診断情報をナビゲート
      vim.keymap.set('n', '[d', '<Plug>(coc-diagnostic-prev)', { silent = true })
      vim.keymap.set('n', ']d', '<Plug>(coc-diagnostic-next)', { silent = true })
      vim.g.coc_global_extensions = {
        'coc-tsserver',
        '@yaegassy/coc-volar',
        'coc-go',
        'coc-phpls',
        'coc-rust-analyzer',
        'coc-diagnostic',
        'coc-snippets',
        'coc-tabnine',
        '@yaegassy/coc-tailwindcss3',
        'coc-webview',
        'coc-markdown-preview-enhanced',
      }
    end,
  }
})

vim.keymap.set("n", "m", ":lua SwitchGutter()<CR>", { noremap = true })
local switchGutterBranches = {
  "<input>",
  "HEAD",
  "origin/main",
  "origin/dev",
  "origin/master",
  "origin/staging",
  "main",
  "dev",
  "master",
  "staging",
}
local isSwitchGutter = false
function SwitchGutter()
  if isSwitchGutter then
    return
  end
  isSwitchGutter = true
  vim.ui.select(switchGutterBranches, {
    prompt = "Select the branch for comparison",
   }, function(item, lnum)
    -- 手動入力
    if item == "<input>" then
      vim.notify("input", vim.log.levels.INFO)
      vim.ui.input({ prompt = 'Enter the branch for comparison: ' }, function(input)
        package.loaded.gitsigns.change_base(input)
      end)
      isSwitchGutter = false
      return
    end
    if item and lnum then
      package.loaded.gitsigns.change_base(item)
      vim.notify(string.format("selected '%s' (idx %d)", item, lnum), vim.log.levels.INFO)
    else
      vim.notify("Selection canceled", vim.log.levels.INFO)
    end
  isSwitchGutter = false
  end)
end
