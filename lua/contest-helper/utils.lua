local M = {}

local extensionHome = vim.fn.stdpath("data") .. "/contest-helper.nvim"

M.getProblemDir = function(name)
	name = string.gsub(name, '[<>:"/\\|?*]', "_")
	return extensionHome .. "/" .. name
end

M.createDiff = function(answer, output)
	local len1 = #answer
	local len2 = #output

	if len1 ~= len2 then
		return { status = false, message = "Output line count does not match Expected" }
	end

	local result = {}

	for i = 1, math.min(len1, len2) do
		if answer[i] ~= output[i] then
			table.insert(result, { i = i, answer = answer[i], output = output[i] })
		end
	end

	if #result > 0 then
		return { status = false, differences = result }
	end

	return { status = true, message = "Output matches Expected" }
end

return M
