# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="madhatter"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git mercurial history-substring-search) 

source $ZSH/oh-my-zsh.sh

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

# history settings
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY

# I know what I want to do, don't correct me
setopt nocorrect

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

[ ! "$UID" = "0" ] && archey3 -c blue
[  "$UID" = "0" ] && archey3 -c red

# rvm
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
