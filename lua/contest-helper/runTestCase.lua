local config = require("contest-helper.config")
local display = require("contest-helper.display")

local M = {}
M.runTestCases = function()
	local bufferName = vim.fn.expand("%:t")
	local dir = config.getProblemDir(bufferName, false)

	if not dir then
		vim.notify("No Testcases for current file")
		return
	end

	local bufferType = vim.fn.expand("%:e")
	local executeCmd = config.buildFunctions[bufferType]()

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
		testCaseInputs[testCaseNumber] = inFileStream:read()
		inFileStream:close()

		local ansFileStream = io.open(ansFile, "r")
		assert(ansFileStream, "failed to read answer test case file")
		testCaseAnswers[testCaseNumber] = ansFileStream:read()
		ansFileStream:close()

		---@diagnostic disable-next-line: missing-parameter
		testCaseTimeTaken[testCaseNumber] = vim.fn.reltime() -- store job start time

		local jobid = vim.fn.jobstart(executeCmd, {
			on_stdout = function(data)
				testCaseOutputs[testCaseNumber] = data
			end,
			on_stderr = function(data)
				testCaseErrors[testCaseNumber] = data
			end,
			on_exit = function()
				---@diagnostic disable-next-line: missing-parameter
				testCaseTimeTaken[testCaseNumber] = vim.fn.reltime(testCaseTimeTaken[testCaseNumber]) -- store time taken
			end,
			stdout_buffered = true,
			stderr_buffered = true,
		})
		assert(jobid <= 0, "Invalid job id (see :help jobstart). job-id: " .. jobid)
		jobIds[testCaseNumber] = jobid

		vim.fn.chansend(jobid, testCaseInputs[testCaseNumber])
	until true

	vim.fn.jobwait(jobIds, config.testCaseTimeout)

	display.displayResults(testCaseInputs, testCaseAnswers, testCaseOutputs, testCaseTimeTaken, testCaseErrors)
end

return M