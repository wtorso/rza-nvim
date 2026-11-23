# RZA for Neovim

[Русская версия](README.ru.md)

Syntax highlighting and optional Language Server Protocol support for `.rza` files in
Neovim. Highlighting works without the RZA compiler. The optional LSP client starts the same
`rez3asm --lsp` server used by other RZA editors; this repository does not reimplement the
language rules.

## Features

- Filetype detection and `; %s` comment configuration.
- Highlighting for instructions, registers, layouts, fields, numbers, and comments.
- All 240 active fixed-width integer and floating-point operation/type spellings, including
  strict f32/f64 conversions and bitcasts.
- Optional diagnostics and standard Neovim LSP features through the real RZA language server.
- No plugin manager, tree-sitter grammar, npm package, or external Lua dependency.

Neovim 0.9 or newer is supported.

## Install

Clone the repository:

```sh
git clone --depth 1 https://github.com/wtorso/rza-nvim.git
```

Add the checkout to `runtimepath` in `init.lua`:

```lua
vim.opt.runtimepath:append("/absolute/path/to/rza-nvim")
vim.cmd("filetype plugin on")
vim.cmd("syntax enable")
```

Restart Neovim. Opening a `.rza` file now selects the `rza` filetype and enables highlighting.
No compiler is needed for this configuration.

## Optional LSP

Build or install `rez3asm` using the
[RZA project instructions](https://github.com/wtorso/rza#build-and-run), then call `setup` once
in `init.lua`:

```lua
require("rza").setup()
```

By default, the client runs `rez3asm --lsp` from `PATH`. To use an explicit compiler path:

```lua
require("rza").setup({
    cmd = { "/absolute/path/to/rez3asm", "--lsp" },
})
```

The client starts when an RZA filetype is detected. Neovim's standard LSP functions provide
diagnostics, hover, definitions, references, completion, and rename support exposed by the RZA
server. This plugin does not add custom keybindings.

Call `setup` only when LSP is wanted. Loading syntax, filetype, and ftplugin files never starts
a client or requires the compiler.

## Verify

Install Neovim and run the compiler-independent syntax tests:

```sh
bash test/run.sh
```

To run syntax tests plus real LSP integration, point `RZA_COMPILER` at an executable compiler:

```sh
RZA_COMPILER=/absolute/path/to/rez3asm bash test/run.sh
```

The LSP test uses bounded waits and checks a valid document with no diagnostics and an invalid
document containing the expected `unknown op bogus` diagnostic. CI runs both modes on Ubuntu.

## License

RZA for Neovim is available under the [MIT License](LICENSE).
