local config = require("contest-helper.config")
local server = require("contest-helper.server")
local runner = require("contest-helper.runner")
local M = {}

M.runTestCase = function ()
    vim.notify("Run the setup function first")
end

M.createTestCase = function ()
    vim.notify("Run the setup function first")
end

M.stop = function()
    server.stop()
end

M.runServer = function ()
    vim.notify("Run the setup function first")
end

M.setup = function(userConfig)
	config.set(userConfig)
    if config.get("startServerOnStartup") then
	server.run()
    end

    M.runTestCase = runner.runTestCase
    M.runServer = server.run

end



return M
