---
name: dev-guidelines
description: Development dos and don'ts for pvim - Lua/plugin layout, keybinding conventions, commit style, and documentation hygiene. Use before making changes or committing in this repository.
---

# pvim dev guidelines

Working checklist for changes to this Neovim config. When in doubt, match the existing `lua/` structure and keymap style rather than introducing a new pattern.

## Repository conventions

- **Config layout stays intentional**: `lua/core/` for base settings, `lua/keybinding/` for key mappings, `lua/plugins/default|extras|lsp/` for plugin specs, `lua/util/` for helpers. Put a new plugin spec under `default/` only if it's on for everyone; optional/heavy plugins go under `extras/`.
- **`pvim` must stay a real PATH binary**, launched via `NVIM_APPNAME=pvim`, never collapse it into a plain shell alias — that's what lets it coexist with a stock Neovim config. Don't touch the launcher contract in `install.sh` without checking `docs/install.md` stays accurate.
- **Snippets live under `snippets/luasnippets/<lang>.lua`**; syntax extensions (JSP, FTL) live under `syntax/`. Keep language-specific additions in their own file rather than a shared catch-all.
- **`undo/` is gitignored** — never force-add undo history or other runtime state.
- **New keybindings get documented immediately** in `docs/keybindings.md` (and `docs/java.md` / `docs/plugins.md` / `docs/ai-suggestions.md` for feature-specific ones) — the in-editor `:PvimSource` reference reads the README/docs tree, so an undocumented keymap is invisible to future-you.
- **Don't silently override an existing leader-key mapping.** Check `lua/keybinding/` for a collision before assigning a new one; if a conflict is unavoidable, call it out in the commit body.
- **AI features stay opt-in and cheap by design** — anything added to the Claude suggestion system should preserve the "off by default" behavior and the tiered cache, not bypass it for convenience.

## Before committing

- Sanity-check plugin changes with `:Lazy sync` and `:checkhealth` — a broken plugin spec should fail loudly, not silently no-op.
- For LSP/tooling changes, confirm `:LspInfo` and `:Mason` still resolve correctly for the affected language.
- For Java/JDTLS changes, verify against a real Spring Boot or Maven project, not just a scratch file — JDTLS behavior differs by project shape.
- Update the relevant `docs/*.md` page in the same commit as the behavior change — a config change that isn't reflected in docs is incomplete.

## Commit conventions

Recent history uses Conventional Commits — keep using that format:

```text
<type>(<scope>): <imperative summary>
```

Types seen in history: `feat`, `fix`, `perf`, `refactor`, `chore`, `docs`. Scope names the affected area, e.g. `cmp`, `search`, `jdtls`, `lsp`, `ai`. Subject imperative, concise, no trailing period.

Good: `fix(cmp): remove duplicate, load-order-fragile autopairs wiring` · `feat(search): add flash.nvim, hlsearch with Esc clear, and extra telescope search maps`

Avoid vague subjects like `update stuff` or `fix bug`.

## Commit hygiene

- No co-authored-by, signed-off-by, or attribution trailers.
- One logical change per commit — don't mix a keybinding change with an unrelated plugin bump.
- Never commit `lazy-lock.json` changes bundled with unrelated feature work — bump it in its own commit when intentionally updating plugin versions.
- Review `git diff --staged` before committing; unstage anything unintentional (stray `undo/` files, local `.claude/settings.local.json` edits, etc.).
- Don't amend published commits — create a new one. Don't force-push to main.
