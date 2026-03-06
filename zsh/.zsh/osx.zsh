# OSX specific settings
#
# Homebrew related paths
export JAVA_HOME="/opt/homebrew/opt/java"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

#necessary to build on M1 for the real world
export DOCKER_DEFAULT_PLATFORM=linux/amd64

#fpath=(~/.zsh/site-functions $(brew --prefix)/share/zsh/site-functions:$fpath)
FPATH=$(brew --prefix)/share/zsh-completions:$(brew --prefix)/share/zsh/site-functions:~/.zsh/site-functions:$FPATH
