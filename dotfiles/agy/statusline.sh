#!/bin/bash
# Antigravity (agy) status line:
# context % | model | 5h 7d quota | cached tokens
export LC_NUMERIC=C  # decimal point, independent of the user's locale
input=$(cat)

# Cache latest quota and cache telemetry for agent access
if [ -n "$input" ] && [ "$input" != "{}" ]; then
    mkdir -p "$HOME/.gemini/antigravity-cli" 2>/dev/null || true
    printf '%s\n' "$input" > "$HOME/.gemini/antigravity-cli/quota_cache.json" 2>/dev/null || true
fi

format_tokens() {
    local t=$1
    if [ -z "$t" ] || [ "$t" -le 0 ]; then
        echo "0"
    elif [ "$t" -ge 1000000 ]; then
        local m=$(( t / 1000000 ))
        local rem=$(( (t % 1000000) / 100000 ))
        if [ "$rem" -gt 0 ] && [ "$m" -lt 10 ]; then
            echo "${m}.${rem}M"
        else
            echo "${m}M"
        fi
    elif [ "$t" -ge 1000 ]; then
        echo "$(( t / 1000 ))k"
    else
        echo "$t"
    fi
}

PCT=$(jq -r '.context_window.used_percentage // 0' <<<"$input" | cut -d. -f1)
CUR_TOKENS=$(jq -r '.context_window.total_input_tokens // .context_window.current_usage.input_tokens // empty' <<<"$input")
MAX_TOKENS=$(jq -r '.context_window.context_window_size // empty' <<<"$input")
MODEL=$(jq -r '.model.display_name // .model.id // "?"' <<<"$input")
FIVE=$(jq -r '(.quota["gemini-5h"].remaining_fraction // empty) * 100 | round' <<<"$input")
REM_SEC=$(jq -r '(.quota["gemini-5h"].reset_in_seconds // (((.quota["gemini-5h"].reset_time // empty | fromdateiso8601?) - now) | floor) // empty)' <<<"$input")
FIVE_RESET=""
if [ -n "$REM_SEC" ]; then
    [ "$REM_SEC" -lt 0 ] && REM_SEC=0
    H=$(( REM_SEC / 3600 ))
    M=$(( (REM_SEC % 3600) / 60 ))
    if [ "$H" -gt 0 ]; then
        [ "$M" -gt 0 ] && FIVE_RESET="${H}h ${M}m" || FIVE_RESET="${H}h"
    else
        FIVE_RESET="${M}m"
    fi
fi
WEEK=$(jq -r '(.quota["gemini-weekly"].remaining_fraction // empty) * 100 | round' <<<"$input")
CACHED=$(jq -r '.context_window.current_usage.cache_read_input_tokens // empty' <<<"$input")

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'
MAGENTA='\033[35m'; DIM='\033[2m'; RESET='\033[0m'

# Context tokens and %, color by threshold
if   [ "$PCT" -ge 90 ]; then CTX_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then CTX_COLOR="$YELLOW"
else CTX_COLOR="$GREEN"; fi

if [ -n "$MAX_TOKENS" ] && [ "$MAX_TOKENS" -gt 0 ]; then
    CUR_STR=$(format_tokens "${CUR_TOKENS:-0}")
    MAX_STR=$(format_tokens "$MAX_TOKENS")
    OUT="${CTX_COLOR}${CUR_STR}/${MAX_STR} (${PCT}%)${RESET}"
else
    OUT="${CTX_COLOR}${PCT}%${RESET}"
fi

# Model
OUT+=" | ${CYAN}${MODEL}${RESET}"

# Rate limits / Quota (Gemini 5h and weekly remaining)
if [ -n "$FIVE" ] || [ -n "$WEEK" ]; then
    LIMITS=""
    if [ -n "$FIVE" ]; then
        LIMITS+="5h ${FIVE}%"
        [ -n "$FIVE_RESET" ] && LIMITS+=" (${FIVE_RESET})"
    fi
    [ -n "$WEEK" ] && LIMITS+="${LIMITS:+ - }7d ${WEEK}%"
    OUT+=" | ${MAGENTA}${LIMITS}${RESET}"
fi

# Cached tokens
if [ -n "$CACHED" ] && [ "$CACHED" -gt 0 ]; then
    CACHED_STR=$(format_tokens "$CACHED")
    OUT+=" | ${GREEN}cached ${CACHED_STR}${RESET}"
fi

printf '%b\n' "$OUT"
