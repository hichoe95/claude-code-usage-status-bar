#!/bin/bash
# Claude Code Status Bar Installer
# Usage: curl -fsSL <url>/install.sh | bash

set -e

STATUSLINE_URL="https://raw.githubusercontent.com/YOUR_USERNAME/claude-statusbar/main/statusline.py"
CLAUDE_DIR="$HOME/.claude"

echo "📦 Installing Claude Code Status Bar..."

# Create .claude directory if not exists
mkdir -p "$CLAUDE_DIR"

# Download statusline.py
cat > "$CLAUDE_DIR/statusline.py" << 'STATUSLINE_EOF'
#!/usr/bin/env python3
"""
Claude Code Status Line

Fetches real usage data from Anthropic API using OAuth token.
API: https://api.anthropic.com/api/oauth/usage
"""

import json
import sys
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path


class Colors:
    RESET = "\033[0m"
    BOLD = "\033[1m"
    DIM = "\033[2m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    CYAN = "\033[36m"
    WHITE = "\033[37m"
    BRIGHT_RED = "\033[91m"
    BRIGHT_GREEN = "\033[92m"
    BRIGHT_YELLOW = "\033[93m"
    BRIGHT_MAGENTA = "\033[95m"
    BRIGHT_CYAN = "\033[96m"


def get_oauth_token():
    creds_file = Path.home() / ".claude" / ".credentials.json"
    if not creds_file.exists():
        return None
    try:
        with open(creds_file) as f:
            creds = json.load(f)
        return creds.get("claudeAiOauth", {}).get("accessToken")
    except:
        return None


def fetch_usage_from_api():
    token = get_oauth_token()
    if not token:
        return None
    try:
        result = subprocess.run(
            ["curl", "-s", "https://api.anthropic.com/api/oauth/usage",
             "-H", f"Authorization: Bearer {token}",
             "-H", "Content-Type: application/json",
             "-H", "anthropic-beta: oauth-2025-04-20"],
            capture_output=True, text=True, timeout=5
        )
        if result.returncode == 0:
            return json.loads(result.stdout)
    except:
        pass
    return None


def get_git_info(cwd):
    """Get git branch and status info."""
    try:
        # Check if in git repo
        result = subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            capture_output=True, text=True, timeout=2, cwd=cwd
        )
        if result.returncode != 0:
            return None

        # Get branch name
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, timeout=2, cwd=cwd
        )
        if result.returncode == 0:
            branch = result.stdout.strip()
        else:
            # Fallback for repos without commits
            result = subprocess.run(
                ["git", "symbolic-ref", "--short", "HEAD"],
                capture_output=True, text=True, timeout=2, cwd=cwd
            )
            branch = result.stdout.strip() if result.returncode == 0 else "?"

        # Get status (modified, staged, untracked counts)
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True, text=True, timeout=2, cwd=cwd
        )
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n') if result.stdout.strip() else []
            modified = sum(1 for l in lines if l and l[1] == 'M')
            staged = sum(1 for l in lines if l and l[0] in 'MADRC')
            untracked = sum(1 for l in lines if l and l[:2] == '??')
            return {"branch": branch, "modified": modified, "staged": staged, "untracked": untracked}
        return {"branch": branch, "modified": 0, "staged": 0, "untracked": 0}
    except:
        return None


