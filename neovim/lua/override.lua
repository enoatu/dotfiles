local vim = vim
-- leader key
vim.g.mapleader = " "
-- バッファが編集中でもその他のファイルを開けるように
vim.o.hidden = true
-- 入力中のコマンドをステータスに表示する
vim.o.showcmd = true
vim.opt.undofile = true

-- yank後にクリップボードにもコピー
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    local copy = require("vim.ui.clipboard.osc52").copy("+")
    copy(vim.fn.getreg('"', 1, true), vim.fn.getregtype('"'))
  end,
})

----  見た目系
-- 行番号を表示
vim.wo.number = true
-- 現在の行を強調表示
vim.wo.cursorline = true
--  現在の行を強調表示（縦）
vim.wo.cursorcolumn = true
--  行末の1文字先までカーソルを移動できるように
vim.o.virtualedit = "onemore"
-- TrueColor対応"
vim.o.termguicolors = true
-- ビープ音を可視化
vim.o.visualbell = true
-- 括弧入力時の対応する括弧を表示
vim.o.showmatch = true
-- ステータスラインを常に表示
vim.o.laststatus = 2
-- コマンドラインの補完
vim.o.wildmode = "list:longest"
-- タブ、空白、改行の可視化
vim.o.list = true
vim.o.listchars = "tab:»·,trail:◀,extends:>,precedes:<,nbsp:%"
-- 全角スペースをハイライト表示
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

-- 検索系
-- 検索文字列が小文字の場合は大文字小文字を区別なく検索する
vim.o.ignorecase = true
-- 検索文字列に大文字が含まれている場合は区別して検索する
vim.o.smartcase = true
-- 検索文字列入力時に順次対象文字列にヒットさせる
vim.o.incsearch = true
-- 検索語をハイライト表示
vim.o.hlsearch = true

-- 操作系
-- 行頭
vim.keymap.set(
    { "n", "v" },
    "<C-h>",
    "^",
    { noremap = true, silent = true, desc = "非空白文字の行頭に移動" }
)
-- 行末
vim.keymap.set({ "n", "v" }, "<C-l>", "$", { noremap = true, silent = true, desc = "行末に移動" })

-- buffer list
vim.keymap.set({ "n", "v" }, "<C-K>", ":call BufferList()<CR>", { noremap = true, silent = true, desc = "BufferList" })

-- バッファの移動
vim.keymap.set({ "n", "v" }, "<C-q>", ":b #<CR>", { noremap = true, silent = true, desc = "前回のバッファに移動" })


-- 削除
vim.keymap.set("v", "<BS>", "<Del>", { noremap = true })
vim.keymap.set("i", "<BS>", "<BS>", { noremap = true })

-- 挿入モードーノーマルモード間移動を高速化
vim.o.ttimeoutlen = 10
vim.o.mouse = "a"
-- "ウィンドウの幅より長い行は折り返され、次の行に続けて表示される
-- vim.wo.wrap = true プラグインにより無効化されている
vim.o.matchtime = 1
vim.o.hidden = true
vim.o.whichwrap = "b,s,<,>,[,]"
-- vnoremap <silent> <C-p> "0p<CR>
-- vim.o.t_Co = 256

vim.keymap.set("c", "w!!", "w !sudo tee > /dev/null %<CR>", { noremap = true })
-- "visualモードで選択してからのインデント調整で調整後に選択範囲を開放しない
vim.keymap.set("v", ">", ">gv", { noremap = true })
vim.keymap.set("v", "<", "<gv", { noremap = true })

vim.opt.spelllang = { "en" }
vim.opt.splitright = false
vim.opt.splitbelow = true
vim.opt.relativenumber = false
vim.opt.wrap = true


-- Disable
vim.keymap.set({ "i", "n" }, "<esc>", "<esc>", { desc = "Escape and clear hlsearch" })

-- abc順で並び替え
vim.keymap.set("v", "<leader>sa", ":sort<CR>", { noremap = true, silent = true, desc = "選択範囲をabc順で並び替え" })
vim.keymap.set("n", "<leader>sa", ":%sort<CR>", { noremap = true, silent = true, desc = "全体をabc順で並び替え" })

-- ec: 同じ tmux ウィンドウ内の Claude Code ペインに現在位置/選択範囲を送る
local function is_claude_exe(cmd)
    -- 引数 (e.g. ".claude/settings.json") に "claude" が含まれる誤検出を避けるため
    -- コマンドの basename のみで判定する
    local base = (cmd or ""):match("([^/]+)$") or ""
    return base == "claude" or base:match("^claude%-")
