# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
#plugins=(git mercurial history-substring-search rvm archlinux)

source ~/.zsh/history-substring-search/history-substring-search.zsh
source ~/.zsh/prompt 

# Customize to your needs...
#
# Usenet News
export NNTPSERVER=news.eternal-september.org

# local hadoop installation
export HADOOP_HOME="$HOME/CDH/hadoop"
export HADOOP_INSTALL=$HADOOP_HOME
 
# local hbase installation
export HBASE_HOME="$HOME/CDH/hbase"
export HBASE_CONF_DIR="$HBASE_HOME/conf"

# zookeeper for hbase
export ZOOKEEPER_HOME="$HOME/CDH/zookeeper"

#export HADOOP_CLASSPATH=$HBASE_HOME/lib/zookeeper-3.3.3-cdh3u4.jar::$HADOOP_CLASSPATH
export HADOOP_CLASSPATH=$(for i in $HBASE_HOME/lib/*.jar ; do echo -n $i: ; done)

export CHEF_HOME="/opt/chef"

# enhance the path (ordered by priority to make manual installation work)
export PATH="$HOME/bin:$HADOOP_HOME/bin:$HBASE_HOME/bin:$ZOOKEEPER_HOME/bin:$SQOOP_HOME/bin:$CHEF_HOME/embedded/bin:/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:$PATH"

# where is my editor
export VIM="/usr/local/share/vim/vim74"

# where does mail go?
export MAIL=/var/spool/mail/$USER

# what is the best editor one can wish for
export EDITOR="vim"

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
export TERM="rxvt-256color"
export JAVA_HOME="/opt/java/jre"

# Ruby DBGp
export RUBYDB_LIB=~/lib/rubylib
export RUBYDB_OPTS="HOST=localhost PORT=9000"
alias druby='ruby -I$RUBYDB_LIB -r $RUBYDB_LIB/rdbgp.rb'

# Alias for debugging php cli
alias dphp='php -d xdebug.remote_autostart=1'

alias phpunit='phpunit.phar'

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

#PS1="%{%B$fg[blue]%}┌─[ %{$fg[green]%}%n%{$fg[white]%}(%{$fg[cyan]%}%m%{$fg[white]%}):%{$fg[yellow]%}%~ %{$fg[blue]%}]
#└──╼ %{$reset_color%}"

[ ! "$UID" = "0" ] && archey3 -c blue
[  "$UID" = "0" ] && archey3 -c red

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
