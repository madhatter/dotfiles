# functions/title.fish — Manually pin the terminal title until the next `title` call.
# Set $TITLE to empty to restore automatic titling.

function title --description 'Pin terminal title'
    set -gx TITLE $argv
end
