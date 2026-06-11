vim.pack.add({
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
  { src = "https://github.com/junegunn/fzf" },
  { src = "https://github.com/junegunn/fzf.vim" }
})

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

---@type nvim_tree.config
local config = {
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
    icons = {
      show = {
        git = false,
        folder = false,
        file = false,
        folder_arrow = false,
      }
    },
    indent_markers = {
      enable = true,
      icons = { corner = "└", edge = "│", item = "├", bottom = "─", none = " " },
    }
  },
  filters = {
    dotfiles = true,
  }
}
require("nvim-tree").setup(config)

vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")
vim.opt.wrap = false
