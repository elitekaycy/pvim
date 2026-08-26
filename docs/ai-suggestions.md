# AI-Powered Code Suggestions

pvim includes a smart code suggestion system with Claude AI integration. It provides Copilot-style ghost text completions optimized for minimal API token usage.

## Quick Start

```vim
:SuggestToggle      " Turn ON the system (OFF by default)
:SuggestStatus      " Check if system is ON or OFF
:AIInit             " Enter your Anthropic API key (one time)
```

## Features

- **Ghost Text**: Inline suggestions appear as you type (like GitHub Copilot)
- **AI-Enhanced**: Uses Claude Haiku for fast, cheap completions
- **Smart Caching**: 3-tier cache (memory → disk → pattern) to minimize API calls
- **Context-Aware**: Understands your class type, fields, framework, and project patterns
- **Token Optimized**: Minimal prompts (~30 tokens), pattern reuse, local generation for simple code

## Commands

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

## Keybindings (Insert Mode)

| Key | Action |
|-----|--------|
| `Tab` | Accept ghost suggestion |
| `Ctrl+]` | Next suggestion |
| `Ctrl+[` | Previous suggestion |
| `Esc` | Dismiss suggestion |

## API Key Setup

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

## How It Works

1. **OFF by default** - no background processing until enabled
2. **Enable**: `:SuggestToggle` turns on ghost text + AI
3. **Type code** → suggestions appear as gray ghost text
4. **Tab** to accept, continue coding
5. **Disable**: `:SuggestToggle` again (state persists across restarts)

## Token Optimization

The system is designed to minimize API costs:

- **Haiku model** by default (fast, ~10x cheaper than Sonnet)
- **200ms debounce** - doesn't call API on every keystroke
- **Multi-tier cache**: memory (10min) → disk (7 days) → pattern matching
- **Pattern learning**: Extracts reusable patterns from AI responses
- **Local generation**: Getters/setters generated without API calls
- **Minimal prompts**: ~30 tokens vs typical ~150 tokens

## Supported Languages

- Java (with Spring Boot detection)
- TypeScript / TypeScript React
- JavaScript / JavaScript React
