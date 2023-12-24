local utils = require("contest-helper.utils")

local M = {}

---@type Config
M.defaults = {
	startServerOnStartup = true,

	trimPreceedingWhitespaces = false,
	trimPrecedingBlankLines = false,

	trimFollowingWhitespaces = true,
	trimFollowingBlankLines = true,

	getProblemName = function(data)
		local site = utils.getSiteName(data.url, "misc")
		local parts = vim.split(data.url, "/")
		local name = data.name

		if site == "codechef" then
			name = parts[#parts]:gsub("tabstatement", "")
		end

		if site == "codeforces" then
			name = table.concat({ parts[#parts - 2], parts[#parts - 1], parts[#parts] })
				:gsub("problem", "")
				:gsub("contest", "")
		end

		if site == "atcoder" then
			name = parts[#parts]
		end

		return utils.cleanName(name)
	end,

	getProblemFolder = function(data)
		local site = utils.getSiteName(data.url, "misc")
		return "~/cc/" .. site
	end,

	getProblemExtension = "cpp",

	createTestCases = true,

	openProblemFile = true,

	buildFunctions = {
		cpp = function()
			local exc = vim.fn.expand("%:r")
			vim.fn.system("make " .. exc)
			return vim.fn.expand("%:p:r")
		end,
		py = function()
			return "python3 " .. vim.fn.expand("%:p")
		end,
		java = function()
			local exc = vim.fn.expand("%:p")
			vim.fn.system("javac " .. exc)
			return "java " .. vim.fn.expand("%:p:r")
		end,
	},
	testCaseTimeout = 10000,
}


---@type Config
---@diagnostic disable-next-line: missing-fields
M.options = {}

---@param opts? Config
M.setup = function(opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
