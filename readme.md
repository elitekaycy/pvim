# pvim

A personalized Neovim configuration tailored for a streamlined and efficient development workflow, with first-class support for Java/Spring Boot development.

![sample img png](./docs/ss.png)

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

### Search & Replace

| Key | Action |
|-----|--------|
| `<leader>sr` | Open Spectre (project search/replace) |
| `<leader>sw` | Search current word |
| `<leader>st` | Search TODOs |
| `/` | Search in file |
| `n` / `N` | Next/prev search result |

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

---

## Features

- **Plugin Management:** Lazy loading with `lazy.nvim` for fast startup
- **File Explorer:** `nvim-tree` for file navigation
- **Fuzzy Finding:** `telescope.nvim` for files, buffers, grep, and more
- **LSP Integration:** Full language server support via `nvim-lspconfig` and Mason
- **Code Completion:** Smart autocompletion with `nvim-cmp`
- **AI Suggestions:** Copilot-style ghost text with Claude AI (Haiku) - token optimized
- **Git Integration:** `gitsigns`, `lazygit`, and git keybindings
- **UI Enhancements:** `lualine`, `bufferline`, `noice`, and 40+ color schemes
- **Syntax Highlighting:** `nvim-treesitter` with extended support for JSP and FreeMarker
- **Debugging:** Full DAP support for Java, C/C++, Rust, Python, and Go
- **Java/Spring Boot:** JDTLS integration with module generation and context-aware snippets
- **Snippets:** `luasnip` with extensive Java, JSP, and FreeMarker snippets
- **REST Client:** Test APIs with `.http` files directly in Neovim
- **Database Client:** Query MySQL, PostgreSQL, SQLite with `vim-dadbod`
- **Quick Navigation:** Harpoon for instant file jumping
- **Search & Replace:** Project-wide with Spectre
- **Diagnostics:** Pretty lists with Trouble
- **Todo Comments:** Highlight and search TODO/FIXME/HACK
- **Git Diffs:** Side-by-side diffs with Diffview
- **Git Interface:** Full Magit-like interface with Neogit
- **Zen Mode:** Distraction-free coding
- **Markdown Preview:** Live preview in browser
- **Test Runner:** Modern test UI with Neotest
- **Session Management:** Auto-save/restore sessions with persistence.nvim
- **Project Management:** Quick project switching with telescope
- **Floating Terminal:** Toggle terminal with toggleterm.nvim
- **Refactoring:** Extract function/variable, inline with refactoring.nvim
- **Code Outline:** Symbols sidebar with aerial.nvim
- **Auto Pairs:** Auto-close brackets and quotes
- **Modern Folds:** Peek preview with nvim-ufo
- **Color Picker:** Pick/convert colors with ccc.nvim

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

## AI-Powered Code Suggestions

pvim includes a smart code suggestion system with Claude AI integration. It provides Copilot-style ghost text completions optimized for minimal API token usage.

### Quick Start

```vim
:SuggestToggle      " Turn ON the system (OFF by default)
:SuggestStatus      " Check if system is ON or OFF
:AIInit             " Enter your Anthropic API key (one time)
```

### Features

- **Ghost Text**: Inline suggestions appear as you type (like GitHub Copilot)
- **AI-Enhanced**: Uses Claude Haiku for fast, cheap completions
- **Smart Caching**: 3-tier cache (memory → disk → pattern) to minimize API calls
- **Context-Aware**: Understands your class type, fields, framework, and project patterns
- **Token Optimized**: Minimal prompts (~30 tokens), pattern reuse, local generation for simple code

### Commands

| Command | Description |
|---------|-------------|
| `:SuggestToggle` | **Master switch** - enable/disable entire system |
| `:SuggestStatus` | Show system status |
| `:AIInit` | Initialize AI / enter API key |
| `:AIStatus` | Show AI status and cache statistics |
| `:AIModel [fast\|smart]` | Switch between Haiku (fast) and Sonnet (quality) |
| `:GhostToggle` | Toggle ghost text only |
| `:AIClearCache` | Clear memory cache |
| `:AIClearCache!` | Clear all caches (memory + disk) |

### Keybindings (Insert Mode)

| Key | Action |
|-----|--------|
| `Tab` | Accept ghost suggestion |
| `Ctrl+]` | Next suggestion |
| `Ctrl+[` | Previous suggestion |
| `Esc` | Dismiss suggestion |

### API Key Setup

Option 1: Environment variable (recommended)
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

Option 2: Config file
```bash
mkdir -p ~/.config/anthropic
echo "sk-ant-..." > ~/.config/anthropic/api_key
chmod 600 ~/.config/anthropic/api_key
```

Option 3: Interactive prompt
```vim
:AIInit
```
Enter your key when prompted. It will offer to save it.

### How It Works

