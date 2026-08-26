# Java Development

pvim has first-class Java and Spring Boot support.

## Requirements

- Java 17+ (required for JDTLS)
- Maven or Gradle

## Install Java (SDKMAN recommended)

```bash
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21-tem
```

## Java Keybindings

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>co` | Organize imports |
| `<leader>crv` | Extract variable |
| `<leader>crc` | Extract constant |
| `<leader>crm` | Extract method |

## JUnit Testing

| Key | Action |
|-----|--------|
| `<leader>jt` | Test nearest method |
| `<leader>jT` | Test class |
| `<leader>jp` | Pick test to run |

## Spring Boot Module Generator

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

## Java Snippets

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

## Clearing JDTLS Cache

If you experience issues:

```bash
rm -rf ~/.local/share/nvim/jdtls/workspace/*
```

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
