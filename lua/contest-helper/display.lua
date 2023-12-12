local config = require("contest-helper.config")

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

	local print = function(lines)
		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
	end

	local tcnr = #testCaseInputs

	for tci = 1, tcnr do
		print({
			"***********************",
			"Test Case: " .. tci,
			"***********************",
			"",
			"Input:",
		})
		print(testCaseInputs[tci])
		print({
			"",
			"Output:",
		})
		print(testCaseOutputs[tci])
		if testCaseErrors[tci] then
			print({
				"",
				"Errors:",
			})
			print(testCaseErrors[tci])
		end
		print({
			"",
			"",
			"Expected:",
		})
		print(testCaseAnswers[tci])
		print({
			"",
			"Diff:",
		})
		print({
			"",
			"",
			"Time Taken:" .. testCaseTimeTaken[tci],
		})
	end
end

return M
