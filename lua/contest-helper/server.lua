-- https://github.com/jmerle/competitive-companion/blob/master/src/hosts/hosts.ts
local port = 10043

local utils = require("contest-helper.utils")

local processClick = function(data)
	local name = utils.getProblemName(data)
	local dir = utils.getProblemDir(name, true)

	for k, v in ipairs(data.tests) do
		for _, x in ipairs({ { ".in", v.input }, { ".ans", v.output } }) do
			local file = io.open(dir .. "/" .. k .. x[1], "w")
			assert(file, "failed to create file")
			file:write(x[2])
			file:close()
		end
	end
end

local M = {}
M.run = function()
	local uv = vim.loop
	local server = uv.new_tcp()
	assert(server, "Failed to bind port")
	server:bind("127.0.0.1", port)
	server:listen(128, function(err)
		assert(not err, err)
		local client = uv.new_tcp()
		assert(client, "Failed to accept connection")
		server:accept(client)
		local buffer = {}
		client:read_start(function(err, chunk)
			assert(not err, err)
			if chunk then
				table.insert(buffer, chunk)
			else
				local received = table.concat(buffer)
				local _, bodystart = received:find("\r\n\r\n")
				local jsontxt = received:sub(bodystart + 1)

				vim.schedule(function()
					local result = vim.fn.json_decode(jsontxt)
					processClick(result)
				end)

				client:shutdown()
				client:close()
			end
		end)
	end)
	vim.notify("Contest-helper Active")
	uv.run()
end

return M
