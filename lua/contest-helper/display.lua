local utils = require("contest-helper.utils")
local hg = require("contest-helper.highlights")
local config = require("contest-helper.config")

local resultBuffernr = -1

---@return integer
local getResultsBuffer = function()
	-- vim.notify(vim.inspect( vim.api.nvim_buf_is_valid(resultBuffernr)) )
	if not vim.api.nvim_buf_is_valid(resultBuffernr) then
        hg.init()
		resultBuffernr = vim.api.nvim_create_buf(false, true)
	end

	---@diagnostic disable-next-line: param-type-mismatch
	if vim.fn.getbufinfo(resultBuffernr)[1].hidden == 1 then
		vim.api.nvim_command("vertical 50 split")
		local new_win = vim.api.nvim_get_current_win()
		-- vim.api.nvim_set_current_win(current_win)

		assert(resultBuffernr, "Failed to create buffer")

		vim.api.nvim_win_set_buf(new_win, resultBuffernr)
		vim.api.nvim_buf_set_option(resultBuffernr, "filetype", "runresult")
		vim.cmd("setlocal nornu")
		vim.cmd("setlocal nonu")
	end

	return resultBuffernr
end

local M = {}

M.clearResults = function()
	if vim.api.nvim_buf_is_valid(resultBuffernr) then
		vim.api.nvim_buf_set_option(resultBuffernr, "modifiable", true)
		vim.api.nvim_buf_set_lines(resultBuffernr, 1, -1, false, {})
		vim.api.nvim_buf_set_option(resultBuffernr, "modifiable", false)
	end
end

---@param testCaseInputs string[][]
---@param testCaseAnswers string[][]
---@param testCaseOutputs string[][]
---@param testCaseErrors string[][]
---@param testCaseTimeTaken string[]
M.displayResults = function(testCaseInputs, testCaseAnswers, testCaseOutputs, testCaseErrors, testCaseTimeTaken)
	local bufnr = getResultsBuffer()
	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
	local nsid = vim.api.nvim_create_namespace("contest-helper")

	---@param text string[]
	---@param hg_name? string
	---@param show_virtual_linenr? boolean
	local print = function(text, hg_name, show_virtual_linenr)
		local start = vim.api.nvim_buf_line_count(bufnr)
		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, text)
		if hg_name then
			for linenr = start, start + #text - 1 do
				vim.api.nvim_buf_add_highlight(bufnr, nsid, hg_name, linenr, 0, -1)
			end
		end
		if show_virtual_linenr then
			for linenr = start, start + #text - 1 do
				local i = tostring(linenr - start + 1)
				vim.api.nvim_buf_set_extmark(
					bufnr,
					nsid,
					linenr,
					0,
					{ virt_text = { { tostring(i), hg.linenr } }, virt_text_pos = "right_align" }
				)
			end
		end
	end

	---@param lines string[]
	---@return string[]
	local trimLineList = function(lines)
		return utils.trimLineList(
			lines,
			config.options.trimPrecedingWhitespaces,
			config.options.trimFollowingWhitespaces,
			config.options.trimPrecedingBlankLines,
			config.options.trimFollowingBlankLines
		)
	end

	local tcnr = #testCaseInputs
	local passed = true
	for tci = 1, tcnr do
		testCaseAnswers[tci] = trimLineList(testCaseAnswers[tci])
		testCaseOutputs[tci] = trimLineList(testCaseOutputs[tci])
		testCaseErrors[tci] = trimLineList(testCaseErrors[tci] or {})
		testCaseInputs[tci] = trimLineList(testCaseInputs[tci])

		local diff = utils.createDiff(testCaseAnswers[tci], testCaseOutputs[tci])
		passed = passed and diff.status

		print({
			"***********************",
			"Test Case: " .. tci,
			"***********************",
		}, diff.status and hg.testcasegood or hg.testcasebad)
		print({ "", "Input:" }, hg.subtitle)
		print(testCaseInputs[tci], nil, true)
		print({
			"",
			"",
			"Output:",
		}, hg.subtitle)
		print(testCaseOutputs[tci], nil, true)
		if #testCaseErrors[tci] > 0 then
			print({
				"",
				"",
				"Errors:",
			}, hg.subtitle)
			print(testCaseErrors[tci], nil, true)
		end
		print({
			"",
			"",
			"Expected:",
		}, hg.subtitle)
		print(testCaseAnswers[tci], nil, true)

		if not diff.status then
			print({
				"",
				"",
				"Diff:",
			}, hg.subtitle)

			if diff.message then
				print({ diff.message })
			else
				-- vim.api.nvim_buf_set_extmark()
				for _, d in ipairs(diff.differences) do
					local linenr = vim.api.nvim_buf_line_count(bufnr)
					vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { d.output .. d.answer })

					vim.api.nvim_buf_add_highlight(bufnr, nsid, hg.diffoutput, linenr, 0, #d.output)
					vim.api.nvim_buf_add_highlight(bufnr, nsid, hg.diffanswer, linenr, #d.output, -1)
					vim.api.nvim_buf_set_extmark(
						bufnr,
						nsid,
						linenr,
						0,
						{ virt_text = { { tostring(d.i), hg.linenr } }, virt_text_pos = "right_align" }
					)
				end
			end
		end

		print({
			"",
			"",
			"Result:",
		}, hg.subtitle)
		print({ "Time Taken " .. testCaseTimeTaken[tci] .. "s" })
	end

	if passed then
		print({ "", "", "Sample Test Cases Passed" }, hg.resultgood)
	else
		print({ "", "", "Sample Test Cases Failed" }, hg.resultbad)
	end

	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

return M
