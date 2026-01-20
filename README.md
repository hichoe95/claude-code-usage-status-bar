# Claude Code Status Bar

Real-time usage monitoring for Claude Code using the Anthropic API.

![Status Bar Example](https://via.placeholder.com/600x40?text=Status+Bar+Example)

## Features

- 📊 Current model display (Opus/Sonnet/Haiku with colors)
- 📁 Current working directory
- ⏱️ 5-hour usage with progress bar and reset time
- 📈 7-day usage with progress bar and reset time
- ▓ Color-coded progress bars (green → yellow → red)

## Installation

### One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-statusbar/main/install.sh | bash
```

### Manual install

1. Copy `statusline.py` to `~/.claude/`:

```bash
cp statusline.py ~/.claude/statusline.py
chmod +x ~/.claude/statusline.py
```

2. Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.claude/statusline.py",
    "padding": 0
  }
}
```

3. Restart Claude Code.

## How it works

The script fetches real usage data from the Anthropic API:

```
GET https://api.anthropic.com/api/oauth/usage
Authorization: Bearer {oauth_token}
```

The OAuth token is automatically read from `~/.claude/.credentials.json` (created when you log into Claude Code).

## Requirements

- Python 3.6+
- Claude Code with OAuth login (not API key)
- `curl` command

## Uninstall

```bash
rm ~/.claude/statusline.py
# Remove "statusLine" section from ~/.claude/settings.json
```

## License

MIT