local failures = {}
local starts = {}
local original_start = vim.lsp.start

local function check(condition, message)
    if not condition then table.insert(failures, message) end
end

vim.lsp.start = function(config)
    table.insert(starts, config)
    return #starts
end

vim.opt.runtimepath:prepend(vim.fn.getcwd())
local rza = require("rza")
rza.setup({
    cmd = { "custom-rez3asm", "--lsp" },
    root_dir = function(buf) return "/tmp/rza-custom-" .. buf end,
})
vim.cmd("filetype plugin on")
vim.cmd("edit test/fixtures/valid.rza")

check(#starts == 1, "first FileType must start one client")
check(starts[1] and starts[1].cmd[1] == "custom-rez3asm",
    "setup must forward the custom command")
local first_buf = vim.api.nvim_get_current_buf()
check(starts[1] and starts[1].root_dir == "/tmp/rza-custom-" .. first_buf,
    "custom root_dir must receive the buffer number")

rza.setup()
vim.cmd("edit test/fixtures/lsp.rza")
check(#starts == 2, "repeated setup must replace, not stack, the autocmd")
check(starts[2] and starts[2].cmd[1] == "rez3asm" and starts[2].cmd[2] == "--lsp",
    "setup must default to rez3asm --lsp")
local second_name = vim.api.nvim_buf_get_name(0)
check(starts[2] and starts[2].root_dir == vim.fs.dirname(second_name),
    "default root_dir must be the document directory")
local before_invalid = vim.api.nvim_get_autocmds({ group = "RzaLsp" })
check(#before_invalid == 1, "valid setup must leave exactly one autocmd")
check(not pcall(rza.setup, { cmd = "rez3asm" }), "string cmd must be rejected")
check(not pcall(rza.setup, { root_dir = 42 }), "numeric root_dir must be rejected")
local after_invalid = vim.api.nvim_get_autocmds({ group = "RzaLsp" })
check(#after_invalid == 1 and after_invalid[1].id == before_invalid[1].id,
    "invalid setup options must preserve the existing autocmd")

vim.lsp.start = original_start
if #failures > 0 then
    for _, message in ipairs(failures) do vim.api.nvim_err_writeln(message) end
    vim.cmd("cquit")
else
    vim.api.nvim_out_write("Neovim setup checks passed\n")
    vim.cmd("qa!")
end
