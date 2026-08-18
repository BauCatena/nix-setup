return {
  "jonroosevelt/gemini-cli.nvim",
  config = function()
    require("gemini").setup()
  end,
  cmd = { "GeminiOpen", "GeminiChat" },
  keys = {
    { "<leader>g", "<cmd>GeminiOpen<cr>", desc = "Open Gemini" },
  },
}
