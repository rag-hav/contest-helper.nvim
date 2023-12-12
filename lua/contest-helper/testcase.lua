local M = {}

local utils = require("contest-helper.utils")
local config = require("contest-helper.config")


M.processParserData = function(data)
	local name = config.get('getProblemName')(data)
	local dir = utils.makeProblemDir(name)
    if not dir then
        -- vim.notify("Already processed this question")
        return -- Already processed this
    end
    vim.notify(name)

	for k, v in ipairs(data.tests) do
		for _, x in ipairs({ { ".in", v.input }, { ".ans", v.output } }) do
			local file = io.open(dir .. "/" .. k .. x[1], "w")
			assert(file, "failed to create file")
			file:write(x[2])
			file:close()
		end
	end
end

return M
