local config = require("contest-helper.config")
local utils = require("contest-helper.utils")
local display = require("contest-helper.display")

local M = {}
M.runTestCase = function()
	local problemName = vim.fn.expand("%:t:r")
	local dir = utils.getProblemDir(problemName)

	if vim.fn.isdirectory(dir) ~= 1 then
		vim.notify("No Testcases for current file")
		return
	end

	local bufferType = vim.fn.expand("%:e")
	local executeCmdGetter = config.options.buildFunctions[bufferType]
	if not executeCmdGetter then
		vim.notify("No builder defined for filetype " .. bufferType)
		return
	end

    display.clearResults()
	local executeCmd = executeCmdGetter()

	local testCaseNumber = 1
	local jobIds = {}

	-- All test case data
	local testCaseInputs = {}
	local testCaseAnswers = {}
	local testCaseOutputs = {}
	local testCaseTimeTaken = {}
	local testCaseErrors = {}

	repeat
		local inFile = dir .. "/" .. testCaseNumber .. ".in"
		local ansFile = dir .. "/" .. testCaseNumber .. ".ans"
		if not vim.fn.filereadable(inFile) or not vim.fn.filereadable(ansFile) then
			break
		end

		local inFileStream = io.open(inFile, "r")
		assert(inFileStream, "failed to read input test case file")
		testCaseInputs[testCaseNumber] = vim.split(inFileStream:read("*a"), "\n")
		inFileStream:close()

		local ansFileStream = io.open(ansFile, "r")
		assert(ansFileStream, "failed to read answer test case file")
		testCaseAnswers[testCaseNumber] = vim.split(ansFileStream:read("*a"), "\n")
		ansFileStream:close()

		---@diagnostic disable-next-line: missing-parameter
		testCaseTimeTaken[testCaseNumber] = vim.fn.reltime() -- store job start time

		local jobid = vim.fn.jobstart(executeCmd, {
			on_stdout = function(_, data, _)
				testCaseOutputs[testCaseNumber] = data
			end,
			on_stderr = function(_, data, _)
				if #data > 0 and (#data ~= 1 or data[1] ~= "") then
					testCaseErrors[testCaseNumber] = data
				end
			end,
			on_exit = function()
				---@diagnostic disable-next-line: missing-parameter
				testCaseTimeTaken[testCaseNumber] = vim.fn.split(vim.fn.reltimestr(vim.fn.reltime(testCaseTimeTaken[testCaseNumber])))[1] -- store time taken
			end,
			stdout_buffered = true,
			stderr_buffered = true,
		})
		assert(
			jobid > 0,
			"Invalid job id (see :help jobstart). job-id: " .. jobid .. "\n Execute Command Used: " .. executeCmd
		)
		jobIds[testCaseNumber] = jobid

		vim.fn.chansend(jobid, testCaseInputs[testCaseNumber])
	until true

	vim.fn.jobwait(jobIds, config.options.testCaseTimeout)

	display.displayResults(testCaseInputs, testCaseAnswers, testCaseOutputs, testCaseErrors, testCaseTimeTaken)
end

return M
