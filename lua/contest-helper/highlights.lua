local M = {}

M.title = "ContestHelperTitle"
M.subtitle = "ContestHelperSubTitle"
M.diffanswer = "ContestHelperDiffAnswer"
M.diffprefix = "ContestHelperDiffPrefix"
M.diffoutput = "ContestHelperDiffOutput"
M.differror = "ContestHelperDiffError"
M.testcasegood = "ContestHelperTestCaseGood"
M.testcasebad = "ContestHelperTestCaseBad"
M.resultgood = "ContestHelperResultGood"
M.resultbad = "ContestHelperResultBad"

local makeHg = function(source)
	local hlid = vim.fn.hlID(source)
	local getAttr = function(mode, name)
		local attr = vim.fn.synIDattr(hlid, name, mode)
		if attr and #attr > 0 then
			return mode .. name .. "=" .. attr .. " "
		end
		return ""
	end
	return getAttr("gui", "fg") .. getAttr("gui", "bg") .. getAttr("cterm", "fg") .. getAttr("cterm", "bg")
end

M.init = function()
	vim.cmd("highlight link " .. M.title .. " MoreMsg")
	vim.cmd("highlight link " .. M.subtitle .. " WarningMsg")
	vim.cmd("highlight link " .. M.diffanswer .. " DiffviewStatusAdded")
	vim.cmd("highlight link " .. M.diffprefix .. " DiffviewStatusLine")

	-- vim.cmd("highlight link " .. M.diffoutput .. " DiffviewStatusBroken")
	vim.cmd("highlight " .. M.diffoutput .. " gui=strikethrough cterm=strikethrough " .. makeHg("DiffviewStatusBroken"))

	vim.cmd("highlight link " .. M.differror .. " DiffviewStatusUnknown")
	vim.cmd("highlight link " .. M.testcasegood .. " DiagnosticOk")
	vim.cmd("highlight link " .. M.testcasebad .. " DiagnosticError")

	vim.cmd("highlight " .. M.resultgood .. " gui=bold cterm=bold " .. makeHg("DiagnosticOk"))
	vim.cmd("highlight " .. M.resultbad .. " gui=bold cterm=bold " .. makeHg("DiagnosticError"))
end

return M
