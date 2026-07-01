# tmux + neovim settings

One command to set up tmux and neovim on a fresh Mac with the same settings as the original machine.

## What gets installed

- **Homebrew** (if not present)
- **tmux** 3.7 - terminal multiplexer
- **neovim** 0.12.3 - code editor
- **rust-analyzer** - Rust LSP server

## tmux settings

| Setting | Value |
|---|---|
| Prefix key | Ctrl-a (instead of Ctrl-b) |
| Mouse support | On |
| Mode keys | Vi (h/j/k/l for navigation) |
| Status bar | Dark background (#1e1e2e), light text (#cdd6f4), shows session name on the left and HH:MM:SS on the right, updates every second |
| Focus events | On (for neovim autoread) |

### Keybindings

- h/j/k/l - navigate panes (left/down/up/right)
- H/J/K/L (repeatable) - resize pane by 5 cells

### tmux plugins (via TPM)

- tmux-sensible - sensible default settings
- tmux-resurrect - save and restore tmux sessions
- tmux-continuum - continuous session saving

## neovim settings

| Setting | Value |
|---|---|
| Leader key | Space |
| Line numbers | On |
| Tab width | 4 spaces |
| Shift width | 4 spaces |
| Expand tabs | Yes (spaces instead of tabs) |
| Scroll offset | 8 lines |
| Line wrap | Off |
| Cursorline | On |
| Autoread | On (triggers on FocusGained and BufEnter) |

### Keybindings

| Key | Action |
|---|---|
| gd | Go to definition |
| K | Hover documentation |
| Space + rn | Rename |
| Space + ca | Code action |
| Space + d | Show diagnostic |
| [d | Previous diagnostic |
| ]d | Next diagnostic |
| Space + ff | Telescope find files |
| Space + fg | Telescope live grep |
| Space + fb | Telescope buffers |
| Space + e | Toggle Neo-tree file explorer |

### Plugin manager

lazy.nvim (by folke) with `rocks` disabled.

### Plugins

| Plugin | Purpose |
|---|---|
| gruvbox-material | Colorscheme (dark, medium background) |
| nvim-lspconfig | LSP client (rust-analyzer enabled) |
| nvim-cmp | Autocompletion with snippets |
| cmp-nvim-lsp | LSP completion source |
| cmp-buffer | Buffer completion source |
| cmp-path | Path completion source |
| LuaSnip | Snippet engine |
| cmp_luasnip | Luasnip completion source |
| telescope.nvim | Fuzzy file finder and grep |
| nvim-treesitter | Syntax highlighting (parsers: rust, lua, vim, vimdoc) |
| neo-tree.nvim | File explorer (v3.x branch) |
| gitsigns.nvim | Git decorations in signcolumn |
| Comment.nvim | Code commenting with gc |
| markdown-preview.nvim | Markdown preview |
| lualine.nvim | Status line with auto theme |

## Usage

```sh
git clone git@github.com:Webrowse/tmux-nvim-settings.git
cd tmux-nvim-settings
chmod +x setup.sh
./setup.sh
```

After the script finishes:

1. Run `tmux`
2. Inside tmux, press `prefix + I` (Ctrl-a then Shift-i) to load tmux plugins
3. Run `nvim`

## Updating

Edit `setup.sh` to add or remove tools, then commit and push. On any future machine, the same clone and run command will apply the updated setup.
