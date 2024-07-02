local vim = vim
local lazypath = vim.fn.stdpath("data") .. "/lazy-test/lazy.nvim"
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
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        any = {
                            { find = "%d+L, %d+B" },
                            { find = "; after #%d+" },
                            { find = "; before #%d+" },
                        },
                    },
                    view = "mini",
                },
            },
            presets = {
                bottom_search = true,
                command_palette = false,
                long_message_to_split = true,
                inc_rename = true,
            },
        },
        -- stylua: ignore
        keys = {
            { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
            { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
            { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
            { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
            { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
            { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll forward", mode = {"i", "n", "s"} },
            { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll backward", mode = {"i", "n", "s"}},
        },
    },
    {
        "enoatu/nvim-smartchr",
        enabled = true,
        config = function()
            require("nvim-smartchr").setup({
                mappings = {
                    default = {
                        { ".", { ".", " . " }, { loop = true } },
                        { ",", { ", ", "," }, { loop = true } },
                        { "&", { " & ", " && ", "&" }, { loop = true } },
                        { "?", { "? ", "?" }, { loop = true } },
                        { "=", { " = ", " => ", " == ", " === ", "=" } },
                    },
                    ["perl|php|python|rust"] = {
                        { "-", { "-", "->", " - ", "--", "-" }, { loop = false } },
                        { ":", { "::", ": ", ":" }, { loop = true } },
                        { "=", { "=", " = ", " => ", " == ", " === ", " eq " }, { loop = true } },
                    },
                    ["tt2html"] = {
                        { "[", { "[%", "[%-", "[" } },
                        { "]", { "%]", "-%]", "]" } },
                    },
                },
            })
        end,
    },
    {
        "kana/vim-smartchr",
        enabled = false,
        config = function()
            vim.cmd([[
            function! SwitchSmartChr()
            if &filetype =~ 'perl\|php\|python\|golong\|rust'
            inoremap <expr> . smartchr#loop('.', ' . ')
            inoremap <expr> , smartchr#loop(', ', ',')
            inoremap <expr> - smartchr#loop('->', ' - ', '--', '-')
            inoremap <expr> = smartchr#loop('=', ' = ', ' => ', ' == ', ' === ', ' eq ')
            inoremap <expr> & smartchr#loop(' & ', ' && ', '&')
            inoremap <expr> ? smartchr#loop('? ', '?')
            inoremap <expr> : smartchr#loop('::', ': ', ':')
            inoremap <expr> [ smartchr#one_of('[')
            inoremap <expr> ] smartchr#one_of(']')
            elseif &filetype == "javascript"
            inoremap <expr> . smartchr#one_of('.')
            inoremap <expr> , smartchr#loop(',', ', ')
            inoremap <expr> - smartchr#one_of('-')
            inoremap <expr> = smartchr#one_of('=')
            inoremap <expr> & smartchr#one_of('&')
            inoremap <expr> ? smartchr#one_of('?')
            inoremap <expr> : smartchr#one_of(':')
            inoremap <expr> [ smartchr#one_of('[%', '[%-', '[')
            inoremap <expr> ] smartchr#one_of('%]', '-%]', ']')
            else
            inoremap <expr> . smartchr#one_of('.')
            inoremap <expr> , smartchr#loop(',', ', ')
            inoremap <expr> - smartchr#one_of('-')
            inoremap <expr> = smartchr#one_of('=')
            inoremap <expr> & smartchr#one_of('&')
            inoremap <expr> ? smartchr#one_of('?')
            inoremap <expr> : smartchr#one_of(':')
            inoremap <expr> [ smartchr#one_of('[')
            inoremap <expr> ] smartchr#one_of(']')
            endif
            endfunction
            autocmd BufEnter * call SwitchSmartChr()
        ]])
        end,
    },
    { -- UI ライブラリ
        "MunifTanjim/nui.nvim",
    },
})
