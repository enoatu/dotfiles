{ -- スクロールバーを表示
    "petertriho/nvim-scrollbar",
    enabled = false,
    config = function()
        local colors = require("tokyonight.colors").setup()
        require("scrollbar").setup({
            handle = {
                text = " ",
                color = "#016669",
                blend = 55,
            },
            marks = {
                GitAdd = {
                    text = "+",
                    priority = 7,
                    gui = nil,
                    color = nil,
                    cterm = nil,
                    color_nr = nil, -- cterm
                    highlight = "GitSignsAdd",
                },
                GitChange = {
                    text = "~",
                    priority = 7,
                    gui = nil,
                    color = nil,
                    cterm = nil,
                    color_nr = nil, -- cterm
                    highlight = "GitSignsChange",
                },
                GitDelete = {
                    text = "_",
                    priority = 7,
                    gui = nil,
                    color = nil,
                    cterm = nil,
                    color_nr = nil, -- cterm
                    highlight = "GitSignsDelete",
                },
            },
            handlers = {
                cursor = false,
                diagnostic = true,
                gitsigns = true, -- Requires gitsigns
                handle = true,
                search = false, -- Requires hlslens
                ale = false, -- Requires ALE
            },
        })
    end,
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
    enabled = vim.g.enable_plugin_lsp_tex or false,
},
{
    import = "lazyvim.plugins.extras.lang.typescript",
    enabled = vim.g.enable_plugin_lsp_typescript or false,
},
{
    import = "lazyvim.plugins.extras.lang.yaml",
    enabled = vim.g.enable_plugin_lsp_yaml or false,
}
{ -- アニメーションで現在のインデントを教えてくれる
    "echasnovski/mini.indentscope",
    enabled = false,
},
{
    "pechorin/any-jump.vim",
    init = function()
        vim.g.any_jump_window_width_ratio = 0.9
        vim.g.any_jump_window_height_ratio = 0.9
        vim.g.any_jump_max_search_results = 20
        vim.g.any_jump_ignored_files = {
            "admin/",
        }
        -- Normal mode: Jump to definition under cursor
        -- vim.keymap.set("n", "<C-j>", ":AnyJump<CR>", { noremap = true })
        -- Visual mode: jump to selected text in visual mode
        vim.keymap.set("v", "<C-j>", ":AnyJumpVisual<CR>", { noremap = true })
        -- Normal mode: open previous opened file (after jump)
        vim.keymap.set("n", "<C-b>", ":AnyJumpBack<CR>")
        -- Normal mode: open last closed search window again
        vim.keymap.set("n", "<C-al>", ":AnyJumpLastResults<CR>")
    end,
},
{
    "enoatu/nvim-smartchr",
    enabled = false,
    config = function()
        require("nvim-smartchr").setup({
            mappings = {
                default = {
                    { ".", { ".", " . " }, { loop = true } },
                    { ",", { ", ", "," }, { loop = true } },
                    { "&", { " & ", " && ", "&" }, { loop = true } },
                    { "?", { "? ", "?" }, { loop = true } },
                    { "=", { " = ", " => ", " == ", " === ", "=" }, { loop = true } },
                },
                ["perl|php|python|rust"] = {
                    { "-", { "->", " - ", "--", "-" } },
                    { ":", { "::", ": ", ":" }, { loop = true } },
                },
                ["tt2html"] = {
                    { "[", { "[%", "[%-", "[" } },
                    { "]", { "%]", "-%]", "]" } },
                },
            },
        })
    end,
},
{ -- python 用(いらないかも)
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
    opts = {
        -- Your options go here
        -- name = "venv",
        -- auto_refresh = false
    },
    event = "VeryLazy", -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
    keys = {
        -- Keymap to open VenvSelector to pick a venv.
        { "<leader>vs", "<cmd>VenvSelect<cr>" },
        -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
        { "<leader>vc", "<cmd>VenvSelectCached<cr>" },
    },
},
{
    "sphamba/smear-cursor.nvim",
    enabled = false,
    opts = {
        cursor_color = "#C678DD",
        stiffness = 0.3,
        trailing_stiffness = 0.1,
        trailing_exponent = 5,
        hide_target_hack = true,
        gamma = 1,
    },
},
{
    "leafOfTree/vim-matchtag",
    enabled = true,
    lazy = true,
    config = function()
        -- matchtagをsearchの背景色にする
        -- vim.api.nvim_set_hl(0, "matchTag", { link = "Search" })
        -- vim.api.nvim_set_hl(0, "matchTag", { link = "MatchParen" })
    end,
},
{
    "tzachar/cmp-tabnine",
    enabled = false,
    build = "./install.sh",
    config = function()
        local tabnine = require("cmp_tabnine.config")
        tabnine:setup({
            max_lines = 1000,
            max_num_results = 100,
            sort = true,
        })
    end,
},
-- lazy plugins: https://www.lazyvim.org/plugins
{ -- snippet engine by lua
    "L3MON4D3/LuaSnip",
},
{ -- snippet collection
    "rafamadriz/friendly-snippets",
},
{
    "zbirenbaum/copilot-cmp",
    enabled = false,
    config = function()
        require("copilot_cmp").setup()
    end,
},
{ -- snippet engine by lua?
    -- "enoatu/nvim-cmp",
    "hrsh7th/nvim-cmp",
    enabled = false,
    -- branch = "feat/above",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "onsails/lspkind.nvim",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
        vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

        local cmp = require("cmp")
        local defaults = require("cmp.config.default")()
        return {
            completion = {
                completeopt = "menu,menuone,noinsert",
            },
            -- view = {
            --     entries = {
            --         name = "custom",
            --         vertical_positioning = "above",
            --         selection_order = "down_top",
            --     },
            --     docs = {
            --         auto_open = true,
            --     },
            -- },
            window = {
                completion = {
                    border = "rounded",
                    winhighlight = "Normal:CmpPmenu,FloatBorder:CmpPmenu,CursorLine:PmenuSel,Search:None",
                    col_offset = 0,
                    side_padding = 1,
                    max_height = 10,
                    -- Adjust the position to above the current line
                    relative = "editor",
                    row = -3,
                    style = "minimal",
                },
                documentation = cmp.config.window.bordered({
                    border = "rounded",
                    winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
                    col_offset = -10,
                    side_padding = 0,
                    scrolloff = 0,
                }),
            },
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                -- tabで補完を確定させる
                ["<Tab>"] = vim.schedule_wrap(function(fallback)
                    if cmp.visible() and has_words_before() then
                        cmp.mapping.confirm({ select = true })
                    end
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", true)
                end, { "i", "s" }),
                ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.abort()
                    end
                    fallback()
                end, { "i", "s" }),
                ["<S-CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            }),
            sources = cmp.config.sources({
                -- { name = "cmp_tabnine", priority = 8 },
                { name = "copilot", priority = 7 },
                { name = "cmp-copilot", priority = 6 },
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            }),
            formatting = {
                format = function(entry, item)
                    local icons = require("lazyvim.config").icons.kinds
                    local lspkind = require("lspkind")
                    local source_mapping = {
                        buffer = "[Buffer]",
                        nvim_lsp = "[LSP]",
                        nvim_lua = "[Lua]",
                        -- cmp_tabnine = "[TN]",
                        path = "[Path]",
                    }
                    if icons[item.kind] then
                        item.kind = icons[item.kind] .. item.kind
                    else
                        item.kind = lspkind.symbolic(item.kind, { mode = "symbol" })
                    end
                    item.menu = source_mapping[entry.source.name]
                    -- if entry.source.name == "cmp_tabnine" then
                    --     local detail = (entry.completion_item.labelDetails or {}).detail
                    --     item.kind = ""
                    --     if detail and detail:find(".*%%.*") then
                    --         item.kind = item.kind .. " " .. detail
                    --     end

                    --     if (entry.completion_item.data or {}).multiline then
                    --         item.kind = item.kind .. " " .. "[ML]"
                    --     end
                    -- end
                    local maxwidth = 80
                    item.abbr = string.sub(item.abbr, 1, maxwidth)
                    return item
                end,
            },
            sorting = {
                priority_weight = 2,
                comparators = {
                    require("copilot_cmp.comparators").prioritize,

                    -- Below is the default comparitor list and order for nvim-cmp
                    cmp.config.compare.offset,
                    -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
                    cmp.config.compare.exact,
                    cmp.config.compare.score,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.locality,
                    cmp.config.compare.kind,
                    cmp.config.compare.sort_text,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                },
            },
            experimental = {
                ghost_text = false, -- copilotと競合する
                -- ghost_text = {
                --     hl_group = "CmpGhostText",
                -- },
            },
        }
    end,
},

