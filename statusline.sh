#!/bin/bash
input=$(cat)

# Parse JSON with jq
jval() { echo "$input" | jq -r "$1 // empty" 2>/dev/null; }

# Model name: parse id (claude-opus-4-6 -> Opus 4.6) or fall back to display_name
MODEL_ID=$(jval '.model.id')
MODEL=""
if [ -n "$MODEL_ID" ]; then
    # Extract family and version: claude-{family}-{ver} -> Family V.V
    MODEL=$(echo "$MODEL_ID" | sed -n 's/^claude-\([a-z]*\)-\([0-9]*\)-\([0-9]*\).*$/\1 \2.\3/p')
    if [ -n "$MODEL" ]; then
        # Capitalize first letter
        MODEL="$(echo "${MODEL:0:1}" | tr '[:lower:]' '[:upper:]')${MODEL:1}"
    fi
fi
[ -z "$MODEL" ] && MODEL=$(jval '.model.display_name')
[ -z "$MODEL" ] && MODEL="Claude"

# Agent name (only present with --agent flag)
AGENT=$(jval '.agent.name')

# Directory
DIR=$(jval '.cwd // .current_dir')
SHORT_DIR="${DIR##*/}"
[ -z "$SHORT_DIR" ] && SHORT_DIR="~"

# Label: agent name if present, otherwise short dir
LABEL="${AGENT:-$SHORT_DIR}"

# Git branch
GIT=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    [ -n "$BRANCH" ] && GIT="$BRANCH"
fi

# Context: used_percentage and progress bar
PCT=$(jval '.context_window.used_percentage')
BAR=""
CTX=""
if [ -n "$PCT" ] && [ "$PCT" -ge 0 ] 2>/dev/null; then
    FILLED=$((PCT / 10))
    EMPTY=$((10 - FILLED))
    BAR=$(printf '%0.s▓' $(seq 1 $FILLED 2>/dev/null))$(printf '%0.s░' $(seq 1 $EMPTY 2>/dev/null))
    # Edge cases: 0% = all empty, 100% = all filled
    [ "$FILLED" -eq 0 ] && BAR="░░░░░░░░░░"
    [ "$FILLED" -ge 10 ] && BAR="▓▓▓▓▓▓▓▓▓▓"
    CTX="${BAR} ${PCT}%"
fi

# Session cost
COST_RAW=$(jval '.cost.total_cost_usd')
COST=""
if [ -n "$COST_RAW" ]; then
    COST=$(printf '$%.2f' "$COST_RAW" 2>/dev/null)
    [ "$COST" = '$0.00' ] && COST=""
fi

# Session duration
DUR_MS=$(jval '.cost.total_duration_ms')
DUR=""
if [ -n "$DUR_MS" ] && [ "$DUR_MS" -gt 0 ] 2>/dev/null; then
    DUR_MIN=$((DUR_MS / 60000))
    [ "$DUR_MIN" -gt 0 ] && DUR="${DUR_MIN}m"
fi

# Lines changed
ADDED=$(jval '.cost.total_lines_added')
REMOVED=$(jval '.cost.total_lines_removed')
LINES=""
if [ -n "$ADDED" ] || [ -n "$REMOVED" ]; then
    A=${ADDED:-0}
    R=${REMOVED:-0}
    if [ "$A" -gt 0 ] || [ "$R" -gt 0 ] 2>/dev/null; then
        LINES="+${A} -${R}"
    fi
fi

# Subtle colors (256-color)
C1='\033[38;5;67m'   # steel blue - label (dir/agent)
C2='\033[38;5;107m'  # sage green - git branch
C3='\033[38;5;141m'  # soft purple - model
C4='\033[38;5;75m'   # light blue - progress bar & context %
C5='\033[38;5;222m'  # warm gold - cost
C6='\033[38;5;109m'  # muted teal - duration
C7='\033[38;5;174m'  # dusty rose - lines changed
D='\033[38;5;240m'   # dim gray - separators
R='\033[0m'

# Build output
OUT="${C1}${LABEL}${R}"
[ -n "$GIT" ] && OUT+=" ${C2}(${GIT})${R}"
OUT+=" ${C3}[${MODEL}]${R}"
[ -n "$CTX" ] && OUT+=" ${C4}${CTX}${R}"

# Append optional stats with separators
STATS=""
[ -n "$COST" ] && STATS+=" ${D}|${R} ${C5}${COST}${R}"
[ -n "$DUR" ] && STATS+=" ${D}|${R} ${C6}${DUR}${R}"
[ -n "$LINES" ] && STATS+=" ${D}|${R} ${C7}${LINES}${R}"
OUT+="${STATS}"

printf "%b\n" "$OUT"
