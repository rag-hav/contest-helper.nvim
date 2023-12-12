local config = require ( "contest-helper.config" )

local resultBuffernr = 0

local getResultsBuffer = function()
    if vim.api.nvim_buf_is_valid(resultBuffernr) then
        return resultBuffernr
    end

	resultBuffernr = vim.api.nvim_create_buf(false, true)
    assert(resultBuffernr, "Failed to create buffer")

	local win_id = vim.api.nvim_open_win(resultBuffernr, true, config.get("windowOpts"))

	return resultBuffernr
end

local M = {}
M.displayResults = function(testCaseInputs, testCaseAnswers, testCaseOutputs, testCaseTimeTaken, testCaseErrors)
    local bufnr = getResultsBuffer()


end

return M
