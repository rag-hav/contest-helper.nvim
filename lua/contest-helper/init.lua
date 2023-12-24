local config = require("contest-helper.config")
local server = require("contest-helper.server")
local runner = require("contest-helper.runner")
local M = {}

local noSetup = function()
	vim.notify("Run the setup function first")
end

M.runTestCase = noSetup

M.createTestCase = noSetup

M.stop = noSetup

M.runServer = noSetup

M.setup = function(userConfig)
	config.setup(userConfig)
	if config.options.startServerOnStartup then
		server.run()
	end

	M.runTestCase = runner.runTestCase
	M.runServer = server.run
	M.stopServer = server.stop
end

return M
