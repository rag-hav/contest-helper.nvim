local plugin = require("contest-helper")
vim.api.nvim_create_user_command("ContestHelperRunCode", plugin.runCode, {})
vim.api.nvim_create_user_command("ContestHelperStartServer", plugin.startServer, {})
vim.api.nvim_create_user_command("ContestHelperStopServer", plugin.stopServer, {})
