#!/bin/zsh
export PATH=$PATH:$HOME/bin
export JAVA_HOME=/usr/lib/jvm/java-8-jdk
#/bin/dmenu_run $1
#/usr/sbin/dmenu_run $1
exe=`PATH=$PATH:$HOME/bin dmenu_run -z -fn .` && eval "exec $exe"
