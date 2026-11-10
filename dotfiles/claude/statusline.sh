#!/bin/bash
# Claude Code status line:
# context % | model | 5h 7d | chat cost | cache warm | cache expires (min, TTL)
export LC_NUMERIC=C  # decimal point, independent of the user's locale
input=$(cat)

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
MODEL=$(jq -r '.model.display_name // "?"' <<<"$input")
FIVE=$(jq -r '.rate_limits.five_hour.used_percentage // empty | 100 - . | round' <<<"$input")
FIVE_RESETS_AT=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<<"$input")
FIVE_RESET=""
if [ -n "$FIVE_RESETS_AT" ]; then
    REM_SEC=$(( FIVE_RESETS_AT - $(date +%s) ))
    [ "$REM_SEC" -lt 0 ] && REM_SEC=0
    H=$(( REM_SEC / 3600 ))
    M=$(( (REM_SEC % 3600) / 60 ))
    if [ "$H" -gt 0 ]; then
        [ "$M" -gt 0 ] && FIVE_RESET="${H}h ${M}m" || FIVE_RESET="${H}h"
    else
        FIVE_RESET="${M}m"
    fi
fi
WEEK=$(jq -r '.rate_limits.seven_day.used_percentage // empty | 100 - . | round' <<<"$input")
COST=$(jq -r '.cost.total_cost_usd // empty' <<<"$input")
WARM=$(jq -r '.prompt_cache.warm // false' <<<"$input")
TTL=$(jq -r '.prompt_cache.ttl // empty' <<<"$input")
EXPIRES=$(jq -r '.prompt_cache.expires_at // empty' <<<"$input")

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

# Rate limits (subscription only)
if [ -n "$FIVE" ] || [ -n "$WEEK" ]; then
    LIMITS=""
    if [ -n "$FIVE" ]; then
        LIMITS+="5h ${FIVE}%"
        [ -n "$FIVE_RESET" ] && LIMITS+=" (${FIVE_RESET})"
    fi
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
