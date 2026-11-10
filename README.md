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

The bootstrap installs both [`prek`](https://github.com/j178/prek), the preferred faster
pre-commit-compatible runner, and `pre-commit` for backwards compatibility. Use `prek`
with the existing `.pre-commit-config.yaml`; `pre-commit` remains available when needed.


## Shell prompt

Starship uses a Zenburn palette matching Neovim, Bat, and Git diffs, with colors from
[zenburn.nvim](https://github.com/phha/zenburn.nvim). The segmented prompt keeps its
existing layout and uses muted red, orange, yellow, green, and blue.

Both bootstraps deploy `dotfiles/config/starship.toml`. To apply only the prompt config:

```sh
cp dotfiles/config/starship.toml ~/.config/starship.toml
```

The next prompt uses the new colors. Terminal background and application interface
colors are configured separately in your terminal application.

## Git

The bootstrap deploys global Git attributes to `~/.config/git/attributes`, including
Markdown-aware diff hunk headers for `*.md` files. Git's generic diff heuristic can choose
unrelated prose instead of nearby Markdown headings; this rule gives the `delta` pager
useful section context when rendering diffs. The bootstrap also selects Delta's built-in
`zenburn` syntax theme, matching the Zenburn theme used by Neovim. File names, hunk
markers, line numbers, and Delta's existing boxes and lines use Zenburn's light-blue
`#8cd0d3`. This affects diff presentation only; repository-local attributes can override it.

## Neovim

Config is deployed to `~/.config/nvim/` from `dotfiles/config/nvim/`.

Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim) - auto-installs on first launch.

**LSP servers** are installed by [Mason](https://github.com/mason-org/mason.nvim) on first interactive launch: basedpyright, ruff, lua_ls, jsonls, yamlls.
Node.js is required for basedpyright, jsonls, and yamlls. The bootstrap installs it via NodeSource.
If that fails (network restrictions), ruff still works without node.

**Python debugging** requires `pip install debugpy` in each project's virtual environment.

**Linux only:** `fd-find` installs as `fdfind`; the bootstrap creates a `~/.local/bin/fd` symlink for telescope.

### Key bindings (leader = Space)

| Key           | Action                       |
|---------------|------------------------------|
| `<leader>ff`  | Find files                   |
| `<leader>fg`  | Live grep                    |
| `<leader>fb`  | Buffers                      |
| `<leader>e`   | Toggle file tree             |
| `<leader>xx`  | Diagnostics panel            |
| `<leader>db`  | Toggle breakpoint            |
| `<leader>dc`  | Start / continue debug       |
| `<leader>du`  | Toggle debug UI              |
| `gd`          | Goto definition              |
| `K`           | Hover docs                   |
| `<leader>cf`  | Format buffer                |
| `s` / `S`     | Flash jump / treesitter jump |
| `<C-h/j/k/l>` | Window navigation            |

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

## Herdr (macOS)

`bootstrap-mac.sh` installs the [Herdr](https://herdr.dev) app (Homebrew cask `herdr-app`)
and, if missing, herdr-core (`hc`) via the official installer. Both update themselves after that.

It also deploys one personal customisation from `dotfiles/config/herdr-app/` to
`~/.config/herdr-app/`: in bare-repo worktree layouts
(`repo/.git` is a bare repo, worktrees beside it), the spaces sidebar names every worktree
after its repo, with the branch in gray (`dotfiles  master`, `dotfiles  feature-x`)
instead of the worktree folder (`master`). Other repos and spaces you renamed are unchanged.

- `mods/spaces-bare/`: a copy of Herdr's shipped `spaces` sidebar mod, edited (search for `bare`).
- `layouts/main-bare.json`: a copy of the shipped `main` layout, using `spaces-bare` instead of `spaces`.

The bootstrap switches to the layout when Herdr is running; otherwise run
`herdr-app do layout.switch --name main-bare` once. `cmd-shift-l` cycles layouts.

Not set up by `bootstrap-ubuntu.sh`: that one targets headless machines and the Docker CI.

### Drift

Both files are snapshots of Herdr 0.1.14's shipped versions (see `cloned_from`) and do not
follow later Herdr updates to `spaces` or `main`. Versions are not pinned: the app updates
itself and herdr-core with no way to opt out. When an update breaks the mod, or you want
upstream's changes, re-create the copies and re-apply the edits:

```sh
herdr-app do mod.clone --name spaces --as spaces-bare     # remove the old copy first
herdr-app do layout.clone --name main --as main-bare      # then set the spaces block's mod to spaces-bare
# re-apply the edits in main.js: diff the old copy against ~/.config/herdr-app/mods/spaces/main.js
herdr-app check ~/.config/herdr-app/mods/spaces-bare
```

Then copy both back into `dotfiles/config/herdr-app/`.

## Caps Lock → Escape (macOS)

Set manually via **System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys**:
set the Caps Lock key to Escape. This persists across reboots. Not scripted because the
underlying pref key is keyboard-specific (embeds the keyboard's vendor/product ID).
`bootstrap-mac.sh` prints a reminder of this step at the end.

## Known issues

- Neovim icons require a full Nerd Font. Set iTerm2 terminal font to **JetBrainsMono Nerd Font** (installed by bootstrap): Profiles → Text → Font. Starship's prompt glyphs also need a Nerd Font.
- On arm64 Linux, the bootstrap automatically installs the `nvim-linux-arm64.tar.gz` tarball.
