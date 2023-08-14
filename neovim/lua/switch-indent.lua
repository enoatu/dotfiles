-- "自動インデント
vim.o.smartindent = true
vim.o.autoindent = true
-- " Tab文字を半角スペースにする
vim.o.expandtab = true

local switchTab = 1
local switchTabMessage = "4スペ"

vim.o.shiftwidth = 4
vim.o.tabstop = 4

vim.keymap.set("n", "<C-i>", ":lua SwitchIndent()<CR>", { noremap = true })
vim.keymap.set("n", "<C-o>", ":lua SwitchIndent()<CR>", { noremap = true })
function SwitchIndent()
	if switchTab == 1 then
		switchTab = 2
		vim.o.expandtab = true
		vim.o.shiftwidth = 2
		vim.o.tabstop = 2
		switchTabMessage = "2スペ"
	elseif switchTab == 2 then
		switchTab = 3
		vim.o.expandtab = false
		vim.o.shiftwidth = 4
		vim.o.tabstop = 4
		switchTabMessage = "タブ"
	elseif switchTab == 3 then
		switchTab = 1
		vim.o.expandtab = true
		vim.o.shiftwidth = 4
		vim.o.tabstop = 4
		switchTabMessage = "4スペ"
	end
	print("SwitchIndent: " .. switchTabMessage)
end
