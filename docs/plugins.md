# Plugin Reference

Detail on every plugin beyond the [quick keybinding reference](./keybindings.md), grouped by feature.

## Diffview (Git Diffs)

Side-by-side git diffs and file history.

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>gd` | Open Diffview |
| `<leader>gh` | File history |
| `<leader>gH` | Branch history |
| `<leader>gq` | Close Diffview |

### In Diffview

| Key | Action |
|-----|--------|
| `<tab>` | Toggle file panel |
| `j/k` | Navigate files |
| `<cr>` | Open diff |
| `q` | Close |

## Neogit (Git Interface)

Full git interface like Magit (Emacs).

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>gn` | Open Neogit |
| `<leader>gc` | Commit popup |
| `<leader>gp` | Pull |
| `<leader>gP` | Push |

### In Neogit

| Key | Action |
|-----|--------|
| `s` | Stage |
| `u` | Unstage |
| `c` | Commit popup |
| `p` | Pull popup |
| `P` | Push popup |
| `r` | Rebase popup |
| `L` | Log popup |
| `?` | Help |
| `q` | Close |

## Zen Mode

Distraction-free coding.

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>z` | Toggle Zen Mode |
| `<leader>tw` | Toggle Twilight (dim inactive code) |

## Markdown Preview

Live preview in browser as you type.

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>mp` | Toggle Markdown Preview |

### Commands

| Command | Description |
|---------|-------------|
| `:MarkdownPreview` | Start preview |
| `:MarkdownPreviewStop` | Stop preview |
| `:MarkdownPreviewToggle` | Toggle preview |

## Neotest (Test Runner)

Modern test runner with nice UI. Supports Java, Jest, Vitest, Go, Python.

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run file tests |
| `<leader>ta` | Run all tests |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Show test output |
| `<leader>tO` | Toggle output panel |
| `<leader>tS` | Stop test |
| `<leader>tw` | Watch file tests |
| `<leader>td` | Debug nearest test |
| `]T` / `[T` | Next/prev failed test |

## Harpoon (Quick Navigation)

Mark files and jump instantly - like bookmarks on steroids.

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>ha` | Add file to harpoon |
| `<leader>hh` | Open harpoon menu |
| `<leader>1-5` | Jump to file 1-5 |
| `]h` / `[h` | Next/prev harpoon file |

## Surround

Add, change, delete surrounding brackets, quotes, tags.

### Usage

| Command | Description | Example |
|---------|-------------|---------|
| `ysiw"` | Surround word with `"` | `word` → `"word"` |
| `yss)` | Surround line with `()` | `x + y` → `(x + y)` |
| `ds"` | Delete surrounding `"` | `"word"` → `word` |
| `cs"'` | Change `"` to `'` | `"word"` → `'word'` |
| `dst` | Delete surrounding tag | `<p>text</p>` → `text` |

## Spectre (Search & Replace)

