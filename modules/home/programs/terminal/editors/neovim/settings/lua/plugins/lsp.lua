-- ~/.config/nvim/lua/plugins/lsp.lua
return {
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            -- Enable your language servers natively for Neovim 0.12
            -- Replace "pyright" or "lua_ls" with the servers you actually use
            vim.lsp.enable({
                "pyright",
                "lua_ls",
            })
        end,
    },
}
