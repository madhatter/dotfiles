# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
#plugins=(git mercurial history-substring-search rvm archlinux)

source ~/.zsh/history-substring-search/history-substring-search.zsh
source ~/.zsh/prompt.zsh
source ~/.zsh/title.zsh

# Customize to your needs...
#
export GPG_TTY=$(tty)

# Usenet News
export NNTPSERVER=news.individual.de

# local hadoop installation
#export HADOOP_HOME="/usr/lib/hadoop-2.7.2"
export HADOOP_HOME="$(pacaur -Ql hadoop|grep /usr/lib|head -n3|tail -n 1|cut -d' ' -f 2)"
export HADOOP_INSTALL=$HADOOP_HOME
 
# local hbase installation
export HBASE_HOME="$HOME/CDH/hbase"
export HBASE_CONF_DIR="$HBASE_HOME/conf"

# zookeeper for hbase
export ZOOKEEPER_HOME="$HOME/CDH/zookeeper"

#export HADOOP_CLASSPATH=$HBASE_HOME/lib/zookeeper-3.3.3-cdh3u4.jar::$HADOOP_CLASSPATH
#export HADOOP_CLASSPATH=$(for i in $HBASE_HOME/lib/*.jar ; do echo -n $i: ; done)

export CHEF_HOME="/opt/chef"

# Go workspace. Go, go, go.
export GOPATH="$HOME/code/go"
export GOROOT="/usr/lib/go"

# where is my editor
export VIM="/usr/local/share/vim/vim81"
#export VIM="/usr/share/vim/vim81"

# where does mail go?
export MAIL=/var/spool/mail/$USER

# what is the best editor one can wish for
export EDITOR="vim"

# default browser for urlscan
export BROWSER=/bin/firefox

# encoding
export LC_CTYPE="de_DE.UTF-8"
export LC_ALL="de_DE.UTF-8"

# don't talk german to me
export LANG="en_EN.UTF-8"
export LANGUAGE="en_EN.UTF-8"

# I needed the timezone sometimes when on other hosts
export TZ="CET"

export CVSROOT=":pserver:awarnecke@astra.etracker.local:/home/cvsroot"
export PARSTREAM_HOME="/opt/parstream"
export WORKSPACE="$HOME/workspace"
export PAGER="less "
#export TERM="rxvt-256color"
export TERM="xterm-256color"

#export JAVA_HOME="/usr/lib/jvm/java-8-jdk/"
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk"

# Ruby DBGp
export RUBYDB_LIB=~/lib/rubylib
export RUBYDB_OPTS="HOST=localhost PORT=9000"
alias druby='ruby -I$RUBYDB_LIB -r $RUBYDB_LIB/rdbgp.rb'

#export RUBY_VERSION=$(cat $HOME/.ruby-version)

# enhance the path (ordered by priority to make manual installation work)
export PATH="$HOME/bin:$GOPATH/bin:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HBASE_HOME/bin:$ZOOKEEPER_HOME/bin:$CHEF_HOME/embedded/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/bin:/sbin:/usr/X11R6/bin:$PATH"

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

autoload -U compinit
compinit

my-backward-delete-word() {
    local WORDCHARS=${WORDCHARS/\//}
    zle backward-delete-word
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

# everything colorful
[ -f $HOME/.LS_COLORS ] && eval $(dircolors -b $HOME/.LS_COLORS)
eval $( dircolors -b $HOME/.LS_COLORS )
export ZLSCOLORS="${LS_COLORS}"
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
alias glp="cd ~/dev/lhotse-puppet"
alias gp="git pull"
alias vcenter_ctrl="/home/awarnecke/dev/lhotse-puppet/modules/epe_client/files/vcenter_ctrl.py -u arvid.warnecke@easy.otto -H http://epe.otto.easynet.de:8080 "
#alias python=/usr/bin/python3.4

alias rubymine="jetbrains-rubymine"
alias firefox-work="firefox -p Work -no-remote"

#PS1="%{%B$fg[blue]%}┌─[ %{$fg[green]%}%n%{$fg[white]%}(%{$fg[cyan]%}%m%{$fg[white]%}):%{$fg[yellow]%}%~ %{$fg[blue]%}]
#└──╼ %{$reset_color%}"

[ ! "$UID" = "0" ] && archey4 -c blue
[  "$UID" = "0" ] && archey4 -c red

# stuff for rvm
export rvmsudo_secure_path=0
export rvm_ignore_gemrc_issues=1
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
#PATH=$HOME/.rvm/gems/$RUBY_VERSION/bin:$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
export SSL_CERT_FILE=/etc/ssl/cert.pem

# ... support zsh in tmux in URxvt too
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# if there is a zprofile, use it
[[ -e ~/.zprofile ]] && emulate sh -c 'source ~/.zprofile'

#. /usr/share/zsh/site-contrib/powerline.zsh
source /usr/sbin/aws_zsh_completer.sh

# direnv integration to set GIT_AUTHOR_EMAIL
eval "$(direnv hook zsh)"

BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"
