local switchGutterBranches = {
  "<input>",
  "HEAD",
  "origin/main",
  "origin/dev",
  "origin/master",
  "origin/staging",
  "main",
  "dev",
  "master",
  "staging",
}
vim.keymap.set("n", "m", ":lua SwitchGutter()<CR>", { noremap = true })
local isSwitchGutter = false
function SwitchGutter()
  if isSwitchGutter then
    return
  end
  isSwitchGutter = true
  vim.ui.select(switchGutterBranches, {
    prompt = "Select the branch for comparison",
   }, function(item, lnum)
    -- 手動入力
    if item == "<input>" then
      vim.notify("input", vim.log.levels.INFO)
      vim.ui.input({ prompt = 'Enter the branch for comparison: ' }, function(input)
        package.loaded.gitsigns.change_base(input)
      end)
      isSwitchGutter = false
      return
    end
    if item and lnum then
      package.loaded.gitsigns.change_base(item)
      vim.notify(string.format("selected '%s' (idx %d)", item, lnum), vim.log.levels.INFO)
    else
      vim.notify("Selection canceled", vim.log.levels.INFO)
    end
  isSwitchGutter = false
  end)
end
