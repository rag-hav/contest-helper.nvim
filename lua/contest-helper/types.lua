---@meta
-- https://github.com/jmerle/competitive-companion#the-format
---@class CCData
---@field name string The full name of the problem. Can be used for display purposes.
---@field group string Used to group problems together, which can be useful for archiving purposes. Follows the format <judge> - <category>, where the hyphen is discarded if the category is empty.
---@field url string A link to the problem on the judge's website.
---@field interactive? boolean Whether this is an interactive problem or not.
---@field memoryLimit integer The memory limit in MB.
---@field timeLimit integer The time limit in ms.
---@field tests CCDataTestCase[] An array of objects containing testcase data. The JSON objects in the array all have two keys: input and output. Both the input and the output need to end with a newline character.
---@field testType CCDataTestType The type of the tests.
---@field input CCDataInputType An object which is used to configure how to receive input.
---@field output CCDataOutputType An object which is used to configure how to send output.
---@field languages CCDataLanguage An object with language specific settings.
---@field batch CCDataBatch An object containing information about the batch of problems that this problem belongs to. Required options:

---@class CCDataTestCase
---@field input string
---@field output string

---@alias CCDataTestType
---| '"single"'  The left side of the device
---| '"multiNumber"'  The right side of the device

---@class CCDataInputType
---@field type CCDataInputTypeType
---@field pattern? string
---@field fileName? string

---@alias CCDataInputTypeType
---| '"stdin"' Receive input via stdin. No additional options required.
---| '"file"'  Receive input via a file. The file name has to be given via the fileName option.
---| '"regex"' Receive input via a file. The file to use is selected by taking the most recently modified that matches the given regex. The regex pattern to use has to be given via the pattern option.

---@class CCDataOutputType
---@field type CCataOutputTypeType
---@field fileName? string

---@alias CCataOutputTypeType
---| '"stdout"' Send output to stdout. No additional options required.
---| '"file"'   Send output to a file. The file name has to be given via the fileName option.

---@class CCDataLanguage
---@field java CCDataLanguageJava An object with Java specific settings

---@class CCDataLanguageJava
---@field mainClass string The name of the outer class containing the solution.
---@field taskClass string The classname-friendly version of the problem's full name. Cannot be the same as mainClass. Can also be useful for non-Java tools because a classname-friendly string is also a filename-friendly string.

---@class CCDataBatch
---@field id string A UUIDv4 string which uniquely identifies a batch. All problems in a batch have the same batch id.
---@field size integer The size of the batch, which is 1 when using a problem parser and the amount of problems in the contest when using a contest parser.

---@class Config
---@field buildFunctions table<string, fun() : string>
---@field createTestCases boolean
---@field getProblemExtension string|string[]|fun(ExtensionData): string
---@field getProblemTemplate? SolutionTemplate|table<string, fun() : SolutionTemplate>
---@field getProblemFolder string|fun(ExtensionData): string
---@field getProblemName fun(ExtensionData): string
---@field postRunHook? fun(boolean, RunResult): string[], string
---@field openProblemFile boolean
---@field startServerOnStartup boolean
---@field testCaseTimeout integer
---@field trimFollowingBlankLines boolean
---@field trimFollowingWhitespaces boolean
---@field trimPrecedingBlankLines boolean
---@field trimPrecedingWhitespaces boolean
---@field seekToFailedTestCase boolean
---@field ignoreOutputPatterns? string[]

---@alias SolutionTemplate string|string[]
---@alias RunResult integer[]

---@class DiffResult
---@field status boolean
---@field message? string
---@field differences? DiffItem[]

---@class DiffItem
---@field i integer
---@field answer string
---@field output string
