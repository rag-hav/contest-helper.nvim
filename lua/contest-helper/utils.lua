local M = {}

local extensionHome = vim.fn.stdpath("data") .. "/contest-helper.nvim"

M.getProblemDir = function (name)
	name = string.gsub(name, '[<>:"/\\|?*]', "_")
	return extensionHome .. "/" .. name
end


return M
