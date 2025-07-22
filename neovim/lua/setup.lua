local vim = vim
local node_path = "~/.local/share/mise/installs/node/18.16.0/bin/node"
vim.opt.termguicolors = true
-- leader はスペース
vim.g.mapleader = " "

local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
        return false
    end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

require("lazy").setup({
    defaults = {
        lazy = false,
        version = "*", -- try installing the latest stable version for plugins that support semver
    },
    -- checker = { enabled = true }, -- automatically check for plugin updates
    performance = {
        rtp = {
            -- disable some rtp plugins
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen", -- 対応するカッコハイライト
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
    spec = {
        {
            "folke/tokyonight.nvim",
            lazy = false,
            priority = 1000,
            opts = {},
            config = function()
                vim.cmd('colorscheme tokyonight-moon')
            end
        },
        { -- #A32B26 等の文字列に色をつける
            "norcalli/nvim-colorizer.lua",
            config = function()
                require("colorizer").setup()
            end,
        },
        {
            "lewis6991/gitsigns.nvim",
            -- :help ibl.config.scope とすると | などの一覧が表示される
            config = function()
                vim.api.nvim_set_hl(0, "GitSignsAddInline", { bg = "#033386" })
                vim.api.nvim_set_hl(0, "GitSignsChangeInline", { bg = "#013369" })
                vim.api.nvim_set_hl(0, "GitSignsDeleteInline", { bg = "#802B26" })

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
                    --  word_diff = true, -- Toggle with `:Gitsigns toggle_word_diff`
                    -- current_line_blame = true,
                    attach_to_untracked = false,
                    on_attach = function(bufnr)
                        local gitsigns = package.loaded.gitsigns
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
                                gitsigns.next_hunk()
                            end)
                            return "<Ignore>"
                        end, { expr = true, desc = "次のhunkへ移動" })
                        map("n", "[c", function()
                            if vim.wo.diff then
                                return "[c"
                            end
                            vim.schedule(function()
                                gitsigns.prev_hunk()
                            end)
                            return "<Ignore>"
                        end, { expr = true, desc = "前のhunkへ移動" })
                        -- 設定によっては行単位でstage することもできる
                        -- Actions
                        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Stage hunk" })
                        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Reset hunk" })

                        map('v', '<leader>hs', function()
                          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                        end, { desc = "Stage hunk" })

                        map('v', '<leader>hr', function()
                          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                        end, { desc = "Reset hunk" })

                        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Stage buffer" })
                        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Reset buffer" })
                        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Preview hunk" })
                        map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })

                        map('n', '<leader>hb', function()
                          gitsigns.blame_line({ full = true })
                        end, { desc = "Blame line" })

                        map('n', '<leader>hd', gitsigns.diffthis, { desc = "Diff this" })

                        map('n', '<leader>hD', function()
                          gitsigns.diffthis('~')
                        end, { desc = "Diff this ~" })

                        map('n', '<leader>hQ', function() gitsigns.setqflist('all') end, { desc = "Set qflist" })
                        map('n', '<leader>hq', gitsigns.setqflist, { desc = "Set qflist" })

                        -- Toggles
                        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = "Toggle blame" })
                        map('n', '<leader>td', gitsigns.toggle_deleted, { desc = "Toggle deleted" })
                        map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = "Toggle word diff" })

                        -- Text object
                        map({'o', 'x'}, 'ih', gitsigns.select_hunk, { desc = "Select hunk" })
                    end,
                })
                -- require("scrollbar.handlers.gitsigns").setup()
                -- vim.api.nvim_create_autocmd("FileType", {
                --     pattern = "python",
                --     callback = function()
                --         vim.b.coc_root_patterns = { ".env" }
                --     end,
                -- })
            end,
        },
        { -- quickfix を見やすくする :grep hogehoge . | copen
            "kevinhwang91/nvim-bqf",
            ft = "qf",
            dependencies = {
                {
                    "junegunn/fzf",
                    run = function()
                        vim.fn["fzf#install"]()
                    end,
                }
            },
            init = function()
                vim.api.nvim_create_user_command("Qf", function(opts)
                    vim.cmd("silent!rg --vimgrep " .. opts.args)
                    vim.cmd("copen")
                end, { nargs = "*" })
            end,
        },
        {
            -- スネークケースとか変える
            "johmsalas/text-case.nvim",
            enabled = false,
            dependencies = { "nvim-telescope/telescope.nvim" },
            config = function()
                require("textcase").setup({})
                require("telescope").load_extension("textcase")
            end,
            keys = {
                "gr", -- Default invocation prefix
                { "gr.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
            },
            cmd = {
                -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
                "Subs",
                "TextCaseOpenTelescope",
                "TextCaseOpenTelescopeQuickChange",
                "TextCaseOpenTelescopeLSPChange",
                "TextCaseStartReplacingCommand",
            },
            -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
            -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
            -- available after the first executing of it or after a keymap of text-case.nvim has been used.
            lazy = false,
        },
        {
            "enoatu/backseat.nvim",
            config = function()
                require("backseat").setup({
                    -- openai_api_key = '', -- Get yours from platform.openai.com/account/api-keys
                    -- openai_api_endpoint = 'http://localhost:8080',
                    -- openai_model_id = 'gpt-4', --gpt-4 (If you do not have access to a model, it says "The model does not exist")
                    openai_model_id = "gpt-3.5-turbo", --gpt-4 (If you do not have access to a model, it says "The model does not exist")
                    language = "japanese", -- Such as 'japanese', 'french', 'pirate', 'LOLCAT'
                    -- -- split_threshold = 100,
                    -- additional_instruction = "Respond snarkily", -- (GPT-3 will probably deny this request, but GPT-4 complies)
                    highlight = {
                        icon = "", -- ''
                        group = "Underlined", -- デフォルトのhighlight group一覧:
                    },
                })
            end,
            enabled = false,
        },
        {
            "enoatu/buffer-scope.nvim",
            enabled = true,
            dir = "~/MyDevelopment/buffer-scope.nvim",
            dependencies = { "nvim-telescope/telescope.nvim" },
            config = function()
                require("buffer-scope").setup({
                    telescope = {
                        buffers = {
                            mappings = {
                                i = {
                                    ["<C-k>"] = "close",  -- インサートモードでC-kで閉じる
                                },
                                n = {
                                    ["<C-k>"] = "close",  -- ノーマルモードでC-kで閉じる
                                },
                            },
                        },
                    },
                })
                require("telescope").load_extension("buffer_scope")
                vim.api.nvim_set_keymap(
                    "n",
                    "<C-k>",
                    "<cmd>Telescope buffer_scope buffers<cr>",
                    { noremap = true, silent = true, desc = "Buffer Scope" }
                )
            end,
        },
        { -- 囲む
            "kylechui/nvim-surround",
            config = function()
                require("nvim-surround").setup({
                    keymaps = {
                        insert = "<C-g>s",
                        insert_line = "<C-g>S",
                        normal = "e", -- ee" で囲む
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
            config = function()
                vim.keymap.set("n", "<Leader>d", ":Gdiff<CR>:windo set wrap<CR>")
                vim.keymap.set("n", "dp", ":diffput<CR>")
            end,
        },
        { -- バッファ管理
            "enoatu/vim-bufferlist", -- vimscript
            -- dir = "~/MyDevelopment/vim-bufferlist",
            lazy = false,
            init = function()
                vim.g.BufferListMaxWidth = 100
            end,
        },
        { -- align
            "Vonr/align.nvim",
            init = function()
                vim.keymap.set({ "n", "v", }, 'ga',
                    function()
                        local a = require('align')
                        a.operator(a.align_to_char)
                    end,
                    { noremap = true, desc = "Align to char" }
                )
            end,
        },
        {
            "yetone/avante.nvim",
	    enabled = false,
            event = "VeryLazy",
            lazy = false,
            version = false, -- Never set this value to "*"! Never!
            opts = {
                -- add any opts here
                -- for example
                -- provider = "copilot",
                provider="claude",
            },
            claude = {
                endpoint = "https://api.anthropic.com",
                model = "claude-sonnet-4-20250514",
                disable_tools = true,
                temperature = 0,
                max_tokens = 8192,
            },
            dual_boost = {
                enabled = true,
                first_provider = "copilot",
                second_provider = "claude",
                prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
                timeout = 60000, -- Timeout in milliseconds
            },
            behaviour = {
                auto_suggestions = true, -- Experimental stage
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                auto_apply_diff_after_generation = true,
                support_paste_from_clipboard = false,
                minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
                enable_token_counting = true, -- Whether to enable token counting. Default to true.
            },
            init = function()
                vim.opt.laststatus = 3
            end,
            -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
            build = "make",
            -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
            dependencies = {
                "nvim-treesitter/nvim-treesitter",
                "stevearc/dressing.nvim",
                "nvim-lua/plenary.nvim",
                "MunifTanjim/nui.nvim",
                --- The below dependencies are optional,
                "echasnovski/mini.pick", -- for file_selector provider mini.pick
                "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
                "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
                "ibhagwan/fzf-lua", -- for file_selector provider fzf
                "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
                "zbirenbaum/copilot.lua", -- for providers='copilot'
                {
                    -- support for image pasting
                    "HakonHarnes/img-clip.nvim",
                    event = "VeryLazy",
                    opts = {
                        -- recommended settings
                        default = {
                            embed_image_as_base64 = false,
                            prompt_for_file_name = false,
                            drag_and_drop = {
                                insert_mode = true,
                            },
                            -- required for Windows users
                            use_absolute_path = true,
                        },
                    },
                },
                {
                    -- Make sure to set this up properly if you have lazy=true
                    'MeanderingProgrammer/render-markdown.nvim',
                    opts = {
                        file_types = { "markdown", "Avante" },
                    },
                    ft = { "markdown", "Avante" },
                },
            },
        },
        { -- コメント の補完
            "CopilotC-Nvim/CopilotChat.nvim",
            config = function()
                require("CopilotChat").setup({
                    window = {
                        layout = "float",
                        relative = "cursor",
                        width = 1,
                        height = 0.8,
                        row = 1,
                    },
                    completeopt = {
                        "noinsert",
                        "noselect",
                    },
                    prompts = {
                        Explain = {
                            prompt = "/COPILOT_EXPLAIN 上記のコードをわかりやすく日本語で説明してください",
                            mapping = "<leader>ce",
                            description = "AIにコードの説明をお願いする",
                        },
                        Review = {
                            prompt = "/COPILOT_REVIEW 選択したコードをレビューしてください。レビューコメントは猫になりきって日本語でお願いします。",
                            mapping = "<leader>cr",
                            description = "AIにコードのレビューをお願いする",
                        },
                        Fix = {
                            prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードを表示してください。",
                            mapping = "<leader>cf",
                            description = "AIにコードの修正をお願いする",
                        },
                        Optimize = {
                            prompt = "/COPILOT_REFACTOR 選択したコードを最適化し、パフォーマンスと可読性を向上させてください。",
                            mapping = "<leader>co",
                            description = "AIにコードの最適化をお願いする",
                        },
                        Docs = {
                            prompt = "/COPILOT_GENERATE 選択したコードに関するドキュメントコメントを日本語で生成してください。",
                            mapping = "<leader>cd",
                            description = "AIにコードのドキュメント作りをお願いする",
                        },
                        Tests = {
                            prompt = "/COPILOT_TESTS 選択したコードの詳細なユニットテストを書いてください。",
                            mapping = "<leader>ct",
                            description = "AIにコードのテストコード作成をお願いする",
                        },
                        FixDiagnostic = {
                            prompt = "コードの診断結果に従って問題を修正してください。",
                            mapping = "<leader>cd",
                            description = "AIにコードの静的解析結果に基づいた修正をお願いする",
                            selection = require("CopilotChat.select").diagnostics,
                        },
                        Commit = {
                            prompt = "コメントのルールに従って変更に対するコミットメッセージを日本語で記述してください。",
                            mapping = "<leader>cc",
                            description = "AIにコミットメッセージの作成をお願いする",
                            selection = require("CopilotChat.select").buffer,
                        },
                        CommitStaged = {
                            prompt = "commitize の規則に従って、ステージ済みの変更に対するコミットメッセージを記述してください。 タイトルは最大50文字で、メッセージは72文字で折り返されるようにしてください。 メッセージ全体を gitcommit 言語のコード ブロックでラップしてください。メッセージは日本語でお願いします。",
                            mapping = "<leader>cs",
                            description = "AIにステージ済みのコミットメッセージの作成をお願いする",
                            selection = function(source)
                                return require("CopilotChat.select").gitdiff(source, true)
                            end,
                        },
                    },
                })
                -- git commit -v で開いた内容をもとにコミットメッセージを生成するコマンドを作成する
                chat = require("CopilotChat")
                vim.api.nvim_create_user_command("CopilotCommit", function()
                    chat.ask(
                        "コメントのメッセージルールに従い、変更に対するコミットメッセージを本文含めて日本語で記述してください。1ファイルだけの変更なら「xxxx.php に対して~」のような形式で。形式は体現止めでお願いします。出力は結果だけでお願いします",
                        {
                            selection = require("CopilotChat.select").buffer,
                            window = {
                                layout = "float",
                                relative = "cursor",
                                width = 1,
                                height = 0.8,
                                row = 1,
                            },
                            show_help = false,
                            auto_follow_cursor = true,
                            callback = function(response)
                                vim.schedule(function()
                                    -- 改行含むresponseをコードに挿入する
                                    response = response:gsub("```", "")
                                    -- 前後の改行を削除する
                                    response = response.gsub(response, "^\n*", "")
                                    response = response.gsub(response, "\n*$", "")
                                    -- レジスタに格納する
                                    vim.fn.setreg('"', response)
                                    -- windowを閉じる
                                    vim.cmd('normal q')
                                    vim.cmd('normal o')
                                    vim.cmd('normal! ""p')
                                end)
                            end,
                        }
                    )
                end, {})
                vim.api.nvim_create_user_command("CopilotChatInline", function(args)
                    chat.ask(args.args, {
                        selection = require("CopilotChat.select").visual,
                        window = {
                            layout = "float",
                            relative = "cursor",
                            width = 1,
                            height = 0.4,
                            row = 1,
                        },
                    })
                end, { nargs = "*", range = true })
                -- shortcut Explain
                vim.api.nvim_set_keymap(
                    "n",
                    "ee",
                    ":CopilotChatExplain<CR>",
                    { noremap = true, silent = true, desc = "AIにコードの説明をお願いする" }
                )
                vim.api.nvim_set_keymap(
                    "v",
                    "ee",
                    ":CopilotChatExplain<CR>",
                    { noremap = true, silent = true, desc = "AIにコードの説明をお願いする" }
                )
            end,
        },
        {
            "github/copilot.vim",
            build = ":lua print('need exec Copilot auth')",
            init = function()
                vim.g.copilot_node_command = node_path
                vim.g.copilot_filetypes = { markdown = true, gitcommit = true, yaml = true }
                -- 確定キーをTABからC-lに変更
                vim.g.copilot_no_tab_map = true
                -- マッピングを自動で設定
                vim.g.copilot_assume_mapped = false
                -- 確定キーをTABからC-lに変更
                vim.keymap.set("i", "<C-l>", 'copilot#Accept("<CR>")', {
                    noremap = true,
                    desc = "copilot 用エンター",
                    expr = true,
                    silent = true,
                    script = true,
                    replace_keycodes = false,
                    remap = true,
                })
            end,
        },
        {
            "neoclide/coc.nvim",
            -- 最新版だとcoc-tsserverが動かない
            commit = "fab97c7db68f24e5cc3c1cf753d3bd1819beef8f",
            build = "yarn install --frozen-lockfile",
            lazy = false,
            init = function()
                -- vim.g.coc_node_path = node_path
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
                -- :Format
                vim.api.nvim_create_user_command("Format", "call CocAction('format')", { nargs = 0 })
                -- :FormatImportでインポートの整理（不要なインポートの削除、並べ替えなど）
                vim.api.nvim_create_user_command(
                    "FormatImport",
                    "call CocActionAsync('runCommand', 'editor.action.organizeImport')",
                    { nargs = 0 }
                )
                -- すべての診断情報を表示
                vim.keymap.set("n", "dg", ":CocList diagnostics<CR>", { silent = true })
                -- [dと]dを使用して診断情報をナビゲート
                vim.keymap.set("n", "[d", "<Plug>(coc-diagnostic-prev)", { silent = true })
                vim.keymap.set("n", "]d", "<Plug>(coc-diagnostic-next)", { silent = true })

                -- pythonなど、見えにくいので調整
                vim.api.nvim_set_hl(0, "CocInlayHint", { fg = "lightgray", bg = "darkcyan" })
                vim.api.nvim_set_hl(0, "CocInlayHintType", { fg = "lightgray", bg = "darkcyan" })
                vim.api.nvim_set_hl(0, "CocInlayHintParameter", { fg = "lightgray", bg = "darkcyan" })
            end,
        },
        { -- fzf
            "nvim-telescope/telescope.nvim",
            dependencies = {
                "nvim-telescope/telescope-live-grep-args.nvim",
                version = "^1.0.0",
                "nvim-lua/plenary.nvim",
            },
            keys = {
                {
                    "<leader><leader>",
                    "<cmd>Telescope find_files hidden=true no_ignore=true<cr>",
                    desc = "Find files noignore",
                },
                {
                    "<C-j>",
                    function()
                        require("telescope-live-grep-args.shortcuts").grep_word_under_cursor()
                    end,
                    mode = "n",
                    desc = "Grep word under cursor",
                },
                {
                    "<C-j>",
                    function()
                        require("telescope-live-grep-args.shortcuts").grep_visual_selection()
                    end,
                    mode = "v",
                    desc = "Grep visual selection",
                },
            },
            config = function()
                local telescope = require("telescope")
                local actions = require("telescope.actions")
                telescope.setup({
                    pickers = {
                        buffers = {
                            mappings = {
                                n = {
                                    ["<C-d>"] = "delete_buffer",
                                    ["<C-K>"] = actions.close,
                                },
                                i = {
                                    ["<C-K>"] = actions.close,
                                },
                            },
                        },
                    },
                })
                telescope.load_extension("live_grep_args")
                local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
                vim.keymap.set(
                    "n",
                    "<C-j>",
                    live_grep_args_shortcuts.grep_word_under_cursor,
                    { noremap = true, silent = true }
                )
                vim.keymap.set(
                    "v",
                    "<C-j>",
                    live_grep_args_shortcuts.grep_visual_selection,
                    { noremap = true, silent = true }
                )
            end,
        },
        {
            "lambdalisue/vim-suda",
        },
        { -- ファイルエクスプローラー
            "stevearc/oil.nvim",
            config = function()
                require("oil").setup({
                    view_options = {
                        show_hidden = true,
                    },
                })
                -- n で親ディレクトリを開く
                vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
                -- oil fix relative path
                vim.api.nvim_create_augroup("OilRelPathFix", {})
                vim.api.nvim_create_autocmd("BufLeave", {
                    group = "OilRelPathFix",
                    pattern = "oil:///*",
                    callback = function()
                        vim.cmd("cd .")
                    end,
                })
            end,
        },
        { -- ダイヤルを回すように値を変更
            "monaqa/dial.nvim",
            keys = {
                { "<C-a>", "<Plug>(dial-increment)", mode = { "n", "v" } },
                { "<C-x>", "<Plug>(dial-decrement)", mode = { "n", "v" } },
                { "g<C-a>", "g<Plug>(dial-increment)", mode = { "n", "v" }, remap = true },
                { "g<C-x>", "g<Plug>(dial-decrement)", mode = { "n", "v" }, remap = true },
            },
            config = function()
                local augend = require("dial.augend")
                require("dial.config").augends:register_group({
                    default = {
                        augend.integer.alias.decimal,
                        augend.constant.new({ elements = { "let", "const" } }),
                        augend.constant.new({ elements = { "var", "const", "let" } }),
                        augend.constant.new({ elements = { "true", "false" } }),
                        augend.constant.new({ elements = { "True", "False" } }),
                    },
                })
            end,
        },
        {
            "folke/trouble.nvim",
            opts = {}, -- for default options, refer to the configuration section for custom setup.
            cmd = "Trouble",
            keys = {
                {
                    "<leader>xx",
                    "<cmd>Trouble diagnostics toggle<cr>",
                    desc = "Diagnostics (Trouble)",
                },
                {
                    "<leader>xX",
                    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                    desc = "Buffer Diagnostics (Trouble)",
                },
                {
                    "<leader>cs",
                    "<cmd>Trouble symbols toggle focus=false<cr>",
                    desc = "Symbols (Trouble)",
                },
                {
                    "<leader>cl",
                    "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                    desc = "LSP Definitions / references / ... (Trouble)",
                },
                {
                    "<leader>xL",
                    "<cmd>Trouble loclist toggle<cr>",
                    desc = "Location List (Trouble)",
                },
                {
                    "<leader>xQ",
                    "<cmd>Trouble qflist toggle<cr>",
                    desc = "Quickfix List (Trouble)",
                },
            },
        },
        -- TreeSitter
        -- Need A C compiler in your path and libstdc++ installed
        {
            "nvim-treesitter/nvim-treesitter",
            config = function()
                -- @キーでTreesitterの賢い選択
                vim.keymap.set('n', '@', '<cmd>lua require("nvim-treesitter.incremental_selection").init_selection()<cr>')
                vim.keymap.set('x', '@', '<cmd>lua require("nvim-treesitter.incremental_selection").scope_incremental()<cr>')
                -- vim.g.matchup_matchparen_enabled = 1
                -- vim.g.matchup_matchparen_offscreen = { method = 'popup' } -- カーソル外のタグも表示
                -- vim.api.nvim_create_autocmd("BufReadPost", {
                --     callback = function()
                --         vim.defer_fn(function()
                --             print("Enable treesitter highlight")
                --             vim.cmd("TSEnable highlight")
                --         end, 1000)
                --     end,
                -- })
                --
            end,
            -- lazy = true, -- filetype が後から設定される時があるため場合は遅延読み込み
            -- lazy = false, -- lazyはfalseでないと動作しないけど...
            lazy = false,
            opts = {
                highlight = {
                    enable = true,
                    disable = function(lang, buf)
                        if lang == "htmldjango" then
                            -- return true
                        end
                        -- 1000 KB 超えのファイルでは tree-sitter によるシンタックスハイライトを行わない
                        local max_filesize = 1000 * 1024
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            print("File too large, disabling treesitter highlight for " .. lang)
                            return true
                        end
                    end,
                    -- additional_vim_regex_highlighting = false,
                },
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
                    "php",
                    "htmldjango",
                    "python",
                    "query",
                    "regex",
                    "vue",
                    "tsx",
                    "typescript",
                    "vim",
                    "vimdoc",
                    "yaml",
                },
                auto_install = true, -- 上記にないものは自動でインストール
                -- 文法理解を利用して選択範囲を自動で見つけてくれる
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = '@',
                        scope_incremental = '@',
                        node_incremental = '<TAB>',
                        node_decremental = '<S-TAB>',
                    },
                },
            },
        },
        { -- 画面上部に現在のインデントを表示
            "nvim-treesitter/nvim-treesitter-context",
            enabled = true, -- 移動しているとneovimが落ちる?
            config = function()
                require("treesitter-context").setup({
                    enable = true, -- 有効化
                    max_lines = 8, -- 画面上に表示する行数の制限 構文解析できない場合を考えて指定しておく
                    mode = "topline", -- カーソルではない
                    patterns = {
                        default = {
                            "class",
                            "function",
                            "method",
                        },
                    },
                })
            end,
        },
        { -- オブジェクトなど整形ツール C-o でトグル
            "Wansmer/treesj",
            keys = {
                { "<C-o>", "<CMD>TSJToggle<CR>", desc = "Toggle Inline/Block" },
            },
            opts = {
                use_default_keymaps = false,
            },
            dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
            config = function()
                require("treesj").setup()
            end,
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
        {
            "folke/snacks.nvim", -- lualine で使用
            opts = {
                scroll = { enabled = false },
            },
        },
        { -- 上部のbufferタブ
            "akinsho/bufferline.nvim",
            config = function()
                local bufferline = require('bufferline')
                bufferline.setup({
                    options = {
                        style_preset = bufferline.style_preset.no_italic,
                        -- or you can combine these e.g.
                        style_preset = {
                            bufferline.style_preset.no_italic,
                            bufferline.style_preset.no_bold
                        },
                        groups = {
                            items = {
                                require('bufferline.groups').builtin.pinned:with({ icon = "󰐃 " })
                            }
                        },
                        separator_style = "padded_slant"


                    }
                })
                vim.keymap.set("n", "L", ":BufferLineCycleNext<CR>", { silent = true, noremap = true, desc = "次のバッファ" })
                vim.keymap.set("n", "H", ":BufferLineCyclePrev<CR>", { silent = true, noremap = true, desc = "前のバッファ" })
            end,
        },
        { -- ステータスライン
            "nvim-lualine/lualine.nvim",
            event = "VeryLazy",
            options = {
                theme = 'tokyonight'
            },
            opts = function()
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
                                    error = "✗",
                                    warn = "⚠",
                                    info = "ℹ",
                                    hint = "➤",
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
                                color = { fg = Snacks.util.color("Statement") },
                            },
                            -- stylua: ignore
                            {
                                function() return require("noice").api.status.mode.get() end,
                                cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
                                color = { fg = Snacks.util.color("Constant") },
                            },
                            -- stylua: ignore
                            {
                                function() return "  " .. require("dap").status() end,
                                cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
                                color = { fg = Snacks.util.color("Debug") },
                            },
                            "copilot",
                            {
                                require("lazy.status").updates,
                                cond = require("lazy.status").has_updates,
                                color = { fg = Snacks.util.color("Special") },
                            },
                            {
                                "diff",
                                symbols = {
                                    added = "➕ ",
                                    modified = "✏ ",
                                    removed = "✗ ",
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
        { -- インデント可視化、チャンク表示
            "shellRaining/hlchunk.nvim",
            event = { "BufReadPre", "BufNewFile" },
            enabled = false,
            config = function()
                require("hlchunk").setup({
                    chunk = {
                        enable = true,
                        style = {
                            { fg = "#FFFFFF" },
                        },
                        use_treesitter = true,
                        chars = {
                            horizontal_line = "─",
                            vertical_line = "│",
                            left_top = "╭",
                            left_bottom = "╰",
                            right_arrow = ">",
                        },
                        textobject = "",
                        max_file_size = 1024 * 1024,
                        error_sign = true,
                        duration = 0,
                        delay = 0,
                    },
                    indent = {
                        enable = true,
                        chars = {
                            "│",
                        },
                        style = {
                            "#A32B26",
                            "#F0B01E",
                            "#016669",
                            "#936419",
                            "#14CDE6",
                            "#C678DD",
                        },
                    }
                })
            end,
        },
        { -- インデント可視化
            "lukas-reineke/indent-blankline.nvim",
            main = "ibl",
            config = function()
                local highlight = {
                    "RainbowRed",
                    "RainbowYellow",
                    "RainbowBlue",
                    "RainbowOrange",
                    "RainbowGreen",
                    "RainbowViolet",
                }
                local hooks = require("ibl.hooks")
                hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#A32B26" })
                    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#F0B01E" })
                    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#016669" })
                    vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#936419" })
                    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#14CDE6" })
                    vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
                end)
                require("ibl").setup({
                    indent = { highlight = highlight },
                    scope = {
                        enabled = false, -- 逆L字のインデントを非表示
                    },
                })
            end,
        },
        { -- キーマップを表示 (leader + sk)
            "folke/which-key.nvim",
        },
        { -- メッセージやcmdlineなどおしゃれに、lualine でも使用
            "folke/noice.nvim",
            event = "VeryLazy",
            dependencies = {
                -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
                "MunifTanjim/nui.nvim",
                -- OPTIONAL:
                --   `nvim-notify` is only needed, if you want to use the notification view.
                --   If not available, we use `mini` as the fallback
                "rcarriga/nvim-notify",
            },
            config = function()
                require("noice").setup({
                  lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                    override = {
                      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                      ["vim.lsp.util.stylize_markdown"] = true,
                    },
                  },
                  -- you can enable a preset for easier configuration
                  presets = {
                    bottom_search = true, -- use a classic bottom cmdline for search
                    command_palette = true, -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = false, -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = false, -- add a border to hover docs and signature help
                  },
                })
            end
        },
        { -- 最初の画面
            "nvimdev/dashboard-nvim",
            opts = function()
                require("alpha-custom")
                return {
                    config = {
                        header = vim.split(vim.g.alpha_logo, "\n"),
                    },
                }
            end,
        },
    },
})
