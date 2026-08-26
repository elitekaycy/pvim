# Install

## One-Line Install

```bash
git clone https://github.com/elitekaycy/pvim.git ~/.config/pvim && ~/.config/pvim/install.sh
```

This will:
- Install Neovim 0.11+ (if needed)
- Install Node.js 18+ and Java 17+
- Install CLI tools (ripgrep, fd, fzf, lazygit)
- Configure shell aliases
- Sync plugins and LSP servers

## Manual Installation

### 1. Prerequisites

- Neovim 0.11.0 or higher
- Node.js 18+
- Java 17+ (for Java development)
- Git, ripgrep, fd, fzf

### 2. Clone the repository

```bash
git clone https://github.com/elitekaycy/pvim.git ~/.config/pvim
```

### 3. Ensure the `pvim` launcher works

`pvim` is expected to be a real executable on your PATH, not just a shell alias.

Make sure `~/.local/bin` is on your PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

The installer creates this launcher:

```bash
~/.local/bin/pvim
```

Its job is simple:

```bash
#!/usr/bin/env bash
export NVIM_APPNAME=pvim
exec nvim "$@"
```

That is why these all work:

```bash
pvim
pvim .
pvim path/to/file.ts
```

Optional aliases if you want shorter typing:

```bash
export PATH="$HOME/.local/bin:$PATH"
alias pvim='NVIM_APPNAME=pvim nvim'
alias pvi='NVIM_APPNAME=pvim nvim'
```

Reload your shell:

```bash
source ~/.zshrc  # or source ~/.bashrc
```

Verify the launcher before debugging anything else:

```bash
which pvim
pvim --headless '+lua print(vim.fn.stdpath("config"))' +qa!
```

Expected config path:

```text
/home/your-user/.config/pvim
```

If `pvim .` opens your normal Neovim config instead of pvim, your shell is not finding the launcher first. Fix your PATH before doing anything else.

### 4. Launch pvim

```bash
pvim
```

Plugins auto-install on first launch. Run `:Mason` to install language servers.

### 5. Use the built-in searchable key reference

Inside pvim:

```vim
:PvimSource
```

You can filter immediately:

```vim
:PvimSource git
:PvimSource test
:PvimSource leader
:PvimSource harpoon
:PvimSource diagnostics
```

Command aliases:

```vim
:PvimKeys
:pvimsource
:pvimkeys
```

This opens the README in a tab and starts a fuzzy search so you can quickly find key combinations without leaving Neovim.

### 6. If you use broot

If you want pressing `Enter` on a file in broot to open that file in `pvim` in the same shell session, two things must be true:

1. broot must use a parent-shell command (`from_shell = true`)
2. you must launch broot through `br` (or alias `broot` to `br`)

Example broot verb:

```toml
[[verbs]]
invocation = "edit"
key = "enter"
apply_to = "file"
external = 'exec pvim "{file}"'
from_shell = true
leave_broot = true
```

Recommended shell setup:

```bash
source ~/.config/broot/launcher/bash/br
alias broot='br'
```

If you run the raw `broot` binary directly, it cannot replace the current shell process, so same-shell `exec pvim ...` behavior will not happen.

## Uninstall

```bash
rm -rf ~/.config/pvim
rm -rf ~/.local/share/pvim
rm -rf ~/.local/state/pvim
rm -rf ~/.cache/pvim
```

Remove the `pvim` alias from your shell config.
