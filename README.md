# Claude Code Status Bar

Real-time usage monitoring for Claude Code.

```
🤖 Opus │ 5h ████░░░░ 25% (4h30m) │ 7d ██░░░░░░ 15% (5d12h) │ CTX ██░░░░░░ 12% │ git main +1 ~2 ?3
📁 ~/project/my-app
```

## Features

| Item | Description |
|------|-------------|
| 🤖 Model | Current model (Opus/Sonnet/Haiku) with color |
| 5h | 5-hour usage with progress bar and reset time |
| 7d | 7-day usage with progress bar and reset time |
| CTX | Context window usage |
| git | Branch name and file status |
| 📁 Path | Current working directory |

### Git Status

- `+N` (green): staged files
- `~N` (yellow): modified files
- `?N` (cyan): untracked files

### Progress Bar Colors

- Green: 0-49%
- Yellow: 50-69%
- Bright Yellow: 70-89%
- Red: 90-100%

## Installation

### One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/hichoe95/claude-code-usage-status-bar/main/install.sh | bash
```

### Manual install

1. Copy `statusline.py` to `~/.claude/`:

```bash
curl -o ~/.claude/statusline.py https://raw.githubusercontent.com/user/claude-statusbar/main/statusline.py
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

## Requirements

- Python 3.6+
- Claude Code with OAuth login
- `curl`, `git`

## Uninstall

```bash
rm ~/.claude/statusline.py
```

Then remove the `statusLine` section from `~/.claude/settings.json`.

## License

MIT
