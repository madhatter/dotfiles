#!/usr/bin/env bash

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // .model.id // "unknown"')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // "0"')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

parts="${model} | ctx:${ctx}%"

if [[ -n "$cost" ]]; then
    parts="${parts} | \$$(printf '%.4f' "$cost")"
fi

if [[ -n "$vim_mode" ]]; then
    parts="${parts} | ${vim_mode}"
fi

printf "%s" "$parts"
