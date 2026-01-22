# This is my zsh configuration file.

source ~/.zsh/history-substring-search/history-substring-search.zsh
source ~/.zsh/title.zsh

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

# GPG agent initialization
export GPG_TTY=$(tty)

# Usenet News
export NNTPSERVER=news.individual.de

# Go workspace. Go, go, go.
export GOPATH="$HOME/code/go"
#export GOROOT="/usr/lib/go"
export GOPROXY="https://proxy.golang.org"

# where does mail go?
export MAIL=/var/spool/mail/$USER

# what is the best editor one can wish for
export EDITOR="nvim"

# default browser for urlscan
export BROWSER=/bin/chromium

# encoding
#export LC_CTYPE="de_DE.UTF-8"
#export LC_ALL="de_DE.UTF-8"

# don't talk german to me
#export LANG="en_EN.UTF-8"
#export LANGUAGE="en_EN.UTF-8"

# I needed the timezone sometimes when on other hosts
export TZ="CET"

export WORKSPACE="$HOME/workspace"
export PAGER="less "
#export TERM="rxvt-256color"
#export TERM="xterm-256color"

#export JAVA_HOME="/usr/lib/jvm/java-8-jdk/"
#export JAVA_HOME="/opt/homebrew/opt/java"

export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

# Ruby DBGp
export RUBYDB_LIB=~/lib/rubylib
export RUBYDB_OPTS="HOST=localhost PORT=9000"
alias druby='ruby -I$RUBYDB_LIB -r $RUBYDB_LIB/rdbgp.rb'

#export RUBY_VERSION=$(cat $HOME/.ruby-version)

# enhance the path (ordered by priority to make manual installation work)
export PATH="/usr/local/go/bin:$HOME/bin:$GOPATH/bin:$HOME/.local/bin:$JAVA_HOME/bin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/bin:/sbin:/usr/X11R6/bin:/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$PATH:$HOME/.cargo/bin"

# Alias for debugging php cli
alias dphp='php -d xdebug.remote_autostart=1'

# cd into my sources folder in $GOPATH
alias cdg="cd $GOPATH/src/github.com/madhatter"

# history settings
export HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY

#options
set -o emacs
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt PROMPT_SUBST
setopt NO_NOMATCH # stop bailing on the command when it fails to match a glob pattern

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

aws-login() {
  for arg in "$@"; do
    case "$arg" in
      live)
        output_profiles=(default dv-live-admin dv-live-developer)
        ;;
      nonlive)
        output_profiles=(default dv-nonlive-admin dv-nonlive-developer)
        ;;
      live-dr)
        output_profiles=(default dv-drlive-admin dv-drlive-developer)
        ;;
      nonlive-dr)
        output_profiles=(default dv-drnonlive-admin dv-drnonlive-developer)
        ;;
      *)
        echo "Unknown profile: $arg"
        echo "Available profiles: live, nonlive, live-dr, nonlive-dr"
        return 1
        ;;
    esac

    for profile in "${output_profiles[@]}"; do
      awsume -o "$profile" "$arg"
    done
  done
}
 
# everything colorful
#[ -f $HOME/.LS_COLORS ] && eval $(dircolors -b $HOME/.LS_COLORS)
#eval $( dircolors -b $HOME/.LS_COLORS )
#export ZLSCOLORS="${LS_COLORS}"
zmodload  zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# ssh hosts
zstyle -e ':completion::*:*:*:hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_,$HOME/.r}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# use LS_COLORS with ls
alias ls='ls --color=auto'
alias ll='ls -la'

# tin
alias rtin="tin -r"

# general aliases
alias gp="git pull"

alias rubymine="jetbrains-rubymine"
alias firefox-work="firefox -p Work -no-remote"

alias pip=pip3
alias python=python3

epub() { pandoc -f epub -t html "$@" | w3m -T text/html }
#mfa() { oathtool --base32 --totp "$(cat ~/.mfa/$1.mfa)" | tee >(xclip -in -selection c) }
mfa() { oathtool --base32 --totp "$(cat ~/.mfa/$1.mfa)" | tee >(tr -d \\n | pbcopy) }

#PS1="%{%B$fg[blue]%}┌─[ %{$fg[green]%}%n%{$fg[white]%}(%{$fg[cyan]%}%m%{$fg[white]%}):%{$fg[yellow]%}%~ %{$fg[blue]%}]
#└──╼ %{$reset_color%}"

if [[ $(uname -s) == "Darwin" ]]; then
  archey -o
elif [[ $(uname -s) == "Linux" ]]; then
  archey
fi

# stuff for rvm
export rvmsudo_secure_path=0
export rvm_ignore_gemrc_issues=1
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
#PATH=$HOME/.rvm/gems/$RUBY_VERSION/bin:$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
export SSL_CERT_FILE=/etc/ssl/cert.pem

# ... support zsh in tmux in URxvt too
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# New keybinding for clear because ^L is used by tmux
bindkey "^L" clear-screen

# if there is a zprofile, use it
[[ -e ~/.zprofile ]] && emulate sh -c 'source ~/.zprofile'

#. /usr/share/zsh/site-contrib/powerline.zsh
#source $HOME/.local/bin/aws_zsh_completer.sh
source $HOME/.zsh/plugins/aws.plugin.zsh

# fzf
#source /usr/share/fzf/key-bindings.zsh
#source /usr/share/fzf/completion.zsh

export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_ed25519 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# direnv integration to set GIT_AUTHOR_EMAIL
eval "$(direnv hook zsh)"

precmd () { print -Pn "\e]0;${PWD/$HOME/\~}\a" }
title() { export TITLE="$*" }

BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source ~/.zsh/prompt.zsh

autoload -U +X bashcompinit && bashcompinit
