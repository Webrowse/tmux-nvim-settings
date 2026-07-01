#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing Homebrew (if needed) ==="
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "=== Installing tmux + neovim + rust-analyzer ==="
brew install tmux neovim rust-analyzer

echo "=== Creating config directories ==="
rm -rf ~/.config/nvim/after
mkdir -p ~/.config/nvim/lua/plugins

echo "=== Writing ~/.tmux.conf ==="
cat > ~/.tmux.conf << 'TMUXEOF'
unbind C-b
set -g prefix C-a
bind C-a send-prefix

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

set -g mouse on
set -g mode-keys vi

set -g status-style 'bg=#1e1e2e fg=#cdd6f4'
set -g status-left '#[bold] #S '
set -g status-right '#[bold] %H:%M:%S '
set -g status-interval 1

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

set -g focus-events on

run '~/.tmux/plugins/tpm/tpm'
TMUXEOF

echo "=== Writing ~/.config/nvim/init.lua ==="
cat > ~/.config/nvim/init.lua << 'NVIMEOF'
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins", { rocks = { enabled = false } })

vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, { command = "checktime" })
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.cursorline = true

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
NVIMEOF

echo "=== Writing ~/.config/nvim/lua/plugins/init.lua ==="
cat > ~/.config/nvim/lua/plugins/init.lua << 'PLUGINSEOF'
return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "dark"
      vim.g.gruvbox_material_background = "medium"
      vim.cmd("colorscheme gruvbox-material")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("rust_analyzer", {})
      vim.lsp.enable("rust_analyzer")
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, { name = "luasnip" },
          { name = "buffer" },  { name = "path" },
        }),
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local install_dir = vim.fn.stdpath("data") .. "/site"
      vim.opt.rtp:append(install_dir)
      require("nvim-treesitter").setup({
        ensure_installed = { "rust", "lua", "vim", "vimdoc" },
        parser_install_dir = install_dir,
      })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = { { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" } },
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function() require("gitsigns").setup() end,
  },
  { "numToStr/Comment.nvim", opts = {} },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && bash install.sh",
    ft = { "markdown" },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("lualine").setup({ options = { theme = "auto" } }) end,
  },
}
PLUGINSEOF

echo "=== Installing tmux plugins ==="
git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || true
~/.tmux/plugins/tpm/bin/install_plugins

echo "=== Installing neovim plugins ==="
nvim --headless "+Lazy! sync" +qa

echo ""
echo "========================"
echo "  All done!"
echo "========================"
echo ""
echo "Next steps:"
echo "  1. Run: tmux"
echo "  2. Inside tmux, press: prefix + I  (Ctrl-a then Shift-i)"
echo "     (this loads TPM plugins fully)"
echo "  3. Run: nvim"
echo ""
