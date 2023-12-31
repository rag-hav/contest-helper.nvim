local M = {}

local utils = require("contest-helper.utils")
local config = require("contest-helper.config")

---@param problemDir string The folder to create the problem file in
---@param problemName string The name of the problem file
---@param problemExt string The extension of the problem file
---@param tests CCDataTestCase[] List of test cases
local _processParserData = function(problemDir, problemName, problemExt, tests)
	assert(type(problemDir) == "string", "Invalid problem folder")
	assert(type(problemName) == "string", "Invalid problem name")
	assert(type(problemExt) == "string", "Invalid problem extension")

	if config.options.openProblemFile then
		local problemPath = vim.fn.expand(problemDir .. problemName .. "." .. problemExt)
		vim.cmd("edit " .. problemPath)

		local template = config.options.getProblemTemplate
		if vim.fn.filereadable(problemPath) == 0 and template then
			if type(template) == "function" then
				template = template()
			end

            if type(template) == "string" then
                template = vim.fn.expand(template)
                template = vim.fn.readfile(template)
            end

            vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
		end
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

---@param data CCData
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
