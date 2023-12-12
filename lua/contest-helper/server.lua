-- https://github.com/jmerle/competitive-companion/blob/master/src/hosts/hosts.ts
local testcase = require("contest-helper.testcase")
local port = 10043

local M = {}
local uv = vim.loop
local server

M.run = function()
	vim.schedule(function()
		M.stop()
		server = uv.new_tcp()
		assert(server, "Failed to bind port")
		server:bind("127.0.0.1", port)
		server:listen(128, function(err)
			assert(not err, err)
			local client = uv.new_tcp()
			assert(client, "Failed to accept connection")
			server:accept(client)
			local buffer = {}
			client:read_start(function(err, chunk)
				if chunk then
					table.insert(buffer, chunk)
				else
					local received = table.concat(buffer)
					local _, bodystart = received:find("\r\n\r\n")
					if bodystart then
						local jsontxt = received:sub(bodystart + 1)

						vim.schedule(function()
							local result = vim.json.decode(jsontxt)
							testcase.processParserData(result)
						end)
					end

					client:shutdown()
					client:close()
				end
			end)
		end)

		-- uv.run()
	end)
end

M.stop = function()
	if server then
		server:close()
		server = nil
	end
end

return M
