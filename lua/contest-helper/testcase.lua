local M = {}

local utils = require("contest-helper.utils")
local config = require("contest-helper.config")

---@param problemDir string The folder to create the problem file in
---@param problemName string The name of the problem file
---@param problemExt string The extension of the problem file
---@param tests ExtensionDataTestCase[] List of test cases
local _processParserData = function(problemDir, problemName, problemExt, tests)
	assert(type(problemDir) == "string", "Invalid problem folder")
	assert(type(problemName) == "string", "Invalid problem name")
	assert(type(problemExt) == "string", "Invalid problem extension")

	local problemPath = problemDir .. problemName .. "." .. problemExt

	if config.options.openProblemFile then
        vim.notify("Opening " .. problemPath)
		vim.cmd("edit " .. problemPath)
	end

	if config.options.createTestCases then
		local dir = utils.getProblemDir(problemName)
		if vim.fn.isdirectory(dir) == 1 then
			vim.notify("Already saved testcases for " .. problemName)
			return
		else
			vim.notify("Creating test cases for " .. problemName)
			vim.fn.mkdir(dir, "p")
		end

		for k, v in ipairs(tests) do
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

---@param data ExtensionData
M.processParserData = function(data)
	local problemDir = config.options.getProblemFolder
	local problemName = config.options.getProblemName(data)
	local problemExt = config.options.getProblemExtension

	if type(problemDir) == "function" then
		problemDir = problemDir(data)
	end

	if problemDir:sub(problemDir:len()) ~= "/" then
		problemDir = problemDir .. "/"
	end

	if type(problemExt) == "function" then
		problemExt = problemExt(data)
	end

	if type(problemExt) == "table" then
		vim.ui.select(problemExt, {}, function(selectedProblemExt)
			_processParserData(problemDir, problemName, selectedProblemExt, data.tests)
		end)
	else
		_processParserData(problemDir, problemName, problemExt, data.tests)
	end
end

return M
