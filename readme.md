# pvim

A personalized Neovim configuration tailored for a streamlined and efficient development workflow, with first-class support for Java/Spring Boot development.

![sample img png](./docs/ss.png)

## Features

- **Plugin Management:** Lazy loading with `lazy.nvim` for fast startup
- **File Explorer:** `nvim-tree` for file navigation
- **Fuzzy Finding:** `telescope.nvim` for files, buffers, grep, and more
- **LSP Integration:** Full language server support via `nvim-lspconfig` and Mason
- **Code Completion:** Smart autocompletion with `nvim-cmp`
- **Git Integration:** `gitsigns`, `lazygit`, and git keybindings
- **UI Enhancements:** `lualine`, `bufferline`, `noice`, and 40+ color schemes
- **Syntax Highlighting:** `nvim-treesitter` with extended support for JSP and FreeMarker
- **Debugging:** Full DAP support for Java, C/C++, Rust, Python, and Go
- **Java/Spring Boot:** JDTLS integration with module generation and context-aware snippets
- **Snippets:** `luasnip` with extensive Java, JSP, and FreeMarker snippets

## Quick Start

### One-Line Install

```bash
git clone https://github.com/elitekaycy/pvim.git ~/.config/pvim && ~/.config/pvim/install.sh
```

This will:
- Install Neovim 0.11+ (if needed)
- Install Node.js 18+ and Java 17+
- Install CLI tools (ripgrep, fd, fzf, lazygit)
- Configure shell aliases
- Sync plugins and LSP servers

### Manual Installation

#### 1. Prerequisites

- Neovim 0.11.0 or higher
- Node.js 18+
- Java 17+ (for Java development)
- Git, ripgrep, fd, fzf

#### 2. Clone the repository

```bash
git clone https://github.com/elitekaycy/pvim.git ~/.config/pvim
```

#### 3. Add shell alias

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
alias pvim='NVIM_APPNAME=pvim nvim'
```

Reload your shell:

```bash
source ~/.zshrc  # or source ~/.bashrc
```

#### 4. Launch pvim

```bash
pvim
```

Plugins will auto-install on first launch. Run `:Mason` to install language servers.

## Supported Languages

| Language | LSP | Debugging | Snippets |
|----------|-----|-----------|----------|
| Java/Spring Boot | JDTLS | nvim-dap | Extensive |
| TypeScript/JavaScript | ts_ls | - | friendly-snippets |
| HTML/CSS | html-lsp, css-lsp | - | friendly-snippets |
| Tailwind CSS | tailwindcss | - | - |
| C/C++ | clangd | codelldb | friendly-snippets |
| Lua | lua_ls | - | friendly-snippets |
| Angular | angularls | - | - |
| JSP | html-lsp | - | Custom JSTL/EL |
| FreeMarker (FTL) | html-lsp | - | Custom |

## Keybindings

Leader key: `<Space>`

### General

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<C-h/j/k/l>` | Navigate splits |

### File Navigation (Telescope)

| Key | Action |
|-----|--------|
| `<leader><leader>` | Find all files |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |

### Buffer Navigation

