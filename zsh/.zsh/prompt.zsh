# prompt.zsh
setopt prompt_subst
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git hg
# let vcs_info only fetch the branch name
zstyle ':vcs_info:git:*' formats '%b'

get_git_details() {
    # if not in a git repository, return nothing
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local staged_count=0
    local unstaged_count=0
    local ahead_behind=""
    
    # 1. Staged / Unstaged
    while IFS= read -r line; do
        local s="${line:0:1}"
        local u="${line:1:1}"
        # Staged
        [[ "$s" != " " && "$s" != "?" ]] && ((staged_count++))
        # Unstaged / Untracked
        [[ "$u" != " " || "$s" == "?" ]] && ((unstaged_count++))
    done < <(git status --porcelain 2>/dev/null)

    # 2. Ahead / Behind
    local -a rev
    rev=( $(git rev-list --left-right --count HEAD...@{u} 2>/dev/null) )
    if (( ${#rev} >= 2 )); then
        [[ $rev[1] -gt 0 ]] && ahead_behind+="%F{white}↑${rev[1]}%f"
        [[ $rev[2] -gt 0 ]] && ahead_behind+="%F{white}↓${rev[2]}%f"
    fi

    # 3. Build result string
    local res="$ahead_behind"

    # if we are ahead or behind, add a space before the rest
    if [[ -n $ahead_behind ]]; then
        res=" ${ahead_behind}"
    fi

    [[ $staged_count -gt 0 ]] && res+=" %F{green}S:${staged_count}%f"
    [[ $unstaged_count -gt 0 ]] && res+=" %F{red}M:${unstaged_count}%f"
    
    echo "$res"
}

get_git_user() {
    local guser=$(git config user.name 2>/dev/null)
    [[ -n "$guser" ]] && echo "${guser}%F{242}@%f" || echo "%F{red}no user%f%F{242}@%f"
}

get_active_github_account() {
    local default_handle="madhatter"
    
    # Check if direnv has set the custom handle, otherwise use the default
    if [[ -n "$GITHUB_ACTIVE_HANDLE" ]]; then
        echo "$GITHUB_ACTIVE_HANDLE%F{242}@%f"
    else
        echo "$default_handle%F{242}@%f"
    fi
}

build_vcs_string() {
    vcs_info
    if [[ -n "$vcs_info_msg_0_" ]]; then
        # vcs_info_msg_0_ ist nur der Branch
        # get_git_details liefert den Rest
        #echo "$(get_git_user)${vcs_info_msg_0_}$(get_git_details) "
        echo "$(get_active_github_account)${vcs_info_msg_0_}$(get_git_details) "
    fi
}

PROMPT='[%F{white}%D{%H:%M.%S}%f] %F{blue}%~%f $(build_vcs_string)%F{magenta}$%f '