Project-wide search and replace with preview.

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>sr` | Open Spectre |
| `<leader>sw` | Search current word |
| `<leader>sf` | Search in current file |

### In Spectre Window

| Key | Action |
|-----|--------|
| `dd` | Toggle item |
| `<cr>` | Open file |
| `<leader>R` | Replace all |
| `<leader>rc` | Replace current line |
| `<leader>q` | Send to quickfix |

## Trouble (Diagnostics)

Pretty list for diagnostics, references, and quickfix.

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle all diagnostics |
| `<leader>xX` | Buffer diagnostics only |
| `<leader>xs` | Symbols outline |
| `<leader>xl` | LSP definitions/references |
| `<leader>xL` | Location list |
| `<leader>xQ` | Quickfix list |

### In Trouble Window

| Key | Action |
|-----|--------|
| `q` | Close |
| `j/k` | Navigate |
| `<cr>` | Jump to issue |
| `o` | Jump and close |
| `K` | Hover details |
| `P` | Toggle preview |

## Todo Comments

Highlight and search TODO, FIXME, HACK, NOTE comments in your code.

### Supported Keywords

| Keyword | Description |
|---------|-------------|
| `TODO:` | Tasks to complete |
| `FIXME:` / `BUG:` | Bugs to fix |
| `HACK:` | Hacky workarounds |
| `WARN:` / `WARNING:` | Warnings |
| `NOTE:` / `INFO:` | Notes |
| `PERF:` / `OPTIM:` | Performance issues |
| `TEST:` | Test related |

### Keybindings

| Key | Action |
|-----|--------|
| `]t` | Jump to next todo |
| `[t` | Jump to previous todo |
| `<leader>st` | Search all todos (Telescope) |
| `<leader>sT` | Search only TODO/FIXME |
| `<leader>xt` | Todo quickfix list |

### Commands

| Command | Description |
|---------|-------------|
| `:TodoTelescope` | Search todos with Telescope |
| `:TodoQuickFix` | Show todos in quickfix |
| `:TodoLocList` | Show todos in location list |

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

## Session Management

Auto-save and restore sessions per project directory.

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>qs` | Restore session for cwd |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Don't save current session |

Sessions auto-restore when opening Neovim without arguments.

## Project Management

Quick switch between projects with Telescope integration.

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>fp` | Find and switch projects |

Projects are auto-detected by `.git`, `package.json`, `pom.xml`, etc.

## Toggleterm (Terminal)

Floating terminal with multiple instances.

### Keybindings

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle terminal |
| `<leader>tf` | Float terminal |
| `<leader>th` | Horizontal terminal |
| `<leader>tv` | Vertical terminal |
| `<leader>t1-3` | Terminal 1/2/3 |
| `<leader>tg` | Lazygit |
| `<leader>tn` | Node REPL |
| `<leader>tp` | Python REPL |

### In Terminal

| Key | Action |
|-----|--------|
| `<Esc>` | Exit to normal mode |
| `<C-h/j/k/l>` | Navigate to window |

## Refactoring

Extract, inline, and debug print with treesitter support.

### Keybindings

| Key | Mode | Action |
|-----|------|--------|
| `<leader>re` | Visual | Extract function |
| `<leader>rf` | Visual | Extract function to file |
| `<leader>rv` | Visual | Extract variable |
| `<leader>ri` | N/V | Inline variable |
| `<leader>rb` | Normal | Extract block |
| `<leader>rB` | Normal | Extract block to file |
| `<leader>rr` | N/V | Refactor menu |
| `<leader>rp` | Normal | Debug print |
| `<leader>rP` | N/V | Debug print variable |
| `<leader>rc` | Normal | Cleanup debug prints |

## Aerial (Code Outline)

Symbols sidebar for quick navigation.

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>o` | Toggle outline |
| `<leader>O` | Toggle outline nav |
| `{` / `}` | Prev/next symbol |

### In Outline

| Key | Action |
|-----|--------|
| `<CR>` | Jump to symbol |
| `o` / `za` | Toggle fold |
| `l` / `h` | Open/close fold |
| `q` | Close |

## Auto Pairs

Auto-close brackets, quotes, and more.

- `()`, `[]`, `{}` auto-close
- `""`, `''` auto-close
- Fast wrap: `Alt+e` to wrap selection
- Smart spaces inside brackets
- Integrates with nvim-cmp

## Modern Folds (UFO)

Better folding with peek preview.

### Keybindings

| Key | Action |
|-----|--------|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zr` | Open folds except kinds |
| `zm` | Close folds with level |
| `zK` | Peek fold preview |

Features:
- Treesitter-based folding
- Preview folded content
- Shows line count in fold

## Color Picker

Pick, edit, and convert colors in CSS/code.

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>cp` | Open color picker |
| `<leader>cc` | Convert color format |
| `<leader>ch` | Toggle color highlight |

### In Picker

| Key | Action |
|-----|--------|
| `h` / `l` | Decrease/increase value |
| `i` | Toggle input mode (RGB/HSL/etc) |
| `o` | Toggle output mode |
| `<CR>` | Confirm |
| `q` | Cancel |

Supports: HEX, RGB, HSL, HWB, LAB, LCH, OKLCH, CMYK

## Flash (Search & Jump)

Jump anywhere in 2-3 keystrokes. Press `s`, type a few characters, then press the label to jump.

### Keybindings

| Key | Mode | Action |
|-----|------|--------|
| `s` | N/V/O | Flash jump (type → label → jump) |
| `S` | N/V/O | Flash treesitter (select code blocks) |
| `r` | O | Remote flash (operator pending) |
| `R` | O/V | Treesitter search |
| `<C-s>` | `/` search | Toggle flash labels in search |
| `f/F/t/T` | N | Enhanced motions with labels |

### How It Works

1. Press `s` in normal mode
2. Type 1-2 characters of where you want to jump
3. Labels appear on all matches
4. Press the label letter to jump instantly

Also integrates with `/` search - when you search with `/`, press `<C-s>` to show jump labels on all matches.
