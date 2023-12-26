local config = require("contest-helper.config")
local server = require("contest-helper.server")
local runner = require("contest-helper.runner")
local hg = require("contest-helper.highlights")
local M = {}

M.runCode = runner.runTestCase
M.startServer = server.start
M.stopServer = server.stop

M.setup = function(opts)
	config.setup(opts)
	if config.options.startServerOnStartup then
		server.start()
	end
end

return M
