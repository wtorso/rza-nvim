local failures = {}
local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients

local function check(condition, message)
    if not condition then
        table.insert(failures, message)
    end
end

local function group_at(line, column)
    return vim.fn.synIDattr(vim.fn.synID(line, column, 1), "name")
end

local function check_group(line, column, expected)
    check(group_at(line, column) == expected,
        string.format("line %d column %d: expected %s, got %s",
            line, column, expected, group_at(line, column)))
end

vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.cmd("filetype plugin on")
vim.cmd("syntax enable")
vim.cmd("edit test/fixtures/sample.rza")

check(vim.bo.filetype == "rza", "filetype must be rza, got " .. vim.bo.filetype)
check(vim.bo.commentstring == "; %s",
    "commentstring must be '; %s', got " .. vim.bo.commentstring)
check(#get_clients() == 0, "highlighting must not start an LSP client")

check_group(1, 1, "rzaKeyword")
check_group(1, 8, "rzaLayout")
check_group(1, 19, "rzaScalarType")
check_group(1, 30, "rzaScalarType")
check_group(2, 21, "rzaLayout")
check(group_at(1, 8) ~= group_at(1, 19), "layout and scalar types must differ")
check_group(2, 14, "rzaConstant")
check_group(3, 26, "rzaConstant")
check_group(4, 5, "rzaRegister")
check_group(5, 5, "rzaRegister")
check_group(4, 10, "rzaNumber")
check_group(5, 11, "rzaNumber")
check_group(2, 27, "rzaNumber")
check_group(7, 24, "rzaNumber")
check_group(6, 25, "rzaField")
check_group(7, 27, "rzaField")
check_group(8, 6, "rzaLabel")
check_group(10, 1, "rzaComment")
check_group(10, 3, "rzaComment")
check_group(10, 10, "rzaComment")
check_group(10, 14, "rzaComment")
check(group_at(11, 5) == "", "%r16 must not have a syntax group")
check_group(12, 18, "rzaScalarType")
check_group(12, 30, "rzaScalarType")
check_group(12, 38, "rzaScalarType")
check_group(12, 55, "rzaScalarType")
check_group(18, 21, "rzaScalarType")
check_group(18, 31, "rzaScalarType")
check_group(19, 19, "rzaScalarType")

local opcodes = {
    "cav", "res", "med", "view", "raise", "decay", "probe", "load", "loadb",
    "mov", "store", "storeb", "slt", "inc", "dec", "await", "print",
    "jmp", "brz", "brnz", "call", "proc", "casc", "acasc", "endc", "ret",
    "layout", "add", "sub", "mul", "div", "mod", "and", "or", "xor",
    "shl", "shr", "ushr", "cadd", "csub", "cmul", "cinc", "cdec", "crc32c",
}

vim.cmd("enew")
vim.api.nvim_buf_set_lines(0, 0, -1, true, opcodes)
vim.cmd("runtime! syntax/rza.vim")
for line, opcode in ipairs(opcodes) do
    check_group(line, 1, "rzaKeyword")
end

local typed = {}
local shared = {
    "mov", "load", "store", "add", "sub", "mul", "inc", "dec",
    "cadd", "csub", "cmul", "cinc", "cdec", "and", "or", "xor",
    "div", "mod", "shl", "ushr",
}
local types = {"i8", "u8", "i16", "u16", "i32", "u32", "i64", "u64"}
for _, base in ipairs(shared) do
    for _, type in ipairs(types) do
        table.insert(typed, base .. "." .. type)
    end
end
for _, opcode in ipairs({"shr.i8", "slt.i8", "ult.u8", "shr.i16", "slt.i16", "ult.u16",
        "shr.i32", "slt.i32", "ult.u32", "shr.i64", "slt.i64", "ult.u64"}) do
    table.insert(typed, opcode)
end
check(#typed == 172, "typed matrix must contain 172 spellings")

local floating = {}
for _, base in ipairs({"mov", "load", "store", "add", "sub", "mul", "div",
        "feq", "fne", "flt", "fle", "fgt", "fge"}) do
    for _, type in ipairs({"f32", "f64"}) do
        table.insert(floating, base .. "." .. type)
    end
end
for _, float in ipairs({"f32", "f64"}) do
    for _, type in ipairs(types) do
        table.insert(floating, "cvt." .. float .. "." .. type)
        table.insert(floating, "cvt." .. type .. "." .. float)
    end
end
table.insert(floating, "cvt.f64.f32")
table.insert(floating, "cvt.f32.f64")
for _, pair in ipairs({{"f32", "i32", "u32"}, {"f64", "i64", "u64"}}) do
    local float, signed, unsigned = pair[1], pair[2], pair[3]
    for _, item in ipairs({"bitcast." .. float .. "." .. signed,
            "bitcast." .. float .. "." .. unsigned,
            "bitcast." .. signed .. "." .. float,
            "bitcast." .. unsigned .. "." .. float}) do
        table.insert(floating, item)
    end
end
check(#floating == 68, "floating matrix must contain 68 spellings")
for _, opcode in ipairs(floating) do
    table.insert(typed, opcode)
end
check(#typed == 240, "typed matrix must contain 240 spellings")

vim.cmd("enew")
vim.api.nvim_buf_set_lines(0, 0, -1, true, typed)
vim.cmd("runtime! syntax/rza.vim")
for line, opcode in ipairs(typed) do
    local suffix = string.find(opcode, ".", 1, true) + 1
    check_group(line, 1, "rzaKeyword")
    check_group(line, suffix, "rzaKeyword")
end

local inactive = {
    "shr.u8", "slt.u8", "ult.i8", "shr.u16", "slt.u16", "ult.i16",
    "shr.u32", "slt.u32", "ult.i32", "shr.u64", "slt.u64", "ult.i64",
    "ult", "loadb.u8", "loadb.u16", "loadb.u32", "loadb.u64",
    "crc32c.i32", "print.i32", "cvt.i64", "cvt.u64", "mod.f32", "mod.f64",
    "cadd.f32", "feq.i32", "cvt.f32.f32", "cvt.i32.i64", "bitcast.f64.u32",
    "mov.f16", "load.bf16", "cvt.f16.f32",
}
vim.cmd("enew")
vim.api.nvim_buf_set_lines(0, 0, -1, true, inactive)
vim.cmd("runtime! syntax/rza.vim")
local asserted_inactive = 0
for line, opcode in ipairs(inactive) do
    check(group_at(line, 1) ~= "rzaKeyword", opcode .. " base must not be a typed keyword")
    local dot = string.find(opcode, ".", 1, true)
    if dot then
        check(group_at(line, dot + 1) ~= "rzaKeyword",
            opcode .. " suffix must not be a typed keyword")
    end
    asserted_inactive = asserted_inactive + 1
end
check(asserted_inactive == #inactive, "every inactive spelling must be asserted")

vim.cmd("enew")
vim.api.nvim_buf_set_lines(0, 0, -1, true, {"loop:"})
vim.cmd("runtime! syntax/rza.vim")
check_group(1, 1, "rzaLabel")

vim.cmd("enew")
vim.api.nvim_buf_set_lines(0, 0, -1, true,
    {"proc convert(input_m: ro, result_m: rw):"})
vim.cmd("runtime! syntax/rza.vim")
check_group(1, 6, "rzaLabel")

if #failures > 0 then
    for _, message in ipairs(failures) do
        vim.api.nvim_err_writeln(message)
    end
    vim.cmd("cquit")
else
    vim.api.nvim_out_write("Neovim syntax and filetype checks passed\n")
    vim.cmd("qa!")
end
