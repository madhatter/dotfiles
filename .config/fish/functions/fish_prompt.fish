# functions/fish_prompt.fish — Custom prompt.
#
# Format: [AWS_ENV] [HH:MM.SS] ~/path user@branch ↑n ↓n S:n M:n $
#
# Note: git status --porcelain runs on every prompt; may be slow in very large repos.

function fish_prompt
    set -l last_status $status

    # AWS environment indicator
    if set -q AWS_ENV
        if string match -rq LIVE -- $AWS_ENV
            printf '%s[%s]%s ' (set_color red) $AWS_ENV (set_color normal)
        else
            printf '%s[%s]%s ' (set_color green) $AWS_ENV (set_color normal)
        end
    end

    # Timestamp
    printf '%s[%s]%s ' (set_color white) (date +%H:%M.%S) (set_color normal)

    # Working directory
    printf '%s%s%s ' (set_color blue) (prompt_pwd) (set_color normal)

    # Git info — only inside a repository
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        # user@branch
        set -l git_user (git config user.name 2>/dev/null)
        if test -n "$git_user"
            printf '%s%s' (set_color normal) $git_user
        else
            printf '%sno user%s' (set_color red) (set_color normal)
        end
        printf '%s@%s' (set_color 242) (set_color normal)

        printf '%s' (git branch --show-current 2>/dev/null)

        # Ahead / behind remote (tab-separated output from git)
        set -l ab_raw (git rev-list --left-right --count HEAD...@{u} 2>/dev/null)
        if test $status -eq 0 -a -n "$ab_raw"
            set -l ab (string split \t -- $ab_raw)
            if test (count $ab) -ge 2
                test "$ab[1]" -gt 0; and printf ' %s↑%s%s' (set_color white) $ab[1] (set_color normal)
                test "$ab[2]" -gt 0; and printf ' %s↓%s%s' (set_color white) $ab[2] (set_color normal)
            end
        end

        # Staged and unstaged/untracked counts
        set -l staged 0
        set -l unstaged 0
        for line in (git status --porcelain 2>/dev/null)
            set -l s (string sub -s 1 -l 1 -- $line)
            set -l u (string sub -s 2 -l 1 -- $line)
            test "$s" != ' ' -a "$s" != '?'; and set staged   (math $staged   + 1)
            test "$u" != ' ' -o "$s" = '?';  and set unstaged (math $unstaged + 1)
        end
        test $staged   -gt 0; and printf ' %sS:%d%s' (set_color green) $staged   (set_color normal)
        test $unstaged -gt 0; and printf ' %sM:%d%s' (set_color red)   $unstaged (set_color normal)

        printf ' '
    end

    # Prompt character — red on non-zero exit, magenta otherwise
    if test $last_status -ne 0
        printf '%s$%s ' (set_color red) (set_color normal)
    else
        printf '%s$%s ' (set_color magenta) (set_color normal)
    end
end