{
    "hrsh7th/cmp-nvim-lsp",
    enabled = false,
},
{
    "hrsh7th/cmp-buffer",
    enabled = false,
},
{
    "hrsh7th/cmp-path",
    enabled = false,
},
{
    "saadparwaiz1/cmp_luasnip",
    enabled = false,
},
--
{ -- lspconfig
    "neovim/nvim-lspconfig",
    config = function()
        vim.g.autoformat = true
    end,
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
{ -- lsp cli
    "williamboman/mason.nvim",
},
{ -- インデント可視化
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    lazy = false,
    enabled = false,
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
{ "AndreM222/copilot-lualine" },
-- {
--     "zbirenbaum/copilot.lua",
--     cmd = "Copilot",
--     event = "InsertEnter",
--     config = function()
--         require("copilot").setup({
--             panel = {
--                 enabled = true,
--                 auto_refresh = false,
--                 keymap = {
--                     jump_prev = "[[",
--                     jump_next = "]]",
--                     accept = "<CR>",
--                     refresh = "gr",
--                     open = "<M-CR>"
--                 },
--                 layout = {
--                     position = "bottom", -- | top | left | right
--                     ratio = 0.4
--                 },
--             },
--             suggestion = {
--                 enabled = true,
--                 auto_trigger = false,
--                 debounce = 75,
--                 keymap = {
--                     accept = "<M-l>",
--                     accept_word = false,
--                     accept_line = false,
--                     next = "<M-]>",
--                     prev = "<M-[>",
--                     dismiss = "<C-]>",
--                 },
--             },
--             filetypes = {
--                 yaml = false,
--                 markdown = false,
--                 help = false,
--                 gitcommit = false,
--                 gitrebase = false,
--                 hgcommit = false,
--                 svn = false,
--                 cvs = false,
--                 ["."] = false,
--             },
--             copilot_node_command = 'node', -- Node.js version must be > 18.x
--             server_opts_overrides = {},
--         })
--     end,
-- },
-- {
--     "fatih/vim-go",
--     init = function()
--         vim.g.go_fmt_autosave = false
--     end,
-- },
--{
--    "z0rzi/ai-chat.nvim",
--    config = function()
--        require('ai-chat').setup {}
--    end,
--},
-- {
--     "codota/tabnine-nvim",
--     build = "./dl_binaries.sh",
--     init = function()
--         vim.g.tabnine = {
--             enabled = true,
--             config = {
--                 max_lines = 1000,
--                 max_num_results = 100,
--                 sort = true,
--             },
--             ignore_pattern = nil,
--             completeopt = "menu,menuone,noinsert",
--             priority = 5000,
--             sort = true,
--             show_prediction_strength = true,
--             snippet_placeholder = "..",
--             max_num_results = 10,
--             max_lines = 1000,
--             priority = 5000,
--             show_prediction_strength = true,
--             sort = true,
--             tabnine_max_lines = 1000,
--             tabnine_max_num_results = 60,
--             tabnine_sort = true,
--             tabnine_show_prediction_strength = true,
--             tabnine_snippet_placeholder = "..",
--         }
--     end,
-- },