1. **OFF by default** - no background processing until enabled
2. **Enable**: `:SuggestToggle` turns on ghost text + AI
3. **Type code** → suggestions appear as gray ghost text
4. **Tab** to accept, continue coding
5. **Disable**: `:SuggestToggle` again (state persists across restarts)

### Token Optimization

The system is designed to minimize API costs:

- **Haiku model** by default (fast, ~10x cheaper than Sonnet)
- **200ms debounce** - doesn't call API on every keystroke
- **Multi-tier cache**: memory (10min) → disk (7 days) → pattern matching
- **Pattern learning**: Extracts reusable patterns from AI responses
- **Local generation**: Getters/setters generated without API calls
- **Minimal prompts**: ~30 tokens vs typical ~150 tokens

### Supported Languages

- Java (with Spring Boot detection)
- TypeScript / TypeScript React
- JavaScript / JavaScript React

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

## Database Client

Query MySQL, PostgreSQL, SQLite, and more directly in Neovim.

### Quick Start

```vim
:DBUI                    " Open database UI
:DBUIAddConnection       " Add new connection
```

### Connection Strings

```
mysql://user:password@localhost:3306/dbname
postgresql://user:password@localhost:5432/dbname
sqlite:///path/to/database.db
mongodb://localhost:27017/dbname
```

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle Database UI |
| `<leader>da` | Add DB connection |
| `<leader>df` | Find DB buffer |
| `<leader>de` | Execute query (normal/visual) |
| `<leader>ds` | Save query |

### Commands

| Command | Description |
|---------|-------------|
| `:DBUI` | Open database UI |
| `:DBUIToggle` | Toggle database UI |
| `:DBUIAddConnection` | Add new connection |
| `:DBUIFindBuffer` | Find DB buffer |

### Features

- Auto-completion for table/column names
- Save and reuse queries
- Browse tables and schemas
- Table helpers (Count, Describe, etc.)

## REST Client

Test APIs directly in Neovim with `.http` files - no Postman needed.

### Quick Start

