-- https://github.com/jmerle/competitive-companion/blob/master/src/hosts/hosts.ts
local testcase = require("contest-helper.testcase")
local port = 10043

local M = {}
local uv = vim.loop
local server = nil

M.status = "Not running"

---@param success 0|nil
---@param _ string?
---@param err_msg string?
local didWork = function(success, _, err_msg)
	if success ~= 0 then
		vim.notify(
			"Contest helper NOT listening for new problems! Some other neovim instance is probably running. " .. err_msg
		)
		return false
	end
	return true
end

M.start = function()
	vim.schedule(function()
		server = uv.new_tcp()
		assert(server, "Failed to create server")
		if not didWork(server:bind("127.0.0.1", port)) then
			return
		end
		if
			not didWork(server:listen(128, function(err)
				assert(not err, err)

				M.status = "Listening for new problems"
				local client = uv.new_tcp()
				assert(client, "Failed to accept connection")
				server:accept(client)
				local buffer = {}
				client:read_start(function(_, chunk)
					if chunk then
						table.insert(buffer, chunk)
					else
						local received = table.concat(buffer)
						local _, bodystart = received:find("\r\n\r\n")
						if bodystart then
							local jsontxt = received:sub(bodystart + 1)

							vim.schedule(function()
								local result = vim.json.decode(jsontxt)
								if result then
									testcase.processParserData(result)
								end
							end)
						end

						client:shutdown()
						client:close()
					end
				end)
			end))
		then
			return
		end

		vim.notify("Contest helper listening for new problems")
	end)
end

M.stop = function()
	if server then
		server:close()
		M.status = "Not running"
		server = nil
	end
end

return M
