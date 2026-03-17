# Linux specific shell settings
#
# default browser for urlscan
export BROWSER=/bin/firefox

# fpath for completions
FPATH=/usr/share/zsh/site-functions:~/.zsh/site-functions:$FPATH                                        

# MFA token generator. It reads the base32 secret from ~/.mfa/NAME.mfa and
# copies the generated token to the clipboard.
mfa() { oathtool --base32 --totp "$(cat ~/.mfa/$1.mfa)" | tee >(xclip -in -selection c) }
