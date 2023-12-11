local M = {}
local resultBuffernr = 0

M.getResultsBuffer = function()
    if vim.api.nvim_buf_is_valid(resultBuffernr) then
        return resultBuffernr
    end

	resultBuffernr = vim.api.nvim_create_buf(false, true)
    assert(resultBuffernr, "Failed to create buffer")

	local win_id = vim.api.nvim_open_win(resultBuffernr, true, {
		relative = "editor",
		width = 30,
		height = 10,
		row = 5,
		col = 5,
		style = "minimal",
		border = "single",
	})

	return resultBuffernr
end

return M
