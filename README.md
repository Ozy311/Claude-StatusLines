# Claude Code Status Line

A compact status line for Claude Code CLI with visual context bar, session cost tracking, and subtle 256-color palette.

## Features

- **jq-powered** - Reliable JSON parsing (requires jq)
- **Visual progress bar** - 10-char `▓░` bar showing context window usage
- **Agent-aware** - Shows agent name when running with `--agent`
- **Smart model names** - Parses `claude-opus-4-6` into `Opus 4.6`
- **Session stats** - Cost ($X.XX), duration (Xm), lines changed (+N -N)
- **Graceful degradation** - Omits sections when data is missing
- **Subtle colors** - Steel blue, sage green, soft purple, warm gold palette

## Preview

With agent and full stats:
```
Don (master) [Opus 4.6] ▓▓▓░░░░░░░ 22% | $0.42 | 5m | +156 -23
```

Minimal (no agent, fresh session):
```
workspace (main) [Sonnet 4.5] ▓░░░░░░░░░ 5%
```

## Requirements

- **jq** (v1.6+) - `apt install jq` / `brew install jq`
- Bash 4+

## Installation

1. Copy `statusline.sh` to your Claude config directory:
   ```bash
   cp statusline.sh ~/.claude/statusline.sh
   chmod +x ~/.claude/statusline.sh
   ```

2. Add to `~/.claude/settings.json`:
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/statusline.sh"
     }
   }
   ```

3. Restart Claude Code

## Color Scheme

| Element | Color | Code |
|---------|-------|------|
| Label (dir/agent) | Steel blue | 67 |
| Git branch | Sage green | 107 |
| Model | Soft purple | 141 |
| Context bar & % | Light blue | 75 |
| Cost | Warm gold | 222 |
| Duration | Muted teal | 109 |
| Lines changed | Dusty rose | 174 |
| Separators | Dim gray | 240 |

## Customization

Edit the color codes in `statusline.sh`:
```bash
C1='\033[38;5;67m'   # label (dir/agent)
C2='\033[38;5;107m'  # git branch
C3='\033[38;5;141m'  # model
C4='\033[38;5;75m'   # progress bar & context %
C5='\033[38;5;222m'  # cost
C6='\033[38;5;109m'  # duration
C7='\033[38;5;174m'  # lines changed
D='\033[38;5;240m'   # separators
```

See [256-color chart](https://www.ditig.com/256-colors-cheat-sheet) for options.

## JSON Fields Used

| Field | Source |
|-------|--------|
| `.model.id` | Model version parsing |
| `.model.display_name` | Fallback model name |
| `.agent.name` | Agent label (--agent mode) |
| `.context_window.used_percentage` | Progress bar + percentage |
| `.cost.total_cost_usd` | Session cost |
| `.cost.total_duration_ms` | Session duration |
| `.cost.total_lines_added` | Lines added |
| `.cost.total_lines_removed` | Lines removed |

## License

MIT
