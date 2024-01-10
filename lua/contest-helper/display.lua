local utils = require("contest-helper.utils")
local hg = require("contest-helper.highlights")
local config = require("contest-helper.config")

local resultBufnr = -1
local resultWindow = -1

local M = {}

M.clearResults = function()
	if vim.api.nvim_buf_is_valid(resultBufnr) then
		vim.api.nvim_buf_set_option(resultBufnr, "modifiable", true)
		vim.api.nvim_buf_set_lines(resultBufnr, 1, -1, false, {})
		vim.api.nvim_buf_set_option(resultBufnr, "modifiable", false)
	end
end

M.displayResults =
	---@param testCaseInputs string[][]
	---@param testCaseAnswers string[][]
	---@param testCaseOutputs string[][]
	---@param testCaseErrors string[][]
	---@param testCaseTimeTaken string[]
	---@param exitCodes integer[]
	function(testCaseInputs, testCaseAnswers, testCaseOutputs, testCaseErrors, testCaseTimeTaken, exitCodes)
		local old_win = vim.api.nvim_get_current_win()

		if not vim.api.nvim_buf_is_valid(resultBufnr) then
			hg.init()
			resultBufnr = vim.api.nvim_create_buf(false, true)
			assert(resultBufnr, "Failed to create buffer")
		end

		---@diagnostic disable-next-line: param-type-mismatch
		if vim.fn.getbufinfo(resultBufnr)[1].hidden == 1 then
			vim.api.nvim_command("vertical 50 split")
			resultWindow = vim.api.nvim_get_current_win()

			vim.api.nvim_win_set_buf(resultWindow, resultBufnr)
			vim.api.nvim_buf_set_option(resultBufnr, "filetype", "runresult")
			vim.cmd("setlocal nornu")
			vim.cmd("setlocal nonu")
		end

		vim.api.nvim_buf_set_option(resultBufnr, "modifiable", true)
		local nsid = vim.api.nvim_create_namespace("contest-helper")


		---@param text? string[]
		---@param hg_name? string
		---@param show_virtual_linenr? boolean
		local print = function(text, hg_name, show_virtual_linenr)
			if not text then
				return
			end
			local start = vim.api.nvim_buf_line_count(resultBufnr)
            if start == 1 then -- remove empty space from top
                start = 0
            end
			vim.api.nvim_buf_set_lines(resultBufnr, start, -1, false, text)
			if hg_name then
				for linenr = start, start + #text - 1 do
					vim.api.nvim_buf_add_highlight(resultBufnr, nsid, hg_name, linenr, 0, -1)
				end
			end
			if show_virtual_linenr then
				for linenr = start, start + #text - 1 do
					local i = tostring(linenr - start + 1)
					vim.api.nvim_buf_set_extmark(
						resultBufnr,
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
		local failedTcLinenr = -1
		local statuses = {}
		for tci = 1, tcnr do
			testCaseAnswers[tci] = trimLineList(testCaseAnswers[tci])
			testCaseOutputs[tci] = trimLineList(testCaseOutputs[tci])
			testCaseErrors[tci] = trimLineList(testCaseErrors[tci] or {})
			testCaseInputs[tci] = trimLineList(testCaseInputs[tci])

			local diff = utils.createDiff(testCaseAnswers[tci], testCaseOutputs[tci], config.options.ignoreOutputPatterns)
			statuses[tci] = diff.status
			if not diff.status then
				passed = false
				failedTcLinenr = vim.api.nvim_buf_line_count(resultBufnr) + 2
			end

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
						local linenr = vim.api.nvim_buf_line_count(resultBufnr)
						vim.api.nvim_buf_set_lines(resultBufnr, -1, -1, false, { d.output .. d.answer })

						vim.api.nvim_buf_add_highlight(resultBufnr, nsid, hg.diffoutput, linenr, 0, #d.output)
						vim.api.nvim_buf_add_highlight(resultBufnr, nsid, hg.diffanswer, linenr, #d.output, -1)
						vim.api.nvim_buf_set_extmark(
							resultBufnr,
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
			if exitCodes[tci] < 0 then
				print({ "Timed out " .. testCaseTimeTaken[tci] .. "s" })
				statuses[tci] = -1
			else
				print({ "Time Taken " .. testCaseTimeTaken[tci] .. "s" })
				if exitCodes[tci] ~= 0 then
					print({ "Exited with return code " .. exitCodes[tci] })
				end
			end
		end

		if passed then
			print({ "", "", "Sample Test Cases Passed" }, hg.resultgood)
		else
			print({ "", "", "Sample Test Cases Failed" }, hg.resultbad)
		end

		vim.api.nvim_set_current_win(old_win)

		if config.options.postRunHook then
			print(config.options.postRunHook(passed, statuses))
		end
		vim.api.nvim_buf_set_option(resultBufnr, "modifiable", false)

		if config.options.seekToFailedTestCase and failedTcLinenr > 0 then
			vim.api.nvim_win_set_cursor(resultWindow, { failedTcLinenr, 0 })
			vim.api.nvim_set_current_win(resultWindow)
		end
	end

return M
