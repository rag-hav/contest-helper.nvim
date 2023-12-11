local M = {}

local makePathSafe = function(inputPath)
	return string.gsub(inputPath, '[<>:"/\\|?*]', "_")
end

M.getProblemDir = function(name, shouldCreate)
	name = makePathSafe(name)
	local dir = vim.fn.stdpath("data") .. "/contest-helper.nvim/" .. name
	if vim.fn.isdirectory(dir) then
		return dir
	end
	if shouldCreate then
		vim.fn.mkdir(dir, "p")
		return dir
	end
end

return M
