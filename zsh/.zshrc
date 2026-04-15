# This is my zsh configuration file.

# p10k instant prompt — must be at the very top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/.zsh/history-substring-search/history-substring-search.zsh

# Load operation system specific settings
if [[ $(uname -s) == "Darwin" ]]; then
  source ~/.zsh/osx.zsh
elif [[ $(uname -s) == "Linux" ]]; then
  source ~/.zsh/linux.zsh
fi

eval "$(mise activate zsh)"

# Pyenv initialization
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Go workspace. Go, go, go.
export GOPATH="$HOME/code/go"

# what is the best editor one can wish for
export EDITOR="nvim"

# don't talk german to me
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

# I needed the timezone sometimes when on other hosts
export TZ="CET"

# set the pager for git and other tools to less, which is more powerful than the default more
export PAGER="less"

# enhance the path (ordered by priority to make manual installation work)
export PATH="$HOME/bin:$GOPATH/bin:$HOME/.local/bin:$JAVA_HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/bin:/sbin:$HOME/.cargo/bin:$PATH"

# Set the PATH for macOS
if [[ $(uname -s) == "Darwin" ]]; then
  export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/ruby/bin:$PATH"
fi


# history settings
export HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY

#options
set -o emacs
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt PROMPT_SUBST
setopt NO_NOMATCH # stop bailing on the command when it fails to match a glob pattern

fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit
compinit

