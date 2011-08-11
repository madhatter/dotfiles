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
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git mercurial) 

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
#
# enhance the path (ordered by priority to make manual installation work)
export PATH="$HOME/bin:CDH3/hadoop/bin:/usr/local/bin:/usr/local/sbin:/Library/MySQL/bin:/usr/local/git/bin:/usr/X11R6/bin:$PATH"

# where is my editor
export VIM="/usr/local/share/vim/vim73"

# what is the best editor one can wish for
export EDITOR="vim"

# encoding
export LC_CTYPE="de_DE.UTF-8"

# I needed the timezone sometimes when on other hosts
export TZ="CET"

# local hadoop installation
export HADOOP_HOME="$HOME/CDH3/hadoop"
 
# history settings
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY


[ -f $HOME/.LS_COLORS ] && eval $(gdircolors -b $HOME/.LS_COLORS)
eval $( gdircolors -b $HOME/.LS_COLORS )
export ZLSCOLORS="${LS_COLORS}"
zmodload  zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# use LS_COLORS with ls
alias ls='gls --color=auto'
alias ll='ls -la'
