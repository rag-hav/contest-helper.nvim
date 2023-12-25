This Neovim plugin is meant to be used with [Competitive Companion Extension](https://github.com/jmerle/competitive-companion)


## Features
* Load test cases of problem.
* Open solution file for the problem.
* Run the solution file on the sample test cases.
* View differences between expected output and current output.

## Install

You can use Lazy to install the plugin-

```lua
{
    "rag-hav/contest-helper.nvim",
    config = function()
        require("contest-helper").setup()
    end,
}

```

## Configuration

The plugin has following configuration options-

```lua
local getSiteName = function(url, fallback)
    for _, site in ipairs({ "codeforces", "codechef", "atcoder", "hackerearth", "hackerrank", "spoj", "cses" }) do
        if string.find(url, site) then
            return site
        end
    end
    return fallback
end

require("contest-helper").setup({
    -- Wether to start server (to listen to problems), when the plugin is loaded.
    -- Only one instance of server can run.
    -- If you have multiple neovim instances open, only the first one will have a running server
    startServerOnStartup = true,

    -- Use these options to clean the files before displaying and differencing output with expected
    -- Wether to trim preceding whitespace from lines in input, output and expected, ex " 0 1 2" -> "0 1 2"
    trimPrecedingWhitespaces = false,
    -- similar to above, ex "0 1 2 " -> "0 1 2"
    trimFollowingWhitespaces = false,
    -- Wether to remove blank lines from the start of input, output and expected, ex "\n1 2 3\n4 5 6\n" -> "1 2 3\n4 5 6\n"
    trimPrecedingBlankLines = true,
    -- Similar to above, ex "1 2 3\n4 5 6\n\n" -> "1 2 3\n4 5 6\n"
    trimFollowingBlankLines = true,

    -- returns name for the problem file.
    -- data is of the type CCData (lua/contest-helper/types.lua)
    -- from https://github.com/jmerle/competitive-companion?tab=readme-ov-file#the-format
    getProblemName = function(data)
        local site = getSiteName(data.url, "misc")
        local parts = vim.split(data.url, "/")
        local name = data.name

        if site == "codechef" then
            name = parts[#parts]:gsub("tabstatement", "")
        end

        if site == "codeforces" then
            name = (parts[#parts - 2] .. parts[#parts - 1] .. parts[#parts])
                :gsub("problem", "")
                :gsub("contest", "")
        end

        if site == "atcoder" then
            name = parts[#parts]
        end

        name = string.gsub(name, "\\W", "") -- remove non alpha numeric characters
        return name
    end,

    -- Folder where the file should be created
    -- Can be a function taking CCData and returning string, or a string itself
    getProblemFolder = function(data)
        local site = getSiteName(data.url, "misc")
        return "~/cc/" .. site
    end,
    -- Extension of the solution file to the problem
    -- Can be a function taking CCData and returning string, a string, or a list of strings
    -- if it is a list of string then a selector will open to select an extension from that list
    -- getProblemExtension = {"cpp", "py", "java"},
    -- getProblemExtension = function(data) return "cpp" end
    getProblemExtension = "cpp",

    -- Wether to store the test cases received from competitive-companion
    -- These are stored in 'data' stdpath (see :help stdpath)
    createTestCases = true,

    openProblemFile = true, -- Wether to open the problem file

    -- A table (dictionary) of extension and their corresponding build function
    -- the build function is responsible for creating a executable file
    -- it should return a string that can be directly executed
    buildFunctions = {
        cpp = function()
            local exc = vim.fn.expand("%:r")
            vim.fn.system("make " .. exc)
            return vim.fn.expand("%:p:r")
        end,
        py = function()
            return "python3 " .. vim.fn.expand("%:p")
        end,
        java = function()
            local exc = vim.fn.expand("%:p")
            vim.fn.system("javac " .. exc)
            return "java " .. vim.fn.expand("%:p:r")
        end,
    },

    -- (millisecond) how long to wait for each test case to be executed before timeout
    testCaseTimeout = 10000,
})
```


## Commands 

The plugin exposes following methods and commands 
| Command                  | Lua Method  | Description                                    |
| ----                     | -------     | ---                                            |
| ContestHelperRunCode     | runCode     | Run the current file against sample test cases |
| ContestHelperStartServer | startServer | Start listening for new problems               |
| ContestHelperStopServer  | stopServer  | Stop listening                                 |

It is recommended to use 'startServerOnStartup' option and create a keybinding for running test cases.

Ex-
```lua
vim.api.nvim_set_keymap("n", "<C-r>", "<cmd>w<cr><cmd>ContestHelperRunCode<cr>", {})
```

