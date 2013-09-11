# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
#plugins=(git mercurial history-substring-search rvm archlinux)

source ~/.zsh/history-substring-search/history-substring-search.zsh
source ~/.zsh/prompt 

# Customize to your needs...
#
# local hadoop installation
export HADOOP_HOME="$HOME/CDH/hadoop"
export HADOOP_INSTALL=$HADOOP_HOME
 
# local hbase installation
export HBASE_HOME="$HOME/CDH/hbase"
export HBASE_CONF_DIR="$HBASE_HOME/conf"

# zookeeper for hbase
export ZOOKEEPER_HOME="$HOME/CDH/zookeeper"

#export HADOOP_CLASSPATH=$HBASE_HOME/lib/zookeeper-3.3.3-cdh3u1.jar::$HADOOP_CLASSPATH

# sqoop home
#export SQOOP_HOME="$HOME/CDH3/sqoop"

# enhance the path (ordered by priority to make manual installation work)
export PATH="$HOME/bin:$HOME/bin/eclipse:/usr/bin:/usr/local/bin:/usr/local/sbin:/Library/MySQL/bin:/usr/local/git/bin:/usr/X11R6/bin:$PATH:$HADOOP_HOME/bin:$HBASE_HOME/bin:$ZOOKEEPER_HOME/bin"
#export PATH="$HOME/bin:$HOME/bin/eclipse:$HADOOP_HOME/bin:$HBASE_HOME/bin:$ZOOKEEPER_HOME/bin:$SQOOP_HOME/bin:/usr/local/bin:/usr/local/sbin:/Library/MySQL/bin:/usr/local/git/bin:/usr/X11R6/bin:$PATH"

# where is my editor
export VIM="/usr/local/share/vim/vim73"

# what is the best editor one can wish for
export EDITOR="vim"

# encoding
export LC_CTYPE="de_DE.UTF-8"

# english outputs please
export LANG="en_US.UTF-8"

# I needed the timezone sometimes when on other hosts
export TZ="Europe/Berlin"

export CVSROOT=":pserver:awarnecke@astra.etracker.local:/home/cvsroot"
export PARSTREAM_HOME="/opt/parstream"
export WORKSPACE="/home/awarnecke/workspace"
export PAGER="less "
export TERM="rxvt-256color"
export JAVA_HOME="/opt/java"

# for bspwm 
export XDG_CONFIG_HOME="$HOME/.config"
export BSPWM_SOCKET="/tmp/bspwm-socket"

# history settings
export HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY

# I know what I want to do, don't correct me
setopt nocorrect

#options
set -o emacs
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt PROMPT_SUBST

autoload -U compinit
compinit

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

# don't correct me when I am talking about hdfs
alias hadoop="noglob hadoop"

# use an alias to set TERM to xterm
alias ssh='TERM=xterm ssh'

# show my calendar events
alias t='pal -c 0 -d today -r 0-3'

[ ! "$UID" = "0" ] && archey3 -c blue
[  "$UID" = "0" ] && archey3 -c red

# rvm
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

export PERL_LOCAL_LIB_ROOT="/home/awarnecke/perl5";
export PERL_MB_OPT="--install_base /home/awarnecke/perl5";
export PERL_MM_OPT="INSTALL_BASE=/home/awarnecke/perl5";
export PERL5LIB="/home/awarnecke/perl5/lib/perl5/x86_64-linux-thread-multi:/home/awarnecke/perl5/lib/perl5";
export PATH="/home/awarnecke/perl5/bin:$PATH";
