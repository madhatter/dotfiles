# OSX specific settings
#
# Homebrew related paths
export JAVA_HOME="/opt/homebrew/opt/java"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

#necessary to build on M1 for the real world
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# fpath for completions
FPATH=$(brew --prefix)/share/zsh-completions:$(brew --prefix)/share/zsh/site-functions:$FPATH

# MFA token generator. It reads the base32 secret from ~/.mfa/NAME.mfa and
# copies the generated token to the clipboard.
mfa() { oathtool --base32 --totp "$(cat ~/.mfa/$1.mfa)" | tee >(tr -d \\n | pbcopy) }

