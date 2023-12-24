local M = {}

local extensionHome = vim.fn.stdpath("data") .. "/contest-helper.nvim"

---@param name string
---@return string
M.getProblemDir = function(name)
	name = M.cleanName(name)
	return extensionHome .. "/" .. name
end

---@param url string
---@param fallback string
---@return string
M.getSiteName = function(url, fallback)
	for _, site in ipairs({ "codeforces", "codechef", "atcoder", "hackerearth", "hackerrank", "spoj", "cses" }) do
		if string.find(url, site) then
			return site
		end
	end
	return fallback
end

---@param name string
---@return string
M.cleanName = function(name)
	-- return string.gsub(name, '[<>:"/\\|?*\\. ]', "_"):gsub("_+", "_")
	local res = string.gsub(name, "\\W", "")
	return res
end

---@param line string
---@param trimPreceedingWhitespace boolean
---@param trimFollowingWhitespace boolean
---@return string
M.trimLine = function(line, trimPreceedingWhitespace, trimFollowingWhitespace)
	if trimPreceedingWhitespace and trimFollowingWhitespace then
		line = vim.trim(line)
	elseif trimPreceedingWhitespace then
		line = string.gsub(line, "^\\s+", "", 1)
	elseif trimFollowingWhitespace then
		line = string.gsub(line, "\\s+$", "", 1)
	end
	return line
end

M.trimLineList =
	---@param lines string[]
	---@param trimPreceedingWhitespace boolean
	---@param trimFollowingWhitespace boolean
	---@param trimPrecedingBlankLines boolean
	---@param trimFollowingBlankLines boolean
	---@return string[]
	function(lines, trimPreceedingWhitespace, trimFollowingWhitespace, trimPrecedingBlankLines, trimFollowingBlankLines)
		local l = 1
		local r = #lines

		for i = l, r do
			lines[i] = M.trimLine(lines[i], trimPreceedingWhitespace, trimFollowingWhitespace)
		end

		if trimPrecedingBlankLines then
			while l <= r and lines[l] == "" do
				l = l + 1
			end
		end
		if trimFollowingBlankLines then
			while l <= r and lines[r] == "" do
				r = r - 1
			end
		end

		if l ~= 1 then
			for i = 0, r - l do
				lines[i + 1] = lines[i + l]
			end
		end

		for i = r - l + 2, #lines do
			lines[i] = nil
		end

		return lines
	end

---@param answer string[]
---@param output string[]
---@return DiffResult
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
