return {
  {
    dir = vim.fn.stdpath("data") .. "/lazy/copilot.lua",
    name = "copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({})
    end,
  },
}
