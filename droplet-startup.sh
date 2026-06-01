#!/bin/bash

MYIP='1.1.1.1'

ufw enable
ufw allow from $MYIP to any port 22 proto tcp
apt-get update 
apt-get install -y ranger caca-utils highlight atool w3m poppler-utils mediainfo
adduser aaa
echo "alias xforce='mkdir blabla && tar -x -C blabla -f'" >> /home/aaa/.bashrc
echo "export EDITOR=nvim" >> /home/aaa/.bashrc
su -c "ranger --copy-config=all" aaa
sed -i -e 's/^set viewmode miller/set viewmode multipane/g' /home/aaa/.config/ranger/rc.conf
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> /home/aaa/.bashrc
mkdir /home/aaa/.config/nvim
cat > ~/.config/nvim/init.lua << 'EOF'
vim.pack.add({
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
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

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() require("nvim-tree.api").tree.open() end,
})

vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")
EOF
