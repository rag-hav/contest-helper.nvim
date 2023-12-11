local port = 10043

local makePathSafe = function(inputPath)
	return string.gsub(inputPath, '[<>:"/\\|?*]', "_")
end

local getProblemDir = function(name, shouldCreate)
	local dir = vim.fn.stdpath("data") .. "/contest-helper.nvim/" .. name
	if vim.fn.isdirectory(dir) then
		return dir
	end
	if shouldCreate then
		vim.fn.mkdir(dir, "p")
		return dir
	end
end

local getProblemName = function(data)
	return data.name
end

local processClick = function(data)
	local name = getProblemName(data)
	local dir = getProblemDir(makePathSafe(name), true)

	for k, v in ipairs(data.tests) do
		for _, x in ipairs({ { ".in", v.input }, { ".ans", v.output } }) do
			local file = io.open(dir .. "/" .. k .. x[1], "w")
			assert(file, "failed to create file")
			file:write(x[2])
			file:close()
		end
	end
end

local buildFunctions = {
	["cpp"] = function()
		local exc = vim.fn.expand("%:r")
		vim.fn.system("make " .. exc)
		return exc
	end,
}

local runTestCases = function()
	local bufferName = vim.fn.expand("%:t")
	local dir = getProblemDir(bufferName, false)

	if not dir then
		vim.notify("No Testcases for current file")
		return
	end

	local bufferType = vim.fn.expand("%:e")
	local executeCmd = buildFunctions[bufferType]()

	local testCaseNumber = 1
    local jobIds = {}

    local testCaseInputs = {}
    local testCaseAnswers = {}
    local testCaseOutputs = {}
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

		local jobid = vim.fn.jobstart(executeCmd, {
            on_stdout = function (data)
                testCaseOutputs[testCaseNumber] = data
            end,
            on_stderr = function (data)

                testCaseErrors[testCaseNumber] = data
            end,
            stdout_buffered = true,
            stderr_buffered = true
        })
		assert(jobid <= 0, "Invalid job id (see :help jobstart). job-id: " .. jobid)
        jobIds[testCaseNumber] = jobid

        vim.fn.chansend(jobid, testCaseInputs[testCaseNumber] )
	until true

    vim.fn.jobwait(jobIds, 10000)

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {"Hello, this is a new buffer!"})

    local win_id = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = 30,
        height = 10,
        row = 5,
        col = 5,
        style = "minimal",
        border = "single",
    })

end

function ftester(qid)
	-- a is the filename
	local a = qid
	-- b is the filename without extension
	local b = qid

	local function executeTest(i)
		local caseIn = string.format(".%s_in%d", a, i)
		local caseAns = string.format(".%s_ans%d", a, i)
		local caseOut = string.format(".%s_out%d", a, i)

		if vim.fn.filereadable(caseIn) == 0 then
			vim.api.nvim_out_write(string.format("No test case for %s\n", a))
			return
		end

		local command = string.format("time -o timetmp -f 'Time Taken %%e\\n' ./%s <%s >%s 2>err", b, caseIn, caseOut)
		vim.fn.system(command)

		vim.api.nvim_out_write(
			string.format("\n\n****************************\nTest Case: %d\n****************************", i)
		)
		vim.api.nvim_out_write(string.format("\nInput: \n%s", vim.fn.readfile(caseIn)))
		vim.api.nvim_out_write(string.format("\n\nOutput: \n%s", vim.fn.readfile(caseOut)))

		if vim.fn.filereadable("err") == 1 then
			vim.api.nvim_out_write(string.format("\n\nErrors: \n%s", vim.fn.readfile("err")))
		end

		vim.api.nvim_out_write(string.format("\n\nExpected: \n%s", vim.fn.readfile(caseAns)))
		vim.api.nvim_out_write(string.format("\n\nDiff: \n"))
		-- Perform diff and display results here

		vim.api.nvim_out_write(string.format("\n\nResult: \n%s", vim.fn.readfile("timetmp")))

		vim.fn.delete("timetmp")
		vim.fn.delete("err")
	end

	local i = 1
	local success = true

	while vim.fn.filereadable(string.format(".%s_in%d", a, i)) == 1 do
		executeTest(i)
		i = i + 1
	end

	if success then
		vim.api.nvim_out_write("Sample test cases passed\n")
		submit(b)
	else
		vim.api.nvim_out_write("Sample test cases failed\n")
	end
end

local run = function()
	local uv = vim.loop
	local server = uv.new_tcp()
	assert(server, "failed to bind port")
	server:bind("127.0.0.1", port)
	server:listen(128, function(err)
		assert(not err, err)
		local client = uv.new_tcp()
		assert(client, "failed to accept connection")
		server:accept(client)
		local buffer = {}
		client:read_start(function(err, chunk)
			assert(not err, err)
			if chunk then
				table.insert(buffer, chunk)
			else
				local received = table.concat(buffer)
				local _, bodystart = received:find("\r\n\r\n")
				local jsontxt = received:sub(bodystart + 1)

				vim.schedule(function()
					local result = vim.fn.json_decode(jsontxt)
					processClick(result)
				end)

				client:shutdown()
				client:close()
			end
		end)
	end)
	print("TCP server listening at 127.0.0.1 port " .. port)
	uv.run()
end

run()