def parse_reset_time(iso_string):
    if not iso_string:
        return None
    try:
        reset_time = datetime.fromisoformat(iso_string.replace('Z', '+00:00'))
        now = datetime.now(timezone.utc)
        remaining = reset_time - now
        if remaining.total_seconds() <= 0:
            return "reset"
        total_seconds = remaining.total_seconds()
        days = int(total_seconds // 86400)
        hours = int((total_seconds % 86400) // 3600)
        minutes = int((total_seconds % 3600) // 60)
        if days > 0:
            return f"{days}d{hours}h"
        elif hours > 0:
            return f"{hours}h{minutes}m"
        return f"{minutes}m"
    except:
        return None


def make_progress_bar(percentage, width=8):
    percentage = min(100, max(0, percentage))
    filled = int(width * percentage / 100)
    empty = width - filled
    if percentage >= 90:
        color = Colors.BRIGHT_RED
    elif percentage >= 70:
        color = Colors.BRIGHT_YELLOW
    elif percentage >= 50:
        color = Colors.YELLOW
    else:
        color = Colors.BRIGHT_GREEN
    bar = "█" * filled + "░" * empty
    return f"{color}{bar}{Colors.RESET}"


def get_model_color(model_name):
    model_lower = model_name.lower()
    if "opus" in model_lower:
        return Colors.BRIGHT_MAGENTA
    elif "sonnet" in model_lower:
        return Colors.BRIGHT_CYAN
    elif "haiku" in model_lower:
        return Colors.BRIGHT_GREEN
    return Colors.CYAN


def main():
    try:
        stdin_data = sys.stdin.read()
        data = json.loads(stdin_data) if stdin_data.strip() else {}
    except:
        data = {}

    model_info = data.get("model", {})
    model_display = model_info.get("display_name", "?")
    current_dir = data.get("workspace", {}).get("current_dir", os.getcwd())

    home = str(Path.home())
    if current_dir.startswith(home):
        display_path = "~" + current_dir[len(home):]
    else:
        display_path = current_dir

    if len(display_path) > 20:
        parts = display_path.split("/")
        if len(parts) > 2:
            display_path = ".../" + "/".join(parts[-2:])

    # Get context window information
    context_window = data.get("context_window", {})
    ctx_used_pct = context_window.get("used_percentage")

    # Get current task/activity info
    activity = data.get("activity", {})
    current_task = activity.get("current_task") or activity.get("status")

    usage = fetch_usage_from_api()

    if usage:
        five_hour = usage.get("five_hour", {})
        pct_5h = int(five_hour.get("utilization", 0))
        time_5h = parse_reset_time(five_hour.get("resets_at")) or "5h"

        seven_day = usage.get("seven_day", {})
        pct_7d = int(seven_day.get("utilization", 0))
        time_7d = parse_reset_time(seven_day.get("resets_at")) or "7d"
    else:
        pct_5h, time_5h = 0, "?"
        pct_7d, time_7d = 0, "?"

    # Get git info
    git_info = get_git_info(current_dir)

    C = Colors
    model_color = get_model_color(model_display)

    parts = [
        f"🤖 {model_color}{C.BOLD}{model_display}{C.RESET}",
    ]

    # Add current task if available
    if current_task:
        task_display = current_task[:30] + "..." if len(current_task) > 30 else current_task
        parts.extend([
            f"{C.WHITE}│{C.RESET}",
            f"{C.WHITE}⚡ {task_display}{C.RESET}",
        ])

    parts.extend([
        f"{C.WHITE}│{C.RESET}",
        f"{C.YELLOW}5h{C.RESET} {make_progress_bar(pct_5h)} {C.BOLD}{pct_5h}%{C.RESET} {C.WHITE}({time_5h}){C.RESET}",
        f"{C.WHITE}│{C.RESET}",
        f"{C.BLUE}7d{C.RESET} {make_progress_bar(pct_7d)} {C.BOLD}{pct_7d}%{C.RESET} {C.WHITE}({time_7d}){C.RESET}",
    ])

    # Add context window info if available
    if ctx_used_pct is not None:
        ctx_pct = int(ctx_used_pct)
        parts.extend([
            f"{C.WHITE}│{C.RESET}",
            f"{C.BRIGHT_MAGENTA}CTX{C.RESET} {make_progress_bar(ctx_pct)} {C.BOLD}{ctx_pct}%{C.RESET}",
        ])

    # Add git info if available
    if git_info:
        branch = git_info["branch"]
        # Truncate long branch names
        if len(branch) > 15:
            branch = branch[:12] + "..."

        git_status = []
        if git_info["staged"] > 0:
            git_status.append(f"{C.BRIGHT_GREEN}+{git_info['staged']}{C.RESET}")
        if git_info["modified"] > 0:
            git_status.append(f"{C.BRIGHT_YELLOW}~{git_info['modified']}{C.RESET}")
        if git_info["untracked"] > 0:
            git_status.append(f"{C.CYAN}?{git_info['untracked']}{C.RESET}")

        git_part = f"{C.BRIGHT_GREEN}git{C.RESET} {C.WHITE}{branch}{C.RESET}"
        if git_status:
            git_part += f" {' '.join(git_status)}"

        parts.extend([
            f"{C.WHITE}│{C.RESET}",
            git_part,
        ])

    # First line
    print(" ".join(parts))

    # Second line: path (parent normal, current dir bright bold)
    if "/" in display_path:
        parent = display_path.rsplit("/", 1)[0] + "/"
        current = display_path.rsplit("/", 1)[1]
        print(f"{C.CYAN}📁 {parent}{C.RESET}{C.BRIGHT_CYAN}{C.BOLD}{current}{C.RESET}")
    else:
        print(f"{C.BRIGHT_CYAN}📁 {C.BOLD}{display_path}{C.RESET}")


if __name__ == "__main__":
    main()
STATUSLINE_EOF

chmod +x "$CLAUDE_DIR/statusline.py"

# Update settings.json
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    # Backup existing settings
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"

    # Add statusLine config using python
    python3 << PYTHON_EOF
import json

with open("$SETTINGS_FILE", "r") as f:
    settings = json.load(f)

settings["statusLine"] = {
    "type": "command",
    "command": "python3 ~/.claude/statusline.py",
    "padding": 0
}

with open("$SETTINGS_FILE", "w") as f:
    json.dump(settings, f, indent=2)
PYTHON_EOF
else
    # Create new settings.json
    cat > "$SETTINGS_FILE" << 'SETTINGS_EOF'
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.claude/statusline.py",
    "padding": 0
  }
}
SETTINGS_EOF
fi

echo "✅ Installation complete!"
echo ""
echo "Status bar will show:"
echo "  🤖 Model │ 5h ████░░░░ 25% (4h30m) │ 7d ██░░░░░░ 15% (5d12h) │ CTX ██░░░░░░ 12% │ git main ~2"
echo "  📁 ~/project/path"
echo ""
echo "Restart Claude Code to see the status bar."
