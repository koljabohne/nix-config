#!/bin/bash
# Claude Code status line:
# context % | model | 5h 7d | chat cost | cache warm | cache expires (min, TTL)
export LC_NUMERIC=C  # decimal point, independent of the user's locale
input=$(cat)

PCT=$(jq -r '.context_window.used_percentage // 0' <<<"$input" | cut -d. -f1)
MODEL=$(jq -r '.model.display_name // "?"' <<<"$input")
FIVE=$(jq -r '.rate_limits.five_hour.used_percentage // empty | 100 - . | round' <<<"$input")
WEEK=$(jq -r '.rate_limits.seven_day.used_percentage // empty | 100 - . | round' <<<"$input")
COST=$(jq -r '.cost.total_cost_usd // empty' <<<"$input")
WARM=$(jq -r '.prompt_cache.warm // false' <<<"$input")
TTL=$(jq -r '.prompt_cache.ttl // empty' <<<"$input")
EXPIRES=$(jq -r '.prompt_cache.expires_at // empty' <<<"$input")

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'
MAGENTA='\033[35m'; DIM='\033[2m'; RESET='\033[0m'

# Context %, color by threshold
if   [ "$PCT" -ge 90 ]; then CTX_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then CTX_COLOR="$YELLOW"
else CTX_COLOR="$GREEN"; fi
OUT="${CTX_COLOR}${PCT}%${RESET}"

# Model
OUT+=" | ${CYAN}${MODEL}${RESET}"

# Rate limits (subscription only)
if [ -n "$FIVE" ] || [ -n "$WEEK" ]; then
    LIMITS=""
    [ -n "$FIVE" ] && LIMITS+="5h ${FIVE}%"
    [ -n "$WEEK" ] && LIMITS+="${LIMITS:+ - }7d ${WEEK}%"
    OUT+=" | ${MAGENTA}${LIMITS}${RESET}"
fi

# Chat cost (list-price estimate, not the actual bill)
[ -n "$COST" ] && OUT+=" | ${YELLOW}$(printf '$%.2f' "$COST")${RESET}"

# Prompt cache: warm/cold and minutes until the cache expires
if [ "$WARM" = "true" ] && [ -n "$EXPIRES" ]; then
    REM_MIN=$(( (EXPIRES - $(date +%s)) / 60 ))
    [ "$REM_MIN" -lt 0 ] && REM_MIN=0
    OUT+=" | ${GREEN}warm${RESET} ${REM_MIN} min"
else
    OUT+=" | ${DIM}cold${RESET}"
fi

printf '%b\n' "$OUT"
