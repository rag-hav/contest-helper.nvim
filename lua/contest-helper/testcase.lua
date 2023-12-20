local M = {}

local utils = require("contest-helper.utils")
local config = require("contest-helper.config")

M.processParserData = function(data)
	local problemDir = config.get("getProblemFolder")(data)
	local problemName = config.get("getProblemName")(data)
	local problemExt = config.get("getProblemExtension")
	if not problemDir or not problemName or not problemExt then
		return
	end

	if problemDir:sub(problemDir:len()) ~= "/" then
		problemDir = problemDir .. "/"
	end

	if type(problemExt) == "table" then
		-- TODO: picker
		problemExt = problemExt[1]
	end

	if type(problemExt) == "function" then
		problemExt = problemExt(data)
	end

	assert(type(problemExt) == "string", "Invalid problem extension")

	local problemPath = problemDir .. problemName .. "." .. problemExt

	if config.get("openProblemFile") then
		vim.cmd("edit " .. problemPath)
	end

	if config.get("createTestCases") then
		local dir = utils.getProblemDir(problemName)
		if vim.fn.isdirectory(dir) == 1 then
			vim.notify("Already saved testcases for " .. problemName)
			return
		else
			vim.notify("Creating test cases for " .. problemName)
			vim.fn.mkdir(dir, "p")
		end

		for k, v in ipairs(data.tests) do
			for _, x in ipairs({ { ".in", v.input }, { ".ans", v.output } }) do
				local filename = dir .. "/" .. k .. x[1]
				local file = io.open(filename, "w")
				assert(file, "failed to create test file " .. filename)
				file:write(x[2])
				file:close()
			end
		end
	end
end

return M
