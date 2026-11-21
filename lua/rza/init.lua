local M = {}

function M.setup(opts)
    opts = opts or {}
    local cmd = opts.cmd or { "rez3asm", "--lsp" }
    if type(cmd) ~= "table" then error("cmd must be a table") end
    local root_type = type(opts.root_dir)
    if root_type ~= "nil" and root_type ~= "string" and root_type ~= "function" then
        error("root_dir must be a string, function, or nil")
    end

    local group = vim.api.nvim_create_augroup("RzaLsp", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "rza",
        callback = function(args)
            local root_dir = opts.root_dir
            if type(root_dir) == "function" then root_dir = root_dir(args.buf) end
            if not root_dir then
                root_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf))
            end
            vim.lsp.start({
                name = "rza",
                cmd = cmd,
                root_dir = root_dir,
            })
        end,
    })
end

return M
