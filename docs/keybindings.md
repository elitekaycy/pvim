# Keybindings

Leader key: `<Space>`. Run `:PvimSource` inside pvim for a live, filterable version of this reference.

## Quick Reference (Most Used Commands)

### Navigation & Files

| Key | Action |
|-----|--------|
| `<leader><leader>` | Find files |
| `<leader>fg` | Live grep (search in files) |
| `<leader>fb` | Find buffers |
| `<leader>fp` | Find projects |
| `<leader>e` | Toggle file explorer |
| `<leader>o` | Toggle code outline |
| `<leader>ha` | Add file to Harpoon |
| `<leader>hh` | Harpoon menu |
| `<leader>1-5` | Jump to Harpoon file 1-5 |
| `<S-h>` / `<S-l>` | Prev/next buffer |

### Terminal

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle floating terminal |
| `<leader>tf` | Float terminal |
| `<leader>th` | Horizontal terminal |
| `<leader>tv` | Vertical terminal |
| `<leader>tg` | Lazygit in terminal |

### Sessions

| Key | Action |
|-----|--------|
| `<leader>qs` | Restore session (cwd) |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Don't save session |

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Open Lazygit |
| `<leader>gn` | Open Neogit (full git UI) |
| `<leader>gd` | Open Diffview (side-by-side diff) |
| `<leader>gh` | File history |
| `<leader>gc` | Commit |
| `<leader>gp` / `<leader>gP` | Pull / Push |
| `]c` / `[c` | Next/prev git hunk |

### Testing (Java/TypeScript)

| Key | Action |
|-----|--------|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run file tests |
| `<leader>ta` | Run all tests |
| `<leader>ts` | Toggle test summary |
| `<leader>td` | Debug nearest test |
| `]T` / `[T` | Next/prev failed test |

### Database (SQL)

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle Database UI |
| `<leader>da` | Add DB connection |
| `<leader>de` | Execute SQL query |
| `<leader>ds` | Save query |

### REST/HTTP Requests

| Key | Action |
|-----|--------|
| `<leader>rs` | Send HTTP request |
| `<leader>ra` | Send all requests |
| `<leader>rp` | Replay last request |
| `<leader>rc` | Copy as cURL |

### Search & Navigation

| Key | Action |
|-----|--------|
| `/` | Search in file (highlights all matches) |
| `n` / `N` | Next/prev search result |
| `<Esc>` | Clear search highlights |
| `s` | Flash jump (type chars → label → jump) |
| `S` | Flash treesitter (select code blocks) |
| `<leader>/` | Fuzzy search in current buffer |
| `<leader>fg` | Live grep (search text in all files) |
| `<leader>fw` | Search word under cursor in all files |
| `<leader>fr` | Resume last search |
| `<leader>sr` | Open Spectre (project search/replace) |
| `<leader>sw` | Search current word (Spectre) |
| `<leader>st` | Search TODOs |

### Code Editing

| Key | Action |
|-----|--------|
| `ysiw"` | Surround word with `"` |
| `ds"` | Delete surrounding `"` |
| `cs"'` | Change `"` to `'` |
| `gc` | Toggle comment (visual mode) |
| `gcc` | Toggle comment (line) |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>f` | Format file |
| `zR` / `zM` | Open/close all folds |
| `zK` | Peek fold preview |

### Refactoring

| Key | Action |
|-----|--------|
| `<leader>re` | Extract function (visual) |
| `<leader>rv` | Extract variable (visual) |
| `<leader>ri` | Inline variable |
| `<leader>rb` | Extract block |
| `<leader>rr` | Refactor menu |
| `<leader>rp` | Debug print |

### Colors (CSS)

| Key | Action |
|-----|--------|
| `<leader>cp` | Color picker |
| `<leader>cc` | Convert color format |
| `<leader>ch` | Toggle color highlight |

### LSP & Diagnostics

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>xx` | Toggle diagnostics list |
| `<leader>xX` | Buffer diagnostics |
| `]d` / `[d` | Next/prev diagnostic |
| `]t` / `[t` | Next/prev TODO |

### Focus & Zen

| Key | Action |
|-----|--------|
| `<leader>z` | Toggle Zen Mode |
| `<leader>tw` | Toggle Twilight (dim inactive) |

### Debugging

| Key | Action |
|-----|--------|
| `<F5>` | Start/Continue |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<leader>b` | Toggle breakpoint |
| `<leader>du` | Toggle debug UI |

### AI Suggestions

| Key | Action |
|-----|--------|
| `:SuggestToggle` | Enable/disable AI suggestions |
| `:AIInit` | Initialize AI (enter API key) |
| `Tab` | Accept ghost suggestion |
| `Ctrl+]` / `Ctrl+[` | Next/prev suggestion |

## General

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<C-h/j/k/l>` | Navigate splits |

## File Navigation (Telescope)

| Key | Action |
|-----|--------|
| `<leader><leader>` | Find all files |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |

## Buffer Navigation

| Key | Action |
|-----|--------|
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |
| `<S-v>` | Vertical split |
| `<leader>bd` | Close buffer |

## LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>f` | Format file |

## Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Open lazygit |
| `<leader>gb` | Git blame line |
| `]c` / `[c` | Next/prev hunk |
