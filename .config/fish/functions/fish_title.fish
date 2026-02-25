# functions/fish_title.fish — Terminal window / tab title.
# While a command runs fish passes it as $argv; at the prompt $argv is empty.

function fish_title
    if set -q TITLE
        echo $TITLE
    else if test -n "$argv"
        echo "$argv · "(prompt_pwd)
    else
        echo (prompt_pwd)
    end
end
