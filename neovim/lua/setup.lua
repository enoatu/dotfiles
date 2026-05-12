-- よく使うショートカット
-- C-o で前のカーソル位置に戻る
-- C-i で次のカーソル位置に進む


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
        { -- カラースキーム
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
        { -- カーソル下の単語を他の出現箇所でもハイライト
            "RRethy/vim-illuminate",
            event = { "BufReadPost", "BufNewFile" },
            config = function()
                require("illuminate").configure({
                    providers = { "lsp", "treesitter", "regex" },
                    delay = 100,
                    filetypes_denylist = { "dashboard", "alpha", "oil" },
                })
                -- ]r [rで同一単語へのジャンプ
                vim.keymap.set("n", "]r", function() require("illuminate").goto_next_reference(false) end, { desc = "次の同一単語へ" })
                vim.keymap.set("n", "[r", function() require("illuminate").goto_prev_reference(false) end, { desc = "前の同一単語へ" })
                -- leader* でカーソル単語に飛べるように
                vim.keymap.set("n", "<leader>*", function()
                    local word = vim.fn.expand("<cword>")
                    if word == "" then return end
                    vim.fn.setreg("/", [[\<]] .. vim.fn.escape(word, [[\]]) .. [[\>]])
                    vim.opt.hlsearch = true
                    vim.fn.histadd("/", vim.fn.getreg("/"))
                end, { desc = "カーソル単語で検索（n/Nで移動）" })
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
                    current_line_blame = true,
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
                        -- 行単位でstage することもできる
                        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Hunk Stage" })
                        -- reset は変更をなかったことにする。unstage とは違う
                        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Hunk Reset" })

                        map('v', '<leader>hs', function()
                          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                        end, { desc = "Stage hunk" })

                        map('v', '<leader>hr', function()
                          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                        end, { desc = "Reset hunk" })

                        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Stage buffer" })
                        -- Gread origin:%と同様
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
        {
            "vim-scripts/TT2-syntax",
            ft = { "tt2", "tt2html" },
        },
        { -- quickfix を見やすくする。Telescope 開いて q を押す :grep hogehoge . | copen
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
        { -- leader+tで日本語に翻訳
            "uga-rosa/translate.nvim",
            config = function()
                require("translate").setup({
                    default = {
                        command = "google",
                    },
                    preset = {
                        output = {
                            split = {
                                append = true,
                            },
                        },
                    },
                    parse_after = {
                        split_by_newline = {
                            cmd = function(text, _)
                                local lines = {}
                                for line in text:gmatch("[^\r\n]+") do
                                    line = vim.trim(line)
                                    if line ~= "" then
                                        table.insert(lines, line)
                                    end
                                end
                                return lines
                            end,
                        },
                    },
                })
                vim.api.nvim_set_keymap("v", "<space>t", ":Translate JA<CR>", { noremap = true, silent = true })
            end,
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
            enabled = false,
            -- dir = "~/MyDevelopment/buffer-scope.nvim",
            dependencies = { "nvim-telescope/telescope.nvim" },
            config = function()
                -- require("buffer-scope").setup({
                --     telescope = {
                --         buffers = {
                --             mappings = {
                --                 i = {
                --                     ["<C-k>"] = "close",  -- インサートモードでC-kで閉じる
                --                 },
                --                 n = {
                --                     ["<C-k>"] = "close",  -- ノーマルモードでC-kで閉じる
                --                 },
                --             },
                --         },
                --     },
                -- })
                -- require("telescope").load_extension("buffer_scope")
                -- vim.api.nvim_set_keymap(
                --     "n",
                --     "<C-k>",
                --     "<cmd>Telescope buffer_scope buffers<cr>",
                --     { noremap = true, silent = true, desc = "Buffer Scope" }
                -- )
            end,
        },
        { -- 囲む
            "kylechui/nvim-surround",
            config = function()
                require("nvim-surround").setup({})
                -- v4からは <Plug> マッピングを直接設定する
                -- vim.keymap.set("i", "<C-s>s", "<Plug>(nvim-surround-insert)", { desc = "カーソル位置を囲む" })
                -- vim.keymap.set("i", "<C-s>S", "<Plug>(nvim-surround-insert-line)", { desc = "カーソル位置を改行ありで囲む" })
                -- vim.keymap.set("n", "es", "<Plug>(nvim-surround-normal-cur)", { desc = "現在行を囲む" })
                -- vim.keymap.set("n", "yS", "<Plug>(nvim-surround-normal-line)", { desc = "モーション範囲を改行ありで囲む" })
                -- vim.keymap.set("n", "ySS", "<Plug>(nvim-surround-normal-cur-line)", { desc = "現在行を改行ありで囲む" })
                vim.keymap.set("x", "S", "<Plug>(nvim-surround-visual)", { desc = "選択範囲を囲む" })
                -- vim.keymap.set("x", "gS", "<Plug>(nvim-surround-visual-line)", { desc = "選択範囲を改行ありで囲む" })
                -- vim.keymap.set("n", "ds", "<Plug>(nvim-surround-delete)", { desc = "囲みを削除" })
                -- vim.keymap.set("n", "cs", "<Plug>(nvim-surround-change)", { desc = "囲みを変更" })
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
            init = function()
                vim.g.BufferListMaxWidth = 100
            end,
        },
        {  -- マルチカーソル
            "jake-stewart/multicursor.nvim",
            branch = "1.0",
            config = function()
                local mc = require("multicursor-nvim")
                mc.setup()

                -- 以下をjson化する手順
                -- 1. matchで\v\S+で検索してすべての単語を選択し、S'してすべての単語を'で囲む
                -- 2. matchで\v\S+'で検索してすべての単語'を選択して、S,で、すべての単語を,で区切る
                -- 3. []をつけたあと、up down で複数行にカーソルをつけて、{ と }, をつけて、後は空白を置換(s/\v\s+/ /g)する
                --   1   Alice    alice@example.com    active
                --   2   Bob      bob@example.com      inactive
                --   3   Carol    carol@example.com    active
                --   4   Dave     dave@example.com     active
                --   5   Eve      eve@example.com      banned
                --   6   Frank    frank@example.com    active
                --   7   Grace    grace@example.com    inactive
                --   8   Heidi    heidi@example.com    active
                --   9   Ivan     ivan@example.com     active
                --  10   Judy     judy@example.com     banned
                --  11   Karl     karl@example.com     active
                --  12   Liam     liam@example.com     active
                --  13   Mona     mona@example.com     inactive
                --  14   Nina     nina@example.com     active
                --  15   Oscar    oscar@example.com    active
                --  16   Peggy    peggy@example.com    banned
                --  17   Quinn    quinn@example.com    active
                --  18   Ruth     ruth@example.com     active
                --  19   Sybil    sybil@example.com    inactive
                --  20   Trent    trent@example.com    active

                local set = vim.keymap.set
                -- 元からあるneovim便利コマンド
                -- f( で次の(にカーソル移動 F( で前の(にカーソル移動
                -- df( で次の(まで削除 dF( で前の(まで削除
                -- cf( で次の(まで変更 cF( で前の(まで変更

                -- Add or skip cursor above/below the main cursor.
                set({"n", "x"}, "<up>", function() mc.lineAddCursor(-1) end)
                set({"n", "x"}, "<down>", function() mc.lineAddCursor(1) end)
                -- set({"n", "x"}, "<C-up>", function() mc.lineSkipCursor(-1) end)
                -- set({"n", "x"}, "<C-down>", function() mc.lineSkipCursor(1) end)

                -- Add or skip adding a new cursor by matching word/selection
                set({"n", "x"}, "<leader>n", function() mc.matchAddCursor(1) end)
                -- set({"n", "x"}, "<leader>s", function() mc.matchSkipCursor(1) end)
                -- set({"n", "x"}, "<leader>N", function() mc.matchAddCursor(-1) end)
                -- set({"n", "x"}, "<leader>S", function() mc.matchSkipCursor(-1) end)

                -- Add and remove cursors with control + left click.
                -- set("n", "<c-leftmouse>", mc.handleMouse)
                -- set("n", "<c-leftdrag>", mc.handleMouseDrag)
                -- set("n", "<c-leftrelease>", mc.handleMouseRelease)

                -- Cursor Split
                set("x", "|", mc.splitCursors)   -- | は分割っぽい記号
                -- Cursor Match
                -- \v\d+とかやれば数字にカーソルつけたりもできる
                set("x", "/", mc.matchCursors)   -- / は検索っぽい記号

                -- Disable and enable cursors.
                -- set({"n", "x"}, "<c-q>", mc.toggleCursor)

                -- Mappings defined in a keymap layer only apply when there are
                -- multiple cursors. This lets you have overlapping mappings.
                mc.addKeymapLayer(function(layerSet)
                    -- Select a different cursor as the main one.
                    -- layerSet({"n", "x"}, "<left>", mc.prevCursor)
                    -- layerSet({"n", "x"}, "<right>", mc.nextCursor)

                    -- -- Delete the main cursor.
                    -- layerSet({"n", "x"}, "<leader>x", mc.deleteCursor)

                    -- Enable and clear cursors using escape.
                    layerSet("n", "<esc>", function()
                        if not mc.cursorsEnabled() then
                            mc.enableCursors()
                        else
                            mc.clearCursors()
                        end
                    end)
                end)

                -- Customize how cursors look.
                local hl = vim.api.nvim_set_hl
                hl(0, "MultiCursorCursor", { reverse = true })
                hl(0, "MultiCursorVisual", { link = "Visual" })
                hl(0, "MultiCursorSign", { link = "SignColumn"})
                hl(0, "MultiCursorMatchPreview", { link = "Search" })
                hl(0, "MultiCursorDisabledCursor", { reverse = true })
                hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
                hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
            end
        },
        { -- align
            "echasnovski/mini.align",
            version = "*",
            keys = {
                { "ga", mode = { "n", "x" }, desc = "Align" },
                { "gA", mode = { "n", "x" }, desc = "Align with preview" },
            },
            opts = {},
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
                vim.keymap.set(
                  { "n", "v" },
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
                -- 実装へジャンプ
                vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", { silent = true })
                vim.keymap.set("n", "gr", "<Plug>(coc-references)", { silent = true })
                -- 現在の単語の名前を変更するための再マッピング
                vim.keymap.set("n", "cr", "<Plug>(coc-rename)", { silent = true })
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
                vim.api.nvim_create_autocmd("BufReadPost", {
                    callback = function()
                        vim.defer_fn(function()
                           --  print("Enable treesitter highlight")
                            vim.cmd("TSEnable highlight")
                        end, 200)
                    end,
                })

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
            enabled = false,
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
            config = function()
                require("noice").setup({
                    lsp = {
                        override = {
                            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                            ["vim.lsp.util.stylize_markdown"] = true,
                        },
                    },
                    presets = {
                        bottom_search = true,
                        command_palette = true,
                        long_message_to_split = true,
                        inc_rename = false,
                        lsp_doc_border = false,
                    },
                    views = {
                        cmdline_popup = {
                            position = {
                                row = "50%",
                                col = "50%",
                            },
                            size = {
                                width = 60,
                                height = "auto",
                            },
                            border = {
                                style = "rounded",
                            },
                            win_options = {
                                winhighlight = { Normal = "Normal", FloatBorder = "FloatBorder" },
                            },
                        },
                        popupmenu = {
                            relative = "editor",
                            position = {
                                row = "60%",
                                col = "50%",
                            },
                            size = {
                                width = 60,
                                height = 10,
                            },
                            border = {
                                style = "rounded",
                            },
                        },
                    },
                })
            end,
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
        }
    },
})
