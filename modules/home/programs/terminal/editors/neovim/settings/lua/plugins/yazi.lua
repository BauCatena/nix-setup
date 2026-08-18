return {
  "mikavilpas/yazi.nvim",
  version = "v10.3.0",
  event = "VeryLazy",
  keys = {
    -- Open yazi in the current working directory
    { "<leader>-", "<cmd>Yazi<cr>", desc = "Open yazi in nvim" },
    -- Open yazi in the directory of the current file
    { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Open yazi in file's dir" },
  },
  opts = {
   open_for_directories = true,
  },
}