end

local function find_claude_pane()
    if vim.env.TMUX == nil or vim.env.TMUX == "" then
        return nil, "tmux 環境ではありません"
    end
    local panes = vim.fn.systemlist({
        "tmux", "list-panes", "-F", "#{pane_id} #{pane_active} #{pane_current_command} #{pane_pid}",
    })
    if vim.v.shell_error ~= 0 then
        return nil, "tmux list-panes 失敗"
    end

    local need_tree = {}
    for _, line in ipairs(panes) do
        local pane_id, active, cmd, pid = line:match("^(%S+)%s+(%S+)%s+(%S+)%s+(%S+)$")
        if pane_id and active ~= "1" then
            if is_claude_exe(cmd) then
                return pane_id
            end
            need_tree[#need_tree + 1] = { pane_id = pane_id, pid = tonumber(pid) }
        end
    end
    if #need_tree == 0 then
        return nil, "Claude ペインが見つかりません"
    end

    -- フォールバック: pane の foreground process が claude でない場合だけ ps ツリーを走査
    local by_ppid = {}
    for _, line in ipairs(vim.fn.systemlist({ "ps", "-ax", "-o", "pid=,ppid=,command=" })) do
        local pid_s, ppid_s, cmd = line:match("^%s*(%d+)%s+(%d+)%s+(.*)$")
        if pid_s then
            local ppid = tonumber(ppid_s)
            by_ppid[ppid] = by_ppid[ppid] or {}
            table.insert(by_ppid[ppid], { pid = tonumber(pid_s), command = cmd })
        end
    end
    local function tree_has_claude(root)
        local queue = { root }
        while #queue > 0 do
            local pid = table.remove(queue, 1)
            for _, c in ipairs(by_ppid[pid] or {}) do
                if is_claude_exe(c.command:match("^(%S+)")) then return true end
                table.insert(queue, c.pid)
            end
        end
        return false
    end
    for _, p in ipairs(need_tree) do
        if tree_has_claude(p.pid) then return p.pane_id end
    end
    return nil, "Claude ペインが見つかりません"
end

local function paste_to_claude(msg)
    local pane_id, err = find_claude_pane()
    if not pane_id then
        vim.notify(err, vim.log.levels.WARN)
        return
    end
    -- -p で bracketed paste (改行を Enter 扱いさせない)、-d で paste 後に buffer を削除
    vim.fn.system({ "tmux", "load-buffer", "-b", "nvim_ec", "-" }, msg)
    vim.fn.system({ "tmux", "paste-buffer", "-p", "-d", "-b", "nvim_ec", "-t", pane_id })
    vim.fn.system({ "tmux", "select-pane", "-t", pane_id })
end

local function build_message(lines, line1, line2)
    local rel = vim.fn.expand("%:.")
    if rel == "" then
        vim.notify("ファイル名が無いバッファです", vim.log.levels.WARN)
        return nil
    end
    if not lines then
        return string.format("@%s:%d ", rel, line1)
    end
    local range = line1 == line2 and tostring(line1) or string.format("%d-%d", line1, line2)
    return string.format("@%s:%s\n```%s\n%s\n```\n", rel, range, vim.bo.filetype or "", table.concat(lines, "\n"))
end

local function send(msg)
    if msg then paste_to_claude(msg) end
end

vim.api.nvim_create_user_command("ClaudeSendContext", function(opts)
    if opts.range > 0 then
        send(build_message(vim.fn.getline(opts.line1, opts.line2), opts.line1, opts.line2))
    else
        send(build_message(nil, vim.fn.line(".")))
    end
end, { range = true, desc = "Claude Code ペインに位置/行範囲を送る" })

vim.keymap.set("n", "ec", function()
    send(build_message(nil, vim.fn.line(".")))
end, { silent = true, desc = "Claude Code ペインに現在位置を送る" })

vim.keymap.set("x", "ec", function()
    local s, e = vim.fn.getpos("v"), vim.fn.getpos(".")
    local lines = vim.fn.getregion(s, e, { type = vim.fn.mode() })
    send(build_message(lines, math.min(s[2], e[2]), math.max(s[2], e[2])))
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { silent = true, desc = "Claude Code ペインに選択範囲を送る" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
        vim.opt_local.autoindent = true
    end,
})

-- ログを出す
vim.cmd("set verbosefile=~/.cache/nvim/log")
vim.cmd("set verbose=3")
