#!/bin/bash
# Antigravity (agy) status line:
# context % | model | 5h 7d quota | cached tokens
export LC_NUMERIC=C  # decimal point, independent of the user's locale
input=$(cat)

PCT=$(jq -r '.context_window.used_percentage // 0' <<<"$input" | cut -d. -f1)
MODEL=$(jq -r '.model.display_name // .model.id // "?"' <<<"$input")
FIVE=$(jq -r '(.quota["gemini-5h"].remaining_fraction // empty) * 100 | round' <<<"$input")
FIVE_RESET=$(jq -r '((.quota["gemini-5h"].reset_time // empty | fromdateiso8601?) // (if .quota["gemini-5h"].reset_in_seconds then (now + .quota["gemini-5h"].reset_in_seconds) else empty end)) | strflocaltime("%H:%M")' <<<"$input")
WEEK=$(jq -r '(.quota["gemini-weekly"].remaining_fraction // empty) * 100 | round' <<<"$input")
CACHED=$(jq -r '.context_window.current_usage.cache_read_input_tokens // empty' <<<"$input")

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'
MAGENTA='\033[35m'; DIM='\033[2m'; RESET='\033[0m'

# Context %, color by threshold
if   [ "$PCT" -ge 90 ]; then CTX_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then CTX_COLOR="$YELLOW"
else CTX_COLOR="$GREEN"; fi
OUT="${CTX_COLOR}${PCT}%${RESET}"

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
    if [ "$CACHED" -ge 1000000 ]; then
        CACHED_STR="$(( CACHED / 1000000 )).$(( (CACHED % 1000000) / 100000 ))M"
    elif [ "$CACHED" -ge 1000 ]; then
        CACHED_STR="$(( CACHED / 1000 ))k"
    else
        CACHED_STR="$CACHED"
    fi
    OUT+=" | ${GREEN}cached ${CACHED_STR}${RESET}"
fi

printf '%b\n' "$OUT"
