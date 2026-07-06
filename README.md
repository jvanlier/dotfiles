dotfiles
========

My dotfiles for a nice and consistent terminal and Neovim experience on macOS and Linux.

## Usage

On mac:

```sh
./bootstrap-mac.sh
```

On Debian or Ubuntu:

```sh
./bootstrap-ubuntu.sh
```


## Neovim

Config is deployed to `~/.config/nvim/` from `dotfiles/config/nvim/`.

Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim) - auto-installs on first launch.

**LSP servers** are installed by [Mason](https://github.com/mason-org/mason.nvim) on first interactive launch: basedpyright, ruff, lua_ls, jsonls, yamlls.
Node.js is required for basedpyright, jsonls, and yamlls. The bootstrap installs it via NodeSource.
If that fails (network restrictions), ruff still works without node.

**Python debugging** requires `pip install debugpy` in each project's virtual environment.

**Linux only:** `fd-find` installs as `fdfind`; the bootstrap creates a `~/.local/bin/fd` symlink for telescope.

### Key bindings (leader = Space)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>e`  | Toggle file tree |
| `<leader>xx` | Diagnostics panel |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Start / continue debug |
| `<leader>du` | Toggle debug UI |
| `gd` | Goto definition |
| `K`  | Hover docs |
| `<leader>cf` | Format buffer |
| `s` / `S` | Flash jump / treesitter jump |
| `<C-h/j/k/l>` | Window navigation |

### First launch checklist

1. Open `nvim` - if plugins are missing or errors appear, run `:Lazy sync` and restart.
2. Run `:Mason` to verify LSP server installation.
3. Run `:checkhealth` to diagnose issues.
4. Treesitter parsers build in the background on first launch (needs the `tree-sitter`
   CLI, installed by bootstrap). If any are missing, run `:TSUpdate` or `:TSInstall python`.


## Rectangle (macOS window manager)

`bootstrap-mac.sh` installs Rectangle and deploys a fixed set of window-snapping shortcuts
(halves, corners, maximise, next/previous display), optimized for the Kinesis Advantage 2
keyboard layout. The bootstrap wipes Rectangle's prefs domain first, so only these shortcuts
are bound — all other Rectangle actions stay unbound.

To change them: edit a binding in Rectangle's Settings, then read the new value with
`defaults read com.knollsoft.Rectangle <action>` and update the matching line in `bootstrap-mac.sh`.

## Caps Lock → Escape (macOS)

Set manually via **System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys**:
set the Caps Lock key to Escape. This persists across reboots. Not scripted because the
underlying pref key is keyboard-specific (embeds the keyboard's vendor/product ID).
`bootstrap-mac.sh` prints a reminder of this step at the end.

## Known issues

- Neovim icons require a full Nerd Font. Set iTerm2 terminal font to **JetBrainsMono Nerd Font** (installed by bootstrap): Profiles → Text → Font. Starship's prompt glyphs also need a Nerd Font.
- On arm64 Linux, the bootstrap automatically installs the `nvim-linux-arm64.tar.gz` tarball.
