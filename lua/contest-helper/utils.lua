local M = {}

local extensionHome = vim.fn.stdpath("data") .. "/contest-helper.nvim"

M.getProblemDir = function(name)
	name = M.cleanName(name)
	return extensionHome .. "/" .. name
end

M.getSiteName = function(url, default)
	for _, site in ipairs({ "codeforces", "codechef", "atcoder", "hackerearth", "hackerrank", "spoj", "cses" }) do
		if string.find(url, site) then
			return site
		end
	end
	return default
end

M.cleanName = function(name)
	-- return string.gsub(name, '[<>:"/\\|?*\\. ]', "_"):gsub("_+", "_")
	return string.gsub(name, "\\W", "")
end

M.trimBlankLine = function(lines)
	if type(lines) ~= "table" then
		return lines
	end
	local l = 1
	local r = #lines

	while l <= r and vim.trim(lines[l]) == "" do
		l = l + 1
	end
	while l <= r and vim.trim(lines[r]) == "" do
		r = r - 1
	end

	for i = 0, r - l do
		lines[i + 1] = lines[i + l]
	end

	for i = r - l + 1, #lines do
		-- table.remove(lines)
        lines[i] = nil
	end

	return lines
end

M.createDiff = function(answer, output)
	local len1 = #answer
	local len2 = #output

	if len1 ~= len2 then
		return { status = false, message = "Output line count does not match Expected" }
	end

	local result = {}

	for i = 1, math.min(len1, len2) do
		if vim.trim(answer[i]) ~= vim.trim(output[i]) then
			table.insert(result, { i = i, answer = answer[i], output = output[i] })
		end
	end

	if #result > 0 then
		return { status = false, differences = result }
	end

	return { status = true, message = "Output matches Expected" }
end

return M
