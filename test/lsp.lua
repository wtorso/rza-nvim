local failures = {}
local timeout_ms = 5000
local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients

local function check(condition, message)
    if not condition then
        table.insert(failures, message)
    end
end

local compiler = vim.env.RZA_COMPILER
if not compiler or compiler == "" then
    error("RZA_COMPILER is required for the LSP integration test")
end

local publications = {}
local default_publish = vim.lsp.handlers["textDocument/publishDiagnostics"]
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
    publications[result.uri] = (publications[result.uri] or 0) + 1
    default_publish(err, result, ctx, config)
end

vim.opt.runtimepath:prepend(vim.fn.getcwd())
require("rza").setup({ cmd = { compiler, "--lsp" } })
vim.cmd("filetype plugin on")

local function open_and_check(path, expected_message)
    vim.cmd("edit " .. path)
    local buf = vim.api.nvim_get_current_buf()
    local uri = vim.uri_from_bufnr(buf)
    local before = publications[uri] or 0
    local attached = vim.wait(timeout_ms, function()
        return #get_clients({ bufnr = buf, name = "rza" }) > 0
    end, 50)
    local clients = get_clients({ bufnr = buf, name = "rza" })
    check(attached and #clients == 1, "expected one rza client, got " .. #clients)
    if #clients == 0 then return nil end

    local received = vim.wait(timeout_ms, function()
        if (publications[uri] or 0) <= before then return false end
        local current = vim.diagnostic.get(buf)
        if not expected_message then return #current == 0 end
        for _, item in ipairs(current) do
            if string.find(item.message, expected_message, 1, true) then return true end
        end
        return false
    end, 50)
    check(received, "diagnostic publication mismatch: " .. vim.inspect(vim.diagnostic.get(buf)))
    return clients[1].id
end

local first_id = open_and_check("test/fixtures/valid.rza", nil)
local second_id = open_and_check("test/fixtures/lsp.rza", "unknown op bogus")
check(first_id and first_id == second_id, "same-root files must reuse one client")
check(#get_clients({ name = "rza" }) == 1, "expected one global rza client")

vim.lsp.handlers["textDocument/publishDiagnostics"] = default_publish
for _, client in ipairs(get_clients({ name = "rza" })) do
    client:stop(true)
end

if #failures > 0 then
    for _, message in ipairs(failures) do
        vim.api.nvim_err_writeln(message)
    end
    vim.cmd("cquit")
else
    vim.api.nvim_out_write("Neovim LSP integration checks passed\n")
    vim.cmd("qa!")
end
