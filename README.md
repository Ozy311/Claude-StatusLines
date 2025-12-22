# Claude Code Status Line

A minimal, no-dependency status line script for Claude Code CLI with subtle blue/purple/green color scheme.

## Features

- **No dependencies** - Pure bash/grep/sed (no jq required)
- **Subtle colors** - Steel blue, NVIDIA green, soft purple palette
- **Shows**: Directory, git branch, model, context %, output style

## Preview

```
workspace (main) [Opus 4.5] 3% {Normal}
```

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
| Directory | Steel blue | 67 |
| Git branch | NVIDIA green | 107 |
| Model | Soft purple | 141 |
| Context % | Light blue | 75 |
| Style | Dim purple | 103 |

## Customization

Edit the color codes in `statusline.sh`:
```bash
C1='\033[38;5;67m'   # directory
C2='\033[38;5;107m'  # git branch
C3='\033[38;5;141m'  # model
C4='\033[38;5;75m'   # context %
C5='\033[38;5;103m'  # style
```

See [256-color chart](https://www.ditig.com/256-colors-cheat-sheet) for options.

## License

MIT
