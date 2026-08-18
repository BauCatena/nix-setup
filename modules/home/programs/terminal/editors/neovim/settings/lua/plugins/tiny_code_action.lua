return {
  "rachartier/tiny-code-action.nvim",
  event = "LspAttach",
  dependencies = {
    { "ibhagwan/fzf-lua" },
  },
  opts = {
    picker = "fzf-lua",
  },
    "rachartier/tiny-code-action.nvim",
    dependencies = {
        -- optional picker via fzf-lua
        {"ibhagwan/fzf-lua"},
        -- .. or via snacks
        {
          "folke/snacks.nvim",
          opts = {
            terminal = {},
          }
        }
    },
    event = "LspAttach",
    opts = {},
}
