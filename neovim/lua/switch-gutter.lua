local switchGutterBranches = {
    "<input>",
    "HEAD",
    "origin/main",
    "origin/dev",
    "origin/develop",
    "origin/master",
    "origin/staging",
    "main",
    "dev",
    "develop",
    "master",
    "staging",
}
local selfGutter = require("self-gutter")
vim.keymap.set("n", "m", ":lua SwitchGutter()<CR>", { noremap = true, silent = true })
local isSwitchGutter = false
local selfOnly = false

-- 比較ブランチを反映する。自分のみモードなら独自描画、通常は gitsigns
local function applyBase(branch)
    if selfOnly then
        selfGutter.activate(branch)
    else
        if selfGutter.active then
            selfGutter.deactivate()
        end
        package.loaded.gitsigns.change_base(branch, true)
    end
end

function SwitchGutter()
    if isSwitchGutter then
        return
    end
    isSwitchGutter = true
    local toggleLabel = "[自分のみ: " .. (selfOnly and "ON" or "OFF") .. "]"
    local items = { toggleLabel }
    for _, branch in ipairs(switchGutterBranches) do
        items[#items + 1] = branch
    end
    vim.ui.select(items, {
        prompt = "Select the branch for comparison",
    }, function(item)
        isSwitchGutter = false
        if not item then
            return
        end
        -- 自分のみモードのトグル
        if item == toggleLabel then
            selfOnly = not selfOnly
            if not selfOnly and selfGutter.active then
                selfGutter.deactivate()
            end
            SwitchGutter()
            return
        end
        -- 手動入力
        if item == "<input>" then
            vim.ui.input({ prompt = "Enter the branch for comparison: " }, function(input)
                if input and input ~= "" then
                    applyBase(input)
                end
            end)
            return
        end
        applyBase(item)
    end)
end