| Key | Action |
|-----|--------|
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |
| `<S-v>` | Vertical split |
| `<leader>bd` | Close buffer |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>f` | Format file |

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Open lazygit |
| `<leader>gb` | Git blame line |
| `]c` / `[c` | Next/prev hunk |

## Java Development

pvim has first-class Java and Spring Boot support.

### Requirements

- Java 17+ (required for JDTLS)
- Maven or Gradle

### Install Java (SDKMAN recommended)

```bash
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21-tem
```

### Java Keybindings

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>co` | Organize imports |
| `<leader>crv` | Extract variable |
| `<leader>crc` | Extract constant |
| `<leader>crm` | Extract method |

### JUnit Testing

| Key | Action |
|-----|--------|
| `<leader>jt` | Test nearest method |
| `<leader>jT` | Test class |
| `<leader>jp` | Pick test to run |

### Spring Boot Module Generator

Generate complete CRUD modules with:

```
:SpringGenModule User
```

This creates:
- `User.java` (Entity)
- `UserDto.java` (DTO)
- `UserRepository.java` (Repository)
- `UserService.java` (Service Interface)
- `UserServiceImpl.java` (Service Implementation)
- `UserController.java` (REST Controller)
- `UserControllerTest.java` (JUnit Tests)
- `UserNotFoundException.java` (Exception)

| Key | Action |
|-----|--------|
| `<leader>jm` | Generate module |
| `<leader>jge` | Go to entity |
| `<leader>jgd` | Go to DTO |
| `<leader>jgr` | Go to repository |
| `<leader>jgs` | Go to service |
| `<leader>jgi` | Go to service impl |
| `<leader>jgc` | Go to controller |
| `<leader>jgt` | Go to test |

### Java Snippets

| Trigger | Description |
|---------|-------------|
| `entity` | JPA Entity class |
| `dto` | DTO record |
| `repo` | Spring Repository |
| `service` | Service interface |
| `serviceimpl` | Service implementation |
| `controller` | REST Controller |
| `getmap` | GET endpoint |
| `postmap` | POST endpoint |
| `putmap` | PUT endpoint |
| `deletemap` | DELETE endpoint |

### Clearing JDTLS Cache

If you experience issues:

```bash
rm -rf ~/.local/share/nvim/jdtls/workspace/*
```

## Debugging

Full debugging support via nvim-dap.

| Key | Action |
|-----|--------|
| `<F5>` | Start/Continue |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |
| `<leader>du` | Toggle debug UI |
| `<leader>dq` | Terminate session |
| `<leader>dr` | Restart session |
| `<leader>de` | Evaluate expression |

### Debug Adapters

- **Java**: Built-in via JDTLS
- **C/C++/Rust**: codelldb (install via Mason)
- **Python**: nvim-dap-python
- **Go**: nvim-dap-go

## Color Schemes

pvim includes 40+ color schemes. Switch themes with:

```
:Theme
```

Popular themes:
- `kanagawa`, `kanagawa-solid`
- `tokyonight`, `tokyonight-solid`
- `catppuccin`, `catppuccin-solid`
- `gruvbox`
- `nord`
- `github-dark`, `github-light`
- `evangelion`
- `noctis` (9 variants)

Themes ending in `-solid` use full backgrounds (no transparency).

## JSP and FreeMarker Support

pvim includes syntax highlighting and snippets for Java template engines.

### JSP Snippets

| Trigger | Description |
|---------|-------------|
| `taglibcore` | JSTL core taglib |
| `cif` | `<c:if>` tag |
| `cforeach` | `<c:forEach>` tag |
| `cout` | `<c:out>` tag |
| `formform` | Spring form |
| `forminput` | Form input field |
| `jsppage` | Full JSP page template |

### FreeMarker (FTL) Snippets

| Trigger | Description |
|---------|-------------|
| `if` | `<#if>` directive |
| `list` | `<#list>` loop |
| `macro` | Macro definition |
| `assign` | Variable assignment |
| `$` | `${variable}` interpolation |
| `ftlpage` | Full FTL page template |

## Project Structure

```
~/.config/pvim/
├── init.lua              # Entry point
├── lua/
│   ├── core/             # Core settings
│   ├── keybinding/       # Key mappings
│   ├── plugins/          # Plugin configurations
│   │   ├── default/      # Core plugins
│   │   ├── extras/       # Optional plugins
│   │   └── lsp/          # Language servers
│   └── util/             # Utilities
├── snippets/             # LuaSnip snippets
│   └── luasnippets/
│       ├── java.lua
│       ├── jsp.lua
│       └── ftl.lua
└── syntax/               # Custom syntax files
    ├── jsp.vim
    └── ftl.vim
```

## Troubleshooting

### Plugins not loading

```vim
:Lazy sync
```

### LSP not working

```vim
:LspInfo
:Mason
```

### Java issues

```bash
# Clear JDTLS cache
rm -rf ~/.local/share/nvim/jdtls/workspace/*

# Verify Java version
java -version  # Should be 17+
```

### Check health

```vim
:checkhealth
```

## Uninstall

```bash
rm -rf ~/.config/pvim
rm -rf ~/.local/share/pvim
rm -rf ~/.local/state/pvim
rm -rf ~/.cache/pvim
```

Remove the `pvim` alias from your shell config.

## License

MIT
