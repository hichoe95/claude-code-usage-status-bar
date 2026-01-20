# Claude Code Status Bar

Real-time usage monitoring for Claude Code using the Anthropic API.

![Status Bar Example](https://via.placeholder.com/600x40?text=~_~V+Opus+~T~B+~_~S~A+path+~T~B+5h+~V~H~V~H~V~H~V~H~V~Q~V~Q~V~Q~V~Q+25%25+(4h30m)+~T~B+7d+~V~H~V~H~V~Q~V~Q~V~Q~V~Q~V~Q~VV
~Q+15%25+(5d12h))

## Features

- ~_~V Current model display (Opus/Sonnet/Haiku with colors)
- ~_~S~A Current working directory
- ~O~O 5-hour usage with progress bar and reset time
- ~_~S~E 7-day usage with progress bar and reset time
- ~_~N Color-coded progress bars (green ~F~R yellow ~F~R red)

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