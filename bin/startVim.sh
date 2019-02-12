#!/bin/zsh

export HOME=/home/awarnecke
source $HOME/.Xdefaults
TERM=xterm-256color urxvt -e vim $1
