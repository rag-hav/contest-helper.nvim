local config = require("contest-helper.config")
local hg = require("contest-helper.highlights")

local resultBuffernr = -1

local getResultsBuffer = function()
	if vim.api.nvim_buf_is_valid(resultBuffernr) then
		return resultBuffernr
	end

	-- local current_win = vim.api.nvim_get_current_win()
	vim.api.nvim_command("vertical 50 split")
	local new_win = vim.api.nvim_get_current_win()
	-- vim.api.nvim_set_current_win(current_win)

	resultBuffernr = vim.api.nvim_create_buf(false, true)
	assert(resultBuffernr, "Failed to create buffer")

	vim.api.nvim_win_set_buf(new_win, resultBuffernr)

	-- local win_id = vim.api.nvim_open_win(resultBuffernr, true, config.get("windowOpts"))

	return resultBuffernr
end

local M = {}
M.displayResults = function(testCaseInputs, testCaseAnswers, testCaseOutputs, testCaseTimeTaken, testCaseErrors)
	local bufnr = getResultsBuffer()

	local print = function(text, hg_name)
		local start = vim.api.nvim_buf_line_count(bufnr)
		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, text)
		if hg_name then
			for linenr = start, start + #text - 1 do
				vim.api.nvim_buf_add_highlight(bufnr, -1, hg_name, linenr, 0, -1)
			end
		end
	end

	local tcnr = #testCaseInputs
    hg.init()

	for tci = 1, tcnr do
		print({
			"***********************",
			"Test Case: " .. tci,
			"***********************",
		}, hg.title)
		print({ "", "Input:" }, hg.subtitle)
		print(testCaseInputs[tci])
		print({
			"",
			"Output:",
		}, hg.subtitle)
		print(testCaseOutputs[tci])
		if testCaseErrors[tci] then
			print({
				"",
				"Errors:",
			}, hg.subtitle)
			print(testCaseErrors[tci])
		end
		print({
			"",
			"",
			"Expected:",
		}, hg.subtitle)
		print(testCaseAnswers[tci])
		print({
			"",
			"Diff:",
		}, hg.subtitle)
		print({
			"",
			"",
			"Result:",
		}, hg.subtitle)
		print({ "Time Taken " .. testCaseTimeTaken[tci] .. "s" })
	end
end

return M