Create a file with `.http` extension:
```http
### Get all users
GET http://localhost:8080/api/users
Content-Type: application/json

### Create user
POST http://localhost:8080/api/users
Content-Type: application/json

{
  "name": "John",
  "email": "john@example.com"
}
```

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>rs` | Send request under cursor |
| `<leader>ra` | Send all requests |
| `<leader>rp` | Replay last request |
| `<leader>rc` | Copy as cURL |
| `<leader>rt` | Toggle body/headers view |
| `<leader>re` | Set environment |
| `]r` / `[r` | Jump to next/prev request |

### Commands

| Command | Description |
|---------|-------------|
| `:RestRun` | Run request under cursor |
| `:RestRunAll` | Run all requests in file |
| `:RestCopy` | Copy request as cURL |
| `:RestEnv` | Set environment |

### HTTP Snippets (in .http files)

Comprehensive snippets for API testing - type trigger and press Tab.

#### Environment Variables

| Trigger | Description |
|---------|-------------|
| `http-env` | Basic env vars (baseUrl, token, apiKey) |
| `http-env-full` | Full env setup with auth and test IDs |
| `http-var` | Single variable definition |
| `http-ref` | Variable reference `{{var}}` |

**Example usage:**
```http
@baseUrl = http://localhost:8080
@token = your-jwt-token

### Get users
GET {{baseUrl}}/api/users
Authorization: Bearer {{token}}
```

**Or use environment files** (`http-client.env.json`):
```json
{
  "dev": { "baseUrl": "http://localhost:8080" },
  "prod": { "baseUrl": "https://api.example.com" }
}
```
Switch with `<leader>re` or `:RestEnv`.

#### GET Requests

| Trigger | Description |
|---------|-------------|
| `http-get` | Basic GET request |
| `http-get-query` | GET with query parameters |
| `http-get-headers` | GET with custom headers |
| `http-get-path` | GET with path parameter |
| `http-get-paginated` | Paginated GET request |

#### POST Requests

| Trigger | Description |
|---------|-------------|
| `http-post-json` | POST with JSON body |
| `http-post-json-nested` | POST with nested JSON object |
| `http-post-json-array` | POST with JSON array |
| `http-post-form` | POST with form data |
| `http-post-multipart` | POST multipart/form-data |
| `http-post-xml` | POST with XML body |

#### PUT/PATCH/DELETE

| Trigger | Description |
|---------|-------------|
| `http-put-json` | PUT update request |
| `http-patch-json` | PATCH partial update |
| `http-patch-jsonpatch` | JSON Patch format |
| `http-delete` | DELETE request |
| `http-delete-body` | DELETE with body |

#### Authentication

| Trigger | Description |
|---------|-------------|
| `http-auth-bearer` | Bearer token auth |
| `http-auth-basic` | Basic auth |
| `http-auth-apikey` | API key header |
| `http-auth-apikey-query` | API key in query string |
| `http-oauth-client-credentials` | OAuth2 client credentials |
| `http-oauth-password` | OAuth2 password grant |
| `http-oauth-refresh` | OAuth2 refresh token |
| `http-jwt-login` | JWT authentication |

#### Full Templates

| Trigger | Description |
|---------|-------------|
| `http-crud` | Full CRUD operations template |
| `http-auth-flow` | Complete auth flow (login/refresh/logout) |
| `http-spring-actuator` | Spring Boot Actuator endpoints |
| `http-graphql-query` | GraphQL query template |
| `http-graphql-mutation` | GraphQL mutation template |
| `http-websocket` | WebSocket handshake |
| `http-health` | Simple health check |
| `http-headers-common` | Common headers snippet |

## SQL Snippets (in .sql files)

Comprehensive snippets for database queries - type trigger and press Tab.

### SELECT Queries

| Trigger | Description |
|---------|-------------|
| `sel` | Basic SELECT |
| `sela` | SELECT with table alias |
| `seld` | SELECT DISTINCT |
| `selo` | SELECT with ORDER BY |
| `selp` | SELECT with pagination (LIMIT/OFFSET) |
| `selc` | SELECT COUNT |
| `selg` | SELECT with GROUP BY and HAVING |
| `selagg` | SELECT with aggregations (SUM, AVG, MIN, MAX) |

### JOINs

| Trigger | Description |
|---------|-------------|
| `join` | INNER JOIN |
| `ljoin` | LEFT JOIN |
| `rjoin` | RIGHT JOIN |
| `fjoin` | FULL OUTER JOIN |
| `mjoin` | Multiple JOINs |

### Subqueries & CTEs

| Trigger | Description |
|---------|-------------|
| `selsub` | SELECT with subquery in WHERE |
| `selexists` | SELECT with EXISTS |
| `cte` | Common Table Expression (WITH) |
| `ctem` | Multiple CTEs |

### INSERT/UPDATE/DELETE

| Trigger | Description |
|---------|-------------|
| `ins` | Basic INSERT |
| `insm` | INSERT multiple rows |
| `inssel` | INSERT from SELECT |
| `insret` | INSERT with RETURNING (PostgreSQL) |
| `upsert` | INSERT ON CONFLICT (PostgreSQL) |
| `insig` | INSERT IGNORE (MySQL) |
| `upd` | Basic UPDATE |
| `updm` | UPDATE multiple columns |
| `updj` | UPDATE with JOIN |
| `upds` | UPDATE with subquery |
| `del` | DELETE |
| `delj` | DELETE with JOIN |
| `dels` | DELETE with subquery |
| `trunc` | TRUNCATE TABLE |

### Table Operations

| Trigger | Description |
|---------|-------------|
| `crt` | CREATE TABLE |
| `crtfk` | CREATE TABLE with foreign key |
| `crtfull` | Full CREATE TABLE template |
| `altadd` | ALTER TABLE ADD COLUMN |
| `altdrop` | ALTER TABLE DROP COLUMN |
| `altmod` | ALTER TABLE MODIFY COLUMN |
| `altren` | RENAME COLUMN |
| `altcon` | ADD CONSTRAINT |
| `creidx` | CREATE INDEX |
| `dropidx` | DROP INDEX |

### Transactions & Views

| Trigger | Description |
|---------|-------------|
| `trans` | Transaction block |
| `transsp` | Transaction with savepoint |
| `view` | CREATE VIEW |
| `matview` | CREATE MATERIALIZED VIEW |

### Functions & Triggers

| Trigger | Description |
|---------|-------------|
| `func` | PostgreSQL function |
| `proc` | MySQL stored procedure |
| `trig` | PostgreSQL trigger |

### Utility Queries

| Trigger | Description |
|---------|-------------|
| `dup` | Find duplicates |
| `tinfo` | Table info (columns) |
| `tsize` | Table sizes |
| `runq` | Running queries |
| `killq` | Kill query |
| `expl` | EXPLAIN ANALYZE |
| `case` | CASE statement |
| `coal` | COALESCE |
| `nullif` | NULLIF |
| `datenow` | Current timestamp |
| `dateint` | Date interval |
| `jsonb` | PostgreSQL JSONB queries |
| `arr` | PostgreSQL ARRAY |
| `window` | Window function (ROW_NUMBER) |
| `rank` | RANK/DENSE_RANK |
| `grant` | GRANT permissions |
| `revoke` | REVOKE permissions |
| `crtuser` | CREATE USER with grants |

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
│       ├── java.lua      # Java/Spring Boot
│       ├── jsp.lua       # JSTL/JSP
│       ├── ftl.lua       # FreeMarker
│       ├── http.lua      # REST API testing
│       └── sql.lua       # SQL/Database
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
