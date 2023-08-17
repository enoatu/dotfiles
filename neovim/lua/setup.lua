local vim = vim
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
            import = "lazyvim.plugins",
        },
        { -- #A32B26 等の文字列に色をつける
            "norcalli/nvim-colorizer.lua",
            config = function()
                vim.o.termguicolors = true
                vim.o.t_Co = 256
                require("colorizer").setup()
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
            lazy = false,
            config = function()
                require("gitsigns").setup({
                    signs = {
                        add = { text = "▌+" },
                        change = { text = "▌~" },
                        delete = { text = "▌_" },
                        topdelete = { text = "▌‾" },
                        changedelete = { text = "▌~" },
                    },
                    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
                    numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
                    linehl = false, -- Toggle with `:Gitsigns toggle_linehl` coc-spell-checker とハイライトがぶつかる
                    word_diff = true, -- Toggle with `:Gitsigns toggle_word_diff`
                    -- current_line_blame = true,
                    attach_to_untracked = false,
                    on_attach = function(bufnr)
                        local gs = package.loaded.gitsigns
                        local function map(mode, l, r, opts)
                            opts = opts or {}
                            opts.buffer = bufnr
                            vim.keymap.set(mode, l, r, opts)
                        end
                        -- Navigation
                        map("n", "]c", function()
                            if vim.wo.diff then
                                return "]c"
                            end
                            vim.schedule(function()
                                gs.next_hunk()
                            end)
                            return "<Ignore>"
                        end, { expr = true, desc = "次のhunkへ移動" })
                        map("n", "[c", function()
                            if vim.wo.diff then
                                return "[c"
                            end
                            vim.schedule(function()
                                gs.prev_hunk()
                            end)
                            return "<Ignore>"
                        end, { expr = true, desc = "前のhunkへ移動" })
                        -- 設定によっては行単位でstage することもできる
                    end,
                })
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
                    },
                })
            end,
        },
        {
            "tpope/vim-fugitive", -- vimscript
            opt = {},
        },
        {
            "enoatu/vim-bufferlist", -- vimscript
            -- dir = "~/MyDevelopment/vim-bufferlist",
            init = function()
                vim.g.BufferListMaxWidth = 100
                -- require("bufferlist")
            end,
        },
        {
            "github/copilot.vim",
            enabled = vim.g.enable_plugin_copilot or false,
            build = ":lua print('need exec Copilot auth')",
            init = function()
                -- 確定キーをTABからC-lに変更
                vim.keymap.set("i", "<C-l>", 'copilot#Accept("<CR>")', {
                    noremap = true,
                    desc = "copilot 用エンター",
                    expr = true,
                    silent = true,
                    script = true,
                    replace_keycodes = false,
                })
                vim.keymap.set("i", "<C-j>", "copilot#Next()", {
                    noremap = true,
                    desc = "copilotで後の候補へ",
                    expr = true,
                    silent = true,
                    script = true,
                    replace_keycodes = false,
                })
                vim.g.copilot_no_tab_map = true
            end,
        },
        {
            "neoclide/coc.nvim",
            build = ":call coc#util#install()",
            init = function()
                -- インストール時実行
                -- call coc#util#install()
                -- coc-snippets を使用する場合は以下実行
                -- pip install pynvim
                -- 定義ジャンプ
                vim.keymap.set("n", "gd", "<Plug>(coc-definition)", { silent = true })
                -- 型定義ジャンプ
                vim.keymap.set("n", "gt", "<Plug>(coc-type-definition)", { silent = true })
                -- grep
                vim.keymap.set("n", "gr", "<Plug>(coc-references)", { silent = true })
                -- 情報表示
                function CocShowDocumentation()
                    if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
                        vim.cmd('execute "h " . expand("<cword>")')
                    elseif vim.fn["coc#rpc#ready"]() then
                        vim.fn.CocActionAsync("doHover")
                    else
                        vim.cmd('execute "!" . &keywordprg . " " . expand("<cword>")')
                    end
                end
                vim.keymap.set("n", "K", ":lua CocShowDocumentation()<CR>", { silent = true })
                -- コードアクション(全て)
                vim.keymap.set("n", "cc", "<Plug>(coc-codeaction)", { silent = true })
                -- コードアクション(特定操作)
                vim.keymap.set("x", "cd", "<Plug>(coc-codeaction-selected)", { silent = true })
                vim.keymap.set("n", "cd", "<Plug>(coc-codeaction-selected)", { silent = true })
                -- 現在の行の問題にAutoFixを適用する
                vim.keymap.set("n", "cq", "<Plug>(coc-fix-current)", { silent = true })
                -- 選択したコードをフォーマットする
                vim.keymap.set("x", "cf", "<Plug>(coc-format-selected)", { silent = true })
                vim.keymap.set("n", "cf", "<Plug>(coc-format-selected)", { silent = true })
                -- :Format all
                vim.cmd('command! -nargs=0 Format :call CocAction("format")')
                -- :ORでインポートの整理（不要なインポートの削除、並べ替えなど）
                vim.cmd('command! -nargs=0 OR :call CocActionAsync("runCommand", "editor.action.organizeImport")')
                -- すべての診断情報を表示
                vim.keymap.set("n", "dg", ":CocList diagnostics<CR>", { silent = true })
                -- [dと]dを使用して診断情報をナビゲート
                vim.keymap.set("n", "[d", "<Plug>(coc-diagnostic-prev)", { silent = true })
                vim.keymap.set("n", "]d", "<Plug>(coc-diagnostic-next)", { silent = true })
            end,
        },
        -- lazy plugins: https://www.lazyvim.org/plugins
        { -- snippet engine by lua
            "L3MON4D3/LuaSnip",
        },
        { -- snippet collection
            "rafamadriz/friendly-snippets",
        },
        { -- snippet engine by lua?
            "hrsh7th/nvim-cmp",
        },
        {
            "hrsh7th/cmp-nvim-lsp",
        },
        {
            "hrsh7th/cmp-buffer",
        },
        {
            "hrsh7th/cmp-path",
        },
        {
            "saadparwaiz1/cmp_luasnip",
        },
        -- mini.pairs
        -- mini.surround
        -- nvim-ts-context-commentstring
        -- mini.comment
        -- mini.ai
        { -- 括弧の補完
            "echasnovski/mini.pairs",
        },
        { -- 囲む
            "echasnovski/mini.surround",
            enabled = false,
        },
        { -- コメント gc
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        { -- コメント gc (行ごと)
            "echasnovski/mini.comment",
        },
        { -- ui系
            "echasnovski/mini.ai",
        },
        -- Editor
        {
            "nvim-neo-tree/neo-tree.nvim",
            enabled = false,
        },
        { -- 複数ファイル検索・置換 (<leader>c で置換)
            "nvim-pack/nvim-spectre",
            cmd = "Spectre",
            opts = { open_cmd = "noswapfile vnew" },
            keys = {
                {
                    "<leader>sr",
                    function()
                        require("spectre").open()
                    end,
                    desc = "Replace in files (Spectre)",
                },
            },
        },
        { -- fzf
            "nvim-telescope/telescope.nvim",
            keys = {
                {
                    "<leader>.",
                    "<cmd>Telescope find_files hidden=true no_ignore=true<cr>",
                    desc = "Find files noignore",
                },
            },
        },
        { -- 検索f の強化版 shogehogeで検索
            "folke/flash.nvim",
        },
        { -- flash のtelescope configtmu
            "nvim-telescope/telescope.nvim",
        },
        { -- カーソルの他の単語もハイライト
            "RRethy/vim-illuminate",
            enabled = false, -- gcc 必要かもなので
        },
        { -- buffer 削除
            "echasnovski/mini.bufremove",
        },
        { -- diagnostics list
            "folke/trouble.nvim",
        },
        { -- todo comment list [t などで移動 <leader>stで検索
            "folke/todo-comments.nvim",
        },
        -- ...
        -- LSP
        -- { import = "lazyvim.plugins.extras.ui.mini-animate" }, -- 動きが遅くなる
        {
            import = "lazyvim.plugins.extras.lang.clang",
            enabled = vim.g.enable_plugin_lsp_clang or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.cmake",
            enabled = vim.g.enable_plugin_lsp_cmake or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.docker",
            enabled = vim.g.enable_plugin_lsp_docker or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.go",
            enabled = vim.g.enable_plugin_lsp_go or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.elixir",
            enabled = vim.g.enable_plugin_lsp_elixir or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.java",
            enabled = vim.g.enable_plugin_lsp_java or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.json",
            enabled = vim.g.enable_plugin_lsp_json or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.python-semshi",
            enabled = vim.g.enable_plugin_lsp_python_semshi or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.python",
            enabled = vim.g.enable_plugin_lsp_python or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.ruby",
            enabled = vim.g.enable_plugin_lsp_ruby or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.rust",
            enabled = vim.g.enable_plugin_lsp_rust or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.tailwind",
            enabled = vim.g.enable_plugin_lsp_tailwind or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.terraform",
            enabled = vim.g.enable_plugin_lsp_terraform or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.tex",
            enabeled = vim.g.enable_plugin_lsp_tex or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.typescript",
            enabled = vim.g.enable_plugin_lsp_typescript or false,
        },
        {
            import = "lazyvim.plugins.extras.lang.yaml",
            enabled = vim.g.enable_plugin_lsp_yaml or false,
        },
        --
        { -- lspconfig
            "neovim/nvim-lspconfig",
        },
        { -- lspをjsonで管理
            "folke/neoconf.nvim",
        },
        { -- lua- language-serverを自動的に構成
            "folke/neodev.nvim",
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
        -- Need A C compiler in your path and libstdc++ installed
        {
            "nvim-treesitter/nvim-treesitter",
            opts = {
                highlight = { enable = true },
                indent = { enable = true },
                ensure_installed = {
                    "bash",
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
            },
        },
        -- lazy: UI --
        { -- notify 強化
            "rcarriga/nvim-notify",
            config = function()
                require("notify").setup({
                    render = "compact",
                    timeout = 500,
                })
            end,
        },
        { -- UI
            "stevearc/dressing.nvim",
            opts = {
                input = {
                    relative = "win", -- position center
                },
            },
        },
        { -- 上部のbufferタブ
            "akinsho/bufferline.nvim",
        },
        {
            "nvim-lualine/lualine.nvim",
            event = "VeryLazy",
            opts = function()
                local icons = require("lazyvim.config").icons
                local Util = require("lazyvim.util")

                return {
                    options = {
                        theme = "auto",
                        globalstatus = true,
                        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
                    },
                    sections = {
                        lualine_a = { "mode" },
                        lualine_b = { "branch" },
                        lualine_c = {
                            {
                                "diagnostics",
                                symbols = {
                                    error = icons.diagnostics.Error,
                                    warn = icons.diagnostics.Warn,
                                    info = icons.diagnostics.Info,
                                    hint = icons.diagnostics.Hint,
                                },
                            },
                            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                            { "filename", path = 1, symbols = { modified = " + ", readonly = "", unnamed = "" } },
                            { "buffer" },
                            -- stylua: ignore
                            {
                                function() return require("nvim-navic").get_location() end,
                                cond = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
                            },
                        },
                        lualine_x = {
                            -- stylua: ignore
                            {
                                function() return require("noice").api.status.command.get() end,
                                cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
                                color = Util.fg("Statement"),
                            },
                            -- stylua: ignore
                            {
                                function() return require("noice").api.status.mode.get() end,
                                cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
                                color = Util.fg("Constant"),
                            },
                            -- stylua: ignore
                            {
                                function() return "  " .. require("dap").status() end,
                                cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
                                color = Util.fg("Debug"),
                            },
                            {
                                require("lazy.status").updates,
                                cond = require("lazy.status").has_updates,
                                color = Util.fg("Special"),
                            },
                            {
                                "diff",
                                symbols = {
                                    added = icons.git.added,
                                    modified = icons.git.modified,
                                    removed = icons.git.removed,
                                },
                            },
                        },
                        lualine_y = {
                            { "progress", separator = " ", padding = { left = 1, right = 0 } },
                            { "location", padding = { left = 0, right = 1 } },
                        },
                        lualine_z = {
                            function()
                                return " " .. os.date("%R")
                            end,
                        },
                    },
                    extensions = { "neo-tree", "lazy" },
                }
            end,
        },
        { -- インデント可視化
            "lukas-reineke/indent-blankline.nvim",
            config = function()
                vim.opt.termguicolors = true

                vim.cmd([[highlight IndentBlanklineIndent1 guifg=#A32B26 gui=nocombine]])
                vim.cmd([[highlight IndentBlanklineIndent2 guifg=#F0B01E gui=nocombine]])
                vim.cmd([[highlight IndentBlanklineIndent3 guifg=#016669 gui=nocombine]])
                vim.cmd([[highlight IndentBlanklineIndent4 guifg=#936419 gui=nocombine]])
                vim.cmd([[highlight IndentBlanklineIndent5 guifg=#14CDE6 gui=nocombine]])
                vim.cmd([[highlight IndentBlanklineIndent6 guifg=#C678DD gui=nocombine]])
                vim.opt.list = true
                -- スペースを⋅で表示
                -- vim.opt.listchars:append "space:⋅"
                require("indent_blankline").setup({
                    space_char_blankline = " ",
                    char_highlight_list = {
                        "IndentBlanklineIndent1",
                        "IndentBlanklineIndent2",
                        "IndentBlanklineIndent3",
                        "IndentBlanklineIndent4",
                        "IndentBlanklineIndent5",
                        "IndentBlanklineIndent6",
                    },
                })
            end,
        },
        { -- アニメーションで現在のインデントを教えてくれる
            "echasnovski/mini.indentscope",
        },
        { -- キーマップを表示 (leader + sk)
            "folke/which-key.nvim",
        },
        { -- メッセージやcmdlineなどおしゃれに
            "folke/noice.nvim",
            enabled = false,
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
            enabled = false,
        },
        { -- アイコン
            "nvim-tree/nvim-web-devicons",
        },
        { -- UI ライブラリ
            "MunifTanjim/nui.nvim",
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

-- 優先
vim.keymap.set(
    "n",
    "<C-k>",
    ":call BufferList()<CR>",
    { noremap = true, silent = true, desc = "バッファリスト" }
)
vim.keymap.set("n", "<C-j>", ":AnyJump<CR>", { noremap = true })
