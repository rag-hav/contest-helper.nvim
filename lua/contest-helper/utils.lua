local M = {}

local extensionHome = vim.fn.stdpath("data") .. "/contest-helper.nvim"

local function getProblemPath(name)
	name = string.gsub(name, '[<>:"/\\|?*]', "_")
	return extensionHome .. "/" .. name
end

-- Only returns the name if it actually made the dir
M.makeProblemDir = function(name)
	local problemFolder = getProblemPath(name)
	if vim.fn.isdirectory(problemFolder) ~= 0 then
		return
	end
	vim.fn.mkdir(problemFolder, "p")
	return problemFolder
end

M.getProblemDir = function(name)
	local problemDir = getProblemPath(name)
	if vim.fn.isdirectory(problemDir) ~= 0 then
		return problemDir
	end
end

return M
