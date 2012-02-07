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
plugins=(git mercurial bundler rails3 rvm gem history-substring-search)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
#
export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home"

# local hadoop installation
export HADOOP_HOME="$HOME/CDH3/hadoop"
export HADOOP_INSTALL=$HADOOP_HOME
 
# local hbase installation
export HBASE_HOME="$HOME/CDH3/hbase"
export HBASE_CONF_DIR="$HBASE_HOME/conf"

# zookeeper for hbase
export ZOOKEEPER_HOME="$HOME/CDH3/zookeeper"

export HADOOP_CLASSPATH=$HBASE_HOME/lib/zookeeper-3.3.3-cdh3u1.jar::$HADOOP_CLASSPATH

# sqoop home
export SQOOP_HOME="$HOME/CDH3/sqoop"

# enhance the path (ordered by priority to make manual installation work)
export PATH="$HOME/bin:$HADOOP_HOME/bin:$HBASE_HOME/bin:$ZOOKEEPER_HOME/bin:$SQOOP_HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/Library/MySQL/bin:/usr/local/git/bin:/usr/X11R6/bin:$PATH"

# where is my editor
export VIM="/usr/local/share/vim/vim73"

# where is the ruby bin
export RUBY_BIN="$HOME/.rvm/rubies/default/bin"

# what is the best editor one can wish for
export EDITOR="vim"

# english outputs please
export LANG="en_EN.UTF-8"

# encoding
export LC_CTYPE="de_DE.UTF-8"
export LC_ALL="de_DE.UTF-8"

# I needed the timezone sometimes when on other hosts
export TZ="CET"

# history settings
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY

# everything for colors
[ -f $HOME/.LS_COLORS ] && eval $(gdircolors -b $HOME/.LS_COLORS)
eval $( gdircolors -b $HOME/.LS_COLORS )
export ZLSCOLORS="${LS_COLORS}"
zmodload  zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# use LS_COLORS with ls
alias ls='gls --color=auto'
alias ll='ls -la'


# rvm
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm
