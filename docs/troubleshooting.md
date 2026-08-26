# Troubleshooting

## Plugins not loading

```vim
:Lazy sync
```

## LSP not working

```vim
:LspInfo
:Mason
```

## Java issues

```bash
# Clear JDTLS cache
rm -rf ~/.local/share/nvim/jdtls/workspace/*

# Verify Java version
java -version  # Should be 17+
```

## Check health

```vim
:checkhealth
```

## `pvim` opens the wrong config

If `pvim .` opens your normal Neovim config instead of pvim, your shell is finding a different binary first. Run `which pvim` and fix `PATH` so `~/.local/bin` comes before anything else that shadows it — see [install.md](./install.md#3-ensure-the-pvim-launcher-works).
