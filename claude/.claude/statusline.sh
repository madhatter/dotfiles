#!/usr/bin/env bash

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // .model.id // "unknown"')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // "0"')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

parts="${model} | ctx:${ctx}%"

if [[ -n "$five_hour" ]]; then
    parts="${parts} | 5h:$(printf '%.0f' "$five_hour")%"
fi

if [[ -n "$seven_day" ]]; then
    parts="${parts} | 7d:$(printf '%.0f' "$seven_day")%"
fi

if [[ -n "$cost" ]]; then
    parts="${parts} | \$$(printf '%.4f' "$cost")"
fi

if [[ -n "$vim_mode" ]]; then
    parts="${parts} | ${vim_mode}"
fi

printf "%s" "$parts"
