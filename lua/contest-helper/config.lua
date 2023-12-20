local M = {}

local config = {
	autoStart = true,

	getProblemName = function(data)
		return string.gsub(data.name, '[<>:"/\\|?*\\. ]', "_"):gsub("_+", "_")
	end,

    getProblemFolder = function (data)
        return "~/cc/misc"
    end,

    getProblemExtension = "cpp",

    createTestCases = true,

    openProblemFile = true,

	buildFunctions = {
		["cpp"] = function()
			local exc = vim.fn.expand("%:r")
			vim.fn.system("make " .. exc)
			return vim.fn.expand("%:p:r")
		end,
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
