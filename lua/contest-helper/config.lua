local M = {}
local utils = require("contest-helper.utils")

local config = {
	startServerOnStartup = true,

	getProblemName = function(data)
		local site = utils.getSiteName(data.url, "misc")
		local parts = vim.split(data.url, "/")
        local name = data.name

		if site == "codechef" then
			name = parts[#parts]:gsub("tabstatement", "")
		end

		if site == "codeforces" then
			name = table.concat({ parts[#parts - 2], parts[#parts - 1], parts[#parts] }):gsub("problem", ""):gsub("contest", "")
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
        py = function ()
            return "python3 " .. vim.fn.expand("%:p")
        end,
        java = function ()
			local exc = vim.fn.expand("%:p")
			vim.fn.system("javac " .. exc)
            return "java " .. vim.fn.expand("%:p:r")
        end

	},
	testCaseTimeout = 10000,

	windowOpts = {
		relative = "editor",
		width = 30,
		height = 10,
		row = 5,
		col = 5,
		style = "minimal",
		border = "single",
	},
}

M.get = function(key)
	if key then
		return config[key]
	end
	return config
end

M.set = function(userConfig)
	userConfig = userConfig or {}
	config = vim.tbl_deep_extend("force", config, userConfig)
end

return M
