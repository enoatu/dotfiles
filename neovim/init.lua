require('base')
require('switch-indent')
require('switch-gutter')
require('lazy-ready')
require("lazy").setup({
  defaults = {
    lazy = false,
    version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight" } },
  -- checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  spec = {
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins"
    },
  -- ステータスライン
    -- {
    --    "nvim-lualine/lualine.nvim",
    --    dependencies = {
    --      "nvim-tree/nvim-web-devicons"
    --    },
    --    config = function()
    --     require('lualine').setup()
    --   end,
    -- },
    -- インデント可視化(lazy 含む)
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
        -- スペースを⋅で表示
        -- vim.opt.listchars:append "space:⋅"
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
    {-- #A32B26 等の文字列に色をつける
      "norcalli/nvim-colorizer.lua",
      config = function()
        vim.o.termguicolors = true
        vim.o.t_Co = 256
        require'colorizer'.setup()
      end,
    },
    -- {
    --   "nvim-treesitter/nvim-treesitter",
    --   build = ":TSUpdate",
    --   event = { "BufReadPost", "BufNewFile" },
    --   config = function()
    --     require('nvim-treesitter.configs').setup {
    --       auto_install = true,
    --     }
    --   end,
    -- },
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
    -- {
    --   'stevearc/dressing.nvim',
    --   opts = {
    --     input = {
    --       relative = "win", -- position center
    --     },
    --     select = {
    --       builtin = {
    --         mappings = {
    --           ["<Esc>"] = "Close",
    --           ["q"] = "Close",
    --           ["<CR>"] = "Confirm",
    --         },
    --       },
    --     },
    --   },
    -- },
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
          linehl     = false, -- Toggle with `:Gitsigns toggle_linehl` coc-spell-checker とハイライトがぶつかる
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
      build = ":Copilot auth",
      init = function()
        -- 確定キーをTABからC-lに変更
        vim.keymap.set("i", "<silent><script><expr> <C-l>", 'copilot#Accept("<CR>")', { noremap = true })
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
          'coc-spell-checker',
          'coc-snippets',
          'coc-tabnine',
          '@yaegassy/coc-tailwindcss3',
          'coc-webview',
          'coc-markdown-preview-enhanced',
        }
      end,
    },
    -- lazy plugins: https://www.lazyvim.org/plugins
    -- Editor
    {
      "nvim-neo-tree/neo-tree.nvim",
      enabled = false,
    },
    -- ...
    -- LSP
    { -- lspconfig
      "neovim/nvim-lspconfig",
    },
    { -- lspをjsonで管理
      "folke/neoconf.nvim",
    },
    { -- lua- language-serverを自動的に構成
      "folke/neodev.nvim"
    },
    { -- mason lsp
      "williamboman/mason-lspconfig.nvim",
    },
    {
      "hrsh7th/cmp-nvim-lsp",
    },
    { -- formatter for lsp
      "jose-elias-alvarez/null-ls.nvim",
    },
    { -- lsp cli
      "williamboman/mason.nvim",
    },
    -- TreeSitter
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
          "bash",
          "c",
          "html",
          "javascript",
          "jsdoc",
          "json",
          "lua",
          "luadoc",
          "luap",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        -- 文法理解を利用して選択範囲を自動で見つけてくれる
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-y>",
            node_incremental = "<C-y>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      }
    },
    -- lazy: UI --
    { -- notify 強化
      "rcarriga/nvim-notify",
    },
    { -- UI
      "stevearc/dressing.nvim",
    },
    { -- 上部のbufferタブ
      "akinsho/bufferline.nvim",
    },
    {  -- インデント可視化
      "lukas-reineke/indent-blankline.nvim",
    },
    { -- アニメーションで現在のインデントを教えてくれる
      "echasnovski/mini.indentscope",
    },
    {  -- キーマップを表示
      "folke/which-key.nvim",
    },
    {  -- メッセージやcmdlineなどおしゃれに
      "folke/noice.nvim",
    },
    { -- 最初の画面
      "goolord/alpha-nvim",
      opts = function()
        local dashboard = require("alpha.themes.dashboard")
        require("alpha-custom")
        dashboard.section.header.val = vim.split(vim.g.alpha_logo, "\n")
        return dashboard
      end,
    },
    { -- lsp 関数のどこにいるかを表示:動作していなさそう
      "SmiteshP/nvim-navic",
      enabled = false
    },
    { -- アイコン
      "nvim-tree/nvim-web-devicons"
    },
    { -- UI ライブラリ
      "MunifTanjim/nui.nvim"
    },
    -- lazy: Util --
    { -- 読み込み時間を測る
      "dstein64/vim-startuptime",
    },
    { -- セッション管理
      "folke/persistence.nvim",
    },
    { -- asyncなど 他のライブラリで使う
      "plenary.nvim",
    },
  },
})
