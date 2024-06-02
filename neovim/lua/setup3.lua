local vim = vim

require("lazy").setup({
    spec = {
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
            'tzachar/cmp-tabnine',
            build = './install.sh',
            config = function()
                local tabnine = require('cmp_tabnine.config')
                tabnine:setup({
                    max_lines = 1000,
                    max_num_results = 100,
                    sort = true,
                })
            end,
        },
        { -- snippet engine by lua?
            "hrsh7th/nvim-cmp",
            version = false, -- last release is way too old
            event = "InsertEnter",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "saadparwaiz1/cmp_luasnip",
                'onsails/lspkind.nvim',
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
                    snippet = {
                        expand = function(args)
                            require("luasnip").lsp_expand(args.body)
                        end,
                    },
                    mapping = cmp.mapping.preset.insert({
                        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                        ["<C-f>"] = cmp.mapping.scroll_docs(4),
                        ["<C-Space>"] = cmp.mapping.complete(),
                        ["<C-e>"] = cmp.mapping.abort(),
                        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                        ["<S-CR>"] = cmp.mapping.confirm({
                            behavior = cmp.ConfirmBehavior.Replace,
                            select = true,
                        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    }),
                    sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "luasnip" },
                        { name = "buffer" },
                        { name = "path" },
                        { name = "cmp_tabnine" },
                    }),
                    formatting = {
                        format = function(entry, item)
                            -- local icons = require("lazyvim.config").icons.kinds
                            -- local lspkind = require('lspkind')
                            -- local source_mapping = {
                            --     buffer = "[Buffer]",
                            --     nvim_lsp = "[LSP]",
                            --     nvim_lua = "[Lua]",
                            --     cmp_tabnine = "[TN]",
                            --     path = "[Path]",
                            -- }
                            -- if icons[item.kind] then
                            --     item.kind = icons[item.kind] .. item.kind
                            -- else
                            --     item.kind = lspkind.symbolic(item.kind, {mode = "symbol"})
                            -- end
                            -- item.menu = source_mapping[entry.source.name]
                            -- if entry.source.name == "cmp_tabnine" then
                            --     local detail = (entry.completion_item.labelDetails or {}).detail
                            --     item.kind = ""
                            --     if detail and detail:find('.*%%.*') then
                            --         item.kind = item.kind .. ' ' .. detail
                            --     end

                            --     if (entry.completion_item.data or {}).multiline then
                            --         item.kind = item.kind .. ' ' .. '[ML]'
                            --     end
                            -- end
                            -- local maxwidth = 80
                            -- item.abbr = string.sub(item.abbr, 1, maxwidth)
                            return item
                        end,
                    },
                    experimental = {
                        ghost_text = false, -- copilotと競合する
                        -- ghost_text = {
                        --     hl_group = "CmpGhostText",
                        -- },
                    },
                    sorting = defaults.sorting,
                }
            end,
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
        --
        { -- lspconfig
            "neovim/nvim-lspconfig",
            config = function()
                vim.g.autoformat = true
            end,
        },
        { -- lua- language-serverを自動的に構成
            "folke/lazydev.nvim",
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
                    "vue",
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
        { -- asyncなど 他のライブラリで使う
            "plenary.nvim",
        },
    },
})