my-backward-delete-word() {
    local WORDCHARS=${WORDCHARS/\//}
    zle backward-delete-word
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

vault-login() {
  # Prüfen ob VAULT_TOKEN gesetzt ist
  if [[ -n "$VAULT_TOKEN" ]]; then
    echo "Trying to renew existing token..."
    _renew_existing_token
    if [[ $? -eq 0 ]]; then
      echo "Renewed existing token"
      return 0
    fi
  fi

  echo "Creating new token..."
  new_token=$(_create_new_token)
  if [[ $? -eq 0 ]]; then
    echo "Created new token"
    export VAULT_TOKEN="$new_token"
  fi
  return $?
}

_create_new_token() {
  vault login -method=oidc role='pdh-da' &>/dev/null
  local vault_status=$?
  cat ~/.vault-token
  return $vault_status
}

_renew_existing_token() {
  vault token renew &>/dev/null
  return $?
}

# AWS login function with aws-sso-util and awsume, supporting multiple profiles based on environment and role
aws-login () {
    local role="${2:-admin}"  # default: admin
    
    case "$1" in
        (live) profile="dv-live-${role}" ;;
        (nonlive) profile="dv-nonlive-${role}" ;;
        (live-dr) profile="dv-drlive-${role}" ;;
        (nonlive-dr) profile="dv-drnonlive-${role}" ;;
        (*) echo "Unknown environment: $1"
            echo "Usage: aws-login <env> [role]"
            echo "  env: live, nonlive, live-dr, nonlive-dr"
            echo "  role: admin, developer (default: admin)"
            return 1 ;;
    esac
    
    aws-sso-util login --profile "$profile"
    source $(pyenv which awsume) "$profile"
    
    # Set AWS_ENV for prompt display
    case "$1" in
        (live-dr*) export AWS_ENV="DRLIVE-${role}" ;;
        (nonlive-dr*) export AWS_ENV="DRNONLIVE-${role}" ;;
        (live*) export AWS_ENV="LIVE-${role}" ;;
        (nonlive*) export AWS_ENV="NONLIVE-${role}" ;;
    esac
}

# Clear AWS environment variables for all profiles
aws-clear() {
    for profile in default dv-live-admin dv-live-developer dv-nonlive-admin dv-nonlive-developer dv-drlive-admin dv-drlive-developer dv-drnonlive-admin dv-drnonlive-developer
    do
        awsume -k "$profile" 
    done
    echo "All AWS profiles cleared"
}

# Prompt function to show AWS environment
aws_prompt() {
    if [[ -n "$AWS_ENV" ]]; then
        if [[ "$AWS_ENV" == *"NONLIVE"* ]]; then
            echo "%F{green}[$AWS_ENV]%f "
        else
            echo "%F{red}[$AWS_ENV]%f "
        fi
    fi
}

# everything colorful
if command -v vivid &>/dev/null; then
    export LS_COLORS=$(vivid generate jellybeans)
elif command -v gdircolors &>/dev/null; then
    eval $(gdircolors ~/.LS_COLORS)
elif command -v dircolors &>/dev/null; then
    eval $(dircolors ~/.LS_COLORS)
fi
zmodload  zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# ssh hosts
zstyle -e ':completion::*:*:*:hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_,$HOME/.r}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# use LS_COLORS with ls
if command -v gls &>/dev/null; then
    alias ls='gls --color=auto'
    alias ll='gls -la'
else
    alias ls='ls --color=auto'
    alias ll='ls -la'
fi

# general aliases
alias gp="git pull"

alias pip=pip3
alias python=python3

if [[ $(uname -s) == "Linux" ]]; then
  alias ff="fastfetch --config ~/.config/fastfetch/config-arch.jsonc"
else
  alias ff="fastfetch"
fi

# history search with arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# if there is a zprofile, use it
[[ -e ~/.zprofile ]] && emulate sh -c 'source ~/.zprofile'

export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_ed25519 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# Set CA bundle overrides only on macOS (Darwin).
# Linux handles root CAs natively via the system trust store.
if [[ -f "$HOME/.config/certs/combined_ca_bundle.pem" ]]; then
  # custom CA bundle containing the office root certificates and the ones from the system
  export CUSTOM_CA_BUNDLE="$HOME/.config/certs/combined_ca_bundle.pem"

  export REQUESTS_CA_BUNDLE="$CUSTOM_CA_BUNDLE"
  export CURL_CA_BUNDLE="$CUSTOM_CA_BUNDLE"
  export SSL_CERT_FILE="$CUSTOM_CA_BUNDLE"
  export NODE_EXTRA_CA_CERTS="$CUSTOM_CA_BUNDLE"
  export AWS_CA_BUNDLE="$CUSTOM_CA_BUNDLE"

  # for node to use the custom CA bundle
  export NODE_OPTIONS="--use-openssl-ca"
fi

# Allow more memory usage for node, e.g. for cdktf (OS independent)
if [[ -z "$NODE_OPTIONS" ]]; then
    export NODE_OPTIONS="--max-old-space-size=16384"
else
    export NODE_OPTIONS="$NODE_OPTIONS --max-old-space-size=16384"
fi

# direnv integration to set GIT_AUTHOR_EMAIL
eval "$(direnv hook zsh)"

precmd () { print -Pn "\e]0;${PWD/$HOME/\~}\a" }
title() { export TITLE="$*" }

yays() { yay -Ss "$@" --color always | awk '/\(Orphaned\)/{getline; next} 1'; }

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# load p10k framework — works on macOS (brew) and Arch (yay)
for _p10k in \
  "$(brew --prefix 2>/dev/null)/share/powerlevel10k/powerlevel10k.zsh-theme" \
  "/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme" \
  "$HOME/powerlevel10k/powerlevel10k.zsh-theme"; do
  [[ -f "$_p10k" ]] && { source "$_p10k"; break }
done
unset _p10k

source ~/.zsh/p10k_prompt.zsh

autoload -U +X bashcompinit && bashcompinit

complete -o nospace -C /opt/homebrew/bin/terraform terraform

complete -o nospace -C /opt/homebrew/bin/vault vault

complete -C aws_completer aws

# bun completions
[ -s "/Users/arvid.warnecke/.bun/_bun" ] && source "/Users/arvid.warnecke/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# GPG agent initialization ($TTY instead of $(tty) because of p10k interference)
export GPG_TTY=$TTY
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
