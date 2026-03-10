# pvim

A personalized Neovim configuration, tailored for a streamlined and efficient development workflow.

![sample img png](./docs/ss.png)

## Features

- **Plugin Management:** Utilizes `lazy.nvim` for efficient plugin management.
- **File Explorer:** Integrated with `nvim-tree` for easy file navigation.
- **Fuzzy Finding:** Powered by `telescope.nvim` for finding files, buffers, and more.
- **LSP Integration:** Comprehensive language server protocol support with `nvim-lspconfig`.
- **Code Completion:** Enhanced autocompletion with `nvim-cmp`.
- **Git Integration:** Seamless git integration with `gitsigns`.
- **UI Enhancements:** A visually appealing and informative UI with `lualine`, `bufferline`, and `noice`.
- **Syntax Highlighting:** Advanced syntax highlighting with `nvim-treesitter`.
- **Auto-Pairing:** Automatic bracket and quote pairing with `nvim-autopairs`.
- **Formatting and Linting:** Code formatting with `formatter.nvim` and linting with `lint.nvim`.
- **Debugging:** Debugging support with `nvim-dap`.
- **Snippets:** Code snippets with `luasnip`.
- **And much more...**

## Prerequisites

- **Neovim version 0.9.0 or above** must be installed on your system. To check your Neovim version, run:

  ```bash
  nvim --version
  ```

## Setup Instructions

##### -> NB. Follow this way to not affect your actual nvim config

#### 1. Clone the pvim repository

Clone the pvim repository into the ~/.config directory by running the following command:

```
git clone https://github.com/elitekaycy/pvim.git ~/.config/pvim
```

#### 2. Edit your .zshrc or .bashrc

Open your ~/.zshrc (or ~/.bashrc if you're using Bash) and add the following alias:

```
export JAVA_HOME=$(asdf where java) or java home path
alias pvim='NVIM_APPNAME=pvim nvim'
```

This alias creates a shortcut for running Neovim with your custom configuration.

#### 3. Reload the shell configuration

To apply the changes, reload your shell configuration:

```
source ~/.zshrc # For Zsh users
source ~/.bashrc # For Bash users 4. Use pvim
```

Now you can use the `pvim` command to open Neovim with your custom configuration.

## Java Development Setup

pvim has first-class Java support with JDTLS (Eclipse JDT Language Server).

### Requirements

- **Java 17+** is required to run JDTLS itself (the language server)
- Your **projects** can target any Java version (8, 11, 17, 21, etc.)

### Install Java (recommended: SDKMAN)

```bash
# Install SDKMAN
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Install Java 21 (for JDTLS) and Java 11 (for legacy projects)
sdk install java 21-tem
sdk install java 11.0.21-tem

# Set default to Java 21
sdk default java 21-tem
```

pvim will automatically detect all installed Java versions from:
- `/usr/lib/jvm`
- `~/.sdkman/candidates/java`
- `~/.jdks`
- `/opt/java`

### Clearing JDTLS Cache

If you experience issues with Java intellisense or after updating pvim, clear the JDTLS workspace cache:

```bash
rm -rf ~/.local/share/nvim/jdtls/workspace/*
```

### Java Keybindings

| Keybinding | Description |
|---|---|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>co` | Organize imports |
| `<leader>crv` | Extract variable |
| `<leader>crc` | Extract constant |
| `<leader>crm` | Extract method (visual) |
| `<leader>jt` | Test nearest method (JUnit) |
| `<leader>jT` | Test class (JUnit) |
| `<leader>jp` | Pick test to run |
| `<leader>jd` | Debug Java application |
| `<leader>jr` | Run Java main class |

## Debugging

pvim includes full debugging support via nvim-dap.

### Debug Keybindings

| Keybinding | Description |
|---|---|
| `<F5>` | Start/Continue debugging |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dq` | Terminate debug session |
| `<leader>dr` | Restart debug session |
| `<leader>du` | Toggle debug UI |
| `<leader>de` | Evaluate expression |
| `<leader>dl` | Run last debug config |
| `<leader>dC` | Clear all breakpoints |

### Supported Languages

- **Java**: Full debugging and JUnit testing via JDTLS
- **C/C++**: Debugging via codelldb
- **Rust**: Debugging via codelldb
- **Python**: Debugging via nvim-dap-python (if installed)
- **Go**: Debugging via nvim-dap-go (if installed)

## Keybindings

### General

| Keybinding | Description |
|---|---|
| `<leader>e` | Toggle File Explorer |
| `<CR>` | Open File in New Buffer |

### Telescope

| Keybinding | Description |
|---|---|
| `<leader><leader>` | Find all files |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Find help tags |

### Buffer Navigation

| Keybinding | Description |
|---|---|
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |
| `<S-v>` | Vsplit |
| `<leader>bd` | Close buffer |