local M = {}

local config = {
    autoStart = true,

	getProblemName = function(data)
		return data.name
	end,

	buildFunctions = {
		["cpp"] = function()
			local exc = vim.fn.expand("%:r")
			vim.fn.system("make " .. exc)
			return exc
		end,
	},
	timeout = 10000,
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
