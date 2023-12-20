local M = {}

M.title = "ContestHelperTitle"
M.subtitle = "ContestHelperSubTitle"

M.init = function ()
    vim.cmd("highlight link " .. M.title .. " MoreMsg")
    vim.cmd("highlight link " .. M.subtitle .. " WarningMsg")
end

return M
