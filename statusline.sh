#!/bin/bash
input=$(cat)

# Parse JSON without jq (using grep/sed)
get_val() {
    echo "$input" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*:.*"\([^"]*\)".*/\1/'
}
get_num() {
    echo "$input" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*[0-9]*" | head -1 | sed 's/.*:[[:space:]]*//'
}

# Extract values
MODEL=$(get_val "display_name")
[ -z "$MODEL" ] && MODEL="Claude"
DIR=$(get_val "cwd")
[ -z "$DIR" ] && DIR=$(get_val "current_dir")
STYLE=$(get_val "name")

# Short directory name
SHORT_DIR="${DIR##*/}"
[ -z "$SHORT_DIR" ] && SHORT_DIR="~"

# Git branch
GIT=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    [ -n "$BRANCH" ] && GIT="$BRANCH"
fi

# Context percentage
CTX=""
INPUT_TOK=$(get_num "input_tokens")
CACHE_CREATE=$(get_num "cache_creation_input_tokens")
CACHE_READ=$(get_num "cache_read_input_tokens")
CTX_SIZE=$(get_num "context_window_size")
if [ -n "$INPUT_TOK" ] && [ -n "$CTX_SIZE" ] && [ "$CTX_SIZE" -gt 0 ] 2>/dev/null; then
    TOTAL=$((INPUT_TOK + ${CACHE_CREATE:-0} + ${CACHE_READ:-0}))
    PCT=$((TOTAL * 100 / CTX_SIZE))
    CTX="${PCT}%"
fi

# Subtle colors (256-color)
C1='\033[38;5;67m'   # steel blue - dir
C2='\033[38;5;107m'  # nvidia green - git
C3='\033[38;5;141m'  # soft purple - model
C4='\033[38;5;75m'   # light blue - context
C5='\033[38;5;103m'  # dim purple - style
R='\033[0m'

# Build output
OUT="${C1}${SHORT_DIR}${R}"
[ -n "$GIT" ] && OUT+=" ${C2}(${GIT})${R}"
OUT+=" ${C3}[${MODEL}]${R}"
[ -n "$CTX" ] && OUT+=" ${C4}${CTX}${R}"
[ -n "$STYLE" ] && [ "$STYLE" != "name" ] && OUT+=" ${C5}{${STYLE}}${R}"

printf "%b\n" "$OUT"
