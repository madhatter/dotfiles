function _p10k_git_status() {
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return

  local staged=0 unstaged=0 untracked=0
  while IFS= read -r line; do
    local s="${line:0:1}" u="${line:1:1}"
    if [[ "$s" == "?" ]]; then
      ((untracked++))
    else
      [[ "$s" != " " ]] && ((staged++))
      [[ "$u" != " " ]] && ((unstaged++))
    fi
  done < <(git status --porcelain 2>/dev/null)

  local -a rev
  rev=( $(git rev-list --left-right --count HEAD...@{u} 2>/dev/null) )

  local out=$'\ue0a0'" ${branch}"
  (( ${#rev} >= 2 )) && {
    (( rev[1] > 0 )) && out+=" ↑${rev[1]}"
    (( rev[2] > 0 )) && out+=" ↓${rev[2]}"
  }
  (( staged > 0 ))    && out+=" S:${staged}"
  (( unstaged > 0 ))  && out+=" M:${unstaged}"
  (( untracked > 0 )) && out+=" ?:${untracked}"

  echo "$out"
}

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon
    dir
    newline
    prompt_char
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    custom_github_user
    custom_git_status
    newline
  )

  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # Box-Drawing around the prompt
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%F{#665c54}╭─'
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{#665c54}╰─'
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX='%F{#665c54}─╮'
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX='%F{#665c54}─╯'

  # Dots filling the gap between left and right
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='·'
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND='#665c54'
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_END_SYMBOL='%{%}'
  typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%{%}'

  # Powerline separators (░▒▓ on left, ▓▒░ on right)
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B4'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B6'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL='░▒▓'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL='▓▒░'
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  # os_icon: purple pill (λ = Arch logo via Nerd Font)
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=0
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=141

  # dir: dark background, light text
  typeset -g POWERLEVEL9K_DIR_BACKGROUND='#3c3836'
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=7

  # GitHub user: dark pill (inner), hidden outside git repos
  typeset -g POWERLEVEL9K_CUSTOM_GITHUB_USER='git rev-parse --is-inside-work-tree &>/dev/null && echo "${GITHUB_ACTIVE_HANDLE:-madhatter}"'
  typeset -g POWERLEVEL9K_CUSTOM_GITHUB_USER_FOREGROUND=7
  typeset -g POWERLEVEL9K_CUSTOM_GITHUB_USER_BACKGROUND='#3c3836'

  # git status: purple pill (outer/right), custom-built for readability
  typeset -g POWERLEVEL9K_CUSTOM_GIT_STATUS='_p10k_git_status'
  typeset -g POWERLEVEL9K_CUSTOM_GIT_STATUS_BACKGROUND=141
  typeset -g POWERLEVEL9K_CUSTOM_GIT_STATUS_FOREGROUND=0

  # prompt_char: ❯ in purple on success, ✘ in dark gray on error
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=141
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=238
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ! $+functions[p10k] )) || p10k reload
}
