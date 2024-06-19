-- Neovim Luaプラグイン：smartchr

local M = {}

-- キーと展開のマッピングを保持するテーブル
M.key_mappings = {}

-- デフォルトのコンテキスト
local DEFAULT_CONTEXT = {}

-- カーソル位置の前に特定の文字列があるかをチェックする関数
local function cursor_preceded_with(pattern)
    local mode = vim.fn.mode()
    if mode == "c" then
        -- -- コマンドラインモードの場合
        -- local pos = vim.fn.getcmdpos() - 1 - 1
        -- local pattern_length = #pattern
        -- return pattern_length <= pos + 1 and vim.fn.getcmdline():sub(pos - pattern_length + 2, pos + 1) == pattern
    else
        -- 挿入モードや他のモードの場合
        return vim.fn.search("\\V" .. vim.fn.escape(pattern, "\\") .. "\\%#", "bcn") ~= 0
    end
end

-- コンテキストが有効かどうかを判断する関数
local function is_valid_context(context)
    -- if context.ctype then
    --     return vim.fn.mode() == "c" and vim.fn.stridx(context.ctype, vim.fn.getcmdtype()) >= 0
    -- else
    --     -- 有効なコンテキストが指定されていない場合は、常に有効
    --     return true
    -- end
    return true
end

-- 文字列の展開と置換を行う関数
function M.expand(key)
    local mapping = M.key_mappings[key]
    if not mapping then
        return key
    end

    local context = mapping.context or DEFAULT_CONTEXT
    local literals = vim.deepcopy(mapping.literals) -- 深いコピーでリストを変更から保護
    local loop = mapping.loop

    if loop then
        -- ループする場合、リテラルリストの最後に最初のリテラルを追加
        table.insert(literals, literals[1])
    end

    -- コンテキストが有効な場合
    if is_valid_context(context) then
        for i = #literals, 2, -1 do
            local current_literal = literals[i]
            local previous_literal = literals[i - 1]

            if cursor_preceded_with(previous_literal) then
                local backspaces = string.rep("<BS>", #previous_literal)
                -- <BS>キーを置き換えて削除動作を行い、新しい文字列を挿入
                local feedkeys = vim.api.nvim_replace_termcodes(backspaces .. current_literal, true, false, true)
                vim.api.nvim_feedkeys(feedkeys, "n", true)
                return ""
            end
        end

        -- カーソル前に適切な文字が見つからない場合の処理
        return literals[1]
    else
        return context.fallback or literals[#literals]
    end
end

-- キーマッピングを登録する関数
function M.map(key, replacements, opts)
    opts = opts or {}
    M.key_mappings[key] = {
        literals = replacements,
        loop = opts.loop or false,
        context = opts.context or DEFAULT_CONTEXT,
    }

    -- キーマッピングを設定
    vim.api.nvim_set_keymap(
        "i",
        key,
        string.format([[v:lua.require('smartchr2').expand('%s')]], key),
        { expr = true, noremap = true }
    )
end

-- プラグインの初期設定を行う関数
function M.setup(mappings)
    for key, mapping in pairs(mappings) do
        M.map(key, mapping.literals, { loop = mapping.loop, context = mapping.context })
    end
end

return M
